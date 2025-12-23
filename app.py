import os
import requests
from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
from datetime import datetime
import json
import firebase_admin
from firebase_admin import credentials, firestore

# ================= FIRESTORE =================
SERVICE_ACCOUNT_FILE = os.environ.get("FIREBASE_SERVICE_ACCOUNT", "serviceAccountKey.json")

if not firebase_admin._apps:
    firebase_cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
    firebase_app = firebase_admin.initialize_app(firebase_cred)
else:
    firebase_app = firebase_admin.get_app()

db = firestore.client()
# ============================================

# ================= HEDERA SDK =================
hedera_available = True
try:
    from hedera import (
        Client,
        AccountId,
        PrivateKey,
        TokenId,
        TransferTransaction
    )
    from hedera.crypto import PublicKey, Signature
except Exception as e:
    hedera_available = False
    print("Hedera SDK not available on this runtime:", e)
# =============================================

app = Flask(__name__)
CORS(app)

# --- Hedera / Mirror constants ---
MIRROR_BASE = "https://mainnet-public.mirrornode.hedera.com"
NCHAIN_TOKEN_ID_STR = "0.0.10136204"

HEDERA_NETWORK = os.environ.get("HEDERA_NETWORK", "testnet")
OPERATOR_ID_STR = os.environ.get("OPERATOR_ID")
OPERATOR_KEY_STR = os.environ.get("OPERATOR_KEY")

proposals_db = []
votes_db = []

# ========== DONATIONS MAP ==========
donations_by_region = {
    "afrique_ouest": 0,
    "afrique_est": 0,
    "moyen_orient": 0,
    "asie_sud": 0,
    "afrique_centrale": 0,
    "afrique_nord": 0,
    "Dakar": 0,
}
# ===================================

APY = 0.10

# ========== PROPOSALS DUMMY DATA ==========
proposals = [
    {
        "id": 1,
        "region": "afrique_ouest",
        "title": "Cantine solidaire Dakar",
        "meals_target": 1000,
        "meals_funded": 0,
        "status": "open",
    }
]
# ==========================================

# ========== HEDERA CONFIG ==========
if hedera_available:
    try:
        NCHAIN_TOKEN_ID = TokenId.fromString(NCHAIN_TOKEN_ID_STR)
        if HEDERA_NETWORK == "testnet":
            hedera_client = Client.forTestnet()
        else:
            hedera_client = Client.forMainnet()

        if OPERATOR_ID_STR and OPERATOR_KEY_STR:
            OPERATOR_ID = AccountId.fromString(OPERATOR_ID_STR)
            OPERATOR_KEY = PrivateKey.fromString(OPERATOR_KEY_STR)
            hedera_client.setOperator(OPERATOR_ID, OPERATOR_KEY)
        else:
            OPERATOR_ID = None
            OPERATOR_KEY = None
            print("Warning: OPERATOR_ID / OPERATOR_KEY not set, send_nchain will be simulated.")
    except Exception as e:
        print(f"Hedera config error: {e}")
        NCHAIN_TOKEN_ID = None
        hedera_client = None
        OPERATOR_ID = None
        OPERATOR_KEY = None
else:
    NCHAIN_TOKEN_ID = None
    hedera_client = None
    OPERATOR_ID = None
    OPERATOR_KEY = None
# ===================================

def get_nchain_balance(account_id: str) -> float:
    try:
        url = f"{MIRROR_BASE}/api/v1/tokens/{NCHAIN_TOKEN_ID_STR}/balances"
        params = {"account.id": account_id}
        r = requests.get(url, params=params, timeout=10)
        r.raise_for_status()
        data = r.json()
        balances = data.get("balances", [])
        if not balances:
            return 0.0
        raw = balances[0].get("balance", 0)
        return raw / 1_000_000.0
    except:
        return 0.0

