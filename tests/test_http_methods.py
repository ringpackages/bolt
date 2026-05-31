import pytest
from conftest import unwrap


def test_get(client):
    r = client.get("/methods/get")
    assert r.status_code == 200
    assert unwrap(r.json())["method"] == "GET"


def test_post_with_json(client):
    r = client.post("/methods/post", json={"key": "val"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["method"] == "POST"
    assert data["body"]["key"] == "val"


def test_put_with_json(client):
    r = client.put("/methods/put", json={"update": True})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["method"] == "PUT"
    assert data["body"]["update"] == 1


def test_patch_with_json(client):
    r = client.patch("/methods/patch", json={"field": "x"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["method"] == "PATCH"


def test_delete(client):
    r = client.delete("/methods/delete")
    assert r.status_code == 200
    assert unwrap(r.json())["method"] == "DELETE"


def test_head(client):
    r = client.head("/methods/head")
    assert r.status_code == 200
    assert r.headers.get("x-method") == "HEAD"


def test_options(client):
    r = client.options("/methods/options")
    assert r.status_code == 204
    assert "GET" in r.headers.get("allow", "")


def test_custom_method(client):
    r = client.request("CUSTOM", "/methods/custom")
    assert r.status_code == 200
    assert unwrap(r.json())["method"] == "CUSTOM"
