import pytest
from conftest import unwrap
import re


# ========================================
# JSON Schema Validation
# ========================================

def test_json_schema_valid(client):
    r = client.post("/validate/json", json={"name": "Alice", "age": 30})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["valid"] == 1
    assert data["data"]["name"] == "Alice"


def test_json_schema_invalid(client):
    r = client.post("/validate/json", json={"name": ""})
    assert r.status_code == 400
    data = unwrap(r.json())
    assert data["valid"] == 0
    assert len(data["errors"]) > 0


# ========================================
# Param / Regex Validation
# ========================================

def test_validate_param_numeric(client):
    r = client.get("/validate/param/123")
    assert r.status_code == 200
    assert unwrap(r.json())["isnumeric"] == 1


def test_validate_param_non_numeric(client):
    r = client.get("/validate/param/abc")
    assert r.status_code == 200
    assert unwrap(r.json())["isnumeric"] == 0


def test_match_regex_match(client):
    r = client.get("/validate/regex", params={"test": "hello"})
    assert r.status_code == 200
    assert unwrap(r.json())["matches"] == 1


def test_match_regex_no_match(client):
    r = client.get("/validate/regex", params={"test": "Hello123"})
    assert r.status_code == 200
    assert unwrap(r.json())["matches"] == 0


# ========================================
# Validate Class (11 methods)
# ========================================

def test_validate_email_valid(client):
    r = client.post("/validate/inputs", json={
        "email": "user@example.com", "url": "https://example.com",
        "ip": "192.168.1.1", "ipv4": "10.0.0.1", "ipv6": "::1",
        "uuid": "550e8400-e29b-41d4-a716-446655440000",
        "jsonString": '{"ok":true}',
        "alpha": "hello", "alphanumeric": "abc123", "numeric": "42",
        "str": "test", "min": "1", "max": "10",
        "num": "5", "lo": "0", "hi": "10"
    })
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["email"] == 1
    assert data["url"] == 1
    assert data["ip"] == 1
    assert data["ipv4"] == 1
    assert data["ipv6"] == 1
    assert data["uuid"] == 1
    assert data["jsonstring"] == 1
    assert data["alpha"] == 1
    assert data["alphanumeric"] == 1
    assert data["numeric"] == 1
    assert data["length"] == 1
    assert data["range"] == 1


def test_validate_email_invalid(client):
    r = client.post("/validate/inputs", json={
        "email": "not-email", "url": "not-url",
        "ip": "not-ip", "ipv4": "not-ipv4", "ipv6": "not-ipv6",
        "uuid": "not-uuid",
        "jsonString": "{invalid",
        "alpha": "abc123", "alphanumeric": "abc!", "numeric": "12.5",
        "str": "ab", "min": "5", "max": "10",
        "num": "20", "lo": "0", "hi": "10"
    })
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["email"] == 0
    assert data["url"] == 0
    assert data["ip"] == 0
    assert data["ipv4"] == 0
    assert data["ipv6"] == 0
    assert data["uuid"] == 0
    assert data["jsonstring"] == 0
    assert data["alpha"] == 0
    assert data["alphanumeric"] == 0
    assert data["length"] == 0
    assert data["range"] == 0


# ========================================
# Templates
# ========================================

def test_template_inline(client):
    r = client.get("/template/inline", params={"name": "Ring"})
    assert r.status_code == 200
    assert "Hello Ring" in r.text


def test_template_inline_default(client):
    r = client.get("/template/inline")
    assert r.status_code == 200
    assert "Hello World" in r.text


def test_template_loop(client):
    r = client.get("/template/loop", params={"count": "3"})
    assert r.status_code == 200
    assert "1" in r.text
    assert "3" in r.text


def test_template_file(client):
    r = client.get("/template/file")
    assert r.status_code == 200
    assert "Hello Bolt" in r.text


# ========================================
# JSON Pretty
# ========================================

def test_json_pretty(client):
    r = client.get("/json/pretty")
    assert r.status_code == 200
    assert "\n" in r.text


# ========================================
# Hash: Argon2
# ========================================

def test_argon2_hash_and_verify(client):
    r = client.post("/hash/argon2", json={"password": "test123"})
    assert r.status_code == 200
    hash_val = unwrap(r.json())["hash"]
    assert hash_val != ""

    r2 = client.post("/hash/verify", json={"password": "test123", "hash": hash_val})
    assert r2.status_code == 200
    assert unwrap(r2.json())["argon2"] == 1


def test_argon2_wrong_password(client):
    r = client.post("/hash/argon2", json={"password": "test123"})
    hash_val = unwrap(r.json())["hash"]

    r2 = client.post("/hash/verify", json={"password": "wrong", "hash": hash_val})
    assert unwrap(r2.json())["argon2"] == 0


# ========================================
# Hash: bcrypt
# ========================================

def test_bcrypt_hash_and_verify(client):
    r = client.post("/hash/bcrypt", json={"password": "mypassword"})
    assert r.status_code == 200
    hash_val = unwrap(r.json())["hash"]
    assert hash_val.startswith("$2")

    r2 = client.post("/hash/bcrypt-verify", json={"password": "mypassword", "hash": hash_val})
    assert r2.status_code == 200
    assert unwrap(r2.json())["valid"] == 1


