#!/usr/bin/env bash

# ==============================================================================
# install.sh - Menjalankan installer Hermes Agent (mobile.sh) di dalam container Termux
# ==============================================================================

set -e

CONTAINER_NAME="termux-rnd"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOBILE_SCRIPT="${SCRIPT_DIR}/mobile.sh"

# Warna output terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Pastikan file mobile.sh ada
if [ ! -f "$MOBILE_SCRIPT" ]; then
    echo -e "${RED}[ERROR] File mobile.sh tidak ditemukan di: ${MOBILE_SCRIPT}${NC}"
    exit 1
fi

echo -e "${BLUE}=== [1/3] Memeriksa Status Container '${CONTAINER_NAME}' ===${NC}"

# Cek apakah Docker daemon aktif
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] Docker daemon tidak aktif atau tidak dapat diakses.${NC}"
    echo "Pastikan Docker Desktop sudah berjalan."
    exit 1
fi

# Cek apakah container sedang berjalan
if [ ! "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    # Jika container ada tapi statusnya stop, start container
    if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
        echo -e "${YELLOW}Container '${CONTAINER_NAME}' ditemukan dalam kondisi stop. Menjalankan container...${NC}"
        docker start "${CONTAINER_NAME}"
    else
        echo -e "${YELLOW}Container '${CONTAINER_NAME}' belum ada.${NC}"
        echo -e "${BLUE}Menjalankan restart.sh untuk inisialisasi container baru...${NC}"
        "${SCRIPT_DIR}/restart.sh"
    fi
fi

echo -e "${GREEN}✓ Container '${CONTAINER_NAME}' aktif.${NC}"

echo -e "\n${BLUE}=== [2/3] Menyalin mobile.sh ke Dalam Container ===${NC}"
docker cp "${MOBILE_SCRIPT}" "${CONTAINER_NAME}:/data/data/com.termux/files/home/mobile.sh"
docker exec "${CONTAINER_NAME}" chmod +x /data/data/com.termux/files/home/mobile.sh
echo -e "${GREEN}✓ mobile.sh berhasil disalin ke ~/mobile.sh di dalam container.${NC}"

echo -e "\n${BLUE}=== [3/3] Menjalankan Instalasi Hermes Agent di Dalam Container ===${NC}\n"
docker exec -it "${CONTAINER_NAME}" /entrypoint.sh bash /data/data/com.termux/files/home/mobile.sh

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${GREEN} Instalasi Selesai! Cara Menggunakan Hermes Agent di Container:${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e " 1. Setup provider LLM / API keys:"
echo -e "    ${GREEN}docker exec -it ${CONTAINER_NAME} /entrypoint.sh hermes setup${NC}"
echo -e ""
echo -e " 2. Jalankan antarmuka interaktif Hermes TUI:"
echo -e "    ${GREEN}docker exec -it ${CONTAINER_NAME} /entrypoint.sh hermes --tui${NC}"
echo -e ""
echo -e " 3. Masuk ke shell Termux:"
echo -e "    ${GREEN}docker exec -it ${CONTAINER_NAME} /entrypoint.sh login${NC}"
echo -e "${BLUE}================================================================${NC}\n"

