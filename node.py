from p2pnetwork.node import Node
import json

class BlockchainNode(Node):
    def __init__(self, host, port, id=None, callback=None, max_connections=0):
        super(BlockchainNode, self).__init__(host, port, id, callback, max_connections)
        self.blockchain = None  # Sera défini après l'initialisation
        print(f"Nœud P2P initialisé sur {host}:{port}")
    
    def set_blockchain(self, blockchain):
        """Définir l'instance blockchain après l'initialisation"""
        self.blockchain = blockchain
    
    def outbound_node_connected(self, connected_node):
        """Appelé quand une connexion sortante est établie"""
        print(f"✓ Connecté au nœud: {connected_node.id}")
        # Synchroniser la blockchain avec ce nœud
        self.sync_blockchain(connected_node)
    
    def inbound_node_connected(self, connected_node):
        """Appelé quand un nœud se connecte à nous"""
        print(f"✓ Nouveau nœud connecté: {connected_node.id}")
    
    def node_message(self, connected_node, data):
        """Traiter les messages reçus des autres nœuds"""
        try:
            message = json.loads(data)
            
            if message['type'] == 'new_block':
                print(f"📦 Nouveau bloc reçu de {connected_node.id}")
                # Ajouter le bloc à notre blockchain
                if self.blockchain:
                    self.blockchain.add_received_block(message['block'])
            
            elif message['type'] == 'new_transaction':
                print(f"💸 Nouvelle transaction reçue de {connected_node.id}")
                # Ajouter la transaction au mempool
                if self.blockchain:
                    self.blockchain.add_transaction(
                        message['transaction']['sender'],
                        message['transaction']['recipient'],
                        message['transaction']['amount']
                    )
            
            elif message['type'] == 'request_chain':
                print(f"📨 Demande de chaîne de {connected_node.id}")
                # Envoyer notre blockchain
                self.send_chain(connected_node)
            
            elif message['type'] == 'chain':
                print(f"🔗 Chaîne reçue de {connected_node.id}")
                # Synchroniser avec la chaîne reçue
                if self.blockchain:
                    self.blockchain.sync_chain(message['chain'])
        
        except json.JSONDecodeError:
            print(f"❌ Erreur de décodage du message de {connected_node.id}")
    
    def node_disconnect_with_outbound_node(self, connected_node):
        """Appelé quand une connexion sortante est fermée"""
        print(f"⚠ Déconnecté du nœud: {connected_node.id}")
    
    def node_request_to_stop(self):
        """Appelé quand le nœud s'arrête"""
        print("🛑 Arrêt du nœud P2P...")
    
    def broadcast_block(self, block):
        """Diffuser un nouveau bloc à tous les nœuds"""
        message = json.dumps({
            'type': 'new_block',
            'block': block.__dict__
        })
        self.send_to_nodes(message)
        print(f"📢 Bloc diffusé à {len(self.all_nodes)} nœuds")
    
    def broadcast_transaction(self, transaction):
        """Diffuser une nouvelle transaction à tous les nœuds"""
        message = json.dumps({
            'type': 'new_transaction',
            'transaction': transaction
        })
        self.send_to_nodes(message)
        print(f"📢 Transaction diffusée à {len(self.all_nodes)} nœuds")
    
    def sync_blockchain(self, connected_node):
        """Demander la blockchain complète à un nœud"""
        message = json.dumps({'type': 'request_chain'})
        self.send_to_node(connected_node, message)
    
    def send_chain(self, connected_node):
        """Envoyer notre blockchain à un nœud"""
        if self.blockchain:
            message = json.dumps({
                'type': 'chain',
                'chain': [block.__dict__ for block in self.blockchain.chain]
            })
            self.send_to_node(connected_node, message)
    
    def get_connected_nodes(self):
        """Obtenir la liste des nœuds connectés"""
        return [
            {'id': node.id, 'host': node.host, 'port': node.port}
            for node in self.all_nodes
        ]
