import hashlib
import secrets
from Crypto.PublicKey import RSA
from Crypto.Cipher import ChaCha20
from Crypto.Util.number import long_to_bytes, bytes_to_long

class RingSignature:
    def __init__(self, ring_size=5):
        self.ring_size = ring_size
        self.key_size = 1024
    
    def generate_keypair(self):
        keypair = RSA.generate(self.key_size)
        return {
            'public': (keypair.e, keypair.n),
            'private': (keypair.d, keypair.n)
        }
    
    def _E(self, glue, key):
        cipher = ChaCha20.new(key=key, nonce=key[:8])
        return bytes_to_long(cipher.encrypt(long_to_bytes(glue)))
    
    def _Ei(self, glue, key):
        cipher = ChaCha20.new(key=key, nonce=key[:8])
        return bytes_to_long(cipher.decrypt(long_to_bytes(glue)))
    
    def _g(self, m, e, n):
        q, r = divmod(m, n)
        if ((q + 1) * n) <= ((2**self.key_size) - 1):
            return q * n + pow(r, e, n)
        return m
    
    def _gi(self, m, d, n):
        q, r = divmod(m, n)
        if ((q + 1) * n) <= ((2**self.key_size) - 1):
            return q * n + pow(r, d, n)
        return m
    
    def sign(self, message, public_keys, signer_idx, private_key):
        n = len(public_keys)
        s = [0] * n
        k = secrets.randbits(256)
        key = hashlib.sha256(str(k).encode()).digest()
        msg_hash = hashlib.sha256(message.encode()).hexdigest()
        v = int(msg_hash, 16) % (2**self.key_size)
        
        for i in range(n):
            if i != signer_idx:
                s[i] = secrets.randbits(self.key_size)
        
        for i in range(signer_idx + 1, n):
            e, mod = public_keys[i]
            v = self._E(self._g(v ^ s[i], e, mod), key)
        
        for i in range(0, signer_idx):
            e, mod = public_keys[i]
            v = self._E(self._g(v ^ s[i], e, mod), key)
        
        d, mod = private_key
        s[signer_idx] = self._gi(self._Ei(v, key), d, mod) ^ v
        
        return {
            'message': message,
            'ring': public_keys,
            's_values': s,
            'v': v
        }
    
    def verify(self, signature):
        message = signature['message']
        public_keys = signature['ring']
        s = signature['s_values']
        v_original = signature['v']
        msg_hash = hashlib.sha256(message.encode()).hexdigest()
        k = int(msg_hash, 16)
        key = hashlib.sha256(str(k).encode()).digest()
        v = v_original
        for i in range(len(public_keys)):
            e, mod = public_keys[i]
            v = self._E(self._g(v ^ s[i], e, mod), key)
        return v == v_original
