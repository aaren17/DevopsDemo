import pytest
from app import app  # This imports your actual Flask app from app.py

# --- FIXTURE (The Setup) ---
# This creates a "fake browser" client so we don't need a real server running
@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

# --- TEST 1: Health Check ---
def test_homepage_status_code(client):
    """Test that the homepage returns a 200 OK status."""
    response = client.get('/')
    assert response.status_code == 200

# --- TEST 2: Content Check ---
def test_homepage_content(client):
    """Test that the homepage contains the correct text."""
    response = client.get('/')
    # We use 'b' because the data comes back as bytes, not a string
    assert b"Junior DevOps Engineer" in response.data