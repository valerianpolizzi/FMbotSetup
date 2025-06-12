#!/bin/bash

# install-deps.sh
# À exécuter AVANT de lancer le binaire PyInstaller

set -e  # Stoppe le script à la moindre erreur

echo "🔧 Installation des dépendances pour FMBot (binaire PyInstaller)"
echo "=============================================================="

# 🔍 Vérification et installation de Python + pip + venv
sudo apt update
sudo apt install -y python3 python3-pip python3-venv

# 🐍 Vérifie que Python est dispo
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 est requis mais non trouvé"
    echo "💡 Tentez : sudo apt install python3 python3-pip"
    exit 1
fi

echo "✅ Python $(python3 --version) détecté"

# 📁 Création d'un environnement virtuel si nécessaire
if [[ ! -d .venv ]]; then
    echo "📦 Création de l'environnement virtuel (.venv)"
    python3 -m venv .venv
else
    echo "✅ Environnement virtuel déjà présent"
fi

# ✅ Activation de l'environnement virtuel
source .venv/bin/activate

# 📜 Installation des dépendances Python
echo "📥 Installation des dépendances..."
pip install --upgrade pip
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
    echo "✅ Navigateurs Playwright déjà présents dans : $BROWSERS_PATH"
    echo "🎉 Votre binaire FMBot est prêt à fonctionner !"
    exit 0
fi

echo "❌ Navigateurs Playwright non trouvés, installation..."

# 🧱 Installation des navigateurs via Playwright
echo "📦 Installation de Playwright et des navigateurs..."
playwright install

# 🔧 Dépendances système (Linux uniquement)
if [[ "$OS" == "linux" ]] && command -v apt &> /dev/null; then
    echo "🔧 Installation des dépendances système Playwright (Linux)"
    playwright install-deps
fi

# ✅ Vérification finale
echo "🔍 Vérification finale de Playwright..."
if python3 -c "from playwright.sync_api import sync_playwright; print('✅ Playwright OK')" &>/dev/null; then
    echo "🎉 Installation terminée avec succès !"
    echo "📍 Navigateurs installés dans : $BROWSERS_PATH"
    echo "🚀 Vous pouvez maintenant lancer votre binaire FMBot"
else
    echo "❌ Test de Playwright échoué"
    exit 1
fi