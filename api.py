import os
import requests
from flask import Flask, jsonify, request, render_template
from flask_cors import CORS

# ================= FIRESTORE =================
import firebase_admin
from firebase_admin import credentials, firestore

# Fichier de clé de service (à adapter)
SERVICE_ACCOUNT_FILE = os.environ.get("FIREBASE_SERVICE_ACCOUNT", "serviceAccountKey.json")

firebase_cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
firebase_app = firebase_admin.initialize_app(firebase_cred)
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
        TransferTransaction,
    )
except Exception as e:
    hedera_available = False
    print("Hedera SDK not available on this runtime:", e)
# =============================================

app = Flask(__name__)
CORS(app)

# --- Hedera / Mirror constants ---
MIRROR_BASE = "https://mainnet-public.mirrornode.hedera.com"
NCHAIN_TOKEN_ID_STR = "0.0.10136204"   # pour Mirror Node (toujours une chaîne)

# Réglages opérateur (pour vrais transferts on‑chain)
HEDERA_NETWORK = os.environ.get("HEDERA_NETWORK", "testnet")
OPERATOR_ID_STR = os.environ.get("OPERATOR_ID")       # ex: "0.0.xxxx"
OPERATOR_KEY_STR = os.environ.get("OPERATOR_KEY")     # clé privée Hedera
# ---------------------------------

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
    "Dakar": 0,  # accept Dakar
}
# ===================================

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
else:
    NCHAIN_TOKEN_ID = None
    hedera_client = None
    OPERATOR_ID = None
    OPERATOR_KEY = None
# ===================================


def get_nchain_balance(account_id: str) -> float:
    """
    Lit le solde NCHAIN via le Mirror Node en utilisant l'ID de token chaîne.
    """
    url = f"{MIRROR_BASE}/api/v1/tokens/{NCHAIN_TOKEN_ID_STR}/balances"
    params = {"account.id": account_id}
    r = requests.get(url, params=params, timeout=10)
    r.raise_for_status()
    data = r.json()
    balances = data.get("balances", [])
    if not balances:
        return 0.0

    raw = balances[0].get("balance", 0)
    # NCHAIN has 6 decimals
    return raw / 1_000_000.0


# --- On‑chain NCHAIN transfer ---
def send_nchain(to_account: str, amount_tokens: float) -> str:
    """
    Envoie amount_tokens NCHAIN vers to_account. Si SDK ou opérateur indisponible,
    renvoie un statut simulé.
    """
    if not hedera_available or NCHAIN_TOKEN_ID is None or hedera_client is None:
        return "SIMULATED_NO_SDK"

    if not OPERATOR_ID or not OPERATOR_KEY:
        return "SIMULATED_NO_OPERATOR"

    tokens_smallest = int(amount_tokens * 1_000_000)  # 6 decimals

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
# ---------------------------------


# ========== PROPOSALS & VOTES (RAM) ==========
@app.route("/proposals", methods=["GET", "POST"])
def proposals_route():
    """
    GET : renvoie les propositions en RAM (proposals_db).
    POST : crée une nouvelle proposition en RAM (simple démo).
    """
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
    wallet = data.get("wallet")  # can be None for now

    if choice not in ("yes", "no", "abstain"):
        return jsonify({"message": "Invalid choice."}), 400

    # Temporary: if no wallet, use fixed weight 1.0
    if not wallet:
        weight = 1.0
    else:
        try:
            weight = get_nchain_balance(wallet)
        except Exception:
            weight = 0.0

    vote_record = {
        "proposal_id": proposal_id,
        "wallet": wallet,
        "choice": choice,
        "weight": weight,
    }
    votes_db.append(vote_record)

    return jsonify({"message": f"Vote '{choice}' recorded.", "weight": weight}), 200


