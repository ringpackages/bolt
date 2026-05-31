import time
import pytest
import httpx
from conftest import unwrap


def test_body_size_limit_413(client):
    r = client.post("/body-check", content="x" * 200, headers={"Content-Type": "text/plain"})
    assert r.status_code == 413


def test_body_within_limit(client):
    r = client.post("/body-check", content="x" * 50, headers={"Content-Type": "text/plain"})
    assert r.status_code == 200


def test_multipart_field_count_limit(client):
    files = [
        ("file", ("a.txt", b"aaa", "text/plain")),
        ("file", ("b.txt", b"bbb", "text/plain")),
        ("file", ("c.txt", b"ccc", "text/plain")),
    ]
    r = client.post("/multipart-check", files=files)
    assert r.status_code == 413


def test_force_secure_cookies(client):
    r = client.get("/session/secure-cookie")
    assert r.status_code == 200
    set_cookie = r.headers.get("set-cookie", "").lower()
    assert "secure" in set_cookie or "__host-" in set_cookie


def test_ip_whitelist_localhost(client):
    r = client.get("/ip-check")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["ip"] in ("127.0.0.1", "::1", "0.0.0.0")


def test_static_path_traversal(client):
    r = client.get("/public/../../etc/passwd")
    assert r.status_code in (400, 403, 404)


def test_signed_cookie_set_and_read(client):
    r1 = client.get("/signed/set")
    assert r1.status_code == 200
    r2 = client.get("/signed/read")
    assert r2.status_code == 200
    data = unwrap(r2.json())
    assert data["user"] == "alice"


def test_signed_cookie_tampered(client):
    r1 = client.get("/signed/set")
    assert r1.status_code == 200
    tampered_client = httpx.Client(
        base_url=str(client.base_url).rstrip("/"),
        cookies={"user": "tampered_value"},
        follow_redirects=False,
    )
    r2 = tampered_client.get("/signed/read")
    assert r2.status_code == 200
    data = unwrap(r2.json())
    assert data["user"] != "alice"


def test_cookie_full_options(client):
    r1 = client.get("/cookie/full")
    assert r1.status_code == 200
    set_cookie = r1.headers.get("set-cookie", "").lower()
    assert "httponly" in set_cookie
    assert "samesite=strict" in set_cookie


def test_etag_conditional_304(client):
    r1 = client.get("/etag/conditional")
    assert r1.status_code == 200
    etag = r1.headers.get("etag")
    assert etag is not None and etag != ""
    r2 = client.get("/etag/conditional", headers={"If-None-Match": etag})
    assert r2.status_code == 304


def test_render_sends_response(client):
    r = client.get("/render")
    assert r.status_code == 200
    assert "Hello Render" in r.text


def test_render_file_sends_response(client):
    r = client.get("/render-file")
    assert r.status_code == 200
    assert "Hello FileRender" in r.text


def test_cache_ttl_expiry(client):
    r1 = client.get("/cache/ttl")
    assert r1.status_code == 200
    data1 = unwrap(r1.json())
    assert data1["value"] == "ttl_value"
    time.sleep(3)
    r2 = client.get("/cache/ttl/expired")
    assert r2.status_code == 200
    data2 = unwrap(r2.json())
    assert data2["value"] == "(expired)"


def test_session_ttl_expiry(client):
    r1 = client.get("/session/ttl")
    assert r1.status_code == 200
    data1 = unwrap(r1.json())
    assert data1["value"] == "ttl_value"
    time.sleep(3)
    r2 = client.get("/session/ttl/expired")
    assert r2.status_code == 200
    data2 = unwrap(r2.json())
    assert data2["value"] == "(expired)"
