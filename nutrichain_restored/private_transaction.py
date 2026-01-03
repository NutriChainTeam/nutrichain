import json
import hashlib
import time
from ring_signature import RingSignature
from stealth_address import StealthAddress

class PrivateTransaction:
    def __init__(self):
        self.ring_sig = RingSignature(ring_size=5)
        self.stealth = StealthAddress()
    
    def create_private_transaction(self, sender_keys, recipient_spend_pub, 
                                   recipient_view_pub, amount, decoy_pubkeys):
        stealth_data = self.stealth.generate_stealth_address(
            recipient_spend_pub, recipient_view_pub
        )
        ring_pubkeys = list(decoy_pubkeys) + [sender_keys['public']]
        tx_data = {
            'recipient_stealth': stealth_data['stealth_address'],
            'ephemeral_public': stealth_data['ephemeral_public'],
            'amount': amount,
            'timestamp': time.time()
        }
        message = json.dumps(tx_data, sort_keys=True)
        return {
            'type': 'private',
            'stealth_address': stealth_data['stealth_address'],
            'ephemeral_public_key': stealth_data['ephemeral_public'],
            'amount': amount,
            'ring_size': len(ring_pubkeys),
            'timestamp': tx_data['timestamp']
        }
