import os
import ssl
import pytest
from conftest import unwrap

TEST_DIR = os.path.dirname(os.path.abspath(__file__))


@pytest.fixture
def tls_client(bolt_server):
    port = bolt_server.split(":")[-1]
    base = f"https://127.0.0.1:{port}"
    ctx = ssl.create_default_context()
    ctx.load_verify_locations(os.path.join(TEST_DIR, "certs", "cert.pem"))
    ctx.check_hostname = False
    import httpx
    with httpx.Client(base_url=base, verify=ctx, follow_redirects=False) as c:
        yield c


def test_tls_health(tls_client):
    r = tls_client.get("/health")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["status"] == "ok"
    assert data["tls"] == 1


def test_tls_data(tls_client):
    r = tls_client.get("/data")
    assert r.status_code == 200
    assert unwrap(r.json())["message"] == "secure hello"


def test_tls_custom_header(tls_client):
    r = tls_client.get("/headers")
    assert r.status_code == 200
    assert r.headers.get("x-tls") == "yes"