def send_nchain(to_account: str, amount_tokens: float) -> str:
    if not hedera_available or NCHAIN_TOKEN_ID is None or hedera_client is None:
        return "SIMULATED_NO_SDK"
    if not OPERATOR_ID or not OPERATOR_KEY:
        return "SIMULATED_NO_OPERATOR"
    
    try:
        tokens_smallest = int(amount_tokens * 1_000_000)
        tx = (
            TransferTransaction()
            .addTokenTransfer(NCHAIN_TOKEN_ID, OPERATOR_ID, -tokens_smallest)
            .addTokenTransfer(NCHAIN_TOKEN_ID, AccountId.fromString(to_account), tokens_smallest)
        )
        tx.freezeWith(hedera_client)
        tx.sign(OPERATOR_KEY)
        tx_response = tx.execute(hedera_client)
        receipt = tx_response.getReceipt(hedera_client)
        return str(receipt.status)
    except Exception as e:
        return f"ERROR: {str(e)}"

def calculate_rewards(wallet):
    try:
        doc_ref = db.collection("staking").document(wallet)
        doc = doc_ref.get()
        if not doc.exists:
            return 0.0
        data = doc.to_dict()
        if "start_time" not in data:
            return 0.0
        now = datetime.utcnow()
        start = datetime.fromisoformat(data["start_time"])
        duration = max((now - start).total_seconds(), 0)
        yearly_seconds = 365 * 24 * 3600
        reward = data["amount"] * APY * (duration / yearly_seconds)
        return reward
    except:
        return 0.0

def get_staking_info(wallet):
    try:
        doc_ref = db.collection("staking").document(wallet)
        doc = doc_ref.get()
        if not doc.exists:
            return {"staked": False, "amount": 0, "pending_rewards": 0, "start_time": None, "apy": APY}
        data = doc.to_dict()
        pending = calculate_rewards(wallet)
        return {
            "staked": True,
            "amount": data["amount"],
            "pending_rewards": pending,
            "start_time": data["start_time"],
            "apy": APY
        }
    except:
        return {"staked": False, "amount": 0, "pending_rewards": 0, "start_time": None, "apy": APY}

@app.route("/proposals", methods=["GET", "POST"])
def proposals_route():
    if request.method == "GET":
        return jsonify({"proposals": proposals_db})

    data = request.get_json() or {}
    title = data.get("title")
    region = data.get("region") or "N/A"
    meals_target = data.get("meals_target") or 0

    if not title:
        return jsonify({"message": "Title is required"}), 400

    new_id = (proposals_db[-1]["id"] + 1) if proposals_db else 1
    proposal = {
        "id": new_id,
        "title": title,
        "region": region,
        "meals_target": meals_target,
        "meals_funded": 0,
        "status": "open",
    }
    proposals_db.append(proposal)
    return jsonify({"message": "Proposal created.", "proposal": proposal}), 201

@app.route("/vote/<int:proposal_id>", methods=["POST"])
def vote(proposal_id):
    data = request.get_json() or {}
    choice = data.get("choice")
    wallet = data.get("wallet")

    if choice not in ("yes", "no", "abstain"):
        return jsonify({"message": "Invalid choice."}), 400

    if not wallet:
        return jsonify({"message": "Wallet (accountId) is required."}), 400

    weight = get_nchain_balance(wallet)
    vote_record = {
        "proposal_id": proposal_id,
        "wallet": wallet,
        "choice": choice,
        "weight": weight,
        "timestamp": datetime.utcnow().isoformat()
    }
    votes_db.append(vote_record)
    
    try:
        db.collection('votes').add(vote_record)
    except Exception as e:
        print(f"Warning: could not save vote to firestore: {e}")

    return jsonify({"message": f"Vote '{choice}' recorded.", "weight": weight}), 200

@app.route("/proposals/<int:proposal_id>/results", methods=["GET"])
def proposal_results(proposal_id):
    yes_weight = no_weight = abstain_weight = 0.0
    for v in votes_db:
        if v["proposal_id"] == proposal_id:
            if v["choice"] == "yes":
                yes_weight += v["weight"]
            elif v["choice"] == "no":
                no_weight += v["weight"]
            elif v["choice"] == "abstain":
                abstain_weight += v["weight"]
    return jsonify({
        "proposal_id": proposal_id,
        "results": {"yes": yes_weight, "no": no_weight, "abstain": abstain_weight},
    })

