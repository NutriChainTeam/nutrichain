#!/usr/bin/env bash

# Dossier du projet
PROJECT_DIR="/home/darksun/nutrichain_restored"

# Python de pyenv
PYTHON_BIN="/home/darksun/.pyenv/versions/3.10.13/bin/python"

cd "$PROJECT_DIR" || {
  echo "Dossier $PROJECT_DIR introuvable."
  exit 1
}

if [ ! -f "api.py" ]; then
  echo "api.py introuvable dans $PROJECT_DIR"
  exit 1
fi

echo "=== Démarrage de NutriChain (Flask) sur http://localhost:5000 ==="
"$PYTHON_BIN" api.py
