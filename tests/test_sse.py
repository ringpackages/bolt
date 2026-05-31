import pytest
from conftest import unwrap


def test_sse_broadcast(client):
    r = client.post("/events/trigger")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["sent"] == 1


def test_sse_named_event(client):
    r = client.post("/events/named")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["sent"] == 1


def test_sse_filter_params_trigger(client):
    r = client.post("/events/filter-trigger", params={"channel": "sports"})
    assert r.status_code == 200
    assert unwrap(r.json())["sent"] == 1


def test_sse_named_filter_event(client):
    r = client.post("/events/named-filter", params={"channel": "news"})
    assert r.status_code == 200
    assert unwrap(r.json())["sent"] == 1


def test_sse_broadcast_nonexistent_path(client):
    r = client.post("/events/nonexistent-broadcast")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["sent_to"] == -1


def test_sse_broadcast_params_nonmatching(client):
    r = client.post("/events/filter-nonmatching")
    assert r.status_code == 200
    data = unwrap(r.json())
    assert data["clients"] == -1
