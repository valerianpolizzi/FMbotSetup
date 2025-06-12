#!/bin/bash

REPO="valerianpolizzi/FMbot"
BINARY="fm-bot"

# Fonction exécutée à la fin du script ou en cas de Ctrl+C
cleanup() {
  echo "🔒 Déconnexion de GitHub CLI..."
  gh auth logout --hostname github.com --yes
}
trap cleanup EXIT INT

echo "🔐 Connexion temporaire à GitHub CLI"
gh auth login

echo "📥 Téléchargement du binaire '$BINARY' depuis $REPO"
gh release download --repo "$REPO" --pattern "$BINARY"

chmod +x "$BINARY"
echo "✅ Téléchargement terminé"