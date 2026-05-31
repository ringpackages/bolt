import asyncio

import pytest
from conftest import unwrap

try:
    import websockets
    HAS_WS = True
except ImportError:
    HAS_WS = False

pytestmark = pytest.mark.skipif(not HAS_WS, reason="websockets not installed")


def _ws_url(bolt_server: str, path: str) -> str:
    return f"ws://{bolt_server.replace('http://', '')}{path}"


@pytest.mark.websocket
def test_echo(bolt_server):
    async def _test():
        async with websockets.connect(_ws_url(bolt_server, "/ws/echo")) as ws:
            await ws.send("hello")
            resp = await ws.recv()
            assert "echo:hello" in resp

    asyncio.run(_test())


@pytest.mark.websocket
def test_binary_echo(bolt_server):
    async def _test():
        async with websockets.connect(_ws_url(bolt_server, "/ws/binary-echo")) as ws:
            await ws.send(b"\x00\x01\x02binary")
            resp = await ws.recv()
            assert resp == b"\x00\x01\x02binary"

    asyncio.run(_test())


@pytest.mark.websocket
def test_text_to_binary_echo(bolt_server):
    async def _test():
        async with websockets.connect(_ws_url(bolt_server, "/ws/binary-echo")) as ws:
            await ws.send("hello text")
            resp = await ws.recv()
            assert "text:hello text" in resp

    asyncio.run(_test())


@pytest.mark.websocket
def test_ws_event_context(bolt_server):
    async def _test():
        async with websockets.connect(_ws_url(bolt_server, "/ws/context/room1")) as ws:
            connect_msg = await ws.recv()
            assert "connected:connect:room1" in connect_msg
            assert "/ws/context/:roomId" in connect_msg or "/ws/context/room1" in connect_msg

            await ws.send("hello room")
            msg = await ws.recv()
            assert "msg:message:room1:hello room" in msg

    asyncio.run(_test())


@pytest.mark.websocket
def test_chat_room_broadcast(bolt_server, client):
    async def _test():
        url = _ws_url(bolt_server, "/ws/chat")
        async with websockets.connect(url) as ws1:
            async with websockets.connect(url) as ws2:
                await ws2.send("hi from ws2")
                msg = await ws1.recv()
                assert "hi from ws2" in msg

    asyncio.run(_test())


@pytest.mark.websocket
def test_binary_room_broadcast(bolt_server, client):
    async def _test():
        url = _ws_url(bolt_server, "/ws/binary-room")
        async with websockets.connect(url) as ws1:
            async with websockets.connect(url) as ws2:
                await ws2.send(b"\xAA\xBB")
                resp = await ws1.recv()
                assert resp == b"\xAA\xBB"

    asyncio.run(_test())


@pytest.mark.websocket
def test_ws_abort(bolt_server, client):
    async def _test():
        async with websockets.connect(_ws_url(bolt_server, "/ws/abort-test")) as ws:
            await ws.send("after-abort")
            await asyncio.sleep(0.5)

    asyncio.run(_test())


def test_ws_stats(bolt_server, client):
    r = client.get("/ws/stats")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert "connections" in data
    assert "room_count" in data
    assert "dropped" in data


def test_ws_client_list(bolt_server, client):
    r = client.get("/ws/clients")
    assert r.status_code == 200
    assert "clients" in unwrap(r.json())


def test_ws_room_members(bolt_server, client):
    r = client.get("/ws/room-members")
    assert r.status_code == 200
    assert "members" in unwrap(r.json())


def test_ws_broadcast_all(bolt_server, client):
    r = client.get("/ws/broadcast")
    assert r.status_code == 200
    assert "sent_to" in unwrap(r.json())


@pytest.mark.websocket
def test_ws_send_to(bolt_server):
    async def _test():
        async with websockets.connect(_ws_url(bolt_server, "/ws/echo")) as ws:
            await ws.send("hello send-to")
            resp = await ws.recv()
            assert "echo:hello send-to" in resp

    asyncio.run(_test())


@pytest.mark.websocket
def test_ws_send_binary_to(bolt_server):
    async def _test():
        async with websockets.connect(_ws_url(bolt_server, "/ws/binary-echo")) as ws:
            await ws.send(b"\x01\x02\x03")
            resp = await ws.recv()
            assert resp == b"\x01\x02\x03"

    asyncio.run(_test())


def test_ws_close_client(bolt_server, client):
    async def _connect():
        async with websockets.connect(_ws_url(bolt_server, "/ws/chat")) as ws:
            await ws.send("hello")

    asyncio.run(_connect())
    import time
    time.sleep(0.2)

    r = client.get("/ws/clients")
    data = unwrap(r.json())
    clients = data.get("clients", [])
    if clients:
        client_id = clients[0]
        r = client.post(f"/ws/close-client?id={client_id}")
        assert r.status_code == 200
        data = unwrap(r.json())
        assert "closed" in data


def test_ws_room_count(bolt_server, client):
    async def _test():
        url = _ws_url(bolt_server, "/ws/chat")
        async with websockets.connect(url) as ws1:
            async with websockets.connect(url) as ws2:
                await asyncio.sleep(0.2)
                r = client.get("/ws/stats")
                data = unwrap(r.json())
                assert data["room_count"] == 2

    asyncio.run(_test())
