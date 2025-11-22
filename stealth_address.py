import hashlib
import secrets
from ecdsa import SECP256k1, SigningKey, VerifyingKey
from ecdsa.util import number_to_string, string_to_number

class StealthAddress:
    """Implémentation des adresses furtives (Stealth Addresses)"""
    
    def __init__(self):
        self.curve = SECP256k1
    
    def generate_master_keys(self):
        """
        Générer les clés maîtresses du destinataire
        
        Returns:
            dict avec spend_key, view_key (privées et publiques)
        """
        # Clé de dépense (spend key)
        spend_private = SigningKey.generate(curve=self.curve)
        spend_public = spend_private.get_verifying_key()
        
        # Clé de visualisation (view key)
        view_private = SigningKey.generate(curve=self.curve)
        view_public = view_private.get_verifying_key()
        
        return {
            'spend_private': spend_private,
            'spend_public': spend_public,
            'view_private': view_private,
            'view_public': view_public
        }
    
    def generate_stealth_address(self, recipient_spend_pub, recipient_view_pub):
        """
        Générer une adresse furtive pour un destinataire
        
        Args:
            recipient_spend_pub: Clé publique de dépense du destinataire
            recipient_view_pub: Clé publique de visualisation du destinataire
        
        Returns:
            dict avec stealth_address, ephemeral_pub_key, shared_secret
        """
        # Générer une clé éphémère aléatoire (r)
        ephemeral_private = SigningKey.generate(curve=self.curve)
        ephemeral_public = ephemeral_private.get_verifying_key()
        
        # Calculer le secret partagé: r * V (V = view_public du destinataire)
        shared_secret = self._ecdh(ephemeral_private, recipient_view_pub)
        
        # Hacher le secret partagé
        hs = hashlib.sha256(shared_secret).digest()
        hs_int = string_to_number(hs) % self.curve.order
        
        # Calculer l'adresse furtive: P' = P + hs*G
        # où P est la clé publique de dépense du destinataire
        hs_point = hs_int * self.curve.generator
        recipient_point = recipient_spend_pub.pubkey.point
        stealth_point = recipient_point + hs_point
        
        # Convertir en adresse
        stealth_address = self._point_to_address(stealth_point)
        
        return {
            'stealth_address': stealth_address,
            'ephemeral_public': ephemeral_public.to_string().hex(),
            'shared_secret': shared_secret.hex()
        }
    
    def recover_stealth_private_key(self, spend_private, view_private, ephemeral_public_hex):
        """
        Récupérer la clé privée d'une adresse furtive (côté destinataire)
        
        Args:
            spend_private: Clé privée de dépense
            view_private: Clé privée de visualisation
            ephemeral_public_hex: Clé éphémère publique de l'expéditeur
        
        Returns:
            Clé privée de l'adresse furtive
        """
        # Reconstituer la clé éphémère publique
        ephemeral_public = VerifyingKey.from_string(
            bytes.fromhex(ephemeral_public_hex),
            curve=self.curve
        )
        
        # Calculer le secret partagé: v * R (R = clé éphémère de l'expéditeur)
        shared_secret = self._ecdh(view_private, ephemeral_public)
        
        # Hacher le secret partagé
        hs = hashlib.sha256(shared_secret).digest()
        hs_int = string_to_number(hs) % self.curve.order
        
        # Calculer la clé privée furtive: p' = p + hs
        spend_private_int = string_to_number(spend_private.to_string())
        stealth_private_int = (spend_private_int + hs_int) % self.curve.order
        
        stealth_private = SigningKey.from_string(
            number_to_string(stealth_private_int, self.curve.order),
            curve=self.curve
        )
        
        return stealth_private
    
    def _ecdh(self, private_key, public_key):
        """Échange de clés Diffie-Hellman sur courbe elliptique"""
        shared_point = private_key.privkey.secret_multiplier * public_key.pubkey.point
        return number_to_string(shared_point.x(), self.curve.order)
    
    def _point_to_address(self, point):
        """Convertir un point de courbe elliptique en adresse"""
        # Concaténer x et y
        point_bytes = number_to_string(point.x(), self.curve.order) + \
                     number_to_string(point.y(), self.curve.order)
        
        # Double hash SHA-256
        first_hash = hashlib.sha256(point_bytes).digest()
        second_hash = hashlib.sha256(first_hash).hexdigest()
        
        return second_hash[:40]
