from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
from blockchain import Blockchain
import time
import uuid
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Instance de la blockchain
blockchain = Blockchain()

# Adresse pour les récompenses de mining
MINING_ADDRESS = "nutrichain_miner_1"

# ========== PROPOSALS EN MÉMOIRE ==========

proposals = {}  # {id: {...}}

@app.route("/proposals", methods=["POST"])
def create_proposal():
    data = request.get_json() or {}

    title = data.get("title")
    country = data.get("country")
    city = data.get("city")
    meals_target = data.get("meals_target")
    description = data.get("description", "")

    if not title or not country or not city or meals_target is None:
        return jsonify({"error": "title, country, city, meals_target requis"}), 400

    try:
        meals_target = int(meals_target)
    except Exception:
        return jsonify({"error": "meals_target doit être un entier"}), 400

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


# ========== DONATIONS MAP ==========

donations_by_region = {
    "afrique_ouest": 0,
    "afrique_est": 0,
    "moyen_orient": 0,
    "asie_sud": 0,
    "afrique_centrale": 0,
    "afrique_nord": 0
}

@app.route("/donations/map", methods=["GET"])
def donations_map():
    """Retourner les repas financés par grande région pour la carte"""
    return jsonify(donations_by_region)


# ========== HOME / DASHBOARD ==========

@app.route('/')
def index():
    return render_template('dashboard.html')


# ========== BLOCKCHAIN ==========

@app.route('/chain', methods=['GET'])
def get_chain():
    """Récupérer toute la chaîne"""
    return jsonify({
        'chain': blockchain.get_chain_data(),
        'length': len(blockchain.chain)
    })


@app.route('/chain/validate', methods=['GET'])
def validate_chain():
    """Vérifier l'intégrité de la blockchain"""
    is_valid = blockchain.is_chain_valid()
    return jsonify({
        'valid': is_valid,
        'message': 'Blockchain valide' if is_valid else 'Blockchain corrompue'
    })


@app.route('/stats', methods=['GET'])
def get_stats():
    """Statistiques globales pour le dashboard"""
    chain_data = blockchain.get_chain_data()
    total_blocks = len(chain_data)
    total_transactions = sum(len(b.get('transactions', [])) for b in chain_data)
    last_block_hash = chain_data[-1].get('hash') if chain_data else None

    return jsonify({
        'total_blocks': total_blocks,
        'total_transactions': total_transactions,
        'last_block_hash': last_block_hash
    })


# ========== TRANSACTIONS ==========

@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    """Créer une nouvelle transaction (don)"""
    values = request.get_json() or {}

    required = ['sender', 'recipient', 'amount']
    if not all(k in values for k in required):
        return jsonify({'error': 'Champs manquants'}), 400

    try:
        amount = float(values['amount'])
    except Exception:
        return jsonify({'error': 'Montant invalide'}), 400

    index = blockchain.add_transaction(
        values['sender'],
        values['recipient'],
        amount
    )

    return jsonify({
        'message': f'Transaction ajoutée au bloc {index}',
        'transaction': {
            'sender': values['sender'],
            'recipient': amount
        }
    }), 201


# ========== MINING ==========

@app.route('/mine', methods=['POST'])
def mine_block():
    """Miner un nouveau bloc avec récompense de mining"""
    # Récompense du mineur
    blockchain.add_transaction("NETWORK", MINING_ADDRESS, 1)

    block = blockchain.mine_block()

    if not block:
        return jsonify({'error': 'Aucune transaction à miner'}), 400

    return jsonify({
        'message': 'Nouveau bloc miné',
        'index': block.index,
        'hash': block.hash,
        'previous_hash': block.previous_hash,
        'transactions': [tx.to_dict() for tx in block.transactions],
        'timestamp': block.timestamp,
        'nonce': block.nonce
    })


# ========== STAKING NUTRI (local) ==========

staking_pool = {}  # { address: montant_total_staké }


