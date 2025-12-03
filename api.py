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
    print("Hedera SDK non disponible sur ce runtime:", e)

app = Flask(__name__)

CORS(app, resources={r"/*": {"origins": "*"}})


# ========== CONFIG HEDERA ==========
HEDERA_NETWORK = "testnet"  # testnet pour dev

if hedera_available:
    # ID du token NCHAIN sur le réseau choisi (à adapter si besoin)
    NCHAIN_TOKEN_ID = TokenId.fromString("0.0.10136204")

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
    "Dakar": 0,  # pour accepter Dakar
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

# --- Envoi on-chain des NCHAIN ---
def send_nchain(to_account: str, amount_tokens: float) -> str:
    if not hedera_available or NCHAIN_TOKEN_ID is None or hedera_client is None:
        # Sur Render (sans SDK/Java), on simule un succès
        return "SIMULATED_ON_RENDER"

    tokens_smallest = int(amount_tokens * 1_000_000)  # 6 décimales
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
    donor_label = data.get("donor_label", "Anonyme")
    region = data.get("region")
    amount = data.get("amount")
    hedera_account = data.get("hedera_account")

    if not wallet_address:
        return jsonify({"error": "wallet_address manquant"}), 400

    if region not in donations_by_region:
        return jsonify({"error": "Région inconnue"}), 400

    if not isinstance(amount, (int, float)) or amount <= 0:
        return jsonify({"error": "Montant invalide"}), 400

    if not hedera_account:
        return jsonify(
            {"error": "Compte Hedera manquant (hedera_account)"}
        ), 400

    # 1 NUTRI = 1 repas (exemple)
    meals = int(amount)

    # Mise à jour des stats régionales
    donations_by_region[region] += amount

    # Ciblage d'une proposition sur cette région
    target_proposal = next(
        (p for p in proposals if p["region"] == region), None
    )
    proposal_id = target_proposal["id"] if target_proposal else None

    if target_proposal is not None:
        funded = target_proposal.get("meals_funded", 0)
        target_proposal["meals_funded"] = funded + meals

    # Envoi on-chain des NCHAIN
    try:
        tx_status = send_nchain(hedera_account, amount)
    except Exception as e:
        return jsonify(
            {"error": "Échec du transfert NCHAIN", "details": str(e)}
        ), 502

    return jsonify(
        {
            "message": f"Don de {amount} NUTRI reçu pour la région {region}",
            "wallet_address": wallet_address,
            "donor_label": donor_label,
            "region": region,
            "amount": amount,
            "meals_funded": meals,
            "proposal_id": proposal_id,
            "donations_by_region": donations_by_region,
            "proposal": target_proposal,
            "hedera_account": hedera_account,
            "nchain_token_id": str(NCHAIN_TOKEN_ID) if NCHAIN_TOKEN_ID else None,
            "nchain_tx_status": str(tx_status),
        }
    ), 201


MIRROR_BASE = "https://mainnet-public.mirrornode.hedera.com"


def get_nchain_balance(account_id: str) -> float:
    """
    Retourne le solde NCHAIN (en unités lisibles) pour un compte Hedera donné.
    """
    url = f"{MIRROR_BASE}/api/v1/tokens/0.0.10136204/balances"
    params = {"account.id": account_id}
    r = requests.get(url, params=params, timeout=10)
    r.raise_for_status()
    data = r.json()
    balances = data.get("balances", [])
    if not balances:
        return 0.0

    raw = balances[0].get("balance", 0)
    # NCHAIN a 6 décimales
    return raw / 1_000_000.0


@app.route("/nchain_balance/<account_id>")
def nchain_balance(account_id):
    try:
        balance = get_nchain_balance(account_id)
    except Exception as e:
        return jsonify({"error": "Mirror node error", "details": str(e)}), 502

    return jsonify(
        {
            "account_id": account_id,
            "token_id": "0.0.10136204",
            "symbol": "NCHAIN",
            "balance": balance,
        }
    )

# ... imports, config Hedera, send_nchain, etc.

@app.route("/link_wallet", methods=["POST"])
def link_wallet():
    """
    Lie un wallet (Hedera ou EVM) au profil NutriChain.
    Pour l'instant, on se contente de renvoyer ce qui est reçu.
    """
    data = request.get_json(force=True) or {}

    account = data.get("account")          # ex: 0.0.123456 (Hedera)
    evm_address = data.get("evm_address")  # ex: 0xABC... (EVM sur Hedera)

    if not account and not evm_address:
        return jsonify({"error": "Aucun identifiant de wallet fourni"}), 400

    # Ici plus tard : sauvegarde en base / Firestore, etc.
    # Pour l'instant on renvoie juste ce qui est reçu.
    return jsonify(
        {
            "message": "Wallet lié à NutriChain (simulation)",
            "account": account,
            "evm_address": evm_address,
        }
    ), 200


@app.route("/")
def index():
    return render_template("dashboard.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
