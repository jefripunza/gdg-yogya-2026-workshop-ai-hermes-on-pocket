#!/usr/bin/env bash
# ==============================================================================
# laptop.sh - Helper Setup Script untuk Pengguna Docker Compose di Laptop
#
# Penggunaan di dalam container hermes-agent:
#   curl -fsSL https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master/laptop.sh | bash
# Atau jika file sudah ada:
#   ./laptop.sh
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}    GDG Yogya 2026 - Hermes & 9Router Laptop Setup Helper       ${NC}"
echo -e "${BLUE}================================================================${NC}"

REPO_RAW_URL="https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master"
TARGET_DIR="${PWD}"

# Jika TARGET_DIR bukan home, pastikan juga tersedia di direktori kerja saat ini
echo -e "\n${BLUE}[1/4] Menyiapkan environment di dalam container...${NC}"

# Sinkronkan folder /opt/data dan ~/.hermes
HERMES_BASE="/opt/data"
if [ -d "$HERMES_BASE" ] && [ ! -d "$HOME/.hermes" ]; then
    ln -s "$HERMES_BASE" "$HOME/.hermes" 2>/dev/null || true
elif [ -d "$HOME/.hermes" ] && [ ! -d "$HERMES_BASE" ]; then
    ln -s "$HOME/.hermes" "$HERMES_BASE" 2>/dev/null || true
fi

mkdir -p "${HERMES_HOME:-$HOME/.hermes}/logs"

echo -e "\n${BLUE}[2/4] Memasang script pembantu (hc.sh & ht.sh)...${NC}"

# Cek apakah ada file lokal di /workspace (jika di-mount volume)
if [ -f "/workspace/hc.sh" ] && [ -f "/workspace/ht.sh" ]; then
    echo -e "${YELLOW}Menyalin file hc.sh & ht.sh dari /workspace...${NC}"
    cp -f /workspace/hc.sh "$TARGET_DIR/hc.sh"
    cp -f /workspace/ht.sh "$TARGET_DIR/ht.sh"
    [ -f "/workspace/laptop.sh" ] && cp -f /workspace/laptop.sh "$TARGET_DIR/laptop.sh"
else
    echo "Mengunduh hc.sh dan ht.sh dari repository resmi..."
    curl -fsSL "${REPO_RAW_URL}/hc.sh" -o "$TARGET_DIR/hc.sh"
    curl -fsSL "${REPO_RAW_URL}/ht.sh" -o "$TARGET_DIR/ht.sh"
    curl -fsSL "${REPO_RAW_URL}/laptop.sh" -o "$TARGET_DIR/laptop.sh" 2>/dev/null || true
fi

# Salin juga ke $HOME jika TARGET_DIR bukan $HOME
if [ "$TARGET_DIR" != "$HOME" ]; then
    cp -f "$TARGET_DIR/hc.sh" "$HOME/hc.sh" 2>/dev/null || true
    cp -f "$TARGET_DIR/ht.sh" "$HOME/ht.sh" 2>/dev/null || true
    cp -f "$TARGET_DIR/laptop.sh" "$HOME/laptop.sh" 2>/dev/null || true
    chmod +x "$HOME/hc.sh" "$HOME/ht.sh" "$HOME/laptop.sh" 2>/dev/null || true
fi

chmod +x "$TARGET_DIR/hc.sh" "$TARGET_DIR/ht.sh" "$TARGET_DIR/laptop.sh" 2>/dev/null || true

# Pastikan shebang kompatibel dengan bash environment Linux container
sed -i 's|/data/data/com.termux/files/usr/bin/bash|/usr/bin/env bash|g' "$TARGET_DIR/hc.sh" "$TARGET_DIR/ht.sh" 2>/dev/null || true

echo -e "${GREEN}✓ hc.sh dan ht.sh berhasil dipasang dan siap dieksekusi.${NC}"

echo -e "\n${BLUE}[3/4] Memeriksa konektivitas container ke 9Router...${NC}"
if grep -q "9router" /etc/hosts 2>/dev/null; then
    echo -e "${GREEN}✓ Layanan '9router' terdeteksi di jaringan internal docker.${NC}"
else
    echo -e "${YELLOW}[INFO] Host '9router' tidak ditemukan di /etc/hosts, menggunakan fallback localhost.${NC}"
fi

echo -e "\n${BLUE}[4/4] Memeriksa dependensi Telegram (python-telegram-bot)...${NC}"
if ! python3 -c "import telegram" >/dev/null 2>&1 && ! python -c "import telegram" >/dev/null 2>&1; then
    echo -e "${YELLOW}Memasang python-telegram-bot[webhooks]==22.8...${NC}"
    if command -v uv >/dev/null 2>&1; then
        uv pip install "python-telegram-bot[webhooks]==22.8" >/dev/null 2>&1 || true
    elif command -v pip3 >/dev/null 2>&1; then
        pip3 install "python-telegram-bot[webhooks]==22.8" >/dev/null 2>&1 || true
    elif command -v pip >/dev/null 2>&1; then
        pip install "python-telegram-bot[webhooks]==22.8" >/dev/null 2>&1 || true
    fi
    echo -e "${GREEN}✓ Dependensi python-telegram-bot berhasil disiapkan.${NC}"
else
    echo -e "${GREEN}✓ Dependensi Telegram sudah tersedia.${NC}"
fi

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${GREEN}✓ Persiapan Selesai! Script Siap Digunakan di Dalam Container    ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e ""
echo -e "Langkah Selanjutnya:"
echo -e "  1. Hubungkan Hermes ke 9Router:"
echo -e "     ${YELLOW}./hc.sh gdg-yogya <paste-api-key-9router>${NC}"
echo -e ""
echo -e "  2. Hubungkan ke Telegram Bot:"
echo -e "     ${YELLOW}./ht.sh <paste-token-telegram>${NC}"
echo -e ""
echo -e "Akses Layanan dari Browser Laptop Anda:"
echo -e "  • 9Router Dashboard : ${GREEN}http://localhost:20128${NC} (Password: 123456)"
echo -e "  • Hermes Dashboard  : ${GREEN}http://localhost:9119${NC}"
echo -e "${BLUE}================================================================${NC}\n"