@app.route('/stake', methods=['POST'])
def stake_tokens():
    """Staker des NUTRI sur la blockchain locale"""
    data = request.get_json() or {}
    address = data.get('address')
    amount = data.get('amount')

    if not address or amount is None:
        return jsonify({'error': 'Adresse ou montant manquant'}), 400

    try:
        amount = float(amount)
    except Exception:
        return jsonify({'error': 'Montant invalide'}), 400

    if amount <= 0:
        return jsonify({'error': 'Montant invalide'}), 400

    # Vérifier le solde NUTRI avant de staker
    balance = blockchain.calculate_balance(address)
    if balance < amount:
        return jsonify({
            'error': 'Solde insuffisant pour staker',
            'balance': balance,
            'required': amount
        }), 400

    if address not in staking_pool:
        staking_pool[address] = 0.0

    staking_pool[address] += amount

    return jsonify({
        'message': f'{amount} NUTRI stakés',
        'address': address,
        'total_staked': staking_pool[address],
        'apy': 7.25
    })


@app.route('/stake/<address>', methods=['GET'])
def get_stake(address):
    """Voir le staking d'une adresse"""
    staked = staking_pool.get(address, 0.0)
    estimated_rewards = staked * 0.0725  # 7.25% APY

    return jsonify({
        'address': address,
        'staked': staked,
        'estimated_annual_rewards': estimated_rewards,
        'apy': 7.25
    })


# ========== DON HUMANITAIRE (REGION + PROPOSAL) ==========

@app.route('/donate', methods=['POST'])
def donate():
    """
    Don humanitaire:
    - wallet_address : adresse NutriCoin (obligatoire)
    - donor_label : pseudo optionnel (affiché publiquement si fourni)
    - region : région ciblée (afrique_ouest, asie_sud, ...) ou "auto"
    - proposal_id : optionnel, si le don cible une proposal précise
    - amount : montant du don (float)
    """
    data = request.get_json() or {}

    wallet_address = data.get('wallet_address')
    donor_label = data.get('donor_label')  # purement décoratif / off-chain
    region = data.get('region', 'auto')
    proposal_id = data.get('proposal_id')
    amount = data.get('amount')

    if not wallet_address:
        return jsonify({'error': 'wallet_address requis pour faire un don'}), 400

    if amount is None:
        return jsonify({'error': 'Montant manquant'}), 400

    try:
        amount = float(amount)
    except Exception:
        return jsonify({'error': 'Montant invalide'}), 400

    if amount <= 0:
        return jsonify({'error': 'Montant invalide'}), 400

    valid_regions = list(donations_by_region.keys())

    # 1) Si proposal_id est donné, on essaie de l'utiliser
    target_proposal = None
    if proposal_id:
        target_proposal = proposals.get(proposal_id)
        if not target_proposal:
            return jsonify({'error': 'proposal_id inconnu'}), 400

        if region == 'auto' or region == 'global':
            region = min(valid_regions, key=lambda r: donations_by_region.get(r, 0.0))

    # 2) Sinon, on reste en mode "région"
    if not proposal_id:
        if region == 'auto' or region == 'global':
            region = min(valid_regions, key=lambda r: donations_by_region.get(r, 0.0))
        else:
            if region not in valid_regions:
                return jsonify({'error': 'Région inconnue'}), 400

    # Conversion don -> repas
    meals = amount  # 1 NUTRI = 1 repas

    donations_by_region[region] = donations_by_region.get(region, 0.0) + meals

    # Mettre à jour la proposal si ciblée
    if target_proposal is not None:
        funded = target_proposal.get("meals_funded", 0)
        target_proposal["meals_funded"] = funded + meals

    return jsonify({
        'message': f'Don de {amount} NUTRI reçu pour la région {region}',
        'wallet_address': wallet_address,
        'donor_label': donor_label,
        'region': region,
        'amount': amount,
        'meals_funded': meals,
        'proposal_id': proposal_id,
        'donations_by_region': donations_by_region,
        'proposal': target_proposal
    }), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
