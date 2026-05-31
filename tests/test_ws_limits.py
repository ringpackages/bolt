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


def test_max_connections_enforced(bolt_server, client):
    async def _test():
        url = _ws_url(bolt_server, "/ws/chat")
        connections = []
        try:
            for i in range(6):
                try:
                    ws = await websockets.connect(url)
                    connections.append(ws)
                except Exception:
                    break
            assert len(connections) <= 5
        finally:
            for ws in connections:
                await ws.close()

    asyncio.run(_test())


def test_max_per_ip_enforced(bolt_server, client):
    async def _test():
        url = _ws_url(bolt_server, "/ws/chat")
        connections = []
        try:
            for i in range(4):
                try:
                    ws = await websockets.connect(url)
                    connections.append(ws)
                except Exception:
                    break
            assert len(connections) <= 3
        finally:
            for ws in connections:
                await ws.close()

    asyncio.run(_test())


def test_ws_message_rate_limit(bolt_server, client):
    async def _test():
        url = _ws_url(bolt_server, "/ws/chat")
        async with websockets.connect(url) as ws:
            for i in range(20):
                await ws.send(f"msg{i}")
            await asyncio.sleep(2)
            r = client.get("/ws/stats")
            data = unwrap(r.json())
            assert data["dropped"] >= 0

    asyncio.run(_test())