@app.route("/api/stake", methods=["POST"])
def stake():
    data = request.get_json() or {}
    wallet = data.get("wallet")
    amount = float(data.get("amount", 0))

    if not wallet or amount <= 0:
        return jsonify({"error": "wallet ou amount invalide"}), 400

    doc_ref = db.collection("staking").document(wallet)
    doc = doc_ref.get()
    if doc.exists:
        return jsonify({"error": "Already staking, unstake first"}), 400

    timestamp = datetime.utcnow().isoformat()
    doc_ref.set({
        "wallet": wallet,
        "amount": amount,
        "start_time": timestamp,
        "apy": APY
    })
    
    try:
        db.collection('staking_history').add({
            "wallet": wallet,
            "amount": amount,
            "action": "stake",
            "timestamp": timestamp
        })
    except:
        pass

    return jsonify({"message": "Stake successful", "amount": amount}), 200

@app.route("/api/unstake", methods=["POST"])
def unstake():
    data = request.get_json() or {}
    wallet = data.get("wallet")

    if not wallet:
        return jsonify({"error": "Wallet required"}), 400

    doc_ref = db.collection("staking").document(wallet)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "No active stake found"}), 400

    data_dict = doc.to_dict()
    staked_amount = data_dict["amount"]
    reward = calculate_rewards(wallet)

    doc_ref.delete()

    rewards_ref = db.collection("rewards").document(wallet)
    rewards_data = rewards_ref.get()
    current_rewards = rewards_data.to_dict().get("total", 0) if rewards_data.exists else 0
    rewards_ref.set({"total": current_rewards + reward})
    
    try:
        db.collection('staking_history').add({
            "wallet": wallet,
            "amount": staked_amount,
            "reward": reward,
            "action": "unstake",
            "timestamp": datetime.utcnow().isoformat()
        })
    except:
        pass

    return jsonify({
        "message": "Unstake successful",
        "staked_amount": staked_amount,
        "reward": reward,
        "total_rewards": current_rewards + reward
    }), 200

@app.route("/api/staking_info/<wallet>", methods=["GET"])
def staking_info(wallet):
    info = get_staking_info(wallet)
    return jsonify(info)

@app.route("/api/donate", methods=["POST"])
def api_donate():
    data = request.get_json() or {}
    app.logger.info(f"New donation: {data}")
    
    if data:
        try:
            record = data.copy()
            if 'timestamp' not in record:
                record['timestamp'] = datetime.utcnow().isoformat()
            db.collection('donations').add(record)
        except:
            pass
    return jsonify({"status": "ok"})

