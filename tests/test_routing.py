import pytest
from conftest import unwrap


def test_single_param(client):
    r = client.get("/params/42")
    assert r.status_code == 200
    assert unwrap(r.json())["id"] == "42"


def test_multiple_params(client):
    r = client.get("/params/1/posts/5")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["id"] == "1"
    assert data["postid"] == "5"


def test_where_valid_numeric(client):
    r = client.get("/items/42")
    assert r.status_code == 200
    assert unwrap(r.json())["id"] == "42"


def test_where_invalid_numeric(client):
    r = client.get("/items/abc")
    assert r.status_code == 400


def test_where_slug_valid(client):
    r = client.get("/slugs/my-post-123")
    assert r.status_code == 200
    assert unwrap(r.json())["slug"] == "my-post-123"


def test_where_slug_invalid(client):
    r = client.get("/slugs/INVALID")
    assert r.status_code == 400


def test_where_all_valid(client):
    r = client.get("/archive/2024/03")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["year"] == "2024"
    assert data["month"] == "03"


def test_where_all_invalid_month(client):
    r = client.get("/archive/2024/15")
    assert r.status_code == 400


def test_where_all_invalid_year(client):
    r = client.get("/archive/20/03")
    assert r.status_code == 400


def test_where_all_products_valid(client):
    r = client.get("/products/widget/AB-1234")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["category"] == "widget"
    assert data["sku"] == "AB-1234"


def test_where_all_products_invalid_sku(client):
    r = client.get("/products/widget/BAD")
    assert r.status_code == 400


def test_prefix_v1(client):
    r = client.get("/api/v1/status")
    assert r.status_code == 200
    assert unwrap(r.json())["version"] == "v1"


def test_prefix_v2(client):
    r = client.get("/api/v2/status")
    assert r.status_code == 200
    assert unwrap(r.json())["version"] == "v2"


def test_query_params(client):
    r = client.get("/search", params={"q": "bolt", "page": "2"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["q"] == "bolt"
    assert data["page"] == "2"


def test_query_all_multi(client):
    r = client.get("/multi-query", params={"tag": ["rust", "web"]})
    assert r.status_code == 200
    tags = unwrap(r.json())["tags"]
    assert "rust" in tags
    assert "web" in tags
