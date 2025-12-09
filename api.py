import os
import requests
from flask import Flask, jsonify, request, render_template
from flask_cors import CORS

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

app = Flask(__name__)

# --- Hedera / Mirror constants ---
MIRROR_BASE = "https://mainnet-public.mirrornode.hedera.com"
NCHAIN_TOKEN_ID_STR = "0.0.10136204"   # pour Mirror Node (toujours une chaîne)
# ---------------------------------

proposals_db = []
votes_db = []


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


@app.route("/proposals", methods=["GET", "POST"])
def proposals():
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


@app.route("/api/donate", methods=["POST"])
def api_donate():
    data = request.get_json()
    # Later: persist to DB or file
    app.logger.info(f"New donation: {data}")
    return jsonify({"status": "ok"}), 200


# simple in‑memory registry: { "0.0.x": "0x..." }
linked_wallets = {}

# ========== HEDERA CONFIG ==========
HEDERA_NETWORK = "testnet"  # testnet for dev

# Objet TokenId pour les transferts on‑chain uniquement
if hedera_available:
    NCHAIN_TOKEN_ID = TokenId.fromString(NCHAIN_TOKEN_ID_STR)

    if HEDERA_NETWORK == "testnet":
        hedera_client = Client.forTestnet()
    else:
        hedera_client = Client.forMainnet()
else:
    NCHAIN_TOKEN_ID = None
    hedera_client = None
# ===================================

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


# --- On‑chain NCHAIN transfer ---
def send_nchain(to_account: str, amount_tokens: float) -> str:
    if not hedera_available or NCHAIN_TOKEN_ID is None or hedera_client is None:
        # On Render (no SDK/Java), simulate success
        return "SIMULATED_ON_RENDER"

    tokens_smallest = int(amount_tokens * 1_000_000)  # 6 decimals
    tx = TransferTransaction(
        token_transfers={
            str(NCHAIN_TOKEN_ID): {
                str(OPERATOR_ID): -tokens_smallest,
                to_account: tokens_smallest,
            }
        }
    )
    tx.freezeWith(hedera_client)
    tx.sign(OPERATOR_KEY)
    tx_response = tx.execute(hedera_client)
    receipt = tx_response.getReceipt(hedera_client)
    return str(receipt.status)
# ---------------------------------


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


@app.route("/proposals", methods=["GET"])
def list_proposals():
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


@app.route("/link_wallet", methods=["POST"])
def link_wallet():
    data = request.get_json(force=True) or {}

    account = data.get("account")          # e.g.: 0.0.123456 (Hedera)
    evm_address = data.get("evm_address")  # e.g.: 0xABC... (EVM on Hedera)

    if not account and not evm_address:
        return jsonify({"error": "No wallet identifier provided"}), 400

    if account:
        linked_wallets[account] = evm_address

    return jsonify(
        {
            "message": "Wallet linked to NutriChain",
            "account": account,
            "evm_address": evm_address,
        }
    ), 200


@app.route("/linked_wallet/<account_id>", methods=["GET"])
def linked_wallet(account_id):
    evm_address = linked_wallets.get(account_id)
    if not evm_address:
        return jsonify({"error": "No wallet linked for this account"}), 404

    return jsonify(
        {
            "account": account_id,
            "evm_address": evm_address,
        }
    ), 200


@app.route("/")
def index():
    treasury_id = "0.0.10128148"  # NCHAIN treasury account
    return render_template("dashboard.html", treasury_id=treasury_id)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

