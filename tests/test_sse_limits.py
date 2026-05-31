import pytest
import httpx
import threading
import time
from conftest import unwrap


def test_sse_max_subscribers(bolt_server):
    results = []

    def connect_sse(idx):
        try:
            with httpx.Client(base_url=bolt_server, timeout=1) as c:
                with c.stream("GET", "/events", headers={"Accept": "text/event-stream"}) as r:
                    results.append((idx, r.status_code))
                    time.sleep(0.5)
        except httpx.ReadTimeout:
            results.append((idx, 200))
        except Exception as e:
            results.append((idx, str(e)))

    threads = []
    for i in range(4):
        t = threading.Thread(target=connect_sse, args=(i,))
        threads.append(t)

    for t in threads:
        t.start()
    for t in threads:
        t.join(timeout=5)

    status_codes = [s for _, s in results if isinstance(s, int)]
    assert 503 in status_codes


def test_sse_broadcast_count(bolt_server, client):
    r = client.get("/broadcast")
    assert r.status_code == 200
