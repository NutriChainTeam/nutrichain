import hashlib
import secrets
from stealth_address import StealthAddress
from ring_signature import RingSignature

class Wallet:
    def __init__(self):
        """Générer un wallet avec support de confidentialité"""
        # Clés standards
        self.private_key = secrets.token_hex(32)
        self.public_key = hashlib.sha256(self.private_key.encode()).hexdigest()
        self.address = self.generate_address()
        
        # Clés de confidentialité (Monero-style)
        self.stealth = StealthAddress()
        self.master_keys = self.stealth.generate_master_keys()
        
        # Clés pour ring signatures
        self.ring_sig = RingSignature()
        self.ring_keys = self.ring_sig.generate_keypair()
    
    def generate_address(self):
        """Créer une adresse depuis la clé publique"""
        first_hash = hashlib.sha256(self.public_key.encode()).digest()
        second_hash = hashlib.sha256(first_hash).hexdigest()
        return second_hash[:40]
    
    def public_key_hex(self):
        """Retourner la clé publique en hex"""
        return self.public_key
    
    def get_stealth_public_keys(self):
        """Obtenir les clés publiques pour recevoir des paiements privés"""
        return {
            'spend_public': self.master_keys['spend_public'].to_string().hex(),
            'view_public': self.master_keys['view_public'].to_string().hex()
        }
    
    def get_ring_public_key(self):
        """Obtenir la clé publique pour ring signatures"""
        return self.ring_keys['public']
    
    def to_dict(self):
        """Exporter en dictionnaire"""
        stealth_keys = self.get_stealth_public_keys()
        
        return {
            'address': self.address,
            'public_key': self.public_key_hex(),
            'spend_public_key': stealth_keys['spend_public'],
            'view_public_key': stealth_keys['view_public'],
            'ring_public_key': f"{self.ring_keys['public'][0]}:{self.ring_keys['public'][1]}"
        }