@app.route("/proposals/<int:proposal_id>/results", methods=["GET"])
def proposal_results(proposal_id):
    yes_weight = 0.0
    no_weight = 0.0
    abstain_weight = 0.0

    for v in votes_db:
        if v["proposal_id"] != proposal_id:
            continue
        if v["choice"] == "yes":
            yes_weight += v["weight"]
        elif v["choice"] == "no":
            no_weight += v["weight"]
        elif v["choice"] == "abstain":
            abstain_weight += v["weight"]

    return jsonify(
        {
            "proposal_id": proposal_id,
            "results": {
                "yes": yes_weight,
                "no": no_weight,
                "abstain": abstain_weight,
            },
        }
    )
# ============================================


@app.route("/api/donate", methods=["POST"])
def api_donate():
    data = request.get_json()
    # Later: persist to DB or file
    app.logger.info(f"New donation: {data}")
    return jsonify({"status": "ok"}), 200


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
    return jsonify({"status": "ok"}), 200


@app.route("/proposals_list", methods=["GET"])
def list_proposals():
    # Version simple basée sur la liste "proposals" statique
    return jsonify({"proposals": proposals}), 200


@app.route("/donate", methods=["GET"])
def show_donate_page():
    return render_template("donate.html")


@app.route("/donate", methods=["POST"])
def donate():
    data = request.get_json(force=True)

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
        return jsonify(
            {"error": "Missing Hedera account (hedera_account)"}
        ), 400

    # 1 NUTRI = 1 meal (example)
    meals = int(amount)

    # Update regional stats
    donations_by_region[region] += amount

    # Target a proposal for this region
    target_proposal = next(
        (p for p in proposals if p["region"] == region), None
    )
    proposal_id = target_proposal["id"] if target_proposal else None

    if target_proposal is not None:
        funded = target_proposal.get("meals_funded", 0)
        target_proposal["meals_funded"] = funded + meals

    # On‑chain NCHAIN transfer
    try:
        tx_status = send_nchain(hedera_account, amount)
    except Exception as e:
        return jsonify(
            {"error": "NCHAIN transfer failed", "details": str(e)}
        ), 502

    return jsonify(
        {
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
        }
    ), 201


@app.route("/nchain_balance/<account_id>")
def nchain_balance(account_id):
    try:
        balance = get_nchain_balance(account_id)
    except Exception as e:
        return jsonify({"error": "Mirror node error", "details": str(e)}), 502

    return jsonify(
        {
            "account_id": account_id,
            "token_id": NCHAIN_TOKEN_ID_STR,
            "symbol": "NCHAIN",
            "balance": balance,
        }
    )


@app.route("/nchain_balance/aid", methods=["GET"])
def nchain_balance_aid():
    return nchain_balance("0.0.10168905")


# ========== LINKED WALLETS AVEC FIRESTORE ==========
@app.route("/linked_wallet/<account_id>", methods=["GET"])
def linked_wallet(account_id):
    """
    Renvoie le wallet lié pour un compte Hedera donné, depuis Firestore.
    """
    doc_ref = db.collection("linked_wallets").document(account_id)
    doc = doc_ref.get()
    if not doc.exists:
        return jsonify({"error": "No wallet linked for this account"}), 404

    data = doc.to_dict()
    return jsonify(data), 200


@app.route("/linked_wallet", methods=["POST"])
def post_linked_wallet():
    """
    Sauvegarde / met à jour un lien wallet dans Firestore :
    {
      "account": "0.0.1234",
      "evm_address": "0xabc...",
      "wallet_type": "hashpack" | "walletconnect" | "unknown"
    }
    """
    data = request.get_json(silent=True) or {}
    account = data.get("account")
    evm_address = data.get("evm_address")
    wallet_type = data.get("wallet_type", "unknown")

    if not account:
        return jsonify({"error": "Missing 'account'"}), 400

    doc_ref = db.collection("linked_wallets").document(account)
    doc_ref.set(
        {
            "account": account,
            "evm_address": evm_address,
            "wallet_type": wallet_type,
        },
        merge=True,
    )

    return jsonify({"status": "ok"}), 201
# ===================================================


@app.route("/")
def index():
    treasury_id = "0.0.10128148"  # NCHAIN treasury account
    return render_template("dashboard.html", treasury_id=treasury_id)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

