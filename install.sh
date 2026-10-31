#!/usr/bin/env bash

# ==============================================================================
# install.sh - Menjalankan installer Hermes Agent & 9Router di dalam container Termux
# ==============================================================================

set -e

CONTAINER_NAME="termux-rnd"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOBILE_SCRIPT="${SCRIPT_DIR}/mobile.sh"
HC_SCRIPT="${SCRIPT_DIR}/hc.sh"
HT_SCRIPT="${SCRIPT_DIR}/ht.sh"

# Warna output terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Pastikan file yang dibutuhkan ada
for f in "$MOBILE_SCRIPT" "$HC_SCRIPT" "$HT_SCRIPT"; do
    if [ ! -f "$f" ]; then
        echo -e "${RED}[ERROR] File tidak ditemukan: $f${NC}"
        exit 1
    fi
done

echo -e "${BLUE}=== [1/3] Memeriksa Status Container '${CONTAINER_NAME}' ===${NC}"

# Cek apakah Docker daemon aktif
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] Docker daemon tidak aktif atau tidak dapat diakses.${NC}"
    echo "Pastikan Docker Desktop sudah berjalan."
    exit 1
fi

# Cek apakah container sedang berjalan
if [ ! "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
        echo -e "${YELLOW}Container '${CONTAINER_NAME}' ditemukan dalam kondisi stop. Menjalankan container...${NC}"
        docker start "${CONTAINER_NAME}"
    else
        echo -e "${YELLOW}Container '${CONTAINER_NAME}' belum ada. Menjalankan restart.sh...${NC}"
        "${SCRIPT_DIR}/restart.sh"
    fi
fi

echo -e "${GREEN}✓ Container '${CONTAINER_NAME}' aktif.${NC}"

echo -e "\n${BLUE}=== [2/3] Menyalin Script (mobile.sh, hc.sh, ht.sh) ke Container ===${NC}"
docker cp "${MOBILE_SCRIPT}" "${CONTAINER_NAME}:/data/data/com.termux/files/home/mobile.sh"
docker cp "${HC_SCRIPT}" "${CONTAINER_NAME}:/data/data/com.termux/files/home/hc.sh"
docker cp "${HT_SCRIPT}" "${CONTAINER_NAME}:/data/data/com.termux/files/home/ht.sh"

docker exec "${CONTAINER_NAME}" chmod +x \
    /data/data/com.termux/files/home/mobile.sh \
    /data/data/com.termux/files/home/hc.sh \
    /data/data/com.termux/files/home/ht.sh

echo -e "${GREEN}✓ Script mobile.sh, hc.sh, dan ht.sh siap di dalam container.~${NC}"

echo -e "\n${BLUE}=== [3/3] Menjalankan Instalasi di Dalam Container ===${NC}\n"
docker exec -it "${CONTAINER_NAME}" /entrypoint.sh bash /data/data/com.termux/files/home/mobile.sh
