import pytest
from conftest import unwrap


def test_send_text(client):
    r = client.get("/text")
    assert r.status_code == 200
    assert "Hello from Bolt!" in r.text


def test_send_status_only(client):
    r = client.get("/status-only")
    assert r.status_code == 204


def test_send_with_custom_status(client):
    r = client.get("/custom-status")
    assert r.status_code == 418
    assert "teapot" in r.text.lower()


def test_json_200(client):
    r = client.get("/json-200")
    assert r.status_code == 200
    assert unwrap(r.json())["ok"] == 1


def test_json_201(client):
    r = client.get("/json-201")
    assert r.status_code == 201
    data = unwrap(r.json())
    assert data["created"] == 1
    assert "id" in data


def test_redirect_temporary(client):
    r = client.get("/redirect-temp")
    assert r.status_code == 302
    assert "/text" in r.headers.get("location", "")


def test_redirect_permanent(client):
    r = client.get("/redirect-perm")
    assert r.status_code == 301
    assert "/text" in r.headers.get("location", "")


def test_not_found(client):
    r = client.get("/not-found")
    assert r.status_code == 404


def test_bad_request(client):
    r = client.get("/bad-request")
    assert r.status_code == 400
    assert "Missing" in r.text


def test_unauthorized(client):
    r = client.get("/unauthorized")
    assert r.status_code == 401


def test_forbidden(client):
    r = client.get("/forbidden")
    assert r.status_code == 403


def test_server_error(client):
    r = client.get("/server-error")
    assert r.status_code == 500


def test_custom_header(client):
    r = client.get("/custom-header")
    assert r.status_code == 200
    assert r.headers.get("x-custom") == "bolt-value"
    assert r.headers.get("cache-control") == "no-cache"


def test_etag(client):
    r = client.get("/etag")
    assert r.status_code == 200
    assert r.headers.get("etag") is not None


def test_echo_body(client):
    payload = "raw text body"
    r = client.post("/echo-body", content=payload, headers={"Content-Type": "text/plain"})
    assert r.status_code == 200


def test_send_file(client):
    r = client.get("/send-file")
    assert r.status_code == 200
    assert "Hello from static file" in r.text


def test_send_file_as(client):
    r = client.get("/send-file-as")
    assert r.status_code == 200
    assert "text/plain" in r.headers.get("content-type", "")


def test_send_binary(client):
    r = client.get("/send-binary")
    assert r.status_code == 200
    assert r.content == b"binary content here"


def test_send_binary_as(client):
    r = client.get("/send-binary-as")
    assert r.status_code == 200
    assert "application/pdf" in r.headers.get("content-type", "")


def test_html_with_status(client):
    r = client.get("/html-status")
    assert r.status_code == 201
    assert "text/html" in r.headers.get("content-type", "")
    assert "<h1>Created</h1>" in r.text
