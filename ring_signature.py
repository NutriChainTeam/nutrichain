import hashlib
import secrets
from Crypto.PublicKey import RSA
from Crypto.Cipher import ChaCha20
from Crypto.Util.number import long_to_bytes, bytes_to_long

class RingSignature:
    """Implémentation des signatures en anneau (Ring Signatures)"""
    
    def __init__(self, ring_size=5):
        self.ring_size = ring_size
        self.key_size = 1024
    
    def generate_keypair(self):
        """Générer une paire de clés RSA"""
        keypair = RSA.generate(self.key_size)
        return {
            'public': (keypair.e, keypair.n),
            'private': (keypair.d, keypair.n)
        }
    
    def _E(self, glue, key):
        """Chiffrement symétrique (ChaCha20)"""
        cipher = ChaCha20.new(key=key, nonce=key[:8])
        return bytes_to_long(cipher.encrypt(long_to_bytes(glue)))
    
    def _Ei(self, glue, key):
        """Déchiffrement symétrique (inversion)"""
        cipher = ChaCha20.new(key=key, nonce=key[:8])
        return bytes_to_long(cipher.decrypt(long_to_bytes(glue)))
    
    def _g(self, m, e, n):
        """Fonction trappe pour RSA"""
        q, r = divmod(m, n)
        if ((q + 1) * n) <= ((2**self.key_size) - 1):
            return q*n + pow(r, e, n)
        return m
    
    def _forward(self, glue, pubkey, x, key):
        """Étape avant dans l'anneau"""
        (e, n) = pubkey
        return self._E(glue ^ self._g(x, e, n), key)
    
    def sign(self, message, ring_pubkeys, signer_idx, signer_privkey):
        """
        Créer une signature en anneau
        
        Args:
            message: Message à signer
            ring_pubkeys: Liste des clés publiques de l'anneau
            signer_idx: Index du signataire dans l'anneau
            signer_privkey: Clé privée du signataire
        
        Returns:
            Signature (v, x_values)
        """
        # Hacher le message pour l'utiliser comme clé
        k = hashlib.sha256(message.encode()).digest()
        
        # Valeur d'initialisation aléatoire
        v = secrets.randbits(self.key_size)
        
        x = [0] * len(ring_pubkeys)
        
        # Étape avant jusqu'à la position du signataire
        glue_in = v
        for i in range(signer_idx):
            x[i] = secrets.randbits(self.key_size)
            glue_in = self._forward(glue_in, ring_pubkeys[i], x[i], k)
        
        # Étape arrière depuis la fin jusqu'à la position du signataire
        glue_out = v
        for i in range(signer_idx + 1, len(ring_pubkeys)):
            x[i] = secrets.randbits(self.key_size)
            glue_out = self._forward(glue_out, ring_pubkeys[i], x[i], k)
        
        # Déchiffrement final
        glue_out = self._Ei(glue_out, k)
        
        # Résoudre pour y
        y = glue_in ^ glue_out
        
        # Déterminer x du signataire
        (d, n) = signer_privkey
        x[signer_idx] = self._g(y, d, n)
        
        return {'v': v, 'x': x}
    
    def verify(self, message, ring_pubkeys, signature):
        """
        Vérifier une signature en anneau
        
        Args:
            message: Message signé
            ring_pubkeys: Clés publiques de l'anneau
            signature: Signature à vérifier
        
        Returns:
            True si valide, False sinon
        """
        k = hashlib.sha256(message.encode()).digest()
        v = signature['v']
        x = signature['x']
        
        # Parcourir tout l'anneau
        z = v
        for i in range(len(ring_pubkeys)):
            z = self._forward(z, ring_pubkeys[i], x[i], k)
        
        # La valeur finale doit correspondre à v
        return z == v
    
    def create_decoy_ring(self, real_pubkey, ring_size):
        """
        Créer un anneau avec des clés leurres
        
        Args:
            real_pubkey: Clé publique réelle
            ring_size: Taille de l'anneau
        
        Returns:
            (ring_pubkeys, real_idx)
        """
        ring = []
        real_idx = secrets.randbelow(ring_size)
        
        for i in range(ring_size):
            if i == real_idx:
                ring.append(real_pubkey)
            else:
                # Générer une clé leurre
                decoy = self.generate_keypair()
                ring.append(decoy['public'])
        
        return ring, real_idx
