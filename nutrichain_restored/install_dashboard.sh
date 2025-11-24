#!/bin/bash

echo "=================================================="
echo "🎨 Installation du Dashboard NutriChain"
echo "=================================================="
echo ""

mkdir -p templates
mkdir -p static

cat > templates/dashboard.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NutriChain | Dashboard Blockchain</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #0d1117; color: #e5e7eb; }
        .card { background-color: #161b22; border: 1px solid #30363d; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3); border-radius: 12px; padding: 20px; }
        .btn-primary { background: linear-gradient(135deg, #38bdf8 0%, #0ea5e9 100%); color: white; font-weight: bold; padding: 12px 24px; border-radius: 8px; transition: all 0.3s; cursor: pointer; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(56, 189, 248, 0.3); }
        .btn-secondary { background-color: #facc15; color: #0d1117; font-weight: bold; padding: 12px 24px; border-radius: 8px; transition: all 0.3s; cursor: pointer; }
        .stat-card { background: linear-gradient(135deg, #1f2937 0%, #111827 100%); border: 1px solid #374151; border-radius: 12px; padding: 20px; }
        .block-item { background-color: #1f2937; border-left: 4px solid #38bdf8; padding: 16px; margin-bottom: 12px; border-radius: 8px; }
        .tx-item { background-color: #1f2937; border-left: 4px solid #facc15; padding: 12px; margin-bottom: 8px; border-radius: 6px; }
        input { background-color: #1f2937; border: 1px solid #374151; color: #e5e7eb; padding: 10px; border-radius: 6px; width: 100%; }
        input:focus { outline: none; border-color: #38bdf8; }
        .tab-button { padding: 12px 24px; background-color: #1f2937; border: 1px solid #374151; border-radius: 8px 8px 0 0; cursor: pointer; transition: all 0.3s; }
        .tab-button.active { background-color: #161b22; border-bottom: 2px solid #38bdf8; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.8); z-index: 1000; justify-content: center; align-items: center; }
        .modal.show { display: flex; }
        .modal-content { background-color: #161b22; border: 1px solid #30363d; border-radius: 12px; padding: 30px; max-width: 500px; width: 90%; }
    </style>
</head>
<body class="p-4 md:p-8">
    <header class="mb-8 flex flex-col md:flex-row justify-between items-center border-b border-[#30363d] pb-6">
        <h1 class="text-4xl font-extrabold text-white tracking-tight mb-4 md:mb-0">
            🔗 NutriChain <span class="text-sm text-gray-500 font-normal">| Dashboard Blockchain</span>
        </h1>
        <div class="flex space-x-4">
            <button id="createWalletBtn" class="btn-secondary">
                <i data-lucide="wallet" class="w-5 h-5 inline mr-2"></i>Créer Wallet
            </button>
            <button id="refreshBtn" class="btn-primary">
                <i data-lucide="refresh-cw" class="w-5 h-5 inline mr-2"></i>Actualiser
            </button>
        </div>
    </header>
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="stat-card">
            <div class="text-gray-400 text-sm mb-2">Blocs Minés</div>
            <div class="text-3xl font-bold text-white" id="totalBlocks">0</div>
        </div>
        <div class="stat-card">
            <div class="text-gray-400 text-sm mb-2">Transactions</div>
            <div class="text-3xl font-bold text-white" id="totalTx">0</div>
        </div>
        <div class="stat-card">
            <div class="text-gray-400 text-sm mb-2">Difficulté</div>
            <div class="text-3xl font-bold text-white" id="difficulty">4</div>
        </div>
        <div class="stat-card">
            <div class="text-gray-400 text-sm mb-2">Dernier Hash</div>
            <div class="text-sm font-mono text-cyan-400" id="lastHash">0x0000...</div>
        </div>
    </div>
    <div class="flex space-x-2 mb-6">
        <button class="tab-button active" onclick="switchTab('blockchain')">
            <i data-lucide="blocks" class="w-4 h-4 inline mr-2"></i>Blockchain
        </button>
        <button class="tab-button" onclick="switchTab('transactions')">
            <i data-lucide="send" class="w-4 h-4 inline mr-2"></i>Transactions
        </button>
        <button class="tab-button" onclick="switchTab('private')">
            <i data-lucide="shield" class="w-4 h-4 inline mr-2"></i>Privé
        </button>
        <button class="tab-button" onclick="switchTab('mining')">
            <i data-lucide="pickaxe" class="w-4 h-4 inline mr-2"></i>Mining
        </button>
    </div>
    <div id="blockchainTab" class="tab-content">
        <div class="card">
            <h2 class="text-2xl font-bold text-white mb-4">📦 Chaîne de Blocs</h2>
            <div id="blockchainContainer"></div>
        </div>
    </div>
    <div id="transactionsTab" class="tab-content" style="display:none;">
        <div class="card">
            <h2 class="text-2xl font-bold text-white mb-4">💸 Créer une Transaction</h2>
            <form id="txForm" class="space-y-4">
                <div>
                    <label class="block text-gray-400 mb-2">Expéditeur</label>
                    <input type="text" id="txSender" placeholder="Adresse de l'expéditeur" required>
                </div>
                <div>
                    <label class="block text-gray-400 mb-2">Destinataire</label>
                    <input type="text" id="txRecipient" placeholder="Adresse du destinataire" required>
                </div>
                <div>
                    <label class="block text-gray-400 mb-2">Montant (NUTRI)</label>
                    <input type="number" id="txAmount" placeholder="0.00" min="0" step="0.01" required>
                </div>
                <button type="submit" class="btn-primary w-full">
                    <i data-lucide="send" class="w-5 h-5 inline mr-2"></i>Envoyer Transaction
                </button>
            </form>
        </div>
    </div>
    <div id="privateTab" class="tab-content" style="display:none;">
        <div class="card">
            <h2 class="text-2xl font-bold text-white mb-4">🔒 Transactions Privées</h2>
            <div class="bg-yellow-900/20 border border-yellow-700 rounded-lg p-4 mb-4">
                <p class="text-yellow-200">
                    <i data-lucide="info" class="w-4 h-4 inline mr-2"></i>
                    Les transactions privées utilisent des <strong>Ring Signatures</strong> et <strong>Stealth Addresses</strong>.
                </p>
            </div>
            <button id="testPrivateTxBtn" class="btn-secondary w-full">
                <i data-lucide="shield" class="w-5 h-5 inline mr-2"></i>Créer Transaction Privée (Test)
            </button>
            <div id="privateTxResult" class="mt-4"></div>
        </div>
    </div>
    <div id="miningTab" class="tab-content" style="display:none;">
        <div class="card">
            <h2 class="text-2xl font-bold text-white mb-4">⛏️ Mining</h2>
            <div class="mb-6">
                <p class="text-gray-400 mb-4">Cliquez pour miner un nouveau bloc</p>
                <button id="mineBtn" class="btn-primary w-full text-lg">
                    <i data-lucide="pickaxe" class="w-6 h-6 inline mr-2"></i>Miner un Bloc
                </button>
            </div>
            <div id="miningResult" class="mt-6"></div>
        </div>
    </div>
    <div id="walletModal" class="modal">
        <div class="modal-content">
            <h2 class="text-2xl font-bold text-white mb-4">Créer un Wallet</h2>
            <div id="walletInfo" class="space-y-4"></div>
            <button onclick="closeModal()" class="btn-primary w-full mt-4">Fermer</button>
        </div>
    </div>
    <script>
        const API_URL = 'http://localhost:5000';
        function switchTab(tab) {
            document.querySelectorAll('.tab-content').forEach(el => el.style.display = 'none');
            document.querySelectorAll('.tab-button').forEach(el => el.classList.remove('active'));
            document.getElementById(tab + 'Tab').style.display = 'block';
            event.target.closest('.tab-button').classList.add('active');
        }
        async function loadBlockchain() {
            try {
                const response = await fetch(API_URL + '/chain');
                const data = await response.json();
                document.getElementById('totalBlocks').textContent = data.length;
                document.getElementById('lastHash').textContent = data.chain[data.chain.length - 1].hash.substring(0, 12) + '...';
                let totalTx = 0;
                data.chain.forEach(block => totalTx += block.transactions.length);
                document.getElementById('totalTx').textContent = totalTx;
                displayBlocks(data.chain);
            } catch (error) {
                console.error('Erreur:', error);
            }
        }
        function displayBlocks(blocks) {
            const container = document.getElementById('blockchainContainer');
            container.innerHTML = '';
            blocks.reverse().forEach(block => {
                const blockDiv = document.createElement('div');
                blockDiv.className = 'block-item';
                blockDiv.innerHTML = '<div class="flex justify-between items-start mb-2"><div class="font-bold text-white text-lg">Bloc #' + block.index + '</div><div class="text-sm text-gray-400">' + new Date(block.timestamp * 1000).toLocaleString('fr-FR') + '</div></div><div class="text-sm text-gray-400 mb-2"><strong>Hash:</strong> <span class="font-mono text-cyan-400">' + block.hash.substring(0, 40) + '...</span></div><div class="text-sm text-gray-400 mb-2"><strong>Nonce:</strong> ' + block.nonce + '</div><div class="text-sm text-gray-400"><strong>Transactions:</strong> ' + block.transactions.length + (block.transactions.length > 0 ? '<div class="mt-2 space-y-1">' + block.transactions.map(tx => '<div class="tx-item text-xs">' + tx.sender + ' → ' + tx.recipient + ' : <strong>' + tx.amount + ' NUTRI</strong></div>').join('') + '</div>' : '') + '</div>';
                container.appendChild(blockDiv);
            });
        }
        document.getElementById('txForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const txData = { sender: document.getElementById('txSender').value, recipient: document.getElementById('txRecipient').value, amount: parseFloat(document.getElementById('txAmount').value) };
            try {
                await fetch(API_URL + '/transactions/new', { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(txData) });
                alert('✅ Transaction ajoutée !');
                e.target.reset();
            } catch (error) {
                alert('❌ Erreur: ' + error.message);
            }
        });
        document.getElementById('mineBtn').addEventListener('click', async () => {
            const btn = document.getElementById('mineBtn');
            btn.disabled = true;
            btn.innerHTML = '<i data-lucide="loader" class="w-6 h-6 inline mr-2 animate-spin"></i> Mining...';
            try {
                const response = await fetch(API_URL + '/mine', {method: 'POST'});
                const block = await response.json();
                document.getElementById('miningResult').innerHTML = '<div class="bg-green-900/20 border border-green-700 rounded-lg p-4"><p class="text-green-200 font-bold mb-2">✅ Bloc #' + block.index + ' miné !</p><p class="text-sm text-gray-400">Hash: ' + block.hash.substring(0, 40) + '...</p></div>';
                loadBlockchain();
            } catch (error) {
                alert('❌ Erreur: ' + error.message);
            } finally {
                btn.disabled = false;
                btn.innerHTML = '<i data-lucide="pickaxe" class="w-6 h-6 inline mr-2"></i> Miner un Bloc';
                lucide.createIcons();
            }
        });
        document.getElementById('testPrivateTxBtn').addEventListener('click', () => {
            document.getElementById('privateTxResult').innerHTML = '<div class="bg-blue-900/20 border border-blue-700 rounded-lg p-4 mt-4"><p class="text-blue-200 font-bold mb-2">🔒 Transaction privée créée</p><p class="text-sm text-gray-400 mb-1"><strong>Adresse furtive:</strong> <span class="font-mono">85de6d62221e214f2975c50b5bf6399a53fc42ea</span></p><p class="text-sm text-gray-400"><strong>Taille de l\'anneau:</strong> 5 participants</p></div>';
        });
        document.getElementById('createWalletBtn').addEventListener('click', () => {
            const privateKey = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
            const address = 'nutri_' + Math.random().toString(36).substring(2, 15);
            document.getElementById('walletInfo').innerHTML = '<div class="bg-yellow-900/20 border border-yellow-700 rounded-lg p-4"><p class="text-yellow-200 text-sm mb-2">⚠️ Sauvegardez ces informations !</p></div><div><label class="block text-gray-400 mb-2">Adresse</label><input type="text" value="' + address + '" readonly class="font-mono"></div><div><label class="block text-gray-400 mb-2">Clé Privée</label><input type="text" value="' + privateKey + '" readonly class="font-mono"></div>';
            document.getElementById('walletModal').classList.add('show');
        });
        function closeModal() {
            document.getElementById('walletModal').classList.remove('show');
        }
        document.getElementById('refreshBtn').addEventListener('click', loadBlockchain);
        loadBlockchain();
        setInterval(loadBlockchain, 10000);
        lucide.createIcons();
    </script>
</body>
</html>
HTMLEOF

echo "✓ Dashboard HTML créé"

cat > api.py << 'EOF'
from flask import Flask, jsonify, request, render_template
from blockchain import Blockchain

app = Flask(__name__)
blockchain = Blockchain()

@app.route('/')
def index():
    return render_template('dashboard.html')

@app.route('/chain', methods=['GET'])
def get_chain():
    return jsonify({'chain': [block.__dict__ for block in blockchain.chain], 'length': len(blockchain.chain)})

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

echo "✓ API mise à jour"
echo ""
echo "✅ Dashboard installé avec succès !"
echo ""
echo "Pour lancer: python api.py"
echo "Puis ouvrez: http://localhost:5000"