@app.route('/api/activity', methods=['GET'])
def get_activity():
    activities = []
    
    try:
        # Donations
        try:
            donations_ref = db.collection('donations').order_by('timestamp', direction=firestore.Query.DESCENDING).limit(5)
            for doc in donations_ref.stream():
                data = doc.to_dict()
                donor = data.get('donor_label') or data.get('wallet_address') or 'Anonymous'
                activities.append({
                    'type': 'donation',
                    'icon': '❤️',
                    'message': f"Donation of {data.get('amount', 0)} NUTRI",
                    'user': donor[:10] + '...' if len(donor) > 10 else donor,
                    'timestamp': data.get('timestamp')
                })
        except:
            pass

        # Votes
        try:
            votes_ref = db.collection('votes').order_by('timestamp', direction=firestore.Query.DESCENDING).limit(5)
            for doc in votes_ref.stream():
                data = doc.to_dict()
                activities.append({
                    'type': 'vote',
                    'icon': '🗳️',
                    'message': f"Voted '{data.get('choice')}' on Prop #{data.get('proposal_id', '?')}",
                    'user': (data.get('wallet') or 'Anonymous')[:6] + '...',
                    'timestamp': data.get('timestamp')
                })
        except:
            pass

        # Stakes
        try:
            stakes_ref = db.collection('staking_history').order_by('timestamp', direction=firestore.Query.DESCENDING).limit(5)
            for doc in stakes_ref.stream():
                data = doc.to_dict()
                action = data.get('action', 'stake').capitalize()
                activities.append({
                    'type': 'stake',
                    'icon': '🔒' if action == 'Stake' else '🔓',
                    'message': f"{action}d {data.get('amount', 0)} NCHAIN",
                    'user': (data.get('wallet') or 'Anonymous')[:6] + '...',
                    'timestamp': data.get('timestamp')
                })
        except:
            pass

        # Sort by timestamp
        def parse_ts(item):
            ts = item.get('timestamp')
            if not ts:
                return datetime.min
            try:
                if isinstance(ts, str):
                    return datetime.fromisoformat(ts.replace('Z', '+00:00'))
                return ts
            except:
                return datetime.min

        activities.sort(key=parse_ts, reverse=True)
        
        final_list = []
        for act in activities[:10]:
            item = act.copy()
            if not isinstance(item['timestamp'], str):
                item['timestamp'] = item['timestamp'].isoformat() if item['timestamp'] else ""
            final_list.append(item)

        return jsonify(final_list)
    except:
        return jsonify([])

@app.route("/about-governance")
def about_governance():
    return render_template("about_governance.html")

@app.route("/donate_page")
def donate_page():
    return render_template("donate.html")

@app.route("/stake")
def stake_page():
    return render_template("stake.html")

@app.route("/governance")
def governance_page():
    return render_template("governance.html")

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})

@app.route("/proposals_list", methods=["GET"])
def list_proposals():
    return jsonify({"proposals": proposals})

@app.route("/donate", methods=["GET"])
def show_donate_page():
    return render_template("donate.html")

@app.route("/donate", methods=["POST"])
def donate():
    data = request.get_json() or {}

    wallet_address = data.get("wallet_address")
    donor_label = data.get("donor_label", "Anonymous")
    region = data.get("region")
    amount = data.get("amount")
    hedera_account = data.get("hedera_account")

    if not wallet_address:
        return jsonify({"error": "wallet_address missing"}), 400

    if region not in donations_by_region:
        return jsonify({"error": "Unknown region"}), 400

    if not isinstance(amount, (int, float)) or amount <= 0:
        return jsonify({"error": "Invalid amount"}), 400

    if not hedera_account:
        return jsonify({"error": "Missing Hedera account (hedera_account)"}), 400

    meals = int(amount)
    donations_by_region[region] += amount

    target_proposal = next((p for p in proposals if p["region"] == region), None)
    proposal_id = target_proposal["id"] if target_proposal else None

    if target_proposal:
        funded = target_proposal.get("meals_funded", 0)
        target_proposal["meals_funded"] = funded + meals

    tx_status = send_nchain(hedera_account, amount)
    
    timestamp = datetime.utcnow().isoformat()
    try:
        db.collection('donations').add({
            "wallet_address": wallet_address,
            "donor_label": donor_label,
            "region": region,
            "amount": amount,
            "timestamp": timestamp,
            "tx_status": str(tx_status)
        })
    except:
        pass

    return jsonify({
        "message": f"Donation of {amount} NUTRI received for region {region}",
        "wallet_address": wallet_address,
        "donor_label": donor_label,
        "region": region,
        "amount": amount,
        "meals_funded": meals,
        "proposal_id": proposal_id,
        "donations_by_region": donations_by_region,
        "proposal": target_proposal,
        "hedera_account": hedera_account,
        "nchain_token_id": NCHAIN_TOKEN_ID_STR,
        "nchain_tx_status": str(tx_status),
    }), 201

