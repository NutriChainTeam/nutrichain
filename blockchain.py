import hashlib
import json
import time

class Block:
    def __init__(self, index, previous_hash, transactions):
        self.index = index
        self.previous_hash = previous_hash
        self.timestamp = time.time()
        self.transactions = transactions
        self.nonce = 0
        self.hash = self.calculate_hash()
    
    def calculate_hash(self):
        block_string = json.dumps({
            "index": self.index,
            "previous_hash": self.previous_hash,
            "timestamp": self.timestamp,
            "transactions": self.transactions,
            "nonce": self.nonce
        }, sort_keys=True)
        return hashlib.sha256(block_string.encode()).hexdigest()
    
    def mine_block(self, difficulty):
        target = "0" * difficulty
        start_time = time.time()
        
        while self.hash[:difficulty] != target:
            self.nonce += 1
            self.hash = self.calculate_hash()
        
        end_time = time.time()
        print(f"Bloc {self.index} miné avec succès !")
        print(f"Hachage : {self.hash}")
        print(f"Nonce : {self.nonce}")
        print(f"Temps : {end_time - start_time:.2f}s")


class Blockchain:
    def __init__(self):
        self.chain = []
        self.difficulty = 4
        self.pending_transactions = []
        self.mining_reward = 10
        print("\n--- Création du bloc genesis ---")
        self.create_genesis_block()
    
    def create_genesis_block(self):
        genesis_block = Block(0, "0", ["Genesis Block"])
        genesis_block.mine_block(self.difficulty)
        self.chain.append(genesis_block)
    
    def get_latest_block(self):
        return self.chain[-1]
    
    def add_transaction(self, sender, recipient, amount):
        transaction = {
            'sender': sender,
            'recipient': recipient,
            'amount': amount
        }
        self.pending_transactions.append(transaction)
        print(f"Transaction: {sender} -> {recipient}: {amount}")
        return True
    
    def mine_pending_transactions(self, mining_reward_address="Mineur"):
        if len(self.pending_transactions) == 0:
            return None
        
        print(f"\n--- Minage de {len(self.pending_transactions)} transactions ---")
        
        new_block = Block(
            len(self.chain),
            self.get_latest_block().hash,
            self.pending_transactions
        )
        
        new_block.mine_block(self.difficulty)
        self.chain.append(new_block)
        
        self.pending_transactions = [{
            'sender': 'Système',
            'recipient': mining_reward_address,
            'amount': self.mining_reward
        }]
        
        return new_block
    
    def is_valid(self):
        for i in range(1, len(self.chain)):
            current = self.chain[i]
            previous = self.chain[i-1]
            
            if current.hash != current.calculate_hash():
                return False
            if current.previous_hash != previous.hash:
                return False
        return True
