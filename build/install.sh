#!/usr/bin/env bash

# ==============================================================================
# install.sh - Menjalankan installer Hermes Agent & 9Router di dalam container Termux
# ==============================================================================

set -e

CONTAINER_NAME="termux-rnd"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MOBILE_SCRIPT="${PROJECT_ROOT}/mobile.sh"
HC_SCRIPT="${PROJECT_ROOT}/hc.sh"
HT_SCRIPT="${PROJECT_ROOT}/ht.sh"
DIAGNOSE_SCRIPT="${PROJECT_ROOT}/diagnose.sh"
WEB_DIST_TAR="${PROJECT_ROOT}/web_dist.tar.gz"

# Warna output terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Pastikan file yang dibutuhkan ada
for f in "$MOBILE_SCRIPT" "$HC_SCRIPT" "$HT_SCRIPT" "$DIAGNOSE_SCRIPT"; do
    if [ ! -f "$f" ]; then
        echo -e "${RED}[ERROR] File tidak ditemukan: $f${NC}"
        exit 1
    fi
done

echo -e "${BLUE}=== [1/3] Memeriksa Status Container & Network '${CONTAINER_NAME}' ===${NC}"

# Cek apakah Docker daemon aktif
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] Docker daemon tidak aktif atau tidak dapat diakses.${NC}"
    echo "Pastikan Docker Desktop sudah berjalan."
    exit 1
fi

# Cek apakah container sudah ada dan memiliki port forward yang lengkap
NEED_RESTART=false

if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
    PORT_CHECK=$(docker port "${CONTAINER_NAME}" 20128 2>/dev/null || true)
    if [ -z "$PORT_CHECK" ]; then
        echo -e "${YELLOW}Container '${CONTAINER_NAME}' lama belum mengekspos port 20128 & 9119.${NC}"
        NEED_RESTART=true
    fi
else
    NEED_RESTART=true
fi

if [ "$NEED_RESTART" = true ]; then
    echo -e "${BLUE}Menjalankan restart.sh untuk inisialisasi container dengan port forwarding yang benar...${NC}"
    "${SCRIPT_DIR}/restart.sh"
elif [ ! "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo -e "${YELLOW}Menjalankan container '${CONTAINER_NAME}'...${NC}"
    docker start "${CONTAINER_NAME}"
fi

echo -e "${GREEN}✓ Container '${CONTAINER_NAME}' aktif dengan port forwarding.${NC}"

echo -e "\n${BLUE}=== [2/3] Menyalin Script & Aset (mobile.sh, hc.sh, ht.sh, diagnose.sh, web_dist.tar.gz) ke Container ===${NC}"
docker cp "${MOBILE_SCRIPT}" "${CONTAINER_NAME}:/data/data/com.termux/files/home/mobile.sh"
docker cp "${HC_SCRIPT}" "${CONTAINER_NAME}:/data/data/com.termux/files/home/hc.sh"
docker cp "${HT_SCRIPT}" "${CONTAINER_NAME}:/data/data/com.termux/files/home/ht.sh"
docker cp "${DIAGNOSE_SCRIPT}" "${CONTAINER_NAME}:/data/data/com.termux/files/home/diagnose.sh"
if [ -f "${WEB_DIST_TAR}" ]; then
    docker cp "${WEB_DIST_TAR}" "${CONTAINER_NAME}:/data/data/com.termux/files/home/web_dist.tar.gz"
fi

docker exec "${CONTAINER_NAME}" chmod +x \
    /data/data/com.termux/files/home/mobile.sh \
    /data/data/com.termux/files/home/hc.sh \
    /data/data/com.termux/files/home/ht.sh \
    /data/data/com.termux/files/home/diagnose.sh

docker exec "${CONTAINER_NAME}" /entrypoint.sh bash -c \
    "termux-fix-shebang /data/data/com.termux/files/home/mobile.sh /data/data/com.termux/files/home/hc.sh /data/data/com.termux/files/home/ht.sh /data/data/com.termux/files/home/diagnose.sh 2>/dev/null || true"

echo -e "${GREEN}✓ Script mobile.sh, hc.sh, ht.sh, dan diagnose.sh siap di dalam container.~${NC}"

echo -e "\n${BLUE}=== [3/3] Menjalankan Instalasi di Dalam Container (Mode --local) ===${NC}\n"
docker exec -it "${CONTAINER_NAME}" /entrypoint.sh bash /data/data/com.termux/files/home/mobile.sh --local

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${GREEN}✓ Instalasi RnD Berhasil Diselesaikan!${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "${YELLOW}📋 CHEATSHEET PERINTAH (Tinggal Salin & Tempel):${NC}\n"

echo -e "1️⃣ ${GREEN}Masuk ke Terminal Termux Container:${NC}"
echo -e "   ${YELLOW}docker exec -it ${CONTAINER_NAME} /entrypoint.sh login${NC}\n"

echo -e "2️⃣ ${GREEN}Konfigurasi Hermes ke 9Router (hc.sh):${NC}"
echo -e "   • Di dalam container Termux:"
echo -e "     ${YELLOW}./hc.sh gdg-yogya <api-key-9router>${NC}"
echo -e "   • Atau langsung dari terminal Mac:"
echo -e "     ${YELLOW}docker exec -it ${CONTAINER_NAME} /entrypoint.sh bash -c \"./hc.sh gdg-yogya <api-key-9router>\"${NC}\n"

echo -e "3️⃣ ${GREEN}Integrasi Telegram Bot (ht.sh):${NC}"
echo -e "   • Di dalam container Termux:"
echo -e "     ${YELLOW}./ht.sh <token-telegram>${NC}"
echo -e "   • Atau langsung dari terminal Mac:"
echo -e "     ${YELLOW}docker exec -it ${CONTAINER_NAME} /entrypoint.sh bash -c \"./ht.sh <token-telegram>\"${NC}\n"

echo -e "4️⃣ ${GREEN}Akses Web Dashboard di Browser:${NC}"
echo -e "   🔹 9Router Dashboard : ${YELLOW}http://localhost:20128${NC} (Password: ${GREEN}123456${NC})"
echo -e "   🔹 Hermes Dashboard  : ${YELLOW}http://localhost:9119${NC}"
echo -e "${BLUE}================================================================${NC}\n"
