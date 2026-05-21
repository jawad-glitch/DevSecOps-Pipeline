from flask import Flask, jsonify, request
import os

app = Flask(__name__)

# Simulated in-memory database for basic CRUD operations
items_db = [
    {"id": 1, "name": "Item One", "category": "DevSecOps Lab Setup"},
    {"id": 2, "name": "Item Two", "category": "AIOps Workflow"}
]

# 1. Health Check Endpoint (Prometheus / Load Balancer Target)
@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "UP",
        "checks": {
            "database": "connected",
            "disk_space": "healthy"
        }
    }), 200

# 2. App Info Endpoint (Configuration Management Tracking)
@app.route('/info', methods=['GET'])
def info():
    return jsonify({
        "app_name": "DevSecOps Demo App",
        "version": os.getenv("APP_VERSION", "1.0.0"),
        "environment": os.getenv("APP_ENV", "production"),
        "framework": "Flask 3.x",
        "runtime": "Python 3.11"
    }), 200

# 3. Basic CRUD Endpoint (Combined GET and POST)
@app.route('/items', methods=['GET', 'POST'])
def items():
    if request.method == 'GET':
        # READ: Return list of all current items
        return jsonify({
            "count": len(items_db),
            "data": items_db
        }), 200
    
    elif request.method == 'POST':
        # CREATE: Expects a JSON body with a 'name' and 'category'
        data = request.get_json() or {}
        
        if not data.get('name'):
            return jsonify({"error": "Missing required field: 'name'"}), 400
        
        highest_id = max(item['id'] for item in items_db) if items_db else 0
        new_item = {
            "id": highest_id + 1,
            "name": data['name'],
            "category": data.get('category', 'Uncategorized')
        }
        
        items_db.append(new_item)
        return jsonify({
            "message": "Item created successfully",
            "created_record": new_item
        }), 201


if __name__ == "__main__":
    server_host = os.getenv("FLASK_RUN_HOST", "127.0.0.1")
    app.run(host=server_host, port=5000)
