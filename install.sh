#!/bin/bash

REPO="https://github.com/valerianpolizzi/FMbot"
BINARY="fm-bot-ubuntu"

# Fonction exécutée à la fin du script ou en cas de Ctrl+C
cleanup() {
  echo "🔒 Déconnexion de GitHub CLI..."
  gh auth logout --hostname github.com
}
trap cleanup EXIT INT

echo "🔐 Connexion temporaire à GitHub CLI"
gh auth login
if [[ $? -ne 0 ]]; then
  echo "❌ Échec de la connexion GitHub CLI. Arrêt du script."
  exit 1
fi

echo "📥 Téléchargement du binaire '$BINARY' depuis $REPO"
gh release download --repo "$REPO" --pattern "$BINARY" --clobber

sudo apt install -y nodejs npm

sudo npm install -g pm2

chmod +x "$BINARY"
echo "✅ Téléchargement terminé"