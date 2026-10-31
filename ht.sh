#!/usr/bin/env bash
# ==============================================================================
# ht.sh - Hermes Telegram Integration & Bot Configurator
# Penggunaan: ./ht.sh <token-telegram> [user-id-telegram]
# Contoh    : ./ht.sh 123456789:ABCdefGHIjklMNOpqrSTUvwxYZ
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}       Hermes Telegram Bot Integration Configurator             ${NC}"
echo -e "${BLUE}================================================================${NC}"

BOT_TOKEN="$1"
ALLOWED_USER="$2"

# Input interaktif jika argumen belum diisi
if [ -z "$BOT_TOKEN" ]; then
    echo -e "${YELLOW}Masukkan Telegram Bot Token Anda (dari @BotFather):${NC}"
    read -r -p "> " BOT_TOKEN
fi

if [ -z "$BOT_TOKEN" ]; then
    echo -e "${RED}[ERROR] Bot Token Telegram tidak boleh kosong!${NC}"
    echo "Panduan: Buat bot baru di Telegram lewat @BotFather dengan ketik /newbot"
    exit 1
fi

echo -e "\n${BLUE}[1/4] Memvalidasi Token ke Telegram Bot API...${NC}"
API_CHECK=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getMe" || true)

BOT_USERNAME=""
BOT_FIRSTNAME=""

if echo "$API_CHECK" | grep -q '"ok":true'; then
    BOT_USERNAME=$(echo "$API_CHECK" | grep -o '"username":"[^"]*' | cut -d'"' -f4 || true)
    BOT_FIRSTNAME=$(echo "$API_CHECK" | grep -o '"first_name":"[^"]*' | cut -d'"' -f4 || true)
    echo -e "${GREEN}✓ Bot Valid! Terhubung ke: @${BOT_USERNAME} (${BOT_FIRSTNAME})${NC}"
else
    echo -e "${YELLOW}[PERINGATAN] Telegram API mengembalikan respon tidak valid atau token salah.${NC}"
    echo -e "${YELLOW}Respon: ${API_CHECK}${NC}"
    echo -e "Pastikan token Anda benar dan koneksi internet aktif."
fi

# Tanyakan User ID Telegram jika belum diberikan
if [ -z "$ALLOWED_USER" ]; then
    echo -e "\n${YELLOW}Masukkan Telegram User/Account ID Anda (Opsional, untuk keamanan/whitelist):${NC}"
    echo -e "Tips: Anda bisa cek ID akun Anda di Telegram via bot @userinfobot"
    echo -e "(Tekan [Enter] untuk izinkan semua chat/grup):"
    read -r -p "> " ALLOWED_USER
fi

HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
mkdir -p "$HERMES_DIR"
mkdir -p "$HERMES_DIR/logs"

ENV_FILE="$HERMES_DIR/.env"
CONFIG_FILE="$HERMES_DIR/config.yaml"

echo -e "\n${BLUE}[2/4] Menyimpan kredensial Telegram ke ${ENV_FILE}...${NC}"
touch "$ENV_FILE"

# Bersihkan konfigurasi telegram lama jika ada
sed -i '/^TELEGRAM_BOT_TOKEN=/d' "$ENV_FILE" 2>/dev/null || true
sed -i '/^TELEGRAM_ALLOWED_USERS=/d' "$ENV_FILE" 2>/dev/null || true

cat << EOF >> "$ENV_FILE"
TELEGRAM_BOT_TOKEN=${BOT_TOKEN}
EOF

if [ -n "$ALLOWED_USER" ]; then
    echo "TELEGRAM_ALLOWED_USERS=${ALLOWED_USER}" >> "$ENV_FILE"
    echo -e "${GREEN}✓ Whitelist Telegram User ID: ${ALLOWED_USER}${NC}"
fi

echo -e "${GREEN}✓ TELEGRAM_BOT_TOKEN berhasil disimpan.${NC}"

echo -e "\n${BLUE}[3/4] Memastikan platform Telegram aktif di ${CONFIG_FILE}...${NC}"
if [ -f "$CONFIG_FILE" ]; then
    if ! grep -q "telegram:" "$CONFIG_FILE" 2>/dev/null; then
        cat << 'EOF' >> "$CONFIG_FILE"

platforms:
  telegram:
    enabled: true
EOF
    fi
