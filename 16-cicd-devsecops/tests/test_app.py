import sys
import os

import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))

from app import app as flask_app


@pytest.fixture
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as client:
        yield client


def test_home(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "ok"


def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "healthy"


def test_status(client):
    resp = client.get("/api/status")
    assert resp.status_code == 200
    body = resp.get_json()
    assert "uptime_seconds" in body
    assert "pid" in body


def test_add(client):
    resp = client.post("/api/add", json={"a": 2, "b": 3})
    assert resp.status_code == 200
    assert resp.get_json()["result"] == 5


def test_add_missing_field(client):
    resp = client.post("/api/add", json={"a": 2})
    assert resp.status_code == 400


def test_calculate_multiply(client):
    resp = client.post("/api/calculate", json={"a": 6, "b": 3, "operation": "multiply"})
    assert resp.status_code == 200
    assert resp.get_json()["result"] == 18


def test_calculate_divide_by_zero(client):
    resp = client.post("/api/calculate", json={"a": 5, "b": 0, "operation": "divide"})
    assert resp.status_code == 400


def test_calculate_unknown_operation(client):
    resp = client.post("/api/calculate", json={"a": 1, "b": 1, "operation": "power"})
    assert resp.status_code == 400
