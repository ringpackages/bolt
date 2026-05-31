import pytest
from conftest import unwrap


def test_cors_preflight(client):
    r = client.options("/data", headers={
        "Origin": "http://example.com",
        "Access-Control-Request-Method": "GET",
    })
    assert r.status_code in (200, 204)
    assert "access-control-allow-origin" in r.headers


def test_cors_actual_request(client):
    r = client.get("/data", headers={"Origin": "http://example.com"})
    assert r.status_code == 200
    acao = r.headers.get("access-control-allow-origin", "")
    assert acao == "*" or acao == "http://example.com"


def test_compression_large_response(client):
    r = client.get("/data", headers={"Accept-Encoding": "gzip, deflate"})
    assert r.status_code == 200
    assert unwrap(r.json())["message"] == "hello"


def test_cors_specific_origin(client):
    r = client.get("/cors-specific", headers={"Origin": "https://example.com"})
    assert r.status_code == 200
    acao = r.headers.get("access-control-allow-origin", "")
    assert acao == "https://example.com" or acao == "*"


def test_cors_disabled(client):
    r = client.options("/cors-disabled", headers={
        "Origin": "http://evil.com",
        "Access-Control-Request-Method": "GET",
    })
    assert r.status_code in (200, 204)
    acao = r.headers.get("access-control-allow-origin", "")
    assert acao != "http://evil.com"


def test_compression_disabled(client):
    r = client.get("/no-compress", headers={"Accept-Encoding": "gzip, deflate"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["message"] == "no compress"
