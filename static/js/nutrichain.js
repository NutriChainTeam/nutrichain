const API_URL = 'http://localhost:5000/api';
let userWallet = null;

// Charger au démarrage
document.addEventListener('DOMContentLoaded', function() {
    loadStats();
    setupEventListeners();
    
    // Auto-refresh toutes les 5 secondes
    setInterval(loadStats, 5000);
});

// Charger les statistiques
async function loadStats() {
    try {
        const response = await fetch(`${API_URL}/stats`);
        const data = await response.json();
        
        // Mettre à jour les stats tokens
        document.getElementById('nutriPrice').textContent = `$${data.nutricoin.price.toFixed(2)}`;
        document.getElementById('apy').textContent = `${data.apy.toFixed(2)}%`;
        document.getElementById('totalStaked').textContent = data.nutricoin.usdt_staked.toLocaleString();
        
        // Mettre à jour l'impact
        document.getElementById('mealsServed').textContent = data.meals.meals_distributed.toLocaleString();
        document.getElementById('peopleFed').textContent = data.meals.people_fed.toLocaleString();
        document.getElementById('countries').textContent = data.meals.countries_served;
        
    } catch (error) {
        console.error('Erreur chargement stats:', error);
    }
}

// Configuration des événements
function setupEventListeners() {
    // Connexion wallet
    const connectBtn = document.getElementById('connectWallet');
    if (connectBtn) {
        connectBtn.onclick = connectWallet;
    }
    
    // Formulaire de staking
    const stakeForm = document.getElementById('stakeForm');
    if (stakeForm) {
        stakeForm.onsubmit = handleStake;
        
        // Calcul en temps réel
        const stakeInput = document.getElementById('stakeAmount');
        if (stakeInput) {
            stakeInput.oninput = calculateStakeRewards;
        }
    }
    
    // Formulaire de retrait
    const withdrawForm = document.getElementById('withdrawForm');
    if (withdrawForm) {
        withdrawForm.onsubmit = handleWithdraw;
        
        const withdrawInput = document.getElementById('withdrawAmount');
        if (withdrawInput) {
            withdrawInput.oninput = calculateWithdrawal;
        }
    }
}

// Connecter un wallet
async function connectWallet() {
    try {
        const response = await fetch(`${API_URL}/wallet/new`, {
            method: 'POST'
        });
        
        userWallet = await response.json();
        
        // Mettre à jour l'interface
        document.getElementById('walletStatus').textContent = 
            userWallet.address.substring(0, 6) + '...' + userWallet.address.substring(38);
        
        // Charger le solde
        loadBalance();
        
        showNotification('✅ Wallet connecté !', 'success');
        
    } catch (error) {
        console.error('Erreur connexion wallet:', error);
        showNotification('❌ Erreur de connexion', 'danger');
    }
}

// Charger le solde utilisateur
async function loadBalance() {
    if (!userWallet) return;
    
    try {
        const response = await fetch(`${API_URL}/balance/${userWallet.address}`);
        const balance = await response.json();
        
        document.getElementById('userBalance').textContent = 
            balance.total_value.toFixed(2);
        
    } catch (error) {
        console.error('Erreur chargement solde:', error);
    }
}

// Calculer les récompenses de staking
function calculateStakeRewards() {
    const amount = parseFloat(document.getElementById('stakeAmount').value) || 0;
    const apy = 0.0725; // 7.25%
    
    document.getElementById('nutriToReceive').textContent = amount.toFixed(2);
    document.getElementById('yearlyInterest').textContent = (amount * apy).toFixed(2);
}

// Gérer le staking
async function handleStake(e) {
    e.preventDefault();
    
    if (!userWallet) {
        showNotification('⚠️ Connectez votre wallet d\'abord', 'warning');
        return;
    }
    
    const amount = parseFloat(document.getElementById('stakeAmount').value);
    
    if (amount < 10) {
        showNotification('❌ Minimum 10 USDT requis', 'danger');
        return;
    }
    
    try {
        showNotification('⏳ Staking en cours...', 'info');
        
        const response = await fetch(`${API_URL}/stake`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                address: userWallet.address,
                amount: amount
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            showNotification(`✅ ${result.nutricoin_received.toFixed(2)} NUTRICOIN reçus !`, 'success');
            
            // Reset le formulaire
            document.getElementById('stakeForm').reset();
            document.getElementById('nutriToReceive').textContent = '0';
            document.getElementById('yearlyInterest').textContent = '0';
            
            // Recharger les stats
            loadStats();
            loadBalance();
            
            // Miner le bloc
            await mineBlock();
            
        } else {
            showNotification('❌ ' + result.error, 'danger');
        }
        
    } catch (error) {
        console.error('Erreur staking:', error);
        showNotification('❌ Erreur lors du staking', 'danger');
    }
}

