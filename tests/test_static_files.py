import pytest
from conftest import unwrap


def test_static_file(client):
    r = client.get("/public/hello.txt")
    assert r.status_code == 200
    assert "Hello from static file" in r.text


def test_static_css(client):
    r = client.get("/public/style.css")
    assert r.status_code == 200
    assert "color" in r.text


def test_static_not_found(client):
    r = client.get("/public/nonexistent.txt")
    assert r.status_code == 404


def test_send_file(client):
    r = client.get("/send-file")
    assert r.status_code == 200
    assert "Hello from static file" in r.text


def test_send_file_as_content_type(client):
    r = client.get("/send-file-as")
    assert r.status_code == 200
    ct = r.headers.get("content-type", "")
    assert "text/plain" in ct