def test_bcrypt_wrong_password(client):
    r = client.post("/hash/bcrypt", json={"password": "mypassword"})
    hash_val = unwrap(r.json())["hash"]

    r2 = client.post("/hash/bcrypt-verify", json={"password": "wrong", "hash": hash_val})
    assert unwrap(r2.json())["valid"] == 0


# ========================================
# Hash: scrypt
# ========================================

def test_scrypt_hash_and_verify(client):
    r = client.post("/hash/scrypt", json={"password": "mypassword"})
    assert r.status_code == 200
    hash_val = unwrap(r.json())["hash"]
    assert hash_val != ""

    r2 = client.post("/hash/scrypt-verify", json={"password": "mypassword", "hash": hash_val})
    assert r2.status_code == 200
    assert unwrap(r2.json())["valid"] == 1


def test_scrypt_wrong_password(client):
    r = client.post("/hash/scrypt", json={"password": "mypassword"})
    hash_val = unwrap(r.json())["hash"]

    r2 = client.post("/hash/scrypt-verify", json={"password": "wrong", "hash": hash_val})
    assert unwrap(r2.json())["valid"] == 0


# ========================================
# Crypto: AES + HMAC
# ========================================

def test_aes_encrypt_decrypt(client):
    key = "0123456789abcdef0123456789abcdef"
    r = client.post("/crypto/encrypt-decrypt", json={"plaintext": "secret", "key": key})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["encrypted"] != ""
    import base64
    assert base64.b64decode(data["decrypted"]).decode() == "secret"


def test_hmac_sign_and_verify(client):
    r = client.post("/crypto/hmac", json={"message": "hello", "key": "hmac-key"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["signature"] != ""
    assert data["valid"] == 1


# ========================================
# DateTime (full coverage)
# ========================================

def test_datetime_now(client):
    r = client.get("/datetime")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert isinstance(data["timestamp"], (int, float))
    assert data["timestampms"] != ""
    assert data["formatted"] != ""
    assert data["now"] != ""
    assert data["nowutc"] != ""


def test_datetime_arithmetic(client):
    r = client.get("/datetime/arithmetic")
    assert r.status_code == 200
    data = unwrap(r.json())
    base = data["base"]
    assert data["plus2days"] > base
    assert data["plus3hours"] > base
    assert data["diff_seconds"] == 172800 or data.get("diff_seconds", data.get("diffseconds")) == 172800
    assert data["parsed"] > 0


# ========================================
# Sanitize (full coverage)
# ========================================

def test_sanitize_html(client):
    r = client.post("/sanitize/html", json={"input": '<script>alert("xss")</script><p>Safe</p>'})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert "script" not in data["safe"]
    assert "Safe" in data["safe"]
    assert data["strict"] == "Safe"
    assert "&lt;" in data["escaped"] or "&amp;" in data["escaped"]


def test_sanitize_extra(client):
    r = client.post("/sanitize/extra", json={"input": '<img onload="alert(1)">test&data'})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["escapeattr"] != ""
    assert data["escapejs"] != ""
    assert data["escapeurl"] != ""


# ========================================
# UUID + SHA-256
# ========================================

def test_uuid(client):
    r = client.get("/utils/uuid")
    assert r.status_code == 200
    uuid = unwrap(r.json())["uuid"]
    assert len(uuid) == 36
    assert uuid.count("-") == 4


def test_sha256(client):
    r = client.get("/utils/sha256", params={"text": "hello"})
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["hash"] != ""
    assert len(data["hash"]) == 64


# ========================================
# URL encode/decode
# ========================================

def test_url_encode(client):
    r = client.get("/utils/url-encode", params={"text": "hello world"})
    assert r.status_code == 200
    assert unwrap(r.json())["encoded"] != "hello world"


def test_url_decode(client):
    r = client.get("/utils/url-decode", params={"text": "hello%20world"})
    assert r.status_code == 200
    assert unwrap(r.json())["decoded"] == "hello world"


# ========================================
# Unixtime (seconds + milliseconds)
# ========================================

def test_unixtime(client):
    r = client.get("/utils/unixtime")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert isinstance(data["seconds"], (int, float))
    assert isinstance(data["milliseconds"], (int, float))
    assert data["milliseconds"] >= data["seconds"] * 1000


# ========================================
# Environment Variables
# ========================================

def test_env_get(client):
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


# ========================================
# Base64 (standard + URL-safe)
# ========================================

def test_base64_encode(client):
    r = client.get("/base64/encode", params={"text": "hello"})
    assert r.status_code == 200
    assert unwrap(r.json())["encoded"] != ""


def test_base64_decode(client):
    import base64
    encoded = base64.b64encode(b"hello").decode()
    r = client.get("/base64/decode", params={"encoded": encoded})
    assert r.status_code == 200
    assert unwrap(r.json())["decoded"] == "hello"


def test_base64_url_encode(client):
    r = client.get("/base64/url-encode", params={"text": "hello?world"})
    assert r.status_code == 200
    encoded = unwrap(r.json())["encoded"]
    assert "+" not in encoded
    assert "/" not in encoded


def test_base64_url_decode(client):
    r = client.get("/base64/url-encode", params={"text": "test"})
    encoded = unwrap(r.json())["encoded"]
    r2 = client.get("/base64/url-decode", params={"encoded": encoded})
    assert r2.status_code == 200
    assert unwrap(r2.json())["decoded"] == "test"
