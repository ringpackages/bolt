import base64
import pytest
from conftest import unwrap


def test_jwt_login_and_me(client):
    r = client.post("/jwt/login", json={"username": "alice", "password": "pass"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert "token" in data
    assert data["expires_in"] == 3600

    token = data["token"]
    r2 = client.get("/jwt/me", headers={"Authorization": f"Bearer {token}"})
    assert r2.status_code == 200
    user_data = unwrap(r2.json())["user"]
    if "Ok" in user_data:
        user_data = user_data["Ok"]
    assert user_data["username"] == "alice"


def test_jwt_login_no_expiry(client):
    r = client.post("/jwt/login-no-exp", json={"username": "bob"})
    assert r.status_code == 200
    token = unwrap(r.json())["token"]
    assert token != ""

    r2 = client.get("/jwt/me", headers={"Authorization": f"Bearer {token}"})
    assert r2.status_code == 200
    user_data = unwrap(r2.json())["user"]
    if "Ok" in user_data:
        user_data = user_data["Ok"]
    assert user_data["username"] == "bob"


def test_jwt_me_no_auth(client):
    r = client.get("/jwt/me")
    assert r.status_code == 401


def test_jwt_me_invalid_token(client):
    r = client.get("/jwt/me", headers={"Authorization": "Bearer invalid.token.here"})
    assert r.status_code == 401


def test_basic_auth_no_header(client):
    r = client.get("/basic-auth")
    assert r.status_code == 401
    assert "WWW-Authenticate" in r.headers


def test_basic_auth_valid(client):
    creds = base64.b64encode(b"admin:secret").decode()
    r = client.get("/basic-auth", headers={"Authorization": f"Basic {creds}"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["username"] == "admin"
    assert data["password"] == "secret"


def test_basic_auth_encode_decode(client):
    r = client.get("/basic-auth-encode")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["encoded"].startswith("Basic ")
    decoded = data["decoded"]
    if "Ok" in decoded:
        decoded = decoded["Ok"]
    assert decoded["username"] == "admin"
    assert decoded["password"] == "secret"


def test_csrf_token_generated(client):
    r = client.get("/csrf/token")
    assert r.status_code == 200
    data = r.json()
    assert "csrf_token" in data or "csrf_token" in unwrap(data)


def test_csrf_manual_verify_with_token(client):
    token_r = client.get("/csrf/token")
    token_data = token_r.json()
    if "Ok" in token_data:
        token = token_data["Ok"]["csrf_token"]
    else:
        token = token_data["csrf_token"]
    r = client.post("/csrf/verify", data={"_csrf": token})
    assert r.status_code == 200


def test_csrf_manual_verify_no_token(client):
    r = client.post("/csrf/verify")
    assert r.status_code == 403
