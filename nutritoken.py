import time
import hashlib

class NutriToken:
    """Gestion des tokens NUTRICOIN et simulation USDT"""
    
    def __init__(self):
        self.nutricoin_supply = 0  # Supply total de NUTRICOIN
        self.usdt_reserve = 0  # Réserve USDT stakée
        self.exchange_rate = 1.0  # 1 USDT = 1 NUTRICOIN (ratio 1:1)
        self.balances = {}  # {address: {nutricoin: amount, usdt: amount}}
        self.staking_positions = {}  # {address: {amount, start_time, apy}}
        
    def stake_usdt(self, user_address, usdt_amount, apy=0.0725):
        """
        Staker USDT pour recevoir NUTRICOIN
        
        Args:
            user_address: Adresse du wallet
            usdt_amount: Montant USDT à staker
            apy: Taux de rendement annuel (7.25% par défaut)
        """
        if usdt_amount < 10:
            return {"success": False, "error": "Minimum 10 USDT requis"}
        
        # Convertir USDT en NUTRICOIN (ratio 1:1)
        nutricoin_received = usdt_amount * self.exchange_rate
        
        # Mettre à jour les réserves
        self.usdt_reserve += usdt_amount
        self.nutricoin_supply += nutricoin_received
        
        # Créer la position de staking
        if user_address not in self.staking_positions:
            self.staking_positions[user_address] = []
        
        position = {
            'amount': nutricoin_received,
            'usdt_staked': usdt_amount,
            'start_time': time.time(),
            'apy': apy,
            'status': 'active'
        }
        
        self.staking_positions[user_address].append(position)
        
        # Mettre à jour le solde
        if user_address not in self.balances:
            self.balances[user_address] = {'nutricoin': 0, 'usdt': 0}
        
        self.balances[user_address]['nutricoin'] += nutricoin_received
        
        return {
            "success": True,
            "nutricoin_received": nutricoin_received,
            "position": position
        }
    
    def calculate_interest(self, user_address):
        """Calculer les intérêts accumulés"""
        if user_address not in self.staking_positions:
            return 0
        
        total_interest = 0
        
        for position in self.staking_positions[user_address]:
            if position['status'] != 'active':
                continue
            
            # Temps écoulé en années
            time_elapsed = (time.time() - position['start_time']) / (365 * 24 * 3600)
            
            # Intérêts = montant * APY * temps
            interest = position['amount'] * position['apy'] * time_elapsed
            total_interest += interest
        
        return total_interest
    
    def withdraw_nutricoin(self, user_address, nutricoin_amount):
        """Retirer NUTRICOIN et recevoir USDT"""
        if user_address not in self.balances:
            return {"success": False, "error": "Aucun solde"}
        
        available = self.balances[user_address]['nutricoin']
        
        if nutricoin_amount > available:
            return {"success": False, "error": "Solde insuffisant"}
        
        # Convertir en USDT
        usdt_to_receive = nutricoin_amount / self.exchange_rate
        
        # Vérifier la réserve
        if usdt_to_receive > self.usdt_reserve:
            return {"success": False, "error": "Réserve USDT insuffisante"}
        
        # Effectuer le retrait
        self.balances[user_address]['nutricoin'] -= nutricoin_amount
        self.usdt_reserve -= usdt_to_receive
        self.nutricoin_supply -= nutricoin_amount
        
        return {
            "success": True,
            "usdt_received": usdt_to_receive,
            "nutricoin_burned": nutricoin_amount
        }
    
    def get_balance(self, user_address):
        """Obtenir le solde d'un utilisateur"""
        if user_address not in self.balances:
            return {'nutricoin': 0, 'usdt': 0, 'interest': 0}
        
        interest = self.calculate_interest(user_address)
        
        return {
            'nutricoin': self.balances[user_address]['nutricoin'],
            'usdt': self.balances[user_address].get('usdt', 0),
            'interest': interest,
            'total_value': self.balances[user_address]['nutricoin'] + interest
        }
    
    def get_stats(self):
        """Statistiques globales"""
        return {
            'total_nutricoin_supply': self.nutricoin_supply,
            'total_usdt_staked': self.usdt_reserve,
            'total_stakers': len(self.staking_positions),
            'exchange_rate': self.exchange_rate
        }
