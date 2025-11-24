#!/usr/bin/env bash

set -e

PROJECT_DIR="/home/darksun/nutrichain_restored"
DASHBOARD="${PROJECT_DIR}/templates/dashboard.html"

echo "=== NutriChain - Revenir au thème sombre ==="

if [ ! -f "$DASHBOARD" ]; then
  echo "Fichier ${DASHBOARD} introuvable."
  exit 1
fi

# Sauvegarde avant modification
cp "$DASHBOARD" "${DASHBOARD}.bak_dark_$(date +%Y%m%d_%H%M%S)"
echo "Backup créé : ${DASHBOARD}.bak_dark_..."

# 1) Body: bg-light -> bg-dark
sed -i 's/class="bg-light text-dark"/class="bg-dark text-light"/g' "$DASHBOARD"

# 2) Navbar: enlever le dégradé vert/bleu, remettre bg-dark
sed -i 's/<nav class="navbar navbar-expand-lg navbar-dark" style="background: linear-gradient(135deg, #2e7d32, #1565c0);">/<nav class="navbar navbar-expand-lg navbar-dark bg-dark border-bottom">/g' "$DASHBOARD"

# 3) Cartes de stats: bg-white -> text-bg-dark
sed -i 's/class="card bg-white border-success mb-3"/class="card text-bg-dark border-success mb-3"/g' "$DASHBOARD"
sed -i 's/class="card bg-white border-info mb-3"/class="card text-bg-dark border-info mb-3"/g' "$DASHBOARD"
sed -i 's/class="card bg-white border-warning mb-3"/class="card text-bg-dark border-warning mb-3"/g' "$DASHBOARD"
sed -i 's/class="card bg-white border-primary mb-3"/class="card text-bg-dark border-primary mb-3"/g' "$DASHBOARD"

# 4) Bordure de la carte Leaflet un peu plus sombre
sed -i 's/border: 1px solid #ddd;/border: 1px solid #333;/g' "$DASHBOARD"

echo "=== Thème sombre appliqué. Recharge http://localhost:5000 ==="
