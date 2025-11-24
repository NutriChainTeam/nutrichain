#!/bin/bash

echo "=================================================="
echo "🔧 Restauration du projet NutriChain"
echo "=================================================="
echo ""

PROJECT_DIR="nutrichain_restored"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

echo "✓ Dossier $PROJECT_DIR créé"

cat > blockchain.py << 'EOF'
import hashlib
import json
import time

class Block:
    def __init__(self, index, previous_hash, transactions):
        self.index = index
        self.previous_hash = previous_hash
        self.timestamp = time.time()
        self.transactions = transactions
        self.nonce = 0
        self.hash = self.calculate_hash()
    
    def calculate_hash(self):
        block_string = json.dumps({
            "index": self.index,
            "previous_hash": self.previous_hash,
            "timestamp": self.timestamp,
            "transactions": self.transactions,
            "nonce": self.nonce
        }, sort_keys=True)
        return hashlib.sha256(block_string.encode()).hexdigest()
    
    def mine_block(self, difficulty):
        target = "0" * difficulty
        start_time = time.time()
        while self.hash[:difficulty] != target:
            self.nonce += 1
            self.hash = self.calculate_hash()
        end_time = time.time()
        print(f"Bloc {self.index} miné avec succès !")

class Blockchain:
    def __init__(self):
        self.chain = []
        self.difficulty = 4
        self.pending_transactions = []
        self.create_genesis_block()
    
    def create_genesis_block(self):
        genesis_block = Block(0, "0", [])
        genesis_block.mine_block(self.difficulty)
        self.chain.append(genesis_block)
    
    def get_latest_block(self):
        return self.chain[-1]
    
    def add_transaction(self, sender, recipient, amount):
        self.pending_transactions.append({
            'sender': sender,
            'recipient': recipient,
            'amount': amount,
            'timestamp': time.time()
        })
    
    def mine_block(self):
        if not self.pending_transactions:
            return None
        new_block = Block(len(self.chain), self.get_latest_block().hash, self.pending_transactions)
        new_block.mine_block(self.difficulty)
        self.chain.append(new_block)
        self.pending_transactions = []
        return new_block.__dict__
    
    def calculate_balance(self, address):
        balance = 0
        for block in self.chain:
            for tx in block.transactions:
                if tx['sender'] == address:
                    balance -= tx['amount']
                if tx['recipient'] == address:
                    balance += tx['amount']
        return balance
EOF

echo "✓ blockchain.py créé"

cat > api.py << 'EOF'
from flask import Flask, jsonify, request
from blockchain import Blockchain

app = Flask(__name__)
blockchain = Blockchain()

@app.route('/chain', methods=['GET'])
def get_chain():
    return jsonify({'chain': [b.__dict__ for b in blockchain.chain], 'length': len(blockchain.chain)})

@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    values = request.get_json()
    blockchain.add_transaction(values['sender'], values['recipient'], values['amount'])
    return jsonify({'message': 'Transaction ajoutée'})

@app.route('/mine', methods=['POST'])
def mine():
    block = blockchain.mine_block()
    return jsonify(block)

@app.route('/balance/<address>', methods=['GET'])
def get_balance(address):
    balance = blockchain.calculate_balance(address)
    return jsonify({'address': address, 'balance': balance})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

echo "✓ api.py créé"

cat > requirements.txt << 'EOF'
flask>=2.0.0
pycryptodome>=3.15.0
EOF

echo "✓ requirements.txt créé"

echo ""
echo "=================================================="
echo "✅ Restauration terminée !"
echo "=================================================="
echo ""
echo "Prochaines étapes:"
echo "1. cd $PROJECT_DIR"
echo "2. pip install -r requirements.txt"
echo "3. python api.py"
echo ""
