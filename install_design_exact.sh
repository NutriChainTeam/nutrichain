#!/bin/bash

echo "=========================================="
echo "🎯 Installation du design EXACT"
echo "=========================================="
echo ""

cd ~/nutrichain_restored
mkdir -p templates

cat > templates/dashboard.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NutriChain - Blockchain Humanitaire</title>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/web3@latest/dist/web3.min.js"></script>
    <link rel="stylesheet" href="/static/css/alerts.css">
    <link rel="stylesheet" href="/static/css/wallet.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        header {
            background: rgba(255, 255, 255, 0.95);
            padding: 20px 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header-content {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }
        .logo-section { display: flex; align-items: center; gap: 15px; }
        .logo-icon { width: 50px; height: 50px; }
        .logo-text h1 { color: #1f2937; font-size: 24px; font-weight: 700; }
        .logo-text p { color: #6b7280; font-size: 12px; }
        .container { max-width: 1400px; margin: 0 auto; padding: 30px 20px; }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .stat-header h3 { color: #6b7280; font-size: 14px; font-weight: 500; }
        .stat-icon { font-size: 24px; }
        .stat-value { color: #1f2937; font-size: 36px; font-weight: 700; margin-bottom: 5px; }
        .stat-change { color: #10b981; font-size: 14px; font-weight: 500; }
        .map-section {
            background: white;
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .map-section h2 {
            color: #1f2937;
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #map { height: 500px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .action-card {
            background: white;
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .action-card h2 { color: #1f2937; font-size: 20px; font-weight: 700; margin-bottom: 10px; }
        .action-card p { color: #6b7280; font-size: 14px; margin-bottom: 20px; }
        .input-group { margin-bottom: 20px; }
        .input-group label {
            display: block;
            color: #374151;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
        }
        .input-group input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.2s;
        }
        .input-group input:focus { outline: none; border-color: #667eea; }
        .btn {
            width: 100%;
            padding: 14px 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }
        footer {
            background: rgba(255, 255, 255, 0.95);
            padding: 40px 20px;
            margin-top: 50px;
        }
        .footer-content {
            max-width: 1400px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 30px;
        }
        .footer-section h3 { color: #1f2937; font-size: 18px; font-weight: 700; margin-bottom: 15px; }
        .footer-section p, .footer-section a {
            color: #6b7280;
            font-size: 14px;
            text-decoration: none;
            display: block;
            margin-bottom: 8px;
        }
        .footer-section a:hover { color: #667eea; }
        .footer-bottom {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
            color: #6b7280;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div id="alertContainer"></div>
    <header>
        <div class="header-content">
            <div class="logo-section">
                <svg class="logo-icon" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <path d="M50,85 C50,85 20,60 20,40 C20,25 30,20 40,25 C45,27 50,35 50,35 C50,35 55,27 60,25 C70,20 80,25 80,40 C80,60 50,85 50,85 Z" 
                          fill="#ef4444" stroke="#dc2626" stroke-width="2"/>
                    <line x1="35" y1="30" x2="35" y2="50" stroke="#1f2937" stroke-width="2"/>
                    <line x1="32" y1="28" x2="32" y2="35" stroke="#1f2937" stroke-width="1.5"/>
                    <line x1="35" y1="28" x2="35" y2="35" stroke="#1f2937" stroke-width="1.5"/>
                    <line x1="38" y1="28" x2="38" y2="35" stroke="#1f2937" stroke-width="1.5"/>
                    <line x1="65" y1="30" x2="65" y2="50" stroke="#1f2937" stroke-width="2"/>
                    <path d="M62,28 L68,28 L68,33 L62,33 Z" fill="#1f2937"/>
                </svg>
                <div class="logo-text">
                    <h1>NutriChain</h1>
                    <p>Blockchain Humanitaire</p>
                </div>
            </div>
            <div class="language-selector">
                <button onclick="changeLanguage('fr')" class="active">🇫🇷 FR</button>
                <button onclick="changeLanguage('en')">🇬🇧 EN</button>
                <button onclick="changeLanguage('es')">🇪🇸 ES</button>
                <button onclick="changeLanguage('ar')">🇸🇦 AR</button>
            </div>
            <div class="wallet-section">
                <button id="walletButton" onclick="connectWallet()">Connecter Wallet</button>
                <span id="walletAddress" style="display: none;"></span>
                <span id="userBalance"></span>
            </div>
        </div>
    </header>
    <div class="container">
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-header"><h3>Repas Distribués</h3><span class="stat-icon">🍽️</span></div>
                <div class="stat-value">12,847</div>
                <div class="stat-change">↑ +127 aujourd'hui</div>
            </div>
            <div class="stat-card">
                <div class="stat-header"><h3>Dons Reçus</h3><span class="stat-icon">💰</span></div>
                <div class="stat-value">15,320</div>
                <div class="stat-change">NUTRI tokens</div>
            </div>
            <div class="stat-card">
                <div class="stat-header"><h3>Pays Actifs</h3><span class="stat-icon">🌍</span></div>
                <div class="stat-value">12</div>
                <div class="stat-change">4 continents</div>
            </div>
            <div class="stat-card">
                <div class="stat-header"><h3>Transparence</h3><span class="stat-icon">✓</span></div>
                <div class="stat-value">100%</div>
                <div class="stat-change">Blockchain</div>
            </div>
        </div>
        <div class="map-section">
            <h2>🌍 Carte Mondiale des Aides</h2>
            <div id="map"></div>
        </div>
        <div class="actions-grid">
            <div class="action-card">
                <h2>Faire un Don</h2>
                <p>Chaque token = 1 repas distribué</p>
                <div class="input-group">
                    <label>Montant (NUTRI)</label>
                    <input type="number" id="donationAmount" placeholder="10" min="1">
                </div>
                <button class="btn" onclick="handleDonation(document.getElementById('donationAmount').value)">Donner maintenant</button>
            </div>
            <div class="action-card">
                <h2>Staker des Tokens</h2>
                <p>APY: 7.25% - Soutenez le réseau</p>
                <div class="input-group">
                    <label>Montant (NUTRI)</label>
                    <input type="number" id="stakeAmount" placeholder="100" min="1">
                </div>
                <button class="btn" onclick="handleStaking(document.getElementById('stakeAmount').value)">Staker maintenant</button>
            </div>
        </div>
    </div>
    <footer>
        <div class="footer-content">
            <div class="footer-section">
                <h3>NutriChain</h3>
                <p>Blockchain humanitaire pour une nutrition durable et transparente</p>
                <p>📧 contact@nutrichain.org</p>
            </div>
            <div class="footer-section">
                <h3>Liens Rapides</h3>
                <a href="#">Blockchain</a>
                <a href="#">Faire un don</a>
                <a href="#">Staking</a>
                <a href="#">Documentation</a>
            </div>
            <div class="footer-section">
                <h3>Communauté</h3>
                <a href="https://github.com/NutriChainTeam/nutrichain">GitHub</a>
                <a href="#">Discord</a>
                <a href="#">Twitter</a>
            </div>
            <div class="footer-section">
                <h3>Statistiques</h3>
                <p>Blocs minés: <span id="footerBlocks">-</span></p>
                <p>Transactions: <span id="footerTx">-</span></p>
            </div>
        </div>
        <div class="footer-bottom">© 2025 NutriChain Team - Open Source | MIT License</div>
    </footer>
    <script src="/static/js/i18n.js"></script>
    <script src="/static/js/alerts.js"></script>
    <script src="/static/js/wallet.js"></script>
    <script>
        const map = L.map('map').setView([20, 0], 2);
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);
        const locs = [
            { coords: [14.5, -14.5], country: "Sénégal", meals: 2847 },
            { coords: [9.0, 38.7], country: "Éthiopie", meals: 3251 },
            { coords: [15.3, 44.2], country: "Yémen", meals: 1893 },
            { coords: [23.8, 90.4], country: "Bangladesh", meals: 2104 }
        ];
        locs.forEach(l => {
            L.circleMarker(l.coords, {
                radius: 15, fillColor: "#ef4444", color: "#dc2626", weight: 2, fillOpacity: 0.7
            }).addTo(map).bindPopup(\`<b>\${l.country}</b><br>🍽️ \${l.meals} repas\`);
        });
        async function loadStats() {
            try {
                const r = await fetch('/stats');
                const d = await r.json();
                document.getElementById('footerBlocks').textContent = d.total_blocks || 0;
                document.getElementById('footerTx').textContent = d.pending_transactions || 0;
            } catch(e) {}
        }
        loadStats();
        setInterval(loadStats, 10000);
    </script>
</body>
</html>
HTMLEOF

echo "✅ Installation terminée !"
echo "🚀 Lancez: python api.py"
