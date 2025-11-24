#!/bin/bash

echo "=========================================="
echo "🚀 NutriChain - Installation Complète"
echo "=========================================="
echo ""
echo "📦 Installation des fonctionnalités :"
echo "   ✓ Connexion Wallet (MetaMask/Web3)"
echo "   ✓ Support Multilingue (FR/EN/ES/AR)"
echo "   ✓ Système d'Alertes"
echo ""

# Créer la structure des dossiers
echo "📁 Création de la structure..."
mkdir -p static/js static/css templates

# ========== 1. WALLET CONNECTION ==========
echo "🔐 Installation du système de wallet..."
cat > static/js/wallet.js << 'EOF'
// Connexion MetaMask et wallets Web3
let userAddress = null;
let web3 = null;

// Détecter MetaMask
async function connectWallet() {
    if (typeof window.ethereum !== 'undefined') {
        try {
            const accounts = await window.ethereum.request({ 
                method: 'eth_requestAccounts' 
            });
            userAddress = accounts[0];
            web3 = new Web3(window.ethereum);
            
            showAlert('success', translations[currentLang].wallet_connected);
            updateWalletUI();
            loadUserBalance();
            return userAddress;
        } catch (error) {
            showAlert('error', translations[currentLang].wallet_error);
            console.error(error);
        }
    } else {
        showAlert('warning', translations[currentLang].install_metamask);
        window.open('https://metamask.io/download/', '_blank');
    }
}

// Déconnexion
function disconnectWallet() {
    userAddress = null;
    showAlert('info', translations[currentLang].wallet_disconnected);
    updateWalletUI();
}

// Mise à jour de l'interface
function updateWalletUI() {
    const walletBtn = document.getElementById('walletButton');
    const walletAddress = document.getElementById('walletAddress');
    
    if (userAddress) {
        walletBtn.textContent = translations[currentLang].disconnect;
        walletBtn.onclick = disconnectWallet;
        walletBtn.classList.add('connected');
        walletAddress.textContent = `${userAddress.slice(0, 6)}...${userAddress.slice(-4)}`;
        walletAddress.style.display = 'inline-block';
    } else {
        walletBtn.textContent = translations[currentLang].connect_wallet;
        walletBtn.onclick = connectWallet;
        walletBtn.classList.remove('connected');
        walletAddress.style.display = 'none';
    }
}

// Charger le solde de l'utilisateur
async function loadUserBalance() {
    if (!userAddress) return;
    
    try {
        const response = await fetch(`/balance/${userAddress}`);
        const data = await response.json();
        document.getElementById('userBalance').textContent = `${data.balance} NUTRI`;
    } catch (error) {
        console.error('Error loading balance:', error);
    }
}

// Écouter les changements de compte
if (typeof window.ethereum !== 'undefined') {
    window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length === 0) {
            disconnectWallet();
        } else {
            userAddress = accounts[0];
            updateWalletUI();
            loadUserBalance();
        }
    });
}
EOF

# ========== 2. MULTILINGUE ==========
echo "🌐 Installation du système multilingue..."
cat > static/js/i18n.js << 'EOF'
// Traductions multilingues
const translations = {
    fr: {
        title: "NutriChain - Blockchain Humanitaire",
        connect_wallet: "Connecter Wallet",
        disconnect: "Déconnecter",
        wallet_connected: "Wallet connecté avec succès !",
        wallet_error: "Erreur de connexion au wallet",
        wallet_disconnected: "Wallet déconnecté",
        install_metamask: "Veuillez installer MetaMask pour continuer",
        donate: "Faire un don",
        donate_now: "Donner maintenant",
        amount: "Montant",
        meals_donated: "repas donnés",
        stats_title: "Statistiques en temps réel",
        total_blocks: "Blocs minés",
        total_donations: "Total des dons",
        stake_tokens: "Staker des tokens",
        stake_now: "Staker maintenant",
        apy: "APY",
        your_balance: "Votre solde",
        transactions: "Transactions",
        blockchain: "Blockchain",
        transparency: "Transparence",
        verified: "Vérifié",
        map_title: "Carte Mondiale des Aides",
        meals_distributed: "Repas distribués",
        active_countries: "Pays actifs",
        donation_success: "Don effectué avec succès !",
        stake_success: "Tokens stakés avec succès !",
        loading: "Chargement..."
    },
    en: {
        title: "NutriChain - Humanitarian Blockchain",
        connect_wallet: "Connect Wallet",
        disconnect: "Disconnect",
        wallet_connected: "Wallet connected successfully!",
        wallet_error: "Wallet connection error",
        wallet_disconnected: "Wallet disconnected",
        install_metamask: "Please install MetaMask to continue",
        donate: "Make a donation",
        donate_now: "Donate now",
        amount: "Amount",
        meals_donated: "meals donated",
        stats_title: "Real-time Statistics",
        total_blocks: "Blocks mined",
        total_donations: "Total donations",
        stake_tokens: "Stake tokens",
        stake_now: "Stake now",
        apy: "APY",
        your_balance: "Your balance",
        transactions: "Transactions",
        blockchain: "Blockchain",
        transparency: "Transparency",
        verified: "Verified",
        map_title: "World Aid Map",
        meals_distributed: "Meals distributed",
        active_countries: "Active countries",
        donation_success: "Donation successful!",
        stake_success: "Tokens staked successfully!",
        loading: "Loading..."
    },
    es: {
        title: "NutriChain - Blockchain Humanitario",
        connect_wallet: "Conectar Billetera",
        disconnect: "Desconectar",
        wallet_connected: "¡Billetera conectada con éxito!",
        wallet_error: "Error de conexión de billetera",
        wallet_disconnected: "Billetera desconectada",
        install_metamask: "Por favor instale MetaMask para continuar",
        donate: "Hacer una donación",
        donate_now: "Donar ahora",
        amount: "Cantidad",
        meals_donated: "comidas donadas",
        stats_title: "Estadísticas en tiempo real",
        total_blocks: "Bloques minados",
        total_donations: "Total de donaciones",
        stake_tokens: "Apostar tokens",
        stake_now: "Apostar ahora",
        apy: "TAE",
        your_balance: "Su saldo",
        transactions: "Transacciones",
        blockchain: "Blockchain",
        transparency: "Transparencia",
        verified: "Verificado",
        map_title: "Mapa Mundial de Ayuda",
        meals_distributed: "Comidas distribuidas",
        active_countries: "Países activos",
        donation_success: "¡Donación realizada con éxito!",
        stake_success: "¡Tokens apostados con éxito!",
        loading: "Cargando..."
    },
    ar: {
        title: "نوتريشين - بلوكشين إنساني",
        connect_wallet: "ربط المحفظة",
        disconnect: "قطع الاتصال",
        wallet_connected: "تم ربط المحفظة بنجاح!",
        wallet_error: "خطأ في الاتصال بالمحفظة",
        wallet_disconnected: "تم قطع اتصال المحفظة",
        install_metamask: "يرجى تثبيت MetaMask للمتابعة",
        donate: "تبرع",
        donate_now: "تبرع الآن",
        amount: "المبلغ",
        meals_donated: "وجبات متبرع بها",
        stats_title: "إحصائيات في الوقت الفعلي",
        total_blocks: "الكتل المُستخرجة",
        total_donations: "إجمالي التبرعات",
        stake_tokens: "رهن الرموز",
        stake_now: "رهن الآن",
        apy: "العائد السنوي",
        your_balance: "رصيدك",
        transactions: "المعاملات",
        blockchain: "بلوكشين",
        transparency: "الشفافية",
        verified: "تم التحقق",
        map_title: "خريطة المساعدات العالمية",
        meals_distributed: "الوجبات الموزعة",
        active_countries: "البلدان النشطة",
        donation_success: "تم التبرع بنجاح!",
        stake_success: "تم رهن الرموز بنجاح!",
        loading: "جاري التحميل..."
    }
};

let currentLang = 'fr';

// Changer de langue
function changeLanguage(lang) {
    currentLang = lang;
    localStorage.setItem('nutrichain_lang', lang);
    updatePageTranslations();
    updateWalletUI(); // Mettre à jour le bouton wallet
    
    // Direction RTL pour l'arabe
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = lang;
}

// Mettre à jour toutes les traductions
function updatePageTranslations() {
    document.querySelectorAll('[data-i18n]').forEach(element => {
        const key = element.getAttribute('data-i18n');
        if (translations[currentLang][key]) {
            if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
                element.placeholder = translations[currentLang][key];
            } else {
                element.textContent = translations[currentLang][key];
            }
        }
    });
    
    // Mettre à jour le titre de la page
    document.title = translations[currentLang].title;
}

// Charger la langue au démarrage
window.addEventListener('DOMContentLoaded', () => {
    const savedLang = localStorage.getItem('nutrichain_lang') || 'fr';
    changeLanguage(savedLang);
});
EOF

# ========== 3. SYSTÈME D'ALERTES ==========
echo "🔔 Installation du système d'alertes..."
cat > static/js/alerts.js << 'EOF'
// Système d'alertes/notifications
function showAlert(type, message, duration = 5000) {
    const alertContainer = document.getElementById('alertContainer') || createAlertContainer();
    
    const alert = document.createElement('div');
    alert.className = `alert alert-${type}`;
    alert.innerHTML = `
        <span class="alert-icon">${getAlertIcon(type)}</span>
        <span class="alert-message">${message}</span>
        <button class="alert-close" onclick="this.parentElement.remove()">×</button>
    `;
    
    alertContainer.appendChild(alert);
    
    // Animation d'entrée
    setTimeout(() => alert.classList.add('show'), 10);
    
    // Auto-fermeture
    if (duration > 0) {
        setTimeout(() => {
            alert.classList.remove('show');
            setTimeout(() => alert.remove(), 300);
        }, duration);
    }
}

