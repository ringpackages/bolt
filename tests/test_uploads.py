import io
import base64
import pytest
from conftest import unwrap


def test_single_file_upload(client):
    files = {"file": ("test.txt", io.BytesIO(b"hello bolt"), "text/plain")}
    r = client.post("/upload", files=files)
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["count"] == 1
    assert data["files"][0]["name"] == "test.txt"


def test_multiple_file_upload(client):
    files = [
        ("file", ("a.txt", io.BytesIO(b"aaa"), "text/plain")),
        ("file", ("b.txt", io.BytesIO(b"bbb"), "text/plain")),
    ]
    r = client.post("/upload", files=files)
    assert r.status_code == 200
    assert unwrap(r.json())["count"] == 2


def test_files_all_method(client):
    files = [
        ("file", ("x.txt", io.BytesIO(b"xxx"), "text/plain")),
        ("file", ("y.txt", io.BytesIO(b"yyy"), "text/plain")),
    ]
    r = client.post("/upload/all", files=files)
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["count"] == 2


def test_upload_by_field(client):
    files = {"avatar": ("pic.png", io.BytesIO(b"\x89PNG"), "image/png")}
    r = client.post("/upload/by-field", files=files)
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["file"]["name"] == "pic.png"


def test_upload_save(client):
    files = {"file": ("save_test.txt", io.BytesIO(b"saved content"), "text/plain")}
    r = client.post("/upload/save", files=files)
    assert r.status_code == 200
    assert unwrap(r.json())["saved"] == 1


def test_form_fields(client):
    r = client.post("/form", data={"username": "alice", "email": "alice@test.com"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["username"] == "alice"
    assert data["email"] == "alice@test.com"


def test_form_multi_values(client):
    r = client.post("/form-multi", data={"tag": ["rust", "web"]})
    assert r.status_code == 200
    tags = unwrap(r.json())["tags"]
    assert "rust" in tags
    assert "web" in tags


def test_upload_no_file(client):
    r = client.post("/upload", data={"notfile": "text"})
    assert r.status_code == 400


def test_body_base64(client):
    raw = b"\x00\x01\x02binary"
    r = client.post("/body-base64", content=raw, headers={"Content-Type": "application/octet-stream"})
    assert r.status_code == 200
    b64 = unwrap(r.json())["base64"]
    decoded = base64.b64decode(b64)
    assert decoded == raw
