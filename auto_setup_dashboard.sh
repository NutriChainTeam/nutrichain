#!/usr/bin/env bash

set -e

PROJECT_DIR="/home/darksun/nutrichain_restored"

echo "=== NutriChain - Auto setup du dashboard ==="
cd "$PROJECT_DIR" || { echo "Dossier projet introuvable"; exit 1; }

mkdir -p static/js static/css templates

echo "-> Installation des features NutriChain (wallet, i18n, alerts, dashboard)..."

cat > static/js/wallet.js << 'EOF'
/* Connexion MetaMask et wallets Web3 */
let userAddress = null;
let web3 = null;

async function connectWallet() {
  if (typeof window.ethereum !== 'undefined') {
    try {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      userAddress = accounts[0];
      web3 = new Web3(window.ethereum);
      showAlert('success', translations[currentLang].walletconnected);
      updateWalletUI();
      loadUserBalance();
      return userAddress;
    } catch (error) {
      showAlert('error', translations[currentLang].walleterror);
      console.error(error);
    }
  } else {
    showAlert('warning', translations[currentLang].installmetamask);
    window.open('https://metamask.io/download', '_blank');
  }
}

function disconnectWallet() {
  userAddress = null;
  showAlert('info', translations[currentLang].walletdisconnected);
  updateWalletUI();
}

function updateWalletUI() {
  const walletBtn = document.getElementById('walletButton');
  const walletAddress = document.getElementById('walletAddress');
  const userBalance = document.getElementById('userBalance');

  if (!walletBtn || !walletAddress) return;

  if (userAddress) {
    walletBtn.textContent = translations[currentLang].disconnect;
    walletBtn.onclick = disconnectWallet;
    walletBtn.classList.add('connected');
    walletAddress.textContent = userAddress.slice(0, 6) + '...' + userAddress.slice(-4);
    walletAddress.style.display = 'inline-block';
  } else {
    walletBtn.textContent = translations[currentLang].connectwallet;
    walletBtn.onclick = connectWallet;
    walletBtn.classList.remove('connected');
    walletAddress.style.display = 'none';
    if (userBalance) userBalance.textContent = '';
  }
}

async function loadUserBalance() {
  if (!userAddress) return;
  try {
    const response = await fetch(`/balance/${userAddress}`);
    const data = await response.json();
    const userBalance = document.getElementById('userBalance');
    if (userBalance) {
      userBalance.textContent = data.balance + ' NUTRI';
    }
  } catch (error) {
    console.error('Error loading balance', error);
  }
}

if (typeof window !== 'undefined' && typeof window.ethereum !== 'undefined') {
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

cat > static/js/i18n.js << 'EOF'
/* Traductions multilingues */
const translations = {
  fr: {
    title: "NutriChain - Blockchain Humanitaire",
    connectwallet: "Connecter Wallet",
    disconnect: "Déconnecter",
    walletconnected: "Wallet connecté avec succès !",
    walleterror: "Erreur de connexion au wallet",
    walletdisconnected: "Wallet déconnecté",
    installmetamask: "Veuillez installer MetaMask pour continuer",
    donate: "Faire un don",
    donatenow: "Donner maintenant",
    amount: "Montant",
    mealsdonated: "repas donnés",
    statstitle: "Statistiques en temps réel",
    totalblocks: "Blocs minés",
    totaldonations: "Total des dons",
    staketokens: "Staker des tokens",
    stakenow: "Staker maintenant",
    apy: "APY",
    yourbalance: "Votre solde",
    transactions: "Transactions",
    blockchain: "Blockchain",
    transparency: "Transparence",
    verified: "Vérifié",
    maptitle: "Carte Mondiale des Aides",
    mealsdistributed: "Repas distribués",
    activecountries: "Pays actifs",
    donationsuccess: "Don effectué avec succès !",
    stakesuccess: "Tokens stakés avec succès !",
    loading: "Chargement..."
  },
  en: {
    title: "NutriChain - Humanitarian Blockchain",
    connectwallet: "Connect Wallet",
    disconnect: "Disconnect",
    walletconnected: "Wallet connected successfully!",
    walleterror: "Wallet connection error",
    walletdisconnected: "Wallet disconnected",
    installmetamask: "Please install MetaMask to continue",
    donate: "Make a donation",
    donatenow: "Donate now",
    amount: "Amount",
    mealsdonated: "meals donated",
    statstitle: "Real-time Statistics",
    totalblocks: "Blocks mined",
    totaldonations: "Total donations",
    staketokens: "Stake tokens",
    stakenow: "Stake now",
    apy: "APY",
    yourbalance: "Your balance",
    transactions: "Transactions",
    blockchain: "Blockchain",
    transparency: "Transparency",
    verified: "Verified",
    maptitle: "World Aid Map",
    mealsdistributed: "Meals distributed",
    activecountries: "Active countries",
    donationsuccess: "Donation successful!",
    stakesuccess: "Tokens staked successfully!",
    loading: "Loading..."
  }
};

let currentLang = 'fr';

function changeLanguage(lang) {
  currentLang = lang;
  localStorage.setItem('nutrichain_lang', lang);
  updatePageTranslations();
  updateWalletUI();
  document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
  document.documentElement.lang = lang;
}

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
  document.title = translations[currentLang].title;
}

