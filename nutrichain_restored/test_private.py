from wallet import Wallet
from private_transaction import PrivateTransaction

print("=== Test des transactions privées NutriChain ===\n")

alice = Wallet()
bob = Wallet()

print(f"Alice: {alice.address}")
print(f"Bob: {bob.address}\n")

priv_tx = PrivateTransaction()
decoys = [alice.ring_sig.generate_keypair()['public'] for _ in range(4)]

print("Création d'une transaction privée Alice -> Bob (100 tokens)...")

tx = priv_tx.create_private_transaction(
    sender_keys={'public': alice.ring_keys['public'], 
                 'private': alice.ring_keys['private']},
    recipient_spend_pub=bob.master_keys['spend_public'],
    recipient_view_pub=bob.master_keys['view_public'],
    amount=100,
    decoy_pubkeys=decoys
)

print(f"✓ Transaction créée")
print(f"  Adresse furtive: {tx['stealth_address']}")
print(f"  Taille de l'anneau: {tx['ring_size']}")
print(f"\n✅ Transaction privée réussie ! 🔒")
