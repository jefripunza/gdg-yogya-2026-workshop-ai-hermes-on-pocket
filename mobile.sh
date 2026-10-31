#!/usr/bin/env bash

# ==============================================================================
# mobile.sh - One-Click Installer Hermes Agent di Termux
# Tutorial: https://github.com/nousresearch/hermes-agent/blob/main/website/docs/getting-started/termux.md
# ==============================================================================

set -e

# Warna output terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}      Hermes Agent Installer for Termux (Nous Research)         ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Validasi environment Termux PREFIX
if [ -z "$PREFIX" ]; then
    export PREFIX="/data/data/com.termux/files/usr"
fi

# 1. Update dan instal dependensi dasar
echo -e "\n${BLUE}[1/4] Memeriksa dan menginstal dependensi dasar...${NC}"
pkg update -y
pkg install -y curl gnupg git python clang make

# 2. Menyiapkan Official APT Repository Hermes Agent
# Catatan: Upstream Nous Research saat ini merilis channel canary
# (channel stable terkadang 404 seperti pada Issue #122445).
echo -e "\n${BLUE}[2/4] Mengunduh GPG Key repositori Hermes Agent...${NC}"
mkdir -p "$PREFIX/etc/apt/keyrings"
KEY_FILE="$PREFIX/etc/apt/keyrings/hermes-agent.asc"
SOURCES_FILE="$PREFIX/etc/apt/sources.list.d/hermes-agent.list"

CANARY_KEY_URL="https://hermes-assets.nousresearch.com/releases/termux/canary/key.asc"
STABLE_KEY_URL="https://hermes-assets.nousresearch.com/releases/termux/stable/key.asc"

DOWNLOADED=false
CHANNEL=""
APT_SUCCESS=false

# Cek channel canary terlebih dahulu
if curl -fsSL "$CANARY_KEY_URL" -o "$KEY_FILE" 2>/dev/null; then
    DOWNLOADED=true
    CHANNEL="canary"
    REPO_URL="https://hermes-assets.nousresearch.com/releases/termux/canary"
    SUITE="hermes-canary"
    echo -e "${GREEN}✓ Berhasil mengunduh GPG key dari channel canary!${NC}"
elif curl -fsSL "$STABLE_KEY_URL" -o "$KEY_FILE" 2>/dev/null; then
    DOWNLOADED=true
    CHANNEL="stable"
    REPO_URL="https://hermes-assets.nousresearch.com/releases/termux/stable"
    SUITE="hermes-stable"
    echo -e "${GREEN}✓ Berhasil mengunduh GPG key dari channel stable!${NC}"
fi

if [ "$DOWNLOADED" = true ]; then
    echo -e "\n${BLUE}[3/4] Mendaftarkan repositori APT (${CHANNEL})...${NC}"
    gpg --show-keys --with-fingerprint "$KEY_FILE" || true
    
    mkdir -p "$PREFIX/etc/apt/sources.list.d"
    printf '%s\n' \
      "deb [signed-by=$KEY_FILE] $REPO_URL $SUITE main" \
      > "$SOURCES_FILE"
    
    echo "Mengupdate index paket Termux..."
    if pkg update -y; then
        echo "Menginstal hermes-agent via APT..."
        if pkg install -y hermes-agent; then
            APT_SUCCESS=true
            echo -e "${GREEN}✓ hermes-agent berhasil diinstal via APT (${CHANNEL})!${NC}"
        fi
    fi
fi

# 3. Fallback ke official install.sh jika APT repository gagal
if [ "$APT_SUCCESS" = false ]; then
    echo -e "\n${YELLOW}[INFO] APT repository tidak tersedia atau gagal. Menggunakan Official Installer script...${NC}"
    echo -e "${BLUE}Menjalankan: curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash${NC}"
    rm -f "$SOURCES_FILE"
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
fi

# Pastikan PATH mencakup bin hermes (di ~/.local/bin, ~/.hermes/bin, atau $PREFIX/bin)
export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PREFIX/bin:$PATH"

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${GREEN}✓ Hermes Agent Siap Digunakan!${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "Langkah selanjutnya:"
echo -e "  1. Jalankan setup wizard untuk konfigurasi provider/API keys:"
echo -e "     ${YELLOW}hermes setup${NC}"
echo -e "  2. Buka antarmuka interaktif TUI:"
echo -e "     ${YELLOW}hermes --tui${NC}"
echo -e "  3. Bantuan perintah CLI:"
echo -e "     ${YELLOW}hermes --help${NC}"
echo -e "${BLUE}================================================================${NC}\n"
