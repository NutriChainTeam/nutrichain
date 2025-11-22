import time

class MealDistribution:
    """Système de distribution de repas financé par les intérêts"""
    
    def __init__(self):
        self.meals_distributed = 0
        self.people_fed = 0
        self.countries_served = 3  # Commencer avec 3 pays
        self.meal_cost = 2.0  # 2 USDT par repas
        self.meal_vouchers = {}  # {voucher_id: {recipient, status, timestamp}}
        self.distribution_history = []
        
    def calculate_meals_from_interest(self, total_interest_usdt):
        """Calculer combien de repas peuvent être financés"""
        return int(total_interest_usdt / self.meal_cost)
    
    def generate_meal_voucher(self, recipient_address):
        """Générer un bon repas pour un bénéficiaire"""
        import hashlib
        import secrets
        
        voucher_id = hashlib.sha256(
            f"{recipient_address}{time.time()}{secrets.token_hex(8)}".encode()
        ).hexdigest()[:16]
        
        voucher = {
            'voucher_id': voucher_id,
            'recipient': recipient_address,
            'status': 'active',
            'timestamp': time.time(),
            'expires': time.time() + (30 * 24 * 3600)  # Expire dans 30 jours
        }
        
        self.meal_vouchers[voucher_id] = voucher
        
        return voucher
    
    def redeem_voucher(self, voucher_id, partner_address):
        """
        Échanger un bon repas chez un partenaire
        
        Args:
            voucher_id: ID du voucher
            partner_address: Adresse du restaurant/partenaire
        """
        if voucher_id not in self.meal_vouchers:
            return {"success": False, "error": "Voucher invalide"}
        
        voucher = self.meal_vouchers[voucher_id]
        
        if voucher['status'] != 'active':
            return {"success": False, "error": "Voucher déjà utilisé"}
        
        if time.time() > voucher['expires']:
            return {"success": False, "error": "Voucher expiré"}
        
        # Marquer comme utilisé
        voucher['status'] = 'redeemed'
        voucher['redeemed_at'] = time.time()
        voucher['partner'] = partner_address
        
        # Incrémenter les compteurs
        self.meals_distributed += 1
        self.people_fed += 1  # Simplification: 1 meal = 1 person
        
        # Enregistrer dans l'historique
        self.distribution_history.append({
            'voucher_id': voucher_id,
            'recipient': voucher['recipient'],
            'partner': partner_address,
            'timestamp': time.time()
        })
        
        return {
            "success": True,
            "meal_distributed": True
        }
    
    def distribute_meals_batch(self, beneficiaries_addresses, meals_available):
        """Distribuer des repas à plusieurs bénéficiaires"""
        vouchers = []
        
        for i, address in enumerate(beneficiaries_addresses):
            if i >= meals_available:
                break
            
            voucher = self.generate_meal_voucher(address)
            vouchers.append(voucher)
        
        return {
            "success": True,
            "vouchers_generated": len(vouchers),
            "vouchers": vouchers
        }
    
    def get_stats(self):
        """Statistiques de distribution"""
        active_vouchers = sum(1 for v in self.meal_vouchers.values() if v['status'] == 'active')
        
        return {
            'meals_distributed': self.meals_distributed,
            'people_fed': self.people_fed,
            'countries_served': self.countries_served,
            'active_vouchers': active_vouchers,
            'total_vouchers': len(self.meal_vouchers)
        }
