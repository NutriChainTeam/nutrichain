#!/bin/bash

echo "✅ Installation du design index.html"
echo ""

mkdir -p templates

# Copier votre index.html dans templates/dashboard.html
cp index.html templates/dashboard.html

echo "✅ Votre design est installé dans templates/dashboard.html"
echo ""
echo "Les fichiers JS/CSS (wallet, multilingue, alertes) sont déjà dans static/"
echo ""
echo "🚀 Pour lancer NutriChain :"
echo "   cd ~/nutrichain_restored"
echo "   python api.py"
echo ""
echo "🌐 Accédez à : http://localhost:5000"