function createAlertContainer() {
    const container = document.createElement('div');
    container.id = 'alertContainer';
    container.className = 'alert-container';
    document.body.appendChild(container);
    return container;
}

function getAlertIcon(type) {
    const icons = {
        success: '✓',
        error: '✕',
        warning: '⚠',
        info: 'ℹ'
    };
    return icons[type] || 'ℹ';
}

// Alertes pour les actions blockchain
async function handleDonation(amount) {
    if (!userAddress) {
        showAlert('warning', translations[currentLang].install_metamask);
        return;
    }
    
    try {
        const response = await fetch('/donate', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                sender: userAddress,
                amount: parseFloat(amount)
            })
        });
        
        const data = await response.json();
        showAlert('success', translations[currentLang].donation_success);
        loadUserBalance();
    } catch (error) {
        showAlert('error', translations[currentLang].wallet_error);
    }
}

async function handleStaking(amount) {
    if (!userAddress) {
        showAlert('warning', translations[currentLang].install_metamask);
        return;
    }
    
    try {
        const response = await fetch('/stake', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                address: userAddress,
                amount: parseFloat(amount)
            })
        });
        
        const data = await response.json();
        showAlert('success', translations[currentLang].stake_success);
        loadUserBalance();
    } catch (error) {
        showAlert('error', translations[currentLang].wallet_error);
    }
}
EOF

# ========== 4. CSS POUR LES ALERTES ==========
echo "🎨 Installation des styles..."
cat > static/css/alerts.css << 'EOF'
.alert-container {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 10000;
    max-width: 400px;
}

[dir="rtl"] .alert-container {
    right: auto;
    left: 20px;
}

.alert {
    display: flex;
    align-items: center;
    padding: 15px 20px;
    margin-bottom: 10px;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    opacity: 0;
    transform: translateX(400px);
    transition: all 0.3s ease;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

[dir="rtl"] .alert {
    transform: translateX(-400px);
}

.alert.show {
    opacity: 1;
    transform: translateX(0);
}

.alert-success {
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
    color: white;
}

.alert-error {
    background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
    color: white;
}

.alert-warning {
    background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
    color: white;
}

.alert-info {
    background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
    color: white;
}

.alert-icon {
    font-size: 20px;
    margin-right: 12px;
    font-weight: bold;
}

[dir="rtl"] .alert-icon {
    margin-right: 0;
    margin-left: 12px;
}

.alert-message {
    flex: 1;
}

.alert-close {
    background: none;
    border: none;
    color: white;
    font-size: 24px;
    cursor: pointer;
    margin-left: 10px;
    padding: 0 5px;
    opacity: 0.8;
    transition: opacity 0.2s;
}

[dir="rtl"] .alert-close {
    margin-left: 0;
    margin-right: 10px;
}

.alert-close:hover {
    opacity: 1;
}
EOF

# ========== 5. CSS POUR LE WALLET ==========
cat > static/css/wallet.css << 'EOF'
.wallet-section {
    display: flex;
    align-items: center;
    gap: 15px;
    padding: 10px 20px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 12px;
}

#walletButton {
    padding: 10px 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    transition: transform 0.2s, box-shadow 0.2s;
}

#walletButton:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

#walletButton.connected {
    background: linear-gradient(135deg, #10b981 0%, #059669 100%);
}

#walletAddress {
    padding: 8px 15px;
    background: rgba(0, 0, 0, 0.2);
    border-radius: 6px;
    color: white;
    font-family: monospace;
    font-size: 14px;
}

#userBalance {
    padding: 8px 15px;
    background: rgba(255, 255, 255, 0.15);
    border-radius: 6px;
    color: white;
    font-weight: 600;
}

.language-selector {
    display: flex;
    gap: 8px;
}

.language-selector button {
    padding: 6px 12px;
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid rgba(255, 255, 255, 0.2);
    border-radius: 6px;
    color: white;
    cursor: pointer;
    transition: all 0.2s;
}

.language-selector button:hover,
.language-selector button.active {
    background: rgba(255, 255, 255, 0.2);
    border-color: rgba(255, 255, 255, 0.4);
}
EOF

