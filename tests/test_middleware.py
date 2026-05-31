import pytest
from conftest import unwrap


def test_global_before_middleware(client):
    r = client.get("/plain")
    assert r.status_code == 200
    assert r.headers.get("x-global-before") == "true"
    assert r.headers.get("x-request-id") is not None


def test_global_after_middleware(client):
    r = client.get("/plain")
    assert r.headers.get("x-global-after") == "true"


def test_named_global_middleware(client):
    r = client.get("/plain")
    assert r.status_code == 200


def test_per_route_before(client):
    r = client.get("/secure/data")
    assert r.status_code == 200
    assert r.headers.get("x-before") == "applied"
    assert unwrap(r.json())["data"] == "secret"


def test_per_route_after(client):
    r = client.get("/secure/audit")
    assert r.status_code == 200
    assert r.headers.get("x-after") == "applied"


def test_per_route_before_and_after(client):
    r = client.get("/secure/full")
    assert r.status_code == 200
    assert r.headers.get("x-before") == "applied"
    assert r.headers.get("x-after") == "applied"
    assert unwrap(r.json())["full"] == "protected"
