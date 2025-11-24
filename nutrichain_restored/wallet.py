import hashlib
import secrets
from stealth_address import StealthAddress
from ring_signature import RingSignature

class Wallet:
    def __init__(self):
        self.private_key = secrets.token_hex(32)
        self.public_key = hashlib.sha256(self.private_key.encode()).hexdigest()
        self.address = self.generate_address()
        self.stealth = StealthAddress()
        self.master_keys = self.stealth.generate_master_keys()
        self.ring_sig = RingSignature()
        self.ring_keys = self.ring_sig.generate_keypair()
    
    def generate_address(self):
        first_hash = hashlib.sha256(self.public_key.encode()).digest()
        second_hash = hashlib.sha256(first_hash).hexdigest()
        return second_hash[:40]
    
    def to_dict(self):
        return {
            'address': self.address,
            'public_key': self.public_key
        }
