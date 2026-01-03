from flask import Flask, request, jsonify
from datetime import datetime
import uuid

app = Flask(__name__)

proposals = {}  # {id: {...}}

@app.route("/proposals", methods=["POST"])
def create_proposal():
    data = request.get_json() or {}

    title = data.get("title")
    country = data.get("country")
    city = data.get("city")
    meals_target = data.get("meals_target")
    description = data.get("description", "")

    if not title or not country or not city or not meals_target:
        return jsonify({"error": "title, country, city, meals_target requis"}), 400

    proposal_id = "prop_" + str(uuid.uuid4())[:8]

    proposals[proposal_id] = {
        "id": proposal_id,
        "title": title,
        "country": country,
        "city": city,
        "meals_target": meals_target,
        "description": description,
        "created_at": datetime.utcnow().isoformat()
    }

    return jsonify(proposals[proposal_id]), 201

@app.route("/proposals", methods=["GET"])
def list_proposals():
    return jsonify(list(proposals.values()))