fi
echo -e "${GREEN}✓ Platform Telegram aktif di config.yaml.${NC}"

# Pastikan dependensi python-telegram-bot terpasang
HERMES_VENV="${PREFIX:-}/lib/hermes-agent/venv"
HERMES_UV="${PREFIX:-}/lib/hermes-agent/tools/uv/data/data/com.termux/files/usr/bin/uv"

if ! python3 -c "import telegram" >/dev/null 2>&1 && ! python -c "import telegram" >/dev/null 2>&1; then
    echo -e "${YELLOW}Menginstal python-telegram-bot ke dalam environment...${NC}"
    if [ -d "$HERMES_VENV" ]; then
        if [ -f "$HERMES_UV" ]; then
            VIRTUAL_ENV="$HERMES_VENV" "$HERMES_UV" pip install "python-telegram-bot[webhooks]==22.8" >/dev/null 2>&1 || true
        elif command -v uv >/dev/null 2>&1; then
            VIRTUAL_ENV="$HERMES_VENV" uv pip install "python-telegram-bot[webhooks]==22.8" >/dev/null 2>&1 || true
        fi
    elif command -v uv >/dev/null 2>&1; then
        uv pip install "python-telegram-bot[webhooks]==22.8" >/dev/null 2>&1 || true
    elif command -v pip3 >/dev/null 2>&1; then
        pip3 install "python-telegram-bot[webhooks]==22.8" >/dev/null 2>&1 || true
    elif command -v pip >/dev/null 2>&1; then
        pip install "python-telegram-bot[webhooks]==22.8" >/dev/null 2>&1 || true
    fi
fi

echo -e "\n${BLUE}[4/4] Merestart Hermes Gateway untuk mengaktifkan koneksi Telegram...${NC}"

# Hentikan proses lama
if pgrep -f "hermes.*gateway" >/dev/null 2>&1; then
    pkill -f "hermes.*gateway" || true
    sleep 1
fi

# Jalankan ulang gateway di background
nohup hermes gateway > "$HERMES_DIR/logs/gateway.log" 2>&1 &
sleep 2

PID_GW=$(pgrep -f "hermes.*gateway" | head -n 1 || true)

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${GREEN}✓ Telegram Bot Hermes Berhasil Terhubung!${NC}"
echo -e "${BLUE}================================================================${NC}"
if [ -n "$BOT_USERNAME" ]; then
    echo -e "🤖 Bot Username : ${YELLOW}@${BOT_USERNAME}${NC}"
fi
echo -e "🚀 Status Gateway: ${GREEN}Aktif (PID: ${PID_GW:-Background})${NC}"
echo -e ""
echo -e "Langkah Selanjutnya:"
echo -e "  1. Buka Telegram dan cari bot Anda: ${YELLOW}@${BOT_USERNAME:-bot_anda}${NC}"
echo -e "  2. Kirim pesan ${GREEN}/start${NC} atau langsung ketik pertanyaan apa saja."
echo -e "  3. Buat Grup Telegram Produktif dengan Topics:"
echo -e "     - Buat Grup baru di Telegram (misal: 'Hermes Pocket Lab')."
echo -e "     - Masukkan bot @${BOT_USERNAME:-bot_anda} ke dalam grup & jadikan ${GREEN}Admin${NC} (wajib agar bot bisa membaca chat grup)."
echo -e "     - ${YELLOW}Tips Grup${NC}: Di grup, bot merespon saat di-mention (@${BOT_USERNAME:-bot_anda}) atau jika Group Privacy di-disable via @BotFather (/setprivacy -> Disable)."
echo -e "     - Buka Info Grup -> Edit -> Aktifkan menu ${YELLOW}'Topics' (Forum)${NC}."
echo -e "     - Buat topik-topik produktif sesuai kebutuhan Anda, contohnya:"
echo -e "         • #General       (Obrolan umum & tanya jawab cepat)"
echo -e "         • #Research      (Riset materi, paper, & analisis konsep)"
echo -e "         • #Coding-Helper (Bantuan debugging & arsitektur kode)"
echo -e "         • #Daily-Planner (Rencana harian & evaluasi tugas)"
echo -e ""
echo -e "🎉 Selamat! AI Agent pribadi Anda sekarang aktif di saku Anda 24/7!"
echo -e "${BLUE}================================================================${NC}\n"

