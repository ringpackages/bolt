import pytest
from conftest import unwrap


def test_panic_recovery(client):
    r = client.get("/panic")
    assert r.status_code == 500


def test_divide_zero(client):
    r = client.get("/divide-zero")
    assert r.status_code in (200, 500)


def test_nil_access(client):
    r = client.get("/nil-access")
    assert r.status_code in (200, 400, 500)


def test_safe_after_panic(client):
    client.get("/panic")
    r = client.get("/safe")
    assert r.status_code == 200
    assert unwrap(r.json())["ok"] == 1


def test_error_handler_catches_panic(client):
    r = client.get("/panic")
    assert r.status_code == 500
    data = r.json()
    if "Ok" in data:
        data = data["Ok"]
    assert data.get("caught") == 1 or data.get("error") == 1
