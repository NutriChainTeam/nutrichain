from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

# stockage en mémoire (à remplacer par une DB plus tard)
stakes = {}        # {wallet: {"amount": x, "start_time": datetime}}
rewards = {}       # {wallet: montant_total_de_rewards}
APY = 0.10         # 10% par an, exemple

def calculate_rewards(wallet):
    data = stakes.get(wallet)
    if not data:
        return 0.0
    now = datetime.utcnow()
    duration = (now - data["start_time"]).total_seconds()  # en secondes
    yearly_seconds = 365 * 24 * 3600
    reward = data["amount"] * APY * (duration / yearly_seconds)
    return reward

@app.route("/stake", methods=["POST"])
def stake():
    data = request.get_json()
    wallet = data.get("wallet")
    amount = float(data.get("amount", 0))

    if not wallet or amount <= 0:
        return jsonify({"error": "wallet ou amount invalide"}), 400

    if wallet in stakes:
        current_reward = calculate_rewards(wallet)
        rewards[wallet] = rewards.get(wallet, 0) + current_reward
        stakes[wallet]["amount"] += amount
        stakes[wallet]["start_time"] = datetime.utcnow()
    else:
        stakes[wallet] = {
            "amount": amount,
            "start_time": datetime.utcnow()
        }

    return jsonify({"status": "staked", "wallet": wallet, "amount": stakes[wallet]["amount"]})

@app.route("/unstake", methods=["POST"])
def unstake():
    data = request.get_json()
    wallet = data.get("wallet")

    if wallet not in stakes:
        return jsonify({"error": "aucun stake pour ce wallet"}), 400

    current_reward = calculate_rewards(wallet)
    rewards[wallet] = rewards.get(wallet, 0) + current_reward

    amount = stakes[wallet]["amount"]
    del stakes[wallet]

    return jsonify({
        "status": "unstaked",
        "wallet": wallet,
        "returned_amount": amount,
        "total_rewards": rewards.get(wallet, 0)
    })

@app.route("/claim_rewards", methods=["POST"])
def claim_rewards():
    data = request.get_json()
    wallet = data.get("wallet")

    if wallet in stakes:
        current_reward = calculate_rewards(wallet)
        rewards[wallet] = rewards.get(wallet, 0) + current_reward
        stakes[wallet]["start_time"] = datetime.utcnow()

    total_reward = rewards.get(wallet, 0)
    if total_reward <= 0:
        return jsonify({"error": "aucune reward à récupérer"}), 400

    rewards[wallet] = 0

    return jsonify({
        "status": "claimed",
        "wallet": wallet,
        "claimed_reward": total_reward
    })

@app.route("/status", methods=["GET"])
def status():
    return jsonify({
        "stakes": stakes,
        "rewards": rewards
    })

@app.route("/donate_rewards", methods=["POST"])
def donate_rewards():
    data = request.get_json()
    wallet = data.get("wallet")
    proposal_id = data.get("proposal_id")  # identifiant de la proposition de don (carte)

    if not wallet or not proposal_id:
        return jsonify({"error": "wallet ou proposal_id manquant"}), 400

    # ajouter les rewards courants avant de donner
    if wallet in stakes:
        current_reward = calculate_rewards(wallet)
        rewards[wallet] = rewards.get(wallet, 0) + current_reward
        stakes[wallet]["start_time"] = datetime.utcnow()

    total_reward = rewards.get(wallet, 0)
    if total_reward <= 0:
        return jsonify({"error": "aucune reward à donner"}), 400

    donated_amount = total_reward
    rewards[wallet] = 0

    return jsonify({
        "status": "donated",
        "wallet": wallet,
        "proposal_id": proposal_id,
        "donated_amount": donated_amount
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
