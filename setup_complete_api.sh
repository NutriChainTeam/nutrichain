#!/bin/bash

echo "=========================================="
echo "🔗 Setup API Complète NutriChain"
echo "=========================================="

# Créer blockchain.py (le cœur du système)
cat > blockchain.py << 'PYEOF'
import hashlib
import json
import time
from typing import List, Dict

class Block:
    def __init__(self, index: int, timestamp: float, transactions: List[Dict], previous_hash: str, nonce: int = 0):
        self.index = index
        self.timestamp = timestamp
        self.transactions = transactions
        self.previous_hash = previous_hash
        self.nonce = nonce
        self.hash = self.calculate_hash()
    
    def calculate_hash(self) -> str:
        block_string = json.dumps({
            "index": self.index,
            "timestamp": self.timestamp,
            "transactions": self.transactions,
            "previous_hash": self.previous_hash,
            "nonce": self.nonce
        }, sort_keys=True)
        return hashlib.sha256(block_string.encode()).hexdigest()
    
    def mine_block(self, difficulty: int):
        target = "0" * difficulty
        while self.hash[:difficulty] != target:
            self.nonce += 1
            self.hash = self.calculate_hash()
        print(f"✅ Bloc miné ! Hash: {self.hash}")
    
    def to_dict(self):
        return {
            "index": self.index,
            "timestamp": self.timestamp,
            "transactions": self.transactions,
            "previous_hash": self.previous_hash,
            "nonce": self.nonce,
            "hash": self.hash
        }

class Blockchain:
    def __init__(self):
        self.chain: List[Block] = []
        self.difficulty = 4
        self.pending_transactions: List[Dict] = []
        self.mining_reward = 10
        self.create_genesis_block()
    
    def create_genesis_block(self):
        genesis_block = Block(0, time.time(), [], "0")
        genesis_block.mine_block(self.difficulty)
        self.chain.append(genesis_block)
    
    def get_latest_block(self) -> Block:
        return self.chain[-1]
    
    def add_transaction(self, sender: str, recipient: str, amount: float):
        transaction = {
            "sender": sender,
            "recipient": recipient,
            "amount": amount,
            "timestamp": time.time()
        }
        self.pending_transactions.append(transaction)
        return len(self.pending_transactions)
    
    def mine_pending_transactions(self, mining_reward_address: str):
        # Créer nouveau bloc avec transactions en attente
        new_block = Block(
            index=len(self.chain),
            timestamp=time.time(),
            transactions=self.pending_transactions,
            previous_hash=self.get_latest_block().hash
        )
        
        # Miner le bloc
        print(f"⛏️  Mining bloc #{new_block.index}...")
        new_block.mine_block(self.difficulty)
        
        # Ajouter à la chaîne
        self.chain.append(new_block)
        
        # Récompense de mining
        self.pending_transactions = [{
            "sender": "SYSTEM",
            "recipient": mining_reward_address,
            "amount": self.mining_reward,
            "timestamp": time.time()
        }]
        
        return new_block
    
    def calculate_balance(self, address: str) -> float:
        balance = 0
        for block in self.chain:
            for tx in block.transactions:
                if tx.get('sender') == address:
                    balance -= tx.get('amount', 0)
                if tx.get('recipient') == address:
                    balance += tx.get('amount', 0)
        return balance
    
    def is_chain_valid(self) -> bool:
        for i in range(1, len(self.chain)):
            current_block = self.chain[i]
            previous_block = self.chain[i - 1]
            
            # Vérifier hash
            if current_block.hash != current_block.calculate_hash():
                return False
            
            # Vérifier lien avec bloc précédent
            if current_block.previous_hash != previous_block.hash:
                return False
        
        return True
    
    def get_chain_data(self):
        return [block.to_dict() for block in self.chain]
PYEOF

# Créer api.py complète
cat > api.py << 'APIEOF'
from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
from blockchain import Blockchain
import time

app = Flask(__name__)
CORS(app)

# Instance de la blockchain
blockchain = Blockchain()

# Adresse pour les récompenses de mining
MINING_ADDRESS = "nutrichain_miner_1"

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

# ========== TRANSACTIONS ==========

@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    """Créer une nouvelle transaction (don)"""
    values = request.get_json()
    
    required = ['sender', 'recipient', 'amount']
    if not all(k in values for k in required):
        return jsonify({'error': 'Champs manquants'}), 400
    
    index = blockchain.add_transaction(
        values['sender'],
        values['recipient'],
        float(values['amount'])
    )
    
    return jsonify({
        'message': f'Transaction ajoutée au bloc {index}',
        'transaction': {
            'sender': values['sender'],
            'recipient': values['recipient'],
            'amount': values['amount']
        }
    }), 201

