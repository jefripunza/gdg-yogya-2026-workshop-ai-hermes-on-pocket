#!/usr/bin/env bash

# ==============================================================================
# mobile.sh - One-Click Installer Hermes Agent & 9Router di Termux
# - Hermes Agent: https://github.com/nousresearch/hermes-agent
# - 9Router: https://github.com/ AgusNarestha / npm: 9router
# ==============================================================================

set -e

# Parsing Argumen
IS_LOCAL=false
for arg in "$@"; do
    case "$arg" in
        -l|--local)
            IS_LOCAL=true
            ;;
    esac
done

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
echo -e "\n${BLUE}[1/6] Memeriksa dan menginstal dependensi dasar Termux...${NC}"
pkg update -y
pkg install -y curl gnupg git python clang make procps

# ------------------------------------------------------------------------------
# 2. Instalasi Hermes Agent (Nous Research)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[2/6] Menyiapkan dan menginstal Hermes Agent...${NC}"
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
echo -e "\n${BLUE}[3/6] Menginstal Node.js versi terbaru & npm...${NC}"
# Di Termux, paket 'nodejs' selalu berisi Current/Latest version
pkg install -y nodejs

NODE_VER=$(node -v || true)
NPM_VER=$(npm -v || true)
echo -e "${GREEN}✓ Node.js terinstal: ${NODE_VER}${NC}"
echo -e "${GREEN}✓ npm terinstal: ${NPM_VER}${NC}"

echo -e "\n${BLUE}[4/6] Menginstal 9Router via npm secara global...${NC}"
npm install -g 9router
echo -e "${GREEN}✓ 9Router berhasil diinstal!${NC}"

# ------------------------------------------------------------------------------
# 4. Menyiapkan Script Pembantu (hc.sh & ht.sh)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[5/6] Menyiapkan script konfigurasi (hc.sh & ht.sh)...${NC}"
REPO_RAW_URL="https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master"

if [ "$IS_LOCAL" = true ]; then
    echo -e "${YELLOW}Mode --local terdeteksi: Menggunakan file hc.sh & ht.sh lokal (skip unduhan GitHub).${NC}"
    if [ -f "./hc.sh" ] && [ "$(pwd)" != "$HOME" ]; then
        cp -f ./hc.sh "$HOME/hc.sh"
    fi
    if [ -f "./ht.sh" ] && [ "$(pwd)" != "$HOME" ]; then
        cp -f ./ht.sh "$HOME/ht.sh"
    fi
    chmod +x "$HOME/hc.sh" "$HOME/ht.sh" 2>/dev/null || true
    echo -e "${GREEN}✓ hc.sh dan ht.sh lokal siap digunakan di: ${HOME}/${NC}"
else
    echo "Mengunduh hc.sh dan ht.sh dari repository resmi..."
    curl -fsSL "${REPO_RAW_URL}/hc.sh" -o "$HOME/hc.sh"
    curl -fsSL "${REPO_RAW_URL}/ht.sh" -o "$HOME/ht.sh"
    chmod +x "$HOME/hc.sh" "$HOME/ht.sh"
    echo -e "${GREEN}✓ hc.sh dan ht.sh berhasil diunduh ke: ${HOME}/${NC}"
fi

# ------------------------------------------------------------------------------
# 5. Setup Auto-Run Script & Pencegah Duplicate Process
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[6/6] Mengonfigurasi auto-start untuk 9Router dan Hermes Gateway...${NC}"

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
echo -e "${GREEN}✓ Setup Instalasi Selesai & Service Aktif!                      ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "🔹 ${YELLOW}9Router Web Dashboard${NC} : http://localhost:20128"
echo -e "🔹 ${YELLOW}Hermes Web Dashboard${NC}  : http://localhost:9119 (atau :8642)"
echo -e ""
echo -e "${YELLOW}👉 LANGKAH SELANJUTNYA (IKUTI URUTAN BERIKUT):${NC}"
echo -e ""
echo -e "1. ${GREEN}Buka 9Router dari Browser HP:${NC}"
echo -e "   - Akses: ${YELLOW}http://localhost:20128${NC}"
echo -e "   - Buka menu ${YELLOW}Providers${NC} -> Integrasikan ${GREEN}Gemini API Key${NC} Anda."
echo -e "   - Buka menu ${YELLOW}Combos${NC}    -> Buat combo bernama ${GREEN}gdg-yogya${NC} (pilih model Gemini)."
echo -e "   - Buka menu ${YELLOW}API Keys${NC}  -> Generate API Key baru, simpan & copy key tersebut."
echo -e ""
echo -e "2. ${GREEN}Konfigurasi Hermes dengan 9Router:${NC}"
echo -e "   - Jalankan perintah berikut di Termux:"
echo -e "     ${GREEN}./hc.sh gdg-yogya <api-key-9router>${NC}"
echo -e "     (Script ini otomatis menghubungkan Hermes ke 9Router lokal)."
echo -e ""
echo -e "3. ${GREEN}Test Chat Hermes dari Browser:${NC}"
echo -e "   - Buka: ${YELLOW}http://localhost:9119${NC}"
echo -e "   - Coba kirim pesan chat pertama ke Hermes untuk memastikan respon model bekerja."
echo -e ""
echo -e "4. ${GREEN}Integrasi ke Telegram Bot:${NC}"
echo -e "   - Buka aplikasi Telegram, chat ke ${YELLOW}@BotFather${NC} -> ketik ${YELLOW}/newbot${NC}."
echo -e "   - Ikuti petunjuk sampai selesai, lalu copy ${GREEN}HTTP API Token${NC} yang diberikan."
echo -e "   - Jalankan perintah ini di Termux:"
echo -e "     ${GREEN}./ht.sh <token-telegram>${NC}"
echo -e "     (Script ini akan meminta Telegram User ID untuk whitelist & mengaktifkan bot)."
echo -e ""
echo -e "5. ${GREEN}Buat Forum Group & Topik Produktif:${NC}"
echo -e "   - Buat Grup baru di Telegram (misal: 'Hermes Pocket Lab')."
echo -e "   - Masukkan Bot Anda ke dalam grup dan jadikan Admin."
echo -e "   - Buka Info Grup -> Edit -> Aktifkan menu ${YELLOW}'Topics' (Forum)${NC}."
echo -e "   - Mulai buat topik-topik produktif Anda (misal: #Coding, #Research, #Daily-Task)."
echo -e ""
echo -e "🎉 Selesai! Anda kini memiliki AI Assistant mandiri yang running di saku Anda 24/7!"
echo -e "${BLUE}================================================================${NC}\n"
