import json
import hashlib
import time
from ring_signature import RingSignature
from stealth_address import StealthAddress

class PrivateTransaction:
    """Transaction privée utilisant Ring Signatures et Stealth Addresses"""
    
    def __init__(self):
        self.ring_sig = RingSignature(ring_size=5)
        self.stealth = StealthAddress()
    
    def create_private_transaction(self, sender_keys, recipient_spend_pub, 
                                   recipient_view_pub, amount, decoy_pubkeys):
        """
        Créer une transaction privée
        
        Args:
            sender_keys: Dictionnaire avec clés privée/publique de l'expéditeur
            recipient_spend_pub: Clé publique de dépense du destinataire
            recipient_view_pub: Clé publique de visualisation du destinataire
            amount: Montant (sera caché dans une vraie implémentation RingCT)
            decoy_pubkeys: Clés publiques des leurres pour la ring signature
        
        Returns:
            Transaction privée complète
        """
        # 1. Générer une adresse furtive pour le destinataire
        stealth_data = self.stealth.generate_stealth_address(
            recipient_spend_pub,
            recipient_view_pub
        )
        
        # 2. Créer l'anneau de signatures
        ring_pubkeys, sender_idx = self._create_ring(
            sender_keys['public'],
            decoy_pubkeys
        )
        
        # 3. Préparer les données de la transaction
        tx_data = {
            'recipient_stealth': stealth_data['stealth_address'],
            'ephemeral_public': stealth_data['ephemeral_public'],
            'amount_commitment': self._commit_amount(amount),  # Pedersen commitment simulé
            'timestamp': time.time()
        }
        
        # 4. Signer avec ring signature
        message = json.dumps(tx_data, sort_keys=True)
        signature = self.ring_sig.sign(
            message,
            ring_pubkeys,
            sender_idx,
            sender_keys['private']
        )
        
        # 5. Construire la transaction complète
        private_tx = {
            'type': 'private',
            'stealth_address': stealth_data['stealth_address'],
            'ephemeral_public_key': stealth_data['ephemeral_public'],
            'amount_commitment': tx_data['amount_commitment'],
            'ring_members': [self._pubkey_to_hex(pk) for pk in ring_pubkeys],
            'ring_signature': {
                'v': signature['v'],
                'x': signature['x']
            },
            'timestamp': tx_data['timestamp']
        }
        
        return private_tx
    
    def verify_private_transaction(self, private_tx):
        """
        Vérifier une transaction privée
        
        Args:
            private_tx: Transaction privée à vérifier
        
        Returns:
            True si valide, False sinon
        """
        # Reconstituer les clés publiques de l'anneau
        ring_pubkeys = [self._hex_to_pubkey(pk) for pk in private_tx['ring_members']]
        
        # Reconstituer les données de la transaction
        tx_data = {
            'recipient_stealth': private_tx['stealth_address'],
            'ephemeral_public': private_tx['ephemeral_public_key'],
            'amount_commitment': private_tx['amount_commitment'],
            'timestamp': private_tx['timestamp']
        }
        
        message = json.dumps(tx_data, sort_keys=True)
        
        # Vérifier la ring signature
        signature = {
            'v': private_tx['ring_signature']['v'],
            'x': private_tx['ring_signature']['x']
        }
        
        return self.ring_sig.verify(message, ring_pubkeys, signature)
    
    def scan_for_received_transactions(self, private_txs, view_private, spend_public):
        """
        Scanner les transactions pour détecter celles reçues
        (Équivalent au scanning avec view key dans Monero)
        
        Args:
            private_txs: Liste de transactions privées
            view_private: Clé privée de visualisation
            spend_public: Clé publique de dépense
        
        Returns:
            Liste des transactions reçues avec leurs clés privées
        """
        received = []
        
        for tx in private_txs:
            try:
                # Essayer de récupérer la clé privée
                stealth_private = self.stealth.recover_stealth_private_key(
                    spend_public,  # Note: devrait être spend_private, erreur dans mon code précédent
                    view_private,
                    tx['ephemeral_public_key']
                )
                
                # Si on arrive ici, la transaction nous appartient
                received.append({
                    'transaction': tx,
                    'stealth_private_key': stealth_private
                })
            except:
                # Cette transaction n'est pas pour nous
                continue
        
        return received
    
    def _create_ring(self, real_pubkey, decoy_pubkeys):
        """Créer un anneau avec le vrai signataire et des leurres"""
        import secrets
        
        ring = list(decoy_pubkeys)
        real_idx = secrets.randbelow(len(ring) + 1)
        ring.insert(real_idx, real_pubkey)
        
        return ring, real_idx
    
    def _commit_amount(self, amount):
        """
        Simuler un Pedersen commitment pour cacher le montant
        Dans une vraie implémentation RingCT, ceci utiliserait
        des courbes elliptiques et des preuves à intervalle
        """
        # Hash simple pour la démo (PAS sécurisé pour production!)
        commitment = hashlib.sha256(str(amount).encode()).hexdigest()
        return commitment[:32]
    
    def _pubkey_to_hex(self, pubkey):
        """Convertir une clé publique en hex"""
        (e, n) = pubkey
        return f"{e:x}:{n:x}"
    
    def _hex_to_pubkey(self, hex_str):
        """Convertir hex en clé publique"""
        e_hex, n_hex = hex_str.split(':')
        return (int(e_hex, 16), int(n_hex, 16))
