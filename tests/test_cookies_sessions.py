import pytest
from conftest import unwrap


def test_set_cookies(client):
    r = client.get("/cookies/set")
    assert r.status_code == 200
    cookies = r.cookies
    assert "session_id" in cookies
    assert "prefs" in cookies


def test_read_cookies(client):
    client.get("/cookies/set")
    r = client.get("/cookies/read")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["session_id"] != ""
    assert data["prefs"] == "dark"


def test_delete_cookie(client):
    client.get("/cookies/set")
    r = client.get("/cookies/delete")
    assert r.status_code == 200
    assert unwrap(r.json())["deleted"] == "session_id"


def test_signed_cookie_set(client):
    r = client.get("/cookies/signed/set")
    assert r.status_code == 200
    assert unwrap(r.json())["signed"] == 1


def test_signed_cookie_read(client):
    client.get("/cookies/signed/set")
    r = client.get("/cookies/signed/read")
    assert r.status_code == 200
    assert unwrap(r.json())["user"] == "alice"


def test_session_set_and_read(client):
    client.get("/session/set")
    r = client.get("/session/read")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["user_id"] == "42"
    assert data["role"] == "admin"


def test_session_delete_key(client):
    client.get("/session/set")
    r = client.get("/session/delete")
    assert r.status_code == 200
    assert unwrap(r.json())["session_deleted"] == "role"


def test_session_clear(client):
    client.get("/session/set")
    r = client.get("/session/clear")
    assert r.status_code == 200
    assert unwrap(r.json())["session_cleared"] == 1


def test_session_regenerate(client):
    client.get("/session/set")
    r = client.get("/session/regenerate")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["data_migrated"] == "before-regen"
    assert data["regenerated"] == 1


def test_flash_set_redirect(client):
    r = client.get("/flash/set")
    assert r.status_code == 302


def test_flash_read_consumed(client):
    client.get("/flash/set")
    r = client.get("/flash/read")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["has_flash"] == 1
    assert data["message"] == "Operation completed!"


def test_flash_is_one_read(client):
    client.get("/flash/set")
    client.get("/flash/read")
    r = client.get("/flash/read-again")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["has_flash"] == 0 or data["message"] == ""
