#!/usr/bin/env bash

# ==============================================================================
# mobile.sh - One-Click Installer Hermes Agent & 9Router di Termux
# - Hermes Agent: https://github.com/nousresearch/hermes-agent
# - 9Router: https://github.com/ AgusNarestha / npm: 9router
# ==============================================================================

set -e

# Warna output terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}   Hermes Agent & 9Router Auto-Installer for Termux             ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Validasi environment Termux PREFIX & HOME
if [ -z "$PREFIX" ]; then
    export PREFIX="/data/data/com.termux/files/usr"
fi
if [ -z "$HOME" ]; then
    export HOME="/data/data/com.termux/files/home"
fi

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PREFIX/bin:$PATH"

# ------------------------------------------------------------------------------
# 1. Update & Dependensi Dasar
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[1/5] Memeriksa dan menginstal dependensi dasar Termux...${NC}"
pkg update -y
pkg install -y curl gnupg git python clang make procps

# ------------------------------------------------------------------------------
# 2. Instalasi Hermes Agent (Nous Research)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[2/5] Menyiapkan dan menginstal Hermes Agent...${NC}"
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
    echo -e "${GREEN}✓ Menggunakan channel canary Nous Research${NC}"
elif curl -fsSL "$STABLE_KEY_URL" -o "$KEY_FILE" 2>/dev/null; then
    DOWNLOADED=true
    CHANNEL="stable"
    REPO_URL="https://hermes-assets.nousresearch.com/releases/termux/stable"
    SUITE="hermes-stable"
    echo -e "${GREEN}✓ Menggunakan channel stable Nous Research${NC}"
fi

if [ "$DOWNLOADED" = true ]; then
    mkdir -p "$PREFIX/etc/apt/sources.list.d"
    printf '%s\n' \
      "deb [signed-by=$KEY_FILE] $REPO_URL $SUITE main" \
      > "$SOURCES_FILE"
    
    if pkg update -y 2>/dev/null; then
        if pkg install -y hermes-agent; then
            APT_SUCCESS=true
            echo -e "${GREEN}✓ hermes-agent berhasil diinstal via APT (${CHANNEL})!${NC}"
        fi
    fi
fi

# Fallback ke official installer script jika APT repo tidak tersedia
if [ "$APT_SUCCESS" = false ]; then
    echo -e "${YELLOW}[INFO] Menggunakan Official Installer script Hermes Agent...${NC}"
    rm -f "$SOURCES_FILE"
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
fi

# ------------------------------------------------------------------------------
# 3. Instalasi Node.js Terbaru & 9Router via npm
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[3/5] Menginstal Node.js versi terbaru & npm...${NC}"
# Di Termux, paket 'nodejs' selalu berisi Current/Latest version
pkg install -y nodejs

NODE_VER=$(node -v || true)
NPM_VER=$(npm -v || true)
echo -e "${GREEN}✓ Node.js terinstal: ${NODE_VER}${NC}"
echo -e "${GREEN}✓ npm terinstal: ${NPM_VER}${NC}"

echo -e "\n${BLUE}[4/5] Menginstal 9Router via npm secara global...${NC}"
npm install -g 9router

echo -e "${GREEN}✓ 9Router berhasil diinstal!${NC}"

# ------------------------------------------------------------------------------
# 4. Setup Auto-Run Script & Pencegah Duplicate Process
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[5/5] Mengonfigurasi auto-start untuk 9Router dan Hermes Gateway...${NC}"

mkdir -p "$HOME/.9router/logs"
mkdir -p "$HOME/.hermes/logs"
AUTOSTART_SCRIPT="$HOME/.autostart_services.sh"

cat << 'EOF' > "$AUTOSTART_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================================
# .autostart_services.sh - Auto-run 9router & hermes gateway (tanpa dobel proses)
# ==============================================================================

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:/data/data/com.termux/files/usr/bin:$PATH"

mkdir -p "$HOME/.9router/logs"
mkdir -p "$HOME/.hermes/logs"

# 1. Pastikan 9router berjalan (jika sudah ada, jangan jalankan lagi)
if pgrep -f "[9]router" >/dev/null 2>&1; then
    PID_9R=$(pgrep -f "[9]router" | head -n 1)
    echo "[✓] 9router sudah berjalan (PID: $PID_9R) -> http://localhost:20128"
elif command -v 9router >/dev/null 2>&1; then
    echo "[+] Menjalankan 9router di background..."
    nohup 9router --host 0.0.0.0 --port 20128 --no-browser > "$HOME/.9router/logs/9router.log" 2>&1 &
    sleep 1
    PID_9R=$(pgrep -f "[9]router" | head -n 1)
    echo "[✓] 9router berhasil aktif (PID: $PID_9R) -> http://localhost:20128"
else
    echo "[!] 9router belum terinstal."
fi

# 2. Pastikan Hermes Gateway berjalan (jika sudah ada, jangan jalankan lagi)
if pgrep -f "hermes.*gateway" >/dev/null 2>&1; then
    PID_HG=$(pgrep -f "hermes.*gateway" | head -n 1)
    echo "[✓] Hermes Gateway sudah berjalan (PID: $PID_HG)"
elif command -v hermes >/dev/null 2>&1; then
    echo "[+] Menjalankan Hermes Gateway di background..."
    nohup hermes gateway > "$HOME/.hermes/logs/gateway.log" 2>&1 &
    sleep 1
    PID_HG=$(pgrep -f "hermes.*gateway" | head -n 1)
    echo "[✓] Hermes Gateway berhasil aktif (PID: $PID_HG)"
else
    echo "[!] Hermes CLI belum terinstal."
fi
EOF

chmod +x "$AUTOSTART_SCRIPT"

# Daftarkan ke ~/.bashrc agar jalan otomatis saat Termux dibuka / login ulang
BASHRC="$HOME/.bashrc"
if ! grep -q "autostart_services.sh" "$BASHRC" 2>/dev/null; then
    cat << 'EOF' >> "$BASHRC"

# Auto-start 9router & Hermes Gateway
if [ -f "$HOME/.autostart_services.sh" ]; then
    bash "$HOME/.autostart_services.sh"
fi
EOF
fi

# Jalankan service sekarang juga
echo -e "\n${BLUE}=== Menjalankan Service Pertama Kali ===${NC}"
bash "$AUTOSTART_SCRIPT"

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${GREEN}✓ Setup Selesai & Service Aktif!${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "🔹 ${YELLOW}9Router Web Dashboard${NC} : http://localhost:20128"
echo -e "🔹 ${YELLOW}9Router OpenAI Proxy${NC}  : http://localhost:20128/v1"
echo -e "🔹 ${YELLOW}Hermes Gateway API${NC}    : http://localhost:8642"
echo -e ""
echo -e "📄 Log 9router       : ~/.9router/logs/9router.log"
echo -e "📄 Log Hermes Gateway: ~/.hermes/logs/gateway.log"
echo -e ""
echo -e "Setiap kali Termux dibuka / di-restart, kedua service di atas akan"
echo -e "otomatis dicek dan dijalankan jika belum aktif (tanpa dobel proses)."
echo -e "${BLUE}================================================================${NC}\n"
