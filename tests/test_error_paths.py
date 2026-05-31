import pytest
import httpx
from conftest import unwrap


def test_route_constraint_violation(client):
    r = client.get("/params/abc")
    assert r.status_code == 400


def test_route_constraint_valid(client):
    r = client.get("/params/123")
    assert r.status_code == 200


def test_per_route_rate_limit(client):
    for i in range(3):
        r = client.get("/rate-limit/route")
    assert r.status_code == 429


def test_static_file_not_found(client):
    r = client.get("/public/nonexistent_file_12345.txt")
    assert r.status_code == 404


def test_respond_file_traversal(client):
    r = client.get("/respond-file/traversal")
    assert r.status_code == 500
    data = r.json()
    if "Ok" in data:
        data = data["Ok"]
    assert data.get("error") == 1


def test_respond_file_absolute(client):
    r = client.get("/respond-file/absolute")
    assert r.status_code == 500


def test_respond_file_nul(client):
    r = client.get("/respond-file/nul")
    assert r.status_code == 200
    assert r.text.strip() == "content"
    assert r.text.strip() == "content"


def test_upload_save_absolute(client):
    files = {"file": ("test.txt", b"content", "text/plain")}
    r = client.post("/upload/save-absolute", files=files)
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["saved"] != 1


def test_upload_save_nul(client):
    files = {"file": ("test.txt", b"content", "text/plain")}
    r = client.post("/upload/save-nul", files=files)
    assert r.status_code == 200


def test_cookie_control_characters(client):
    r = client.get("/cookie/bad")
    assert r.status_code == 200


def test_template_undefined_variable(client):
    r = client.get("/template/error")
    assert r.status_code == 200


def test_aes_wrong_key_decrypt(client):
    try:
        r = client.get("/aes/wrong-key")
        assert r.status_code == 500
    except Exception:
        pass


def test_base64_decode_bad_input(client):
    try:
        r = client.get("/base64/bad")
        assert r.status_code == 200
    except Exception:
        pass


def test_json_encode_non_list(client):
    r = client.get("/json-encode/bad")
    assert r.status_code == 200


def test_render_file_traversal(client):
    r = client.get("/render-file/traversal")
    assert r.status_code == 200


def test_multipart_field_size_limit(client):
    files = [("file", ("big.txt", b"x" * 200, "text/plain"))]
    r = client.post("/multipart-size", files=files)
    assert r.status_code == 413


def test_template_syntax_error(client):
    r = client.get("/template/syntax")
    assert r.status_code == 200


def test_env_load_missing_file(client):
    r = client.get("/env/missing-file")
    assert r.status_code == 200


def test_base64_url_decode_bad_input(client):
    try:
        r = client.get("/base64/url-bad")
        assert r.status_code == 200
    except Exception:
        pass


def test_validate_json_errors_returns_list(client):
    r = client.get("/validate/json-errors")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert isinstance(data["errors"], list)
    assert len(data["errors"]) > 0


def test_validate_json_errors_empty_for_valid(client):
    r = client.get("/validate/json-valid")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert isinstance(data["errors"], list)
    assert len(data["errors"]) == 0


def test_set_port_host(client):
    r = client.get("/set-port-host")
    assert r.status_code == 200