@app.route("/nchain_balance/<account_id>")
def nchain_balance(account_id):
    try:
        balance = get_nchain_balance(account_id)
    except:
        return jsonify({"error": "Mirror node error"}), 502
    return jsonify({
        "account_id": account_id,
        "token_id": NCHAIN_TOKEN_ID_STR,
        "symbol": "NCHAIN",
        "balance": balance,
    })

@app.route("/nchain_balance/aid", methods=["GET"])
def nchain_balance_aid():
    return nchain_balance("0.0.10168905")

@app.route("/linked_wallet/<account_id>", methods=["GET"])
def linked_wallet(account_id):
    doc_ref = db.collection("linked_wallets").document(account_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "No wallet linked for this account"}), 404
    return jsonify(doc.to_dict())

@app.route("/linked_wallet", methods=["POST"])
def post_linked_wallet():
    data = request.get_json(silent=True) or {}
    account = data.get("account")
    evm_address = data.get("evm_address")
    wallet_type = data.get("wallet_type", "unknown")

    if not account:
        return jsonify({"error": "Missing 'account'"}), 400

    doc_ref = db.collection("linked_wallets").document(account)
    doc_ref.set({
        "account": account,
        "evm_address": evm_address,
        "wallet_type": wallet_type,
    }, merge=True)
    return jsonify({"status": "ok"})

@app.route("/hashpack_connect", methods=["POST"])
def hashpack_connect():
    data = request.get_json() or {}
    wallet_hedera = data.get("wallet_hedera")
    signature = data.get("signature")

    if not wallet_hedera or not signature:
        return jsonify({"error": "Missing wallet or signature"}), 400

    try:
        doc_ref = db.collection("linked_wallets").document(wallet_hedera)
        doc_ref.set({
            "account": wallet_hedera,
            "wallet_type": "hashpack",
            "connected_at": datetime.utcnow().isoformat()
        }, merge=True)
        return jsonify({"status": "ok", "wallet_type": "hashpack"})
    except:
        return jsonify({"error": "Database error"}), 500

@app.route("/")
def index():
    treasury_id = "0.0.10128148"
    return render_template("dashboard.html", treasury_id=treasury_id)

@app.route("/api/login_wallet", methods=["POST"])
def login_wallet():
    data = request.get_json() or {}
    wallet = data.get("wallet")
    hedera_account = data.get("hedera")

    if not wallet:
        return jsonify({"error": "No wallet provided"}), 400

    try:
        doc_ref = db.collection("linked_wallets").document(wallet)
        payload = {
            "account": hedera_account,
            "evm_address": wallet,
            "wallet_type": "evm",
            "connected_at": datetime.utcnow().isoformat()
        }
        doc_ref.set(payload, merge=True)
    except:
        return jsonify({"error": "Firestore error"}), 500

    return jsonify({"status": "ok", "wallet": wallet})

@app.route("/api/evm_to_hedera", methods=["GET"])
def evm_to_hedera():
    evm = request.args.get("evm")
    if not evm:
        return jsonify({"error": "missing evm"}), 400

    doc_ref = db.collection("linked_wallets").document(evm)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "no link found"}), 404

    data = doc.to_dict()
    return jsonify({"evm": evm, "hedera": data.get("account")})

@app.route("/api/link_hedera", methods=["POST"])
def link_hedera():
    data = request.get_json() or {}
    evm = data.get("evm")
    hedera_account = data.get("hedera")

    if not evm or not hedera_account:
        return jsonify({"error": "Missing evm or hedera"}), 400

    try:
        doc_ref = db.collection("linked_wallets").document(evm)
        doc_ref.set({
            "evm_address": evm,
            "account": hedera_account,
            "wallet_type": "evm",
            "linked_at": datetime.utcnow().isoformat(),
        }, merge=True)
    except:
        return jsonify({"error": "Firestore error"}), 500

    return jsonify({"status": "ok", "evm": evm, "hedera": hedera_account})

@app.route("/admin")
def admin_dashboard():
    return render_template("admin_dashboard.html")

@app.route("/wallet")
def wallet():
    return render_template("wallet.html")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
