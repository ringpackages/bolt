import pytest
from conftest import unwrap
import time


def test_cache_set_and_get(client):
    client.get("/cache/set", params={"key": "foo", "value": "bar"})
    r = client.get("/cache/get", params={"key": "foo"})
    assert r.status_code == 200
    assert unwrap(r.json())["value"] == "bar"


def test_cache_delete(client):
    client.get("/cache/set", params={"key": "delme", "value": "val"})
    client.get("/cache/delete", params={"key": "delme"})
    r = client.get("/cache/get", params={"key": "delme"})
    assert r.status_code == 200
    assert unwrap(r.json())["value"] == ""


def test_cache_clear(client):
    client.get("/cache/set", params={"key": "a", "value": "1"})
    client.get("/cache/set", params={"key": "b", "value": "2"})
    r = client.get("/cache/clear")
    assert r.status_code == 200
    assert unwrap(r.json())["cleared"] == 1


def test_cache_set_with_ttl(client):
    r = client.get("/cache/set-ttl", params={"key": "ttlkey", "value": "ttlval", "ttl": "2"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["cached"] == 1
    assert data["ttl"] == 2

    r2 = client.get("/cache/get", params={"key": "ttlkey"})
    assert unwrap(r2.json())["value"] == "ttlval"


def test_cache_get_nonexistent(client):
    r = client.get("/cache/get", params={"key": "doesnotexist"})
    assert r.status_code == 200
    assert unwrap(r.json())["value"] == ""
