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
def test_chat_room_broadcast(bolt_server, client):
    async def _test():
        url = _ws_url(bolt_server, "/ws/chat")
        async with websockets.connect(url) as ws1:
            async with websockets.connect(url) as ws2:
                await ws2.send("hi from ws2")
                msg = await ws1.recv()
                assert "hi from ws2" in msg

    asyncio.run(_test())


def test_ws_stats(client):
    r = client.get("/ws/stats")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert "connections" in data
    assert "room_count" in data
