import pytest
from main import app

@pytest.fixture
def client():
    app.config['TESTING'] = True

    with app.test_client() as test_client:
        yield test_client

def test_health(client):
    response = client.get('/health')
    assert response.status_code == 200

    json_data = response.get_json()
    assert json_data["status"] == 'UP'

def test_post_endpoint(client):
    response = client.post('/items', json={
        'name': 'Kubernetes Mastery',
        'category': 'DevOps lab'
    })

    assert response.status_code == 201

    json_data = response.get_json()
    assert json_data['message'] == "Item created successfully"
