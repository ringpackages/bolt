import pytest
from conftest import unwrap


def test_env_get_var(client):
    r = client.get("/env/get-var")
    assert r.status_code == 200
    assert unwrap(r.json())["value"] != ""


def test_env_get_or(client):
    r = client.get("/env/key/HOME")
    assert r.status_code == 200
    assert unwrap(r.json())["value"] != "(not set)"


def test_env_set(client):
    r = client.post("/env/set", json={"key": "BOLT_TEST_VAR", "value": "hello"})
    assert r.status_code == 200
    assert unwrap(r.json())["set"] == 1


def test_env_load_file(client):
    r = client.get("/env/load-file")
    assert r.status_code == 200
    assert unwrap(r.json())["value"] == "loaded_from_file"


def test_env_load_env(client):
    r = client.get("/env/load-env")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["home"] != ""
