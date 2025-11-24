#!/usr/bin/env bash
set -e

PROJECT_DIR="$HOME/nutrichain_restored"
API_FILE="${PROJECT_DIR}/api.py"
BC_FILE="${PROJECT_DIR}/blockchain.py"

echo "=== NutriChain - Ajout des vérifications de solde NUTRI ==="

# Backups
cp "$API_FILE" "${API_FILE}.bak_balance_$(date +%Y%m%d_%H%M%S)"
cp "$BC_FILE"  "${BC_FILE}.bak_balance_$(date +%Y%m%d_%H%M%S)"
echo "Backups créés pour api.py et blockchain.py"

########################################
# 1) Ajouter get_balance à Blockchain
########################################

# Si la méthode existe déjà, on ne refait rien
if grep -q "def get_balance(self, address" "$BC_FILE"; then
  echo "get_balance existe déjà dans blockchain.py, on ne la recrée pas."
else
  echo "Ajout de get_balance(self, address) dans blockchain.py..."

  # Insère la fonction juste avant la ligne "def mine_pending_transactions" ou, à défaut, avant la fin de la classe
  python - << 'EOF'
from pathlib import Path

bc_path = Path("$BC_FILE")
code = bc_path.read_text(encoding="utf-8")

marker = "    def mine_pending_transactions(self"
insert_code = """
    def get_balance(self, address: str) -> float:
        balance = 0.0
        for block in self.chain:
            for tx in block.transactions:
                if tx.get('sender') == address:
                    balance -= float(tx.get('amount', 0))
                if tx.get('recipient') == address:
                    balance += float(tx.get('amount', 0))

        for tx in self.pending_transactions:
            if tx.get('sender') == address:
                balance -= float(tx.get('amount', 0))
            if tx.get('recipient') == address:
                balance += float(tx.get('amount', 0))

        return balance

"""

if marker in code:
    code = code.replace(marker, insert_code + marker)
else:
    # fallback: on ajoute à la fin du fichier
    code += "\n" + insert_code + "\n"

bc_path.write_text(code, encoding="utf-8")
EOF

fi

########################################
# 2) Modifier /donate et /stake dans api.py
########################################
echo "Mise à jour de /donate et /stake dans api.py..."

python - << 'EOF'
from pathlib import Path

api_path = Path("$API_FILE")
code = api_path.read_text(encoding="utf-8")

# Nouveau bloc /donate
new_donate = '''
@app.route('/donate', methods=['POST'])
def donate():
    """Faire un don (alias de transaction)"""
    values = request.get_json() or {}

    donor = values.get('donor', 'anonymous')
    region = values.get('region', 'global')
    amount = float(values.get('amount', 0))

    if amount <= 0:
        return jsonify({'error': 'Montant invalide'}), 400

    # Si le donateur n'est pas "anonymous", vérifier le solde NUTRI
    if donor != 'anonymous':
        balance = blockchain.get_balance(donor)
        if balance < amount:
            return jsonify({
                'error': 'Solde insuffisant',
                'balance': balance,
                'required': amount
            }), 400

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
'''

# Nouveau bloc /stake
new_stake = '''
staking_pool = {}

@app.route('/stake', methods=['POST'])
def stake():
    """Staker des tokens"""
    values = request.get_json() or {}
    address = values.get('address')
    amount = float(values.get('amount', 0))

    if not address:
        return jsonify({'error': 'Adresse manquante'}), 400

    if amount <= 0:
        return jsonify({'error': 'Montant invalide'}), 400

    # Vérifier le solde NUTRI avant de staker
    balance = blockchain.get_balance(address)
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
'''

# Remplacer l'ancien /donate
import re

code = re.sub(
    r"@app\.route\('/donate'.*?^def stake\(",
    new_donate + "\n\n@app.route('/stake', methods=['POST'])\ndef stake(",
    code,
    flags=re.DOTALL | re.MULTILINE
)

api_path.write_text(code, encoding="utf-8")
EOF

echo "=== Mise à jour terminée. Redémarre avec ./run_nutrichain.sh ==="
