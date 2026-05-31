import time
import pytest
from conftest import unwrap


def test_rate_limit_within_limit(client):
    for _ in range(3):
        r = client.get("/limited")
        assert r.status_code == 200


def test_rate_limit_exceeded(client):
    for _ in range(3):
        client.get("/limited")
    r = client.get("/limited")
    assert r.status_code == 429


def test_rate_limit_post(client):
    for _ in range(2):
        r = client.post("/limited-post")
        assert r.status_code == 200
    r = client.post("/limited-post")
    assert r.status_code == 429


def test_global_rate_limit(client):
    for _ in range(5):
        r = client.get("/global-limited")
        assert r.status_code == 200
    r = client.get("/global-limited")
    assert r.status_code == 429


def test_check_rate_limit(client):
    r = client.get("/check-rate-limit")
    assert r.status_code == 200
    assert "allowed" in unwrap(r.json())


def test_rate_limit_window_reset(client):
    for _ in range(2):
        client.get("/limited-short-window")
    r = client.get("/limited-short-window")
    assert r.status_code == 429
    time.sleep(3)
    r = client.get("/limited-short-window")
    assert r.status_code == 200


def test_custom_error_handler(client):
    r = client.get("/cause-error")
    assert r.status_code == 500
    data = unwrap(r.json())
    assert data.get("custom_error") == 1
    assert data.get("error") == 1


def test_health_check(client):
    r = client.get("/health-check")
    assert r.status_code == 200


def test_ip_whitelist_localhost(client):
    r = client.get("/ip-allowed")
    assert r.status_code == 200


def test_request_info(client):
    r = client.get("/request/info", headers={"User-Agent": "pytest"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["method"] == "GET"
    assert data["path"] == "/request/info"
    assert data["uri"] != ""
    assert data["requestid"] != ""
    assert data["useragent"] == "pytest"


def test_json_body(client):
    r = client.post("/json-body", json={"name": "test"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["parsed"] == 1
    assert data["data"]["name"] == "test"


def test_ip_blacklist_blocks_ip(bolt_server):
    import httpx
    r = httpx.get(f"{bolt_server}/ip-blocked", headers={"X-Forwarded-For": "10.0.0.1"})
    assert r.status_code == 403


def test_proxy_whitelist_without_header_uses_peer(bolt_server):
    import httpx
    r = httpx.get(f"{bolt_server}/proxy-used")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["ip"] in ("127.0.0.1", "::1")