@app.route('/transactions/pending', methods=['GET'])
def get_pending_transactions():
    """Récupérer les transactions en attente"""
    return jsonify({
        'transactions': blockchain.pending_transactions,
        'count': len(blockchain.pending_transactions)
    })

# ========== MINING ==========

@app.route('/mine', methods=['POST'])
def mine():
    """Miner un nouveau bloc"""
    # Obtenir l'adresse du mineur (optionnel)
    data = request.get_json() or {}
    miner_address = data.get('miner_address', MINING_ADDRESS)
    
    # Miner le bloc
    start_time = time.time()
    new_block = blockchain.mine_pending_transactions(miner_address)
    mining_time = time.time() - start_time
    
    return jsonify({
        'message': 'Bloc miné avec succès',
        'block': new_block.to_dict(),
        'mining_time': f"{mining_time:.2f}s",
        'reward': blockchain.mining_reward,
        'miner': miner_address
    }), 200

# ========== WALLET / BALANCE ==========

@app.route('/balance/<address>', methods=['GET'])
def get_balance(address):
    """Obtenir le solde d'une adresse"""
    balance = blockchain.calculate_balance(address)
    return jsonify({
        'address': address,
        'balance': balance,
        'unit': 'NUTRI'
    })

# ========== STATS ==========

@app.route('/stats', methods=['GET'])
def get_stats():
    """Statistiques globales"""
    total_blocks = len(blockchain.chain)
    total_transactions = sum(len(block.transactions) for block in blockchain.chain)
    pending_tx = len(blockchain.pending_transactions)
    
    return jsonify({
        'total_blocks': total_blocks,
        'total_transactions': total_transactions,
        'pending_transactions': pending_tx,
        'difficulty': blockchain.difficulty,
        'mining_reward': blockchain.mining_reward,
        'last_block_hash': blockchain.get_latest_block().hash
    })

# ========== DONATIONS (spécifique humanitaire) ==========

@app.route('/donate', methods=['POST'])
def donate():
    """Faire un don (alias de transaction)"""
    values = request.get_json()
    
    donor = values.get('donor', 'anonymous')
    region = values.get('region', 'global')
    amount = float(values.get('amount', 0))
    
    if amount <= 0:
        return jsonify({'error': 'Montant invalide'}), 400
    
    # Créer la transaction
    blockchain.add_transaction(
        sender=donor,
        recipient=f"food_program_{region}",
        amount=amount
    )
    
    return jsonify({
        'message': f'{amount} NUTRI donnés = {amount} repas',
        'donor': donor,
        'region': region,
        'meals': amount
    }), 201

# ========== STAKING ==========

staking_pool = {}

@app.route('/stake', methods=['POST'])
def stake():
    """Staker des tokens"""
    values = request.get_json()
    address = values.get('address')
    amount = float(values.get('amount', 0))
    
    if address not in staking_pool:
        staking_pool[address] = 0
    
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
    staked = staking_pool.get(address, 0)
    estimated_rewards = staked * 0.0725  # 7.25% APY
    
    return jsonify({
        'address': address,
        'staked': staked,
        'estimated_annual_rewards': estimated_rewards,
        'apy': 7.25
    })

if __name__ == '__main__':
    print("\n" + "="*50)
    print("🍽️  NutriChain - Blockchain Humanitaire")
    print("="*50)
    print(f"📧 Contact: contact@nutrichain.org")
    print(f"🌐 Dashboard: http://localhost:5000")
    print(f"📊 API: http://localhost:5000/chain")
    print(f"⛏️  Mining: POST http://localhost:5000/mine")
    print("="*50 + "\n")
    
    app.run(host='0.0.0.0', port=5000, debug=True)
APIEOF

# Créer requirements.txt
cat > requirements.txt << 'REQEOF'
Flask==3.0.0
Flask-Cors==4.0.0
REQEOF

echo ""
echo "✅ API Complète créée !"
echo ""
echo "📦 Fichiers créés:"
echo "   • blockchain.py (logique blockchain + mining)"
echo "   • api.py (API Flask complète)"
echo "   • requirements.txt"
echo ""
echo "🚀 Installation:"
echo "   pip install -r requirements.txt"
echo "   python api.py"
echo ""
echo "📍 Endpoints disponibles:"
echo "   GET  /chain              - Voir la blockchain"
echo "   POST /mine               - Miner un bloc"
echo "   POST /transactions/new   - Créer transaction"
echo "   POST /donate             - Faire un don"
echo "   GET  /balance/<address>  - Voir solde"
echo "   POST /stake              - Staker tokens"
echo "   GET  /stats              - Statistiques"
echo ""
