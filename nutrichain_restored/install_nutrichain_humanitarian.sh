#!/bin/bash

echo "=========================================="
echo "🍽️  NutriChain - Blockchain Humanitaire"
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
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #0d1117; color: #e5e7eb; min-height: 100vh; display: flex; flex-direction: column; }
        .sidebar { background: linear-gradient(135deg, #161b22 0%, #0d1117 100%); border-right: 1px solid #30363d; height: 100vh; position: fixed; width: 260px; overflow-y: auto; }
        .content-area { margin-left: 260px; }
        .logo-spin { animation: spin 3s linear infinite; }
        @keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
        .impact-banner { background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 30px; border-radius: 12px; color: white; margin-bottom: 30px; }
    </style>
</head>
<body>
    <div class="sidebar p-6">
        <h1 class="text-2xl font-bold text-white flex items-center">
            <i data-lucide="heart" class="w-8 h-8 mr-2 text-green-400 logo-spin"></i>NutriChain
        </h1>
        <p class="text-xs text-gray-400 mt-1">Aide Humanitaire Alimentaire</p>
    </div>
    <div class="content-area p-8">
        <div class="impact-banner">
            <h2 class="text-3xl font-bold mb-2">🍽️ 1 Token NUTRI = 1 Repas Garanti</h2>
            <p class="text-green-100">Blockchain transparente pour nourrir les personnes dans le besoin</p>
        </div>
        <h1 class="text-4xl font-bold text-white">Bienvenue sur NutriChain</h1>
        <p class="text-gray-400 mt-4">Votre blockchain humanitaire est active !</p>
    </div>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>lucide.createIcons();</script>
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
    print("\n🍽️  NutriChain - Aide Humanitaire")
    print("📧 contact@nutrichain.org")
    print("🌐 http://localhost:5000\n")
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

echo ""
echo "✅ Installation terminée !"
echo "Lancez: python api.py"