// Calculer le retrait
function calculateWithdrawal() {
    const amount = parseFloat(document.getElementById('withdrawAmount').value) || 0;
    document.getElementById('usdtToReceive').textContent = amount.toFixed(2);
}

// Gérer le retrait
async function handleWithdraw(e) {
    e.preventDefault();
    
    if (!userWallet) {
        showNotification('⚠️ Connectez votre wallet d\'abord', 'warning');
        return;
    }
    
    const amount = parseFloat(document.getElementById('withdrawAmount').value);
    
    try {
        showNotification('⏳ Retrait en cours...', 'info');
        
        const response = await fetch(`${API_URL}/withdraw`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                address: userWallet.address,
                amount: amount
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            showNotification(`✅ ${result.usdt_received.toFixed(2)} USDT reçus !`, 'success');
            
            document.getElementById('withdrawForm').reset();
            document.getElementById('usdtToReceive').textContent = '0';
            
            loadStats();
            loadBalance();
            
            await mineBlock();
            
        } else {
            showNotification('❌ ' + result.error, 'danger');
        }
        
    } catch (error) {
        console.error('Erreur retrait:', error);
        showNotification('❌ Erreur lors du retrait', 'danger');
    }
}

// Miner un bloc
async function mineBlock() {
    try {
        const response = await fetch(`${API_URL}/mine`, {
            method: 'POST'
        });
        
        const result = await response.json();
        console.log('Bloc miné:', result);
        
    } catch (error) {
        console.error('Erreur minage:', error);
    }
}

// Afficher une notification
function showNotification(message, type) {
    // Créer une notification Bootstrap
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed top-0 start-50 translate-middle-x mt-3`;
    alertDiv.style.zIndex = '9999';
    alertDiv.style.minWidth = '300px';
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(alertDiv);
    
    // Auto-supprimer après 3 secondes
    setTimeout(() => {
        alertDiv.remove();
    }, 3000);
}

// Charger les propositions DAO (si section existe)
async function loadProposals() {
    const container = document.getElementById('proposalsContainer');
    if (!container) return;
    
    // Propositions statiques pour démo
    const proposals = [
        {
            id: 1,
            title: 'Expansion en Afrique de l\'Ouest',
            description: 'Étendre notre programme au Sénégal, Mali et Burkina Faso',
            votesYes: 1247,
            votesNo: 89,
            status: 'active'
        },
        {
            id: 2,
            title: 'Partenariat avec la Croix-Rouge',
            description: 'Collaboration pour distribution d\'urgence',
            votesYes: 982,
            votesNo: 145,
            status: 'active'
        }
    ];
    
    container.innerHTML = '';
    
    proposals.forEach(prop => {
        const total = prop.votesYes + prop.votesNo;
        const yesPercent = (prop.votesYes / total * 100).toFixed(1);
        
        const propHtml = `
            <div class="proposal-card">
                <h5>${prop.title}</h5>
                <p class="text-muted">${prop.description}</p>
                
                <div class="vote-bar mb-2">
                    <div class="vote-bar-fill" style="width: ${yesPercent}%"></div>
                </div>
                
                <div class="d-flex justify-content-between mb-3">
                    <span><i class="bi bi-hand-thumbs-up-fill text-success"></i> ${prop.votesYes} (${yesPercent}%)</span>
                    <span><i class="bi bi-hand-thumbs-down-fill text-danger"></i> ${prop.votesNo}</span>
                </div>
                
                <div class="btn-group w-100">
                    <button class="btn btn-success" onclick="vote(${prop.id}, 'yes')">
                        <i class="bi bi-check-lg"></i> Voter Pour
                    </button>
                    <button class="btn btn-danger" onclick="vote(${prop.id}, 'no')">
                        <i class="bi bi-x-lg"></i> Voter Contre
                    </button>
                </div>
            </div>
        `;
        
        container.innerHTML += propHtml;
    });
}

// Voter sur une proposition
function vote(proposalId, voteType) {
    if (!userWallet) {
        showNotification('⚠️ Connectez votre wallet pour voter', 'warning');
        return;
    }
    
    showNotification(`✅ Vote "${voteType}" enregistré !`, 'success');
    
    // Recharger après un court délai
    setTimeout(loadProposals, 1000);
}

// Charger les propositions si la section existe
if (document.getElementById('proposalsContainer')) {
    loadProposals();
}
