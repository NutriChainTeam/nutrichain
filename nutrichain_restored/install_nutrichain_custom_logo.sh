#!/bin/bash

echo "=========================================="
echo "🍽️  NutriChain - Logo Personnalisé"
echo "=========================================="
echo ""

mkdir -p templates static

cat > templates/dashboard.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NutriChain | Aide Humanitaire Alimentaire</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #0d1117; color: #e5e7eb; min-height: 100vh; display: flex; flex-direction: column; }
        .main-content { flex: 1; }
        .sidebar { background: linear-gradient(135deg, #161b22 0%, #0d1117 100%); border-right: 1px solid #30363d; height: 100vh; position: fixed; width: 260px; overflow-y: auto; }
        .content-area { margin-left: 260px; }
        .card { background-color: #161b22; border: 1px solid #30363d; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3); border-radius: 12px; padding: 20px; }
        .btn-primary { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; font-weight: bold; padding: 12px 24px; border-radius: 8px; transition: all 0.3s; cursor: pointer; border: none; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(16, 185, 129, 0.3); }
        .btn-secondary { background-color: #f59e0b; color: white; font-weight: bold; padding: 12px 24px; border-radius: 8px; transition: all 0.3s; cursor: pointer; border: none; }
        .btn-secondary:hover { background-color: #d97706; }
        .stat-card { background: linear-gradient(135deg, #1f2937 0%, #111827 100%); border: 1px solid #374151; border-radius: 12px; padding: 20px; transition: transform 0.3s; }
        .stat-card:hover { transform: translateY(-5px); }
        input, textarea, select { background-color: #1f2937; border: 1px solid #374151; color: #e5e7eb; padding: 10px; border-radius: 6px; width: 100%; }
        input:focus, textarea:focus { outline: none; border-color: #10b981; }
        .nav-item { padding: 12px 20px; cursor: pointer; transition: all 0.3s; border-left: 3px solid transparent; }
        .nav-item:hover { background-color: #1f2937; border-left-color: #10b981; }
        .nav-item.active { background-color: #1f2937; border-left-color: #10b981; }
        .footer { background: linear-gradient(135deg, #161b22 0%, #0d1117 100%); border-top: 1px solid #30363d; padding: 40px 0; margin-top: 60px; }
        .logo-spin { animation: spin 3s linear infinite; }
        @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
        .impact-banner { background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 30px; border-radius: 12px; color: white; margin-bottom: 30px; }
        #map { height: 500px; border-radius: 12px; }
        .leaflet-popup-content-wrapper { background-color: #161b22; color: #e5e7eb; }
        .leaflet-popup-tip { background-color: #161b22; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="p-6 border-b border-[#30363d]">
            <h1 class="text-2xl font-bold text-white flex items-center">
                <!-- LOGO PERSONNALISÉ : Cœur + Fourchette + Couteau -->
                <svg class="w-8 h-8 mr-2 logo-spin" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <!-- Cœur -->
                    <path d="M50 85 C20 60, 10 45, 10 30 C10 15, 20 5, 30 5 C40 5, 45 15, 50 25 C55 15, 60 5, 70 5 C80 5, 90 15, 90 30 C90 45, 80 60, 50 85 Z" 
                          fill="#10b981" stroke="#059669" stroke-width="2"/>
                    <!-- Fourchette (gauche) -->
                    <line x1="35" y1="25" x2="35" y2="50" stroke="white" stroke-width="2"/>
                    <line x1="32" y1="25" x2="32" y2="35" stroke="white" stroke-width="1.5"/>
                    <line x1="38" y1="25" x2="38" y2="35" stroke="white" stroke-width="1.5"/>
                    <line x1="35" y1="25" x2="35" y2="35" stroke="white" stroke-width="1.5"/>
                    <!-- Couteau (droite) -->
                    <line x1="65" y1="28" x2="65" y2="50" stroke="white" stroke-width="2"/>
                    <path d="M62 25 L68 25 L65 28 Z" fill="white"/>
                </svg>
                NutriChain
            </h1>
            <p class="text-xs text-gray-400 mt-1">Aide Humanitaire Alimentaire</p>
        </div>
        <nav class="p-4">
            <div class="nav-item active" onclick="showSection('dashboard')">
                <i data-lucide="layout-dashboard" class="w-5 h-5 inline mr-3"></i>Dashboard
            </div>
            <div class="nav-item" onclick="showSection('map')">
                <i data-lucide="map" class="w-5 h-5 inline mr-3"></i>Carte Mondiale
            </div>
            <div class="nav-item" onclick="showSection('donate')">
                <i data-lucide="hand-heart" class="w-5 h-5 inline mr-3"></i>Faire un Don
            </div>
            <div class="nav-item" onclick="showSection('meals')">
                <i data-lucide="utensils" class="w-5 h-5 inline mr-3"></i>Repas Distribués
            </div>
            <div class="nav-item" onclick="showSection('transparency')">
                <i data-lucide="search-check" class="w-5 h-5 inline mr-3"></i>Transparence
            </div>
            <div class="nav-item" onclick="showSection('staking')">
                <i data-lucide="coins" class="w-5 h-5 inline mr-3"></i>Staking Solidaire
            </div>
            <div class="nav-item" onclick="showSection('governance')">
                <i data-lucide="vote" class="w-5 h-5 inline mr-3"></i>Gouvernance DAO
            </div>
        </nav>
        <div class="absolute bottom-4 left-0 right-0 px-6">
            <div class="bg-[#1f2937] rounded-lg p-3 text-xs">
                <div class="flex items-center text-green-400 mb-1">
                    <div class="w-2 h-2 bg-green-400 rounded-full mr-2 animate-pulse"></div>Réseau Actif
                </div>
                <div class="text-gray-400">localhost:5000</div>
            </div>
        </div>
    </div>

    <div class="content-area main-content">
        <div class="p-8">
            <!-- DASHBOARD -->
            <div id="dashboardSection" class="section">
                <div class="impact-banner">
                    <h2 class="text-3xl font-bold mb-2">🍽️ 1 Token NUTRI = 1 Repas Garanti</h2>
                    <p class="text-green-100">Blockchain transparente pour nourrir les personnes dans le besoin</p>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                    <div class="stat-card">
                        <div class="flex justify-between items-start mb-3">
                            <div class="text-gray-400 text-sm">Repas Distribués</div>
                            <i data-lucide="utensils" class="w-8 h-8 text-green-400"></i>
                        </div>
                        <div class="text-4xl font-bold text-white">12,847</div>
                        <div class="text-xs text-green-400 mt-2">↑ +127 aujourd'hui</div>
                    </div>
                    <div class="stat-card">
                        <div class="flex justify-between items-start mb-3">
                            <div class="text-gray-400 text-sm">Dons Reçus</div>
                            <i data-lucide="hand-heart" class="w-8 h-8 text-orange-400"></i>
                        </div>
                        <div class="text-4xl font-bold text-white">15,320</div>
                        <div class="text-xs text-gray-400 mt-2">NUTRI tokens</div>
                    </div>
                    <div class="stat-card">
                        <div class="flex justify-between items-start mb-3">
                            <div class="text-gray-400 text-sm">Pays Actifs</div>
                            <i data-lucide="map-pin" class="w-8 h-8 text-purple-400"></i>
                        </div>
                        <div class="text-4xl font-bold text-white">12</div>
                        <div class="text-xs text-gray-400 mt-2">Sur 4 continents</div>
                    </div>
                    <div class="stat-card">
                        <div class="flex justify-between items-start mb-3">
                            <div class="text-gray-400 text-sm">Transparence</div>
                            <i data-lucide="shield-check" class="w-8 h-8 text-cyan-400"></i>
                        </div>
                        <div class="text-4xl font-bold text-white">100%</div>
                        <div class="text-xs text-gray-400 mt-2">Blockchain</div>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div class="card">
                        <h3 class="text-xl font-bold text-white mb-4 flex items-center">
                            <i data-lucide="map" class="w-6 h-6 mr-2 text-cyan-400"></i>Carte Mondiale
                        </h3>
                        <p class="text-gray-400 text-sm mb-4">Voir les aides en temps réel</p>
                        <button onclick="showSection('map')" class="btn-primary w-full">Voir la Carte</button>
                    </div>
                    <div class="card">
                        <h3 class="text-xl font-bold text-white mb-4 flex items-center">
                            <i data-lucide="hand-heart" class="w-6 h-6 mr-2 text-green-400"></i>Faire un Don
                        </h3>
                        <p class="text-gray-400 text-sm mb-4">Chaque token finance un repas</p>
                        <button onclick="showSection('donate')" class="btn-secondary w-full">Donner</button>
                    </div>
                    <div class="card">
                        <h3 class="text-xl font-bold text-white mb-4 flex items-center">
                            <i data-lucide="coins" class="w-6 h-6 mr-2 text-orange-400"></i>Staking Solidaire
                        </h3>
                        <p class="text-gray-400 text-sm mb-4">Vos récompenses = repas gratuits</p>
                        <button onclick="showSection('staking')" class="btn-primary w-full">Staker</button>
                    </div>
                </div>
            </div>

            <!-- CARTE MONDIALE -->
            <div id="mapSection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">🌍 Carte Mondiale des Aides</h2>
                <div class="card mb-6">
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4 text-center">
                        <div><div class="text-2xl font-bold text-green-400">45</div><div class="text-xs text-gray-400">Cantines actives</div></div>
                        <div><div class="text-2xl font-bold text-orange-400">12</div><div class="text-xs text-gray-400">Pays couverts</div></div>
                        <div><div class="text-2xl font-bold text-purple-400">4,521</div><div class="text-xs text-gray-400">Personnes aidées</div></div>
                        <div><div class="text-2xl font-bold text-cyan-400">127</div><div class="text-xs text-gray-400">Repas aujourd'hui</div></div>
                    </div>
                </div>
                <div class="card">
                    <div id="map"></div>
                </div>
            </div>

            <!-- FAIRE UN DON -->
            <div id="donateSection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">🍽️ Faire un Don</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="card">
                        <h3 class="text-xl font-bold text-white mb-4">Donner des Tokens NUTRI</h3>
                        <div class="bg-green-900/20 border border-green-700 rounded-lg p-4 mb-4">
                            <p class="text-green-200 text-sm mb-2">
                                <i data-lucide="info" class="w-4 h-4 inline mr-2"></i><strong>1 NUTRI = 1 repas complet</strong>
                            </p>
                            <p class="text-xs text-gray-400">Transparence totale sur la blockchain</p>
                        </div>
                        <form class="space-y-4">
                            <div>
                                <label class="block text-gray-400 mb-2">Montant (NUTRI)</label>
                                <input type="number" id="donateAmount" placeholder="10" min="1" value="10">
                                <p class="text-xs text-gray-400 mt-1">= <span id="mealCount">10</span> repas</p>
                            </div>
                            <div>
                                <label class="block text-gray-400 mb-2">Région (optionnel)</label>
                                <select>
                                    <option>Toutes les régions</option>
                                    <option>Afrique Subsaharienne</option>
                                    <option>Asie du Sud</option>
                                    <option>Moyen-Orient</option>
                                    <option>Amérique Latine</option>
                                </select>
                            </div>
                            <button type="submit" class="btn-primary w-full">
                                <i data-lucide="hand-heart" class="w-5 h-5 inline mr-2"></i>Faire un Don
                            </button>
                        </form>
                    </div>
                    <div class="card">
                        <h3 class="text-xl font-bold text-white mb-4">Suggestions</h3>
                        <div class="space-y-3">
                            <div class="bg-[#1f2937] p-4 rounded-lg cursor-pointer hover:bg-[#374151]">
                                <div class="font-bold text-white">5 NUTRI</div>
                                <div class="text-xs text-gray-400">5 repas / 1 personne</div>
                            </div>
                            <div class="bg-[#1f2937] p-4 rounded-lg cursor-pointer hover:bg-[#374151]">
                                <div class="font-bold text-white">30 NUTRI</div>
                                <div class="text-xs text-gray-400">1 famille / semaine</div>
                            </div>
                            <div class="bg-[#1f2937] p-4 rounded-lg cursor-pointer hover:bg-[#374151]">
                                <div class="font-bold text-white">100 NUTRI</div>
                                <div class="text-xs text-gray-400">Cantine scolaire</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- REPAS -->
            <div id="mealsSection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">🍽️ Repas Distribués</h2>
                <div class="card">
                    <div class="bg-[#1f2937] border-l-4 border-orange-400 p-4 rounded mb-3">
                        <div class="flex justify-between">
                            <div>
                                <div class="font-bold text-white">127 repas distribués</div>
                                <div class="text-xs text-gray-400">Restos du Cœur - Paris, France</div>
                            </div>
                            <div class="text-sm text-gray-400">Il y a 2h</div>
                        </div>
                    </div>
                    <div class="bg-[#1f2937] border-l-4 border-orange-400 p-4 rounded">
                        <div class="flex justify-between">
                            <div>
                                <div class="font-bold text-white">50 repas distribués</div>
                                <div class="text-xs text-gray-400">Cantine Al-Amal - Damas, Syrie</div>
                            </div>
                            <div class="text-sm text-gray-400">Il y a 5h</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TRANSPARENCE -->
            <div id="transparencySection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">🔍 Transparence Blockchain</h2>
                <div class="card">
                    <div class="bg-[#1f2937] border-l-4 border-green-400 p-4 rounded mb-3">
                        <div class="text-sm mb-1"><strong>Don:</strong> 100 NUTRI → Programme Éthiopie</div>
                        <div class="text-xs text-gray-400 font-mono">Hash: 0x7a3f8e9b2c1d5f4a...d9e2</div>
                    </div>
                    <div class="bg-[#1f2937] border-l-4 border-green-400 p-4 rounded">
                        <div class="text-sm mb-1"><strong>Don:</strong> 50 NUTRI → Secours Catholique France</div>
                        <div class="text-xs text-gray-400 font-mono">Hash: 0x2b8c6d7e9f1a3b5c...f4a1</div>
                    </div>
                </div>
            </div>

            <!-- STAKING -->
            <div id="stakingSection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">💎 Staking Solidaire</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="card">
                        <h3 class="text-xl font-bold text-white mb-4">Comment ça marche ?</h3>
                        <div class="bg-blue-900/20 border border-blue-700 rounded-lg p-4 mb-4">
                            <ul class="space-y-2 text-sm text-blue-200">
                                <li>✓ Stakez vos tokens NUTRI</li>
                                <li>✓ Gagnez 7% APY de récompenses</li>
                                <li>✓ 100% des récompenses = repas gratuits</li>
                                <li>✓ Votre capital reste disponible</li>
                            </ul>
                        </div>
                        <form class="space-y-4">
                            <div>
                                <label class="block text-gray-400 mb-2">Montant à Staker</label>
                                <input type="number" placeholder="100" min="1">
                            </div>
                            <button type="submit" class="btn-primary w-full">
                                <i data-lucide="coins" class="w-5 h-5 inline mr-2"></i>Staker pour Aider
                            </button>
                        </form>
                    </div>
                    <div class="card">
                        <h3 class="text-xl font-bold text-white mb-4">Votre Impact</h3>
                        <div class="bg-[#1f2937] p-4 rounded-lg mb-3">
                            <div class="text-gray-400 text-sm mb-1">Tokens Stakés</div>
                            <div class="text-3xl font-bold text-white">0 NUTRI</div>
                        </div>
                        <div class="bg-[#1f2937] p-4 rounded-lg">
                            <div class="text-gray-400 text-sm mb-1">Repas Financés par vos Récompenses</div>
                            <div class="text-2xl font-bold text-green-400">0 repas/an</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- GOUVERNANCE -->
            <div id="governanceSection" class="section" style="display:none;">
                <h2 class="text-3xl font-bold text-white mb-6">🗳️ Gouvernance DAO</h2>
                <div class="card">
                    <div class="flex justify-between items-start mb-3">
                        <div>
                            <h3 class="font-bold text-white text-lg">Financer 500 repas en Éthiopie</h3>
                            <p class="text-sm text-gray-400">Programme d'urgence dans la région du Tigré</p>
                        </div>
                        <span class="text-xs bg-green-900/30 text-green-400 px-3 py-1 rounded-full">En cours</span>
                    </div>
                    <div class="flex gap-2 mt-4">
                        <button class="btn-primary flex-1">Voter Pour (78%)</button>
                        <button class="btn-secondary flex-1">Voter Contre (22%)</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- FOOTER -->
        <footer class="footer">
            <div class="max-w-7xl mx-auto px-8">
                <div class="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
                    <div>
                        <h3 class="text-white font-bold mb-4 flex items-center">
                            <!-- Logo dans le footer aussi -->
                            <svg class="w-6 h-6 mr-2 logo-spin" viewBox="0 0 100 100">
                                <path d="M50 85 C20 60, 10 45, 10 30 C10 15, 20 5, 30 5 C40 5, 45 15, 50 25 C55 15, 60 5, 70 5 C80 5, 90 15, 90 30 C90 45, 80 60, 50 85 Z" 
                                      fill="#10b981" stroke="#059669" stroke-width="2"/>
                                <line x1="35" y1="25" x2="35" y2="50" stroke="white" stroke-width="2"/>
                                <line x1="32" y1="25" x2="32" y2="35" stroke="white" stroke-width="1.5"/>
                                <line x1="38" y1="25" x2="38" y2="35" stroke="white" stroke-width="1.5"/>
                                <line x1="35" y1="25" x2="35" y2="35" stroke="white" stroke-width="1.5"/>
                                <line x1="65" y1="28" x2="65" y2="50" stroke="white" stroke-width="2"/>
                                <path d="M62 25 L68 25 L65 28 Z" fill="white"/>
                            </svg>
                            NutriChain
                        </h3>
                        <p class="text-gray-400 text-sm mb-4">Blockchain humanitaire. 1 token = 1 repas. Transparence totale.</p>
                    </div>
                    <div>
                        <h4 class="text-white font-semibold mb-4">Mission</h4>
                        <ul class="space-y-2 text-sm text-gray-400">
                            <li>Nourrir les nécessiteux</li>
                            <li>Transparence 100%</li>
                            <li>Impact mesurable</li>
                        </ul>
                    </div>
                    <div>
                        <h4 class="text-white font-semibold mb-4">Ressources</h4>
                        <ul class="space-y-2 text-sm">
                            <li><a href="#" class="text-gray-400 hover:text-green-400">Documentation</a></li>
                            <li><a href="#" class="text-gray-400 hover:text-green-400">Whitepaper</a></li>
                        </ul>
                    </div>
                    <div>
                        <h4 class="text-white font-semibold mb-4">Contact</h4>
                        <p class="text-gray-400 text-sm flex items-center">
                            <i data-lucide="mail" class="w-4 h-4 mr-2"></i>contact@nutrichain.org
                        </p>
                    </div>
                </div>
                <div class="border-t border-[#30363d] pt-6 text-center text-sm text-gray-400">
                    <p>© 2025 NutriChain. Open Source MIT License.</p>
                </div>
            </div>
        </footer>
    </div>

    <script>
        let map;
        
        function showSection(section) {
            document.querySelectorAll('.section').forEach(el => el.style.display = 'none');
            document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
            document.getElementById(section + 'Section').style.display = 'block';
            event.target.classList.add('active');
            
            if (section === 'map' && !map) {
                initMap();
            }
        }
        
        function initMap() {
            map = L.map('map').setView([20, 0], 2);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap'
            }).addTo(map);
            
            const locations = [
                {lat: 48.8566, lng: 2.3522, name: 'Paris, France', meals: 127, org: 'Restos du Cœur'},
                {lat: 33.5138, lng: 36.2765, name: 'Damas, Syrie', meals: 50, org: 'Cantine Al-Amal'},
                {lat: 9.0320, lng: 38.7469, name: 'Addis-Abeba, Éthiopie', meals: 89, org: 'Programme WFP'},
                {lat: 28.6139, lng: 77.2090, name: 'New Delhi, Inde', meals: 234, org: 'Akshaya Patra'},
                {lat: -23.5505, lng: -46.6333, name: 'São Paulo, Brésil', meals: 156, org: 'Banco de Alimentos'},
                {lat: 36.8065, lng: 10.1815, name: 'Tunis, Tunisie', meals: 78, org: 'Croissant Rouge'},
                {lat: 31.7917, lng: 35.2167, name: 'Jérusalem', meals: 42, org: 'Leket Israel'},
                {lat: -4.0435, lng: 39.6682, name: 'Mombasa, Kenya', meals: 91, org: 'Food4Education'},
                {lat: 23.8103, lng: 90.4125, name: 'Dhaka, Bangladesh', meals: 203, org: 'BRAC'},
                {lat: 13.0827, lng: 80.2707, name: 'Chennai, Inde', meals: 167, org: 'Amma Canteen'},
                {lat: 6.5244, lng: 3.3792, name: 'Lagos, Nigeria', meals: 112, org: 'Food Bank Nigeria'},
                {lat: 33.8869, lng: 35.5131, name: 'Beyrouth, Liban', meals: 65, org: 'Secours Islamique'}
            ];
            
            locations.forEach(loc => {
                const marker = L.marker([loc.lat, loc.lng]).addTo(map);
                marker.bindPopup(`
                    <div style="color: #e5e7eb;">
                        <strong>${loc.name}</strong><br>
                        <span style="color: #10b981;">🍽️ ${loc.meals} repas distribués</span><br>
                        <small>${loc.org}</small>
                    </div>
                `);
            });
        }
        
        document.getElementById('donateAmount')?.addEventListener('input', (e) => {
            document.getElementById('mealCount').textContent = e.target.value || 0;
        });
        
        lucide.createIcons();
    </script>
</body>
</html>
HTMLEOF

cat > api.py << 'EOF'
from flask import Flask, render_template
from blockchain import Blockchain

app = Flask(__name__)
blockchain = Blockchain()

@app.route('/')
def index():
    return render_template('dashboard.html')

if __name__ == '__main__':
    print("\n🍽️  NutriChain - Logo Personnalisé")
    print("📧 contact@nutrichain.org")
    print("🌐 http://localhost:5000\n")
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

echo ""
echo "✅ Logo personnalisé installé !"
echo "💚 Cœur vert avec fourchette et couteau"
echo ""
echo "Lancez: python api.py"
