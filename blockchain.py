import hashlib
import json
import time
from typing import List, Dict


class Block:
    def __init__(self, index: int, timestamp: float, transactions: List[Dict], previous_hash: str, nonce: int = 0):
        self.index = index
        self.timestamp = timestamp
        self.transactions = transactions
        self.previous_hash = previous_hash
        self.nonce = nonce
        self.hash = self.calculate_hash()

    def calculate_hash(self) -> str:
        block_string = json.dumps({
            "index": self.index,
            "timestamp": self.timestamp,
            "transactions": self.transactions,
            "previous_hash": self.previous_hash,
            "nonce": self.nonce
        }, sort_keys=True)
        return hashlib.sha256(block_string.encode()).hexdigest()

    def mine_block(self, difficulty: int):
        target = "0" * difficulty
        while not self.hash.startswith(target):
            self.nonce += 1
            self.hash = self.calculate_hash()
        print(f"✅ Bloc miné ! Hash: {self.hash}")

    def to_dict(self) -> Dict:
        return {
            "index": self.index,
            "timestamp": self.timestamp,
            "transactions": self.transactions,
            "previous_hash": self.previous_hash,
            "nonce": self.nonce,
            "hash": self.hash
        }


class Blockchain:
    def __init__(self):
        self.chain: List[Block] = [self.create_genesis_block()]
        self.difficulty: int = 4
        self.pending_transactions: List[Dict] = []
        self.mining_reward: float = 10.0

    def create_genesis_block(self) -> Block:
        return Block(
            index=0,
            timestamp=time.time(),
            transactions=[],
            previous_hash="0"
        )

    def get_latest_block(self) -> Block:
        return self.chain[-1]

    def add_transaction(self, sender: str, recipient: str, amount: float) -> int:
        transaction = {
            "sender": sender,
            "recipient": recipient,
            "amount": amount,
            "timestamp": time.time()
        }
        self.pending_transactions.append(transaction)
        return self.get_latest_block().index + 1

    def mine_pending_transactions(self, mining_reward_address: str) -> Block:
        new_block = Block(
            index=len(self.chain),
            timestamp=time.time(),
            transactions=self.pending_transactions,
            previous_hash=self.get_latest_block().hash
        )

        print(f"⛏️  Mining bloc #{new_block.index}...")
        new_block.mine_block(self.difficulty)

        self.chain.append(new_block)

        # Récompense de mining pour le prochain bloc
        self.pending_transactions = [{
            "sender": "SYSTEM",
            "recipient": mining_reward_address,
            "amount": self.mining_reward,
            "timestamp": time.time()
        }]

        return new_block

    def calculate_balance(self, address: str) -> float:
        balance = 0.0

        # Blocs confirmés
        for block in self.chain:
            for tx in block.transactions:
                if tx.get("sender") == address:
                    balance -= float(tx.get("amount", 0))
                if tx.get("recipient") == address:
                    balance += float(tx.get("amount", 0))

        # Transactions en attente
        for tx in self.pending_transactions:
            if tx.get("sender") == address:
                balance -= float(tx.get("amount", 0))
            if tx.get("recipient") == address:
                balance += float(tx.get("amount", 0))

        return balance

    def is_chain_valid(self) -> bool:
        for i in range(1, len(self.chain)):
            current_block = self.chain[i]
            previous_block = self.chain[i - 1]

            if current_block.hash != current_block.calculate_hash():
                return False

            if current_block.previous_hash != previous_block.hash:
                return False

        return True

    def get_chain_data(self):
        return [block.to_dict() for block in self.chain]