# ========== 6. DASHBOARD HTML COMPLET ==========
echo "📄 Création du dashboard complet..."
cat > templates/dashboard.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NutriChain - Blockchain Humanitaire</title>
    <link rel="stylesheet" href="/static/css/alerts.css">
    <link rel="stylesheet" href="/static/css/wallet.css">
    <script src="https://cdn.jsdelivr.net/npm/web3@latest/dist/web3.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        header {
            background: rgba(255, 255, 255, 0.95);
            padding: 20px;
            border-radius: 16px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        h1 {
            color: #1f2937;
            font-size: 28px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        
        .stat-card h3 {
            color: #6b7280;
            font-size: 14px;
            margin-bottom: 10px;
        }
        
        .stat-card .value {
            color: #1f2937;
            font-size: 32px;
            font-weight: bold;
        }
        
        .action-section {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        
        .action-section h2 {
            color: #1f2937;
            margin-bottom: 20px;
        }
        
        .input-group {
            margin-bottom: 15px;
        }
        
        .input-group label {
            display: block;
            color: #6b7280;
            margin-bottom: 5px;
        }
        
        .input-group input {
            width: 100%;
            padding: 12px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 16px;
        }
        
        .btn {
            padding: 12px 24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 16px;
            transition: transform 0.2s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div id="alertContainer"></div>
    
    <div class="container">
        <header>
            <div class="header-content">
                <h1 data-i18n="title">NutriChain - Blockchain Humanitaire</h1>
                
                <div class="language-selector">
                    <button onclick="changeLanguage('fr')" class="active">🇫🇷 FR</button>
                    <button onclick="changeLanguage('en')">🇬🇧 EN</button>
                    <button onclick="changeLanguage('es')">🇪🇸 ES</button>
                    <button onclick="changeLanguage('ar')">🇸🇦 AR</button>
                </div>
                
                <div class="wallet-section">
                    <button id="walletButton" onclick="connectWallet()" data-i18n="connect_wallet">
                        Connecter Wallet
                    </button>
                    <span id="walletAddress" style="display: none;"></span>
                    <span id="userBalance"></span>
                </div>
            </div>
        </header>
        
        <div class="stats-grid">
            <div class="stat-card">
                <h3 data-i18n="meals_distributed">Repas distribués</h3>
                <div class="value" id="mealsCount">12,847</div>
            </div>
            <div class="stat-card">
                <h3 data-i18n="total_donations">Total des dons</h3>
                <div class="value" id="donationsCount">15,320 NUTRI</div>
            </div>
            <div class="stat-card">
                <h3 data-i18n="total_blocks">Blocs minés</h3>
                <div class="value" id="blocksCount">Loading...</div>
            </div>
            <div class="stat-card">
                <h3 data-i18n="transparency">Transparence</h3>
                <div class="value">100% ✓</div>
            </div>
        </div>
        
        <div class="action-section">
            <h2 data-i18n="donate">Faire un don</h2>
            <div class="input-group">
                <label data-i18n="amount">Montant (NUTRI)</label>
                <input type="number" id="donationAmount" placeholder="10" min="1">
            </div>
            <button class="btn" onclick="handleDonation(document.getElementById('donationAmount').value)" data-i18n="donate_now">
                Donner maintenant
            </button>
        </div>
        
        <div class="action-section">
            <h2 data-i18n="stake_tokens">Staker des tokens</h2>
            <p style="margin-bottom: 15px; color: #6b7280;">
                <span data-i18n="apy">APY</span>: 7.25%
            </p>
            <div class="input-group">
                <label data-i18n="amount">Montant (NUTRI)</label>
                <input type="number" id="stakeAmount" placeholder="100" min="1">
            </div>
            <button class="btn" onclick="handleStaking(document.getElementById('stakeAmount').value)" data-i18n="stake_now">
                Staker maintenant
            </button>
        </div>
    </div>
    
    <script src="/static/js/i18n.js"></script>
    <script src="/static/js/alerts.js"></script>
    <script src="/static/js/wallet.js"></script>
    <script>
        // Charger les statistiques
        async function loadStats() {
            try {
                const response = await fetch('/stats');
                const data = await response.json();
                document.getElementById('blocksCount').textContent = data.total_blocks || 0;
            } catch (error) {
                console.error('Error loading stats:', error);
            }
        }
        
        loadStats();
        setInterval(loadStats, 10000); // Mise à jour toutes les 10 secondes
    </script>
</body>
</html>
HTMLEOF

echo ""
echo "=========================================="
echo "✅ Installation terminée !"
echo "=========================================="
echo ""
echo "📂 Fichiers créés :"
echo "   ✓ static/js/wallet.js"
echo "   ✓ static/js/i18n.js"
echo "   ✓ static/js/alerts.js"
echo "   ✓ static/css/alerts.css"
echo "   ✓ static/css/wallet.css"
echo "   ✓ templates/dashboard.html"
echo ""
echo "🚀 Pour lancer NutriChain :"
echo "   python api.py"
echo ""
echo "🌐 Accédez à : http://localhost:5000"
echo ""
echo "📧 contact@nutrichain.org"
echo "=========================================="
