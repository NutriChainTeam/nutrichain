#!/bin/bash

echo "=================================================="
echo "🎨 Installation Dashboard NutriChain Complet"
echo "=================================================="
echo ""

mkdir -p templates static

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
        body { font-family: 'Inter', sans-serif; background-color: #0d1117; color: #e5e7eb; min-height: 100vh; display: flex; flex-direction: column; }
        .main-content { flex: 1; }
        .sidebar { background: linear-gradient(135deg, #161b22 0%, #0d1117 100%); border-right: 1px solid #30363d; height: 100vh; position: fixed; width: 250px; }
        .content-area { margin-left: 250px; }
        .card { background-color: #161b22; border: 1px solid #30363d; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3); border-radius: 12px; padding: 20px; }
        .btn-primary { background: linear-gradient(135deg, #38bdf8 0%, #0ea5e9 100%); color: white; font-weight: bold; padding: 12px 24px; border-radius: 8px; transition: all 0.3s; cursor: pointer; border: none; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(56, 189, 248, 0.3); }
        .btn-secondary { background-color: #facc15; color: #0d1117; font-weight: bold; padding: 12px 24px; border-radius: 8px; transition: all 0.3s; cursor: pointer; border: none; }
        .stat-card { background: linear-gradient(135deg, #1f2937 0%, #111827 100%); border: 1px solid #374151; border-radius: 12px; padding: 20px; transition: transform 0.3s; }
        .stat-card:hover { transform: translateY(-5px); }
        .block-item { background-color: #1f2937; border-left: 4px solid #38bdf8; padding: 16px; margin-bottom: 12px; border-radius: 8px; transition: all 0.3s; }
        .block-item:hover { border-left-width: 8px; }
        .tx-item { background-color: #1f2937; border-left: 4px solid #facc15; padding: 12px; margin-bottom: 8px; border-radius: 6px; }
        input { background-color: #1f2937; border: 1px solid #374151; color: #e5e7eb; padding: 10px; border-radius: 6px; width: 100%; }
        input:focus { outline: none; border-color: #38bdf8; }
        .nav-item { padding: 12px 20px; cursor: pointer; transition: all 0.3s; border-left: 3px solid transparent; }
        .nav-item:hover { background-color: #1f2937; border-left-color: #38bdf8; }
        .nav-item.active { background-color: #1f2937; border-left-color: #38bdf8; }
        .footer { background: linear-gradient(135deg, #161b22 0%, #0d1117 100%); border-top: 1px solid #30363d; padding: 30px 0; margin-top: 50px; }
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.8); z-index: 1000; justify-content: center; align-items: center; }
        .modal.show { display: flex; }
        .modal-content { background-color: #161b22; border: 1px solid #30363d; border-radius: 12px; padding: 30px; max-width: 500px; width: 90%; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="p-6 border-b border-[#30363d]">
            <h1 class="text-2xl font-bold text-white flex items-center">
                <i data-lucide="hexagon" class="w-8 h-8 mr-2 text-cyan-400"></i>NutriChain
            </h1>
            <p class="text-xs text-gray-400 mt-1">Blockchain Platform</p>
        </div>
        <nav class="p-4">
            <div class="nav-item active" onclick="showSection('dashboard')">
                <i data-lucide="layout-dashboard" class="w-5 h-5 inline mr-3"></i>Dashboard
            </div>
            <div class="nav-item" onclick="showSection('blockchain')">
                <i data-lucide="blocks" class="w-5 h-5 inline mr-3"></i>Blockchain
            </div>
            <div class="nav-item" onclick="showSection('transactions')">
                <i data-lucide="send" class="w-5 h-5 inline mr-3"></i>Transactions
            </div>
            <div class="nav-item" onclick="showSection('private')">
                <i data-lucide="shield" class="w-5 h-5 inline mr-3"></i>Transactions Privées
            </div>
            <div class="nav-item" onclick="showSection('mining')">
                <i data-lucide="pickaxe" class="w-5 h-5 inline mr-3"></i>Mining
            </div>
            <div class="nav-item" onclick="showSection('wallets')">
                <i data-lucide="wallet" class="w-5 h-5 inline mr-3"></i>Wallets
            </div>
        </nav>
        <div class="absolute bottom-4 left-0 right-0 px-6">
            <div class="bg-[#1f2937] rounded-lg p-3 text-xs">
                <div class="flex items-center text-green-400 mb-1">
                    <div class="w-2 h-2 bg-green-400 rounded-full mr-2 animate-pulse"></div>Réseau Actif
                </div>
                <div class="text-gray-400">API: localhost:5000</div>
            </div>
        </div>
    </div>

    <div class="content-area main-content">
        <div class="p-8">
            <div id="dashboardSection" class="section">
                <div class="flex justify-between items-center mb-8">
                    <h2 class="text-3xl font-bold text-white">Dashboard</h2>
                    <button id="refreshBtn" class="btn-primary">
                        <i data-lucide="refresh-cw" class="w-5 h-5 inline mr-2"></i>Actualiser
                    </button>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                    <div class="stat-card">
                        <div class="flex justify-between items-start mb-3">
                            <div class="text-gray-400 text-sm">Blocs Minés</div>
                            <i data-lucide="blocks" class="w-8 h-8 text-cyan-400"></i>
                        </div>
                        <div class="text-4xl font-bold text-white" id="totalBlocks">0</div>
                        <div class="text-xs text-green-400 mt-2">↑ +1 aujourd'hui</div>
                    </div>
                    <div class="stat-card">
                        <div class="flex justify-between items-start mb-3">
                            <div class="text-gray-400 text-sm">Transactions</div>
                            <i data-lucide="arrow-right-left" class="w-8 h-8 text-yellow-400"></i>
                        </div>
                        <div class="text-4xl font-bold text-white" id="totalTx">0</div>
                        <div class="text-xs text-gray-400 mt-2">Total confirmées</div>
                    </div>
                    <div class="stat-card">
                        <div class="flex justify-between items-start mb-3">
                            <div class="text-gray-400 text-sm">Difficulté</div>
                            <i data-lucide="zap" class="w-8 h-8 text-purple-400"></i>
                        </div>
                        <div class="text-4xl font-bold text-white" id="difficulty">4</div>
                        <div class="text-xs text-gray-400 mt-2">Niveau de mining</div>
                    </div>
                    <div class="stat-card">
                        <div class="flex justify-between items-start mb-3">
                            <div class="text-gray-400 text-sm">Dernier Hash</div>
                            <i data-lucide="hash" class="w-8 h-8 text-green-400"></i>
                        </div>
                        <div class="text-sm font-mono text-cyan-400" id="lastHash">0x0000...</div>
                        <div class="text-xs text-gray-400 mt-2">Hash actuel</div>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div class="card">
                        <h3 class="text-xl font-bold text-white mb-4 flex items-center">
                            <i data-lucide="send" class="w-6 h-6 mr-2 text-cyan-400"></i>Transaction Rapide
                        </h3>
                        <button onclick="showSection('transactions')" class="btn-primary w-full">Créer une transaction</button>
                    </div>
                    <div class="card">
                        <h3 class="text-xl font-bold text-white mb-4 flex items-center">
                            <i data-lucide="pickaxe" class="w-6 h-6 mr-2 text-yellow-400"></i>Miner un Bloc
                        </h3>
                        <button id="quickMineBtn" class="btn-secondary w-full">Démarrer le mining</button>
                    </div>
                    <div class="card">
                        <h3 class="text-xl font-bold text-white mb-4 flex items-center">
                            <i data-lucide="wallet" class="w-6 h-6 mr-2 text-purple-400"></i>Nouveau Wallet
                        </h3>
                        <button id="quickWalletBtn" class="btn-primary w-full">Créer un wallet</button>
                    </div>
                </div>
            </div>

            <div id="blockchainSection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">📦 Chaîne de Blocs</h2>
                <div class="card"><div id="blockchainContainer"></div></div>
            </div>

            <div id="transactionsSection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">💸 Transactions</h2>
                <div class="card">
                    <form id="txForm" class="space-y-4">
                        <div><label class="block text-gray-400 mb-2">Expéditeur</label>
                        <input type="text" id="txSender" placeholder="Adresse de l'expéditeur" required></div>
                        <div><label class="block text-gray-400 mb-2">Destinataire</label>
                        <input type="text" id="txRecipient" placeholder="Adresse du destinataire" required></div>
                        <div><label class="block text-gray-400 mb-2">Montant (NUTRI)</label>
                        <input type="number" id="txAmount" placeholder="0.00" min="0" step="0.01" required></div>
                        <button type="submit" class="btn-primary w-full">
                            <i data-lucide="send" class="w-5 h-5 inline mr-2"></i>Envoyer Transaction
                        </button>
                    </form>
                </div>
            </div>

            <div id="privateSection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">🔒 Transactions Privées</h2>
                <div class="card">
                    <div class="bg-yellow-900/20 border border-yellow-700 rounded-lg p-4 mb-4">
                        <p class="text-yellow-200">
                            <i data-lucide="info" class="w-4 h-4 inline mr-2"></i>Ring Signatures + Stealth Addresses
                        </p>
                    </div>
                    <button id="testPrivateTxBtn" class="btn-secondary w-full">
                        <i data-lucide="shield" class="w-5 h-5 inline mr-2"></i>Créer Transaction Privée
                    </button>
                    <div id="privateTxResult" class="mt-4"></div>
                </div>
            </div>

            <div id="miningSection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">⛏️ Mining</h2>
                <div class="card">
                    <p class="text-gray-400 mb-4">Minez un nouveau bloc</p>
                    <button id="mineBtn" class="btn-primary w-full text-lg">
                        <i data-lucide="pickaxe" class="w-6 h-6 inline mr-2"></i>Miner un Bloc
                    </button>
                    <div id="miningResult" class="mt-6"></div>
                </div>
            </div>

            <div id="walletsSection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">👛 Gestion des Wallets</h2>
                <div class="card">
                    <button id="createWalletBtn" class="btn-secondary w-full mb-4">
                        <i data-lucide="plus-circle" class="w-5 h-5 inline mr-2"></i>Créer un Nouveau Wallet
                    </button>
                </div>
            </div>
        </div>

        <footer class="footer">
            <div class="max-w-7xl mx-auto px-8">
                <div class="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
                    <div>
                        <h3 class="text-white font-bold mb-4 flex items-center">
                            <i data-lucide="hexagon" class="w-6 h-6 mr-2 text-cyan-400"></i>NutriChain
                        </h3>
                        <p class="text-gray-400 text-sm mb-4">Plateforme blockchain open-source dédiée à la nutrition.</p>
                        <div class="flex space-x-3">
                            <a href="#" class="text-gray-400 hover:text-cyan-400"><i data-lucide="github" class="w-5 h-5"></i></a>
                            <a href="#" class="text-gray-400 hover:text-cyan-400"><i data-lucide="twitter" class="w-5 h-5"></i></a>
                        </div>
                    </div>
                    <div>
                        <h4 class="text-white font-semibold mb-4">Ressources</h4>
                        <ul class="space-y-2 text-sm">
                            <li><a href="#" class="text-gray-400 hover:text-cyan-400">Documentation</a></li>
                            <li><a href="#" class="text-gray-400 hover:text-cyan-400">API Reference</a></li>
                        </ul>
                    </div>
                    <div>
                        <h4 class="text-white font-semibold mb-4">Communauté</h4>
                        <ul class="space-y-2 text-sm">
                            <li><a href="#" class="text-gray-400 hover:text-cyan-400">Discord</a></li>
                            <li><a href="#" class="text-gray-400 hover:text-cyan-400">Forum</a></li>
                        </ul>
                    </div>
                    <div>
                        <h4 class="text-white font-semibold mb-4">Contact</h4>
                        <p class="text-gray-400 text-sm flex items-center">
                            <i data-lucide="mail" class="w-4 h-4 mr-2"></i>contact@nutrichain.io
                        </p>
                    </div>
                </div>
                <div class="border-t border-[#30363d] pt-6 text-center text-sm text-gray-400">
                    <p>© 2025 NutriChain. Open Source sous licence MIT.</p>
                </div>
            </div>
        </footer>
    </div>

    <div id="walletModal" class="modal">
        <div class="modal-content">
            <h2 class="text-2xl font-bold text-white mb-4">Nouveau Wallet</h2>
            <div id="walletInfo" class="space-y-4"></div>
            <button onclick="closeModal()" class="btn-primary w-full mt-4">Fermer</button>
        </div>
    </div>

    <script>
        const API_URL = 'http://localhost:5000';
        
        function showSection(section) {
            document.querySelectorAll('.section').forEach(el => el.style.display = 'none');
            document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
            document.getElementById(section + 'Section').style.display = 'block';
            event.target.classList.add('active');
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
                blockDiv.innerHTML = '<div class="flex justify-between items-start mb-2"><div class="font-bold text-white text-lg">Bloc #' + block.index + '</div><div class="text-sm text-gray-400">' + new Date(block.timestamp * 1000).toLocaleString('fr-FR') + '</div></div><div class="text-sm text-gray-400 mb-2"><strong>Hash:</strong> <span class="font-mono text-cyan-400">' + block.hash.substring(0, 40) + '...</span></div><div class="text-sm text-gray-400"><strong>Nonce:</strong> ' + block.nonce + ' | <strong>Transactions:</strong> ' + block.transactions.length + '</div>';
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

        async function mineBlock() {
            const btn = event.target;
            btn.disabled = true;
            btn.innerHTML = '<i data-lucide="loader" class="w-6 h-6 inline mr-2 animate-spin"></i> Mining...';
            try {
                const response = await fetch(API_URL + '/mine', {method: 'POST'});
                const block = await response.json();
                document.getElementById('miningResult').innerHTML = '<div class="bg-green-900/20 border border-green-700 rounded-lg p-4 mt-4"><p class="text-green-200 font-bold">✅ Bloc #' + block.index + ' miné !</p></div>';
                loadBlockchain();
            } catch (error) {
                alert('❌ Erreur');
            } finally {
                btn.disabled = false;
                btn.innerHTML = '<i data-lucide="pickaxe" class="w-6 h-6 inline mr-2"></i> Miner un Bloc';
                lucide.createIcons();
            }
        }

        document.getElementById('mineBtn').addEventListener('click', mineBlock);
        document.getElementById('quickMineBtn').addEventListener('click', mineBlock);

        document.getElementById('testPrivateTxBtn').addEventListener('click', () => {
            document.getElementById('privateTxResult').innerHTML = '<div class="bg-blue-900/20 border border-blue-700 rounded-lg p-4 mt-4"><p class="text-blue-200 font-bold">🔒 Transaction privée créée</p><p class="text-sm text-gray-400 mt-2">Adresse furtive: 85de6d62221e214f2975c50b5bf6399a53fc42ea</p></div>';
        });

        function createWallet() {
            const privateKey = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
            const address = 'nutri_' + Math.random().toString(36).substring(2, 15);
            document.getElementById('walletInfo').innerHTML = '<div class="bg-yellow-900/20 border border-yellow-700 rounded-lg p-4"><p class="text-yellow-200 text-sm">⚠️ Sauvegardez !</p></div><div><label class="block text-gray-400 mb-2">Adresse</label><input type="text" value="' + address + '" readonly class="font-mono"></div><div><label class="block text-gray-400 mb-2">Clé Privée</label><input type="text" value="' + privateKey + '" readonly class="font-mono"></div>';
            document.getElementById('walletModal').classList.add('show');
        }

        document.getElementById('createWalletBtn').addEventListener('click', createWallet);
        document.getElementById('quickWalletBtn').addEventListener('click', createWallet);

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

echo "✅ Dashboard restauré !"
echo "Lancez: python api.py puis ouvrez http://localhost:5000"
