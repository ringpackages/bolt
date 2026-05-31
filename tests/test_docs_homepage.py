import pytest
from conftest import unwrap


def test_homepage(client):
    r = client.get("/")
    assert r.status_code == 200
    assert "Bolt" in r.text


def test_docs_endpoint(client):
    r = client.get("/docs/")
    assert r.status_code == 200


def test_docs_has_swagger(client):
    r = client.get("/docs/")
    assert "swagger" in r.text.lower() or "openapi" in r.text.lower()


def test_api_users_route(client):
    r = client.get("/api/users")
    assert r.status_code == 200
    assert "users" in unwrap(r.json())


def test_api_users_by_id(client):
    r = client.get("/api/users/42")
    assert r.status_code == 200
    assert unwrap(r.json())["id"] == "42"


def test_docs_info_set(client):
    r = client.get("/openapi.json")
    assert r.status_code == 200
    data = r.json()
    assert data.get("info", {}).get("title") == "Test API"
    assert data.get("info", {}).get("version") == "1.0.0"
    assert data.get("info", {}).get("description") == "API for testing docs"
