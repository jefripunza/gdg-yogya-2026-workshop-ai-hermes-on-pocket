#!/usr/bin/env bash

# ==============================================================================
# setup-packages.sh - Instal paket-paket dasar RnD ke dalam container Termux
# ==============================================================================

set -e

CONTAINER_NAME="termux-rnd"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if ! docker ps -q -f name=^/${CONTAINER_NAME}$ >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] Container '${CONTAINER_NAME}' tidak sedang berjalan.${NC}"
    echo "Silakan jalankan container terlebih dahulu dengan: ./restart.sh"
    exit 1
fi

echo -e "${BLUE}=== Mengupdate repository dan menginstal paket RnD Termux ===${NC}"
echo -e "${YELLOW}Paket yang akan diinstal: curl, wget, git, python, nano, tar, unzip, jq, openssh, build-essential${NC}\n"

docker exec -it "${CONTAINER_NAME}" /entrypoint.sh sh -c \
    "pkg update -y && pkg install -y curl wget git python nano tar unzip jq openssh build-essential && pkg clean"

echo -e "\n${GREEN}✓ Setup paket berhasil diselesaikan!${NC}"

