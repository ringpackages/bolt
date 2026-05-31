import pytest
from conftest import unwrap


def test_body_within_limit(client):
    r = client.post("/body-check", content="a" * 50, headers={"Content-Type": "text/plain"})
    assert r.status_code == 200


def test_body_exceeds_limit(client):
    r = client.post("/body-oversized", content="a" * 200, headers={"Content-Type": "text/plain"})
    assert r.status_code in (400, 413)


def test_multipart_within_limits(client):
    r = client.post("/multipart-limit", data={"field1": "ok"}, files={
        "file": ("test.txt", __import__("io").BytesIO(b"hi"), "text/plain")
    })
    assert r.status_code == 200


def test_session_config(client):
    r = client.get("/session/config-test")
    assert r.status_code == 200
    assert unwrap(r.json())["value"] == "test_value"


def test_cache_config(client):
    r = client.get("/cache/config-test")
    assert r.status_code == 200
    assert unwrap(r.json())["value"] == "cfg_value"


def test_json_decode(client):
    r = client.get("/json-decode")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["decoded"]["name"] == "bolt"


def test_render_template_return(client):
    r = client.get("/render-template-return")
    assert r.status_code == 200
    assert "Hello World" in r.text


def test_set_openapi_spec(client):
    r = client.get("/openapi-spec")
    assert r.status_code == 200
    assert unwrap(r.json())["set"] == 1


def test_request_info(client):
    r = client.get("/request/info")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["method"] == "GET"
    assert data["path"] == "/request/info"
    assert data["ip"] != ""


def test_cache_capacity_limit(client):
    r = client.get("/cache/capacity-test")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["capacity"] > 0


def test_session_capacity_limit(client):
    r = client.get("/session/capacity-test")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["found"] == True
