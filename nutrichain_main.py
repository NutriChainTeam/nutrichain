import argparse
import threading
import sys
from flask import Flask, jsonify, request, render_template
from flask_cors import CORS

from blockchain import Blockchain
from wallet import Wallet
from node import BlockchainNode
from nutritoken import NutriToken
from meal_distribution import MealDistribution

try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    print("⚠️ 'requests' module not installed. Do: pip install requests")
    REQUESTS_AVAILABLE = False

app = Flask(__name__)
CORS(app)

class NutriTokenLimited(NutriToken):
    MAX_SUPPLY = 10_000_000  # 10 millions max

    def stake_usdt(self, address, amount, apy=0.0725):
        coins_to_create = amount
        if self.total_nutricoin_supply + coins_to_create > self.MAX_SUPPLY:
            return {"success": False, "error": "Quantité dépasse le supply maximum autorisé."}
        return super().stake_usdt(address, amount, apy)

blockchain = Blockchain()
nutri_token = NutriTokenLimited()
meal_system = MealDistribution()
node = None
my_port = 5000
peer_ports = []
proposals_store = []

def broadcast_to_peers(endpoint, data):
    if not REQUESTS_AVAILABLE:
        print("❌ Cannot broadcast: requests not installed", flush=True)
        return
    print(f"\n{'='*60}\n🔄 BROADCAST {endpoint}:", flush=True)
    for peer_port in peer_ports:
        if peer_port == my_port:
            print(f"  ⏭️ Skip self {peer_port}", flush=True)
            continue
        try:
            url = f'http://localhost:{peer_port}/api/sync/{endpoint}'
            print(f"  📤 Sending to {url}...", flush=True)
            res = requests.post(url, json=data, timeout=2)
            print(f"  ✅ Peer {peer_port}: {res.status_code}", flush=True)
        except Exception as e:
            print(f"  ❌ FAILED to peer {peer_port}: {type(e).__name__} {e}", flush=True)
    print(f"{'='*60}\n", flush=True)

@app.route('/api/sync/stake', methods=['POST'])
def sync_stake():
    data = request.get_json()
    print(f"📥 SYNC stake from peer: {data}", flush=True)
    result = nutri_token.stake_usdt(data['address'], float(data['amount']))
    if result['success']:
        blockchain.add_transaction(
            'USDT_Reserve', data['address'], result['nutricoin_received']
        )
    return jsonify({'success': True, 'synced': True})

@app.route('/api/sync/withdraw', methods=['POST'])
def sync_withdraw():
    data = request.get_json()
    print(f"📥 SYNC withdraw from peer: {data}", flush=True)
    result = nutri_token.withdraw_nutricoin(data['address'], float(data['amount']))
    if result['success']:
        blockchain.add_transaction(
            data['address'], 'USDT_Reserve', result['nutricoin_burned']
        )
    return jsonify({'success': True, 'synced': True})

@app.route('/api/sync/proposal', methods=['POST'])
def sync_proposal():
    data = request.get_json()
    print(f"📥 SYNC proposal from peer: {data.get('title','')}", flush=True)
    if not any(p['id'] == data['id'] for p in proposals_store):
        proposals_store.append(data)
    return jsonify({'success': True, 'synced': True})

@app.route('/api/sync/vote', methods=['POST'])
def sync_vote():
    data = request.get_json()
    print(f"📥 SYNC vote from peer: {data}", flush=True)
    for proposal in proposals_store:
        if proposal['id'] == data['proposal_id']:
            if data['vote_type'] == 'yes':
                proposal['votes_yes'] += 1
            else:
                proposal['votes_no'] += 1
            break
    return jsonify({'success': True, 'synced': True})

@app.route('/api/proposals/list', methods=['GET'])
def get_proposals_list():
    return jsonify({'proposals': proposals_store})

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/api/stats', methods=['GET'])
def get_stats():
    token_stats = nutri_token.get_stats()
    total_usdt_staked = token_stats['total_usdt_staked']
    meals_distributed = int(total_usdt_staked / 2)
    people_fed = int(meals_distributed / 1.4)
    countries_served = min(5 + int(meals_distributed / 1000), 25)
    meal_stats = {
        'meals_distributed': meals_distributed,
        'people_fed': people_fed,
        'countries_served': countries_served,
        'total_budget_used': int(total_usdt_staked * 0.15)
    }
    return jsonify({
        'nutricoin': {
            'price': 1.0,
            'supply': nutri_token.total_nutricoin_supply,
            'usdt_staked': token_stats['total_usdt_staked'],
            'stakers': token_stats['total_stakers']
        },
        'meals': meal_stats,
        'apy': 7.25,
        'node_info': {
            'port': my_port,
            'peers': peer_ports
        }
    })

@app.route('/api/wallet/new', methods=['POST'])
def create_wallet():
    wallet = Wallet()
    return jsonify(wallet.to_dict())

@app.route('/api/stake', methods=['POST'])
def stake_tokens():
    data = request.get_json()
    print(f"\n🔥 STAKE: {data}", flush=True)
    if 'address' not in data or 'amount' not in data:
        return jsonify({'error': 'Missing parameters'}), 400
    result = nutri_token.stake_usdt(data['address'], float(data['amount']))
    if result['success']:
        blockchain.add_transaction('USDT_Reserve', data['address'], result['nutricoin_received'])
        broadcast_to_peers('stake', {'address': data['address'], 'amount': float(data['amount'])})
    return jsonify(result)

