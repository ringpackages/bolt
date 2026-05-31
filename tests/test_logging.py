import pytest
from conftest import unwrap


def test_log_message(client):
    r = client.get("/log", params={"msg": "hello"})
    assert r.status_code == 200
    assert unwrap(r.json())["logged"] == "hello"


def test_log_with_level(client):
    r = client.get("/log/level", params={"level": "warn", "msg": "danger"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["logged"] == 1
    assert data["level"] == "warn"


def test_set_log_level(client):
    r = client.get("/log/set-level", params={"level": "debug"})
    assert r.status_code == 200
    assert unwrap(r.json())["level_set"] == "debug"


def test_disable_logging(client):
    r = client.get("/log/disable")
    assert r.status_code == 200
    assert unwrap(r.json())["logging_disabled"] == 1


def test_enable_logging(client):
    r = client.get("/log/enable")
    assert r.status_code == 200
    assert unwrap(r.json())["logging_enabled"] == 1