window.addEventListener('DOMContentLoaded', () => {
  const savedLang = localStorage.getItem('nutrichain_lang') || 'fr';
  changeLanguage(savedLang);
});
EOF

cat > static/js/alerts.js << 'EOF'
/* Système d'alertes/notifications */
function showAlert(type, message, duration = 5000) {
  let alertContainer = document.getElementById('alertContainer');
  if (!alertContainer) {
    alertContainer = createAlertContainer();
  }

  const alert = document.createElement('div');
  alert.className = `alert alert-${type}`;
  alert.innerHTML = `
    <span class="alert-icon">${getAlertIcon(type)}</span>
    <span class="alert-message">${message}</span>
    <button class="alert-close" onclick="this.parentElement.remove()">×</button>
  `;

  alertContainer.appendChild(alert);
  setTimeout(() => alert.classList.add('show'), 10);

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
    success: '✔',
    error: '✖',
    warning: '⚠',
    info: 'ℹ'
  };
  return icons[type] || 'ℹ';
}
EOF

cat > static/css/alerts.css << 'EOF'
.alert-container {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 10000;
  max-width: 400px;
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
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}
.alert.show {
  opacity: 1;
  transform: translateX(0);
}
.alert-success {
  background: linear-gradient(135deg, #10b981 0, #059669 100);
  color: white;
}
.alert-error {
  background: linear-gradient(135deg, #ef4444 0, #dc2626 100);
  color: white;
}
.alert-warning {
  background: linear-gradient(135deg, #f59e0b 0, #d97706 100);
  color: white;
}
.alert-info {
  background: linear-gradient(135deg, #3b82f6 0, #2563eb 100);
  color: white;
}
.alert-icon {
  font-size: 20px;
  margin-right: 12px;
  font-weight: bold;
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
}
.alert-close:hover {
  opacity: 1;
}
EOF

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
  background: linear-gradient(135deg, #667eea 0, #764ba2 100);
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
  background: linear-gradient(135deg, #10b981 0, #059669 100);
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

cat > templates/dashboard.html << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>NutriChain - Blockchain Humanitaire</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <link
    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
    rel="stylesheet"
  >
  <link rel="stylesheet" href="{{ url_for('static', filename='css/alerts.css') }}">
  <link rel="stylesheet" href="{{ url_for('static', filename='css/wallet.css') }}">
  <link
    rel="stylesheet"
    href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
  />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
</head>
<body class="bg-light text-dark">

<div id="alertContainer"></div>

<nav class="navbar navbar-expand-lg navbar-dark" style="background: linear-gradient(135deg, #2e7d32, #1565c0);">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="#">
      <span>NutriChain</span>
    </a>
    <div class="d-flex align-items-center gap-3">
      <div class="language-selector">
        <button onclick="changeLanguage('fr')" class="active">FR</button>
        <button onclick="changeLanguage('en')">EN</button>
      </div>
      <div class="wallet-section">
        <button id="walletButton" onclick="connectWallet()" data-i18n="connectwallet">Connecter Wallet</button>
        <span id="walletAddress" style="display:none;"></span>
        <span id="userBalance"></span>
      </div>
    </div>
  </div>
</nav>

<div class="container-fluid mt-4">
  <div class="row">
    <main class="col-12 px-md-4 py-2">

      <section id="overview-section" class="mb-4">
        <h1 class="h3 mb-3" data-i18n="statstitle">Statistiques en temps réel</h1>
        <p class="text-secondary">
          Chaque token = 1 repas distribué. Suivez en temps réel les dons, la blockchain et le staking.
        </p>

        <div class="row">
          <div class="col-md-3">
            <div class="card bg-white border-success mb-3">
              <div class="card-body">
                <h5 class="card-title" data-i18n="totalblocks">Blocs minés</h5>
                <p class="card-text fs-4" id="statBlocks">-</p>
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="card bg-white border-info mb-3">
              <div class="card-body">
                <h5 class="card-title" data-i18n="transactions">Transactions</h5>
                <p class="card-text fs-4" id="statTx">-</p>
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="card bg-white border-warning mb-3">
              <div class="card-body">
                <h5 class="card-title">En attente</h5>
                <p class="card-text fs-4" id="statPending">-</p>
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="card bg-white border-primary mb-3">
              <div class="card-body">
                <h5 class="card-title">Dernier hash</h5>
                <p class="card-text small" id="statLastHash">-</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="map-section" class="mb-5">
        <h2 class="h4 mb-3" data-i18n="maptitle">Carte Mondiale des Aides</h2>
        <div id="map" style="height: 450px; border-radius: 0.75rem; overflow: hidden; border: 1px solid #ddd;"></div>
      </section>

      <section id="don-section" class="mb-5">
        <h2 class="h4 mb-3" data-i18n="donate">Faire un don NutriChain</h2>
        <form id="donationForm" class="row g-3">
          <div class="col-md-4">
            <label class="form-label">Donateur (adresse ou pseudo)</label>
            <input type="text" class="form-control" id="donor" placeholder="0x123... ou 'anonyme'">
          </div>
          <div class="col-md-4">
            <label class="form-label">Région</label>
            <input type="text" class="form-control" id="region" placeholder="afrique, asie, global...">
          </div>
          <div class="col-md-4">
            <label class="form-label" data-i18n="amount">Montant (NUTRI)</label>
            <input type="number" class="form-control" id="amount" min="0" step="0.01" required>
          </div>
          <div class="col-12 d-flex justify-content-end">
            <button type="submit" class="btn btn-success" data-i18n="donatenow">
              Envoyer le don
            </button>
          </div>
        </form>
        <div class="mt-3" id="donationStatus"></div>
      </section>

      <section id="stake-section" class="mb-5">
        <h2 class="h4 mb-3" data-i18n="staketokens">Staking & rendement</h2>
        <form id="stakeForm" class="row g-3">
          <div class="col-md-6">
            <label class="form-label">Adresse</label>
            <input type="text" class="form-control" id="stakeAddress" placeholder="Adresse à staker">
          </div>
          <div class="col-md-3">
            <label class="form-label" data-i18n="amount">Montant (NUTRI)</label>
            <input type="number" class="form-control" id="stakeAmount" min="0" step="0.01">
          </div>
          <div class="col-md-3 d-flex align-items-end">
            <button type="submit" class="btn btn-warning w-100" data-i18n="stakenow">
              Staker
            </button>
          </div>
        </form>
        <div class="mt-3" id="stakeStatus"></div>
      </section>

      <section id="chain-section" class="mb-5">
        <h2 class="h4 mb-3" data-i18n="blockchain">Derniers blocs</h2>
        <div class="table-responsive">
          <table class="table table-striped align-middle">
            <thead>
              <tr>
                <th>#</th>
                <th>Hash</th>
                <th>Précédent</th>
                <th>Tx</th>
              </tr>
            </thead>
            <tbody id="chainTableBody"></tbody>
          </table>
        </div>
      </section>

    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/web3@latest/dist/web3.min.js"></script>
<script src="{{ url_for('static', filename='js/i18n.js') }}"></script>
<script src="{{ url_for('static', filename='js/alerts.js') }}"></script>
<script src="{{ url_for('static', filename='js/wallet.js') }}"></script>

<script>
  async function loadStats() {
    try {
      const res = await fetch('/stats');
      const data = await res.json();
      document.getElementById('statBlocks').textContent = data.total_blocks;
      document.getElementById('statTx').textContent = data.total_transactions;
      document.getElementById('statPending').textContent = data.pending_transactions;
      document.getElementById('statLastHash').textContent = data.last_block_hash.slice(0, 16) + '...';
    } catch (e) {
      console