@app.route('/api/withdraw', methods=['POST'])
def withdraw_tokens():
    data = request.get_json()
    print(f"\n🔥 WITHDRAW: {data}", flush=True)
    if 'address' not in data or 'amount' not in data:
        return jsonify({'error': 'Missing parameters'}), 400
    result = nutri_token.withdraw_nutricoin(data['address'], float(data['amount']))
    if result['success']:
        blockchain.add_transaction(
            data['address'], 'USDT_Reserve', result['nutricoin_burned']
        )
        broadcast_to_peers('withdraw', {'address': data['address'], 'amount': float(data['amount'])})
    return jsonify(result)

@app.route('/api/balance/<address>', methods=['GET'])
def get_balance(address):
    balance = nutri_token.get_balance(address)
    return jsonify(balance)

@app.route('/api/proposal/create', methods=['POST'])
def create_proposal():
    data = request.get_json()
    if 'title' not in data or 'description' not in data or 'budget' not in data:
        return jsonify({'error': 'Missing parameters'}), 400
    import time
    proposal = {
        'id': len(proposals_store) + 1,
        'title': data['title'],
        'description': data['description'],
        'budget': float(data['budget']),
        'votes_yes': 0,
        'votes_no': 0,
        'created_at': int(time.time() * 1000),
        'voting_ends': int(time.time() * 1000) + 7 * 86400000,
        'creator': data.get('creator', 'Anonymous')
    }
    proposals_store.append(proposal)
    broadcast_to_peers('proposal', proposal)
    return jsonify({'success': True, 'proposal': proposal})

@app.route('/api/proposal/vote', methods=['POST'])
def vote_proposal():
    data = request.get_json()
    if 'proposal_id' not in data or 'vote_type' not in data:
        return jsonify({'error': 'Missing parameters'}), 400
    proposal_id = int(data['proposal_id'])
    vote_type = data['vote_type']
    proposal = next((p for p in proposals_store if p['id'] == proposal_id), None)
    if not proposal:
        return jsonify({'error': 'Proposal not found'}), 404
    if vote_type == 'yes':
        proposal['votes_yes'] += 1
    else:
        proposal['votes_no'] += 1
    broadcast_to_peers('vote', {'proposal_id': proposal_id, 'vote_type': vote_type})
    return jsonify({'success': True, 'proposal': proposal})

@app.route('/api/proposals', methods=['GET'])
def get_proposals():
    return jsonify({'proposals': proposals_store})

@app.route('/api/chain', methods=['GET'])
def get_chain():
    chain_data = []
    for block in blockchain.chain:
        chain_data.append({
            'index': block.index,
            'timestamp': block.timestamp,
            'transactions': block.transactions,
            'previous_hash': block.previous_hash,
            'hash': block.hash,
            'nonce': block.nonce
        })
    return jsonify({'chain': chain_data, 'length': len(chain_data)})

@app.route('/api/mine', methods=['POST'])
def mine():
    block = blockchain.mine_pending_transactions()
    if block is None:
        return jsonify({'message': 'Aucune transaction à miner'})
    return jsonify({
        'message': 'Bloc miné avec succès',
        'index': block.index,
        'hash': block.hash,
        'transactions': block.transactions,
        'nonce': block.nonce
    })

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'port': my_port,
        'peers': peer_ports,
        'blockchain_length': len(blockchain.chain),
        'proposals_count': len(proposals_store),
        'requests_available': REQUESTS_AVAILABLE
    })

def sync_with_peers():
    if not REQUESTS_AVAILABLE:
        print("⚠️  Sync skipped (requests not installed)")
        return
    print("\n🔄 Sync with peers at startup...")
    for peer_port in peer_ports:
        if peer_port == my_port:
            continue
        try:
            url = f'http://localhost:{peer_port}/api/proposals'
            res = requests.get(url, timeout=2)
            if res.status_code == 200:
                peers_props = res.json()['proposals']
                for prop in peers_props:
                    if not any(p['id'] == prop['id'] for p in proposals_store):
                        proposals_store.append(prop)
                print(f"✅ Synced {len(peers_props)} proposals from peer {peer_port}")
                break
        except Exception as e:
            print(f"❌ Could not sync with peer {peer_port}: {e}")
    print(f"📊 Total proposals after sync: {len(proposals_store)}\n")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=5000)
    parser.add_argument('--p2p-port', type=int, default=6000)
    parser.add_argument('--peers', type=str, default='5000,5001,5002')
    args = parser.parse_args()
    my_port = args.port
    app.config['PORT'] = my_port
    peer_ports = [int(p.strip()) for p in args.peers.split(',')]
    node = BlockchainNode('localhost', args.p2p_port)
    node.set_blockchain(blockchain)
    node_thread = threading.Thread(target=node.start)
    node_thread.daemon = True
    node_thread.start()
    import time
    time.sleep(2)
    if my_port != 5000:
        sync_with_peers()
    print(f"\n{'='*60}")
    print(f"🍽️  NUTRICHAIN - Nœud {my_port}")
    print(f"{'='*60}")
    print(f"🌐 Web: http://localhost:{args.port}/")
    print(f"🔌 API: http://localhost:{args.port}/api/stats")
    print(f"🌐 P2P: localhost:{args.p2p_port}")
    print(f"👥 Peers: {peer_ports}")
    print(f"📦 Requests: {'✅' if REQUESTS_AVAILABLE else '❌'}")
    print(f"{'='*60}\n")
    if not REQUESTS_AVAILABLE:
        print("⚠️ Installez requests avec: pip install requests\n")
    sys.stdout.flush()
    app.run(host='0.0.0.0', port=args.port, debug=False, use_reloader=False)
