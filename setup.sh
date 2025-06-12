#!/bin/bash

# install-deps.sh
# À exécuter AVANT de lancer le binaire PyInstaller

set -e

echo "🔧 Installation des dépendances pour FMBot (binaire PyInstaller)"
echo "=============================================================="

# 🔍 Installation des paquets système requis
sudo apt update
sudo apt install -y python3 python3-pip python3-venv

# 🐍 Vérifie la présence de Python 3
if ! command -v python3 &>/dev/null; then
  echo "❌ Python 3 requis mais introuvable"
  exit 1
fi

echo "✅ Python $(python3 --version) détecté"

# 📁 Création de l’environnement virtuel
if [[ ! -d .venv ]]; then
  echo "📦 Création de l’environnement virtuel .venv"
  python3 -m venv .venv
fi

# ✅ Activation
source .venv/bin/activate

# 📥 Mise à jour de pip dans l’environnement virtuel uniquement
echo "📦 Mise à jour locale de pip..."
python -m pip install --upgrade pip

# 📜 Installation des dépendances
echo "📥 Installation des dépendances Python..."
pip install \
  greenlet==3.2.2 \
  playwright==1.52.0 \
  pyee==13.0.0 \
  typing_extensions==4.13.2

# 🧭 Détection de l'OS
case "$OSTYPE" in
  darwin*)  OS="macos"; BROWSERS_PATH="$HOME/Library/Caches/ms-playwright"; echo "🍎 macOS détecté" ;;
  linux*)   OS="linux"; BROWSERS_PATH="$HOME/.cache/ms-playwright"; echo "🐧 Linux détecté" ;;
  *)        echo "❌ OS non supporté: $OSTYPE"; exit 1 ;;
esac

# 🔍 Vérification si navigateurs déjà installés
if [[ -d "$BROWSERS_PATH" ]] && find "$BROWSERS_PATH" -name "chromium-*" -o -name "firefox-*" | grep -q .; then
  echo "✅ Navigateurs Playwright déjà présents"
  echo "🎉 FMBot prêt à fonctionner !"
  deactivate
  exit 0
fi

# 🌐 Installation des navigateurs
echo "🌐 Installation des navigateurs Playwright..."
playwright install

# 🔧 Dépendances Linux (si nécessaire)
if [[ "$OS" == "linux" ]] && command -v apt &>/dev/null; then
  echo "🔧 Installation des dépendances système Playwright (Linux)"
  playwright install-deps
fi

# ✅ Vérification finale
echo "🔍 Vérification finale de l’installation..."
if python3 -c "from playwright.sync_api import sync_playwright; print('✅ Playwright OK')" &>/dev/null; then
  echo "🎉 Installation réussie ! Navigateurs dans : $BROWSERS_PATH"
  echo "🚀 Prêt à lancer le binaire FMBot"
else
  echo "❌ Erreur lors du test Playwright"
fi

sudo apt install gh