#!/usr/bin/env bash

# ==============================================================================
# restart.sh - Script untuk reset, rebuild, dan run ulang container Termux RnD
# ==============================================================================

set -e

# Konfigurasi
CONTAINER_NAME="termux-rnd"
IMAGE_NAME="termux-rnd:latest"
HOST_PORT="8080"
CONTAINER_PORT="8080"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_HOST="${SCRIPT_DIR}/workspace"
WORKSPACE_CONTAINER="/data/data/com.termux/files/home/workspace"

# Warna terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parsing argumen
AUTO_ATTACH=false
AS_ROOT=false
RUN_SETUP=false

for arg in "$@"; do
    case "$arg" in
        -i|--interactive)
            AUTO_ATTACH=true
            ;;
        --root)
            AS_ROOT=true
            ;;
        -s|--setup)
            RUN_SETUP=true
            ;;
        -h|--help)
            echo "Penggunaan: ./restart.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -s, --setup         Otomatis instal paket-paket dasar RnD setelah container aktif"
            echo "  -i, --interactive   Langsung masuk ke sesi shell Termux setelah container siap"
            echo "  --root              Masuk sebagai user root (entrypoint_root.sh)"
            echo "  -h, --help          Tampilkan panduan ini"
            exit 0
            ;;
    esac
done

echo -e "${BLUE}=== [1/4] Memeriksa Docker Daemon ===${NC}"
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] Docker daemon tidak aktif atau tidak dapat diakses.${NC}"
    echo "Pastikan aplikasi Docker Desktop sedang berjalan."
    exit 1
fi
echo -e "${GREEN}✓ Docker daemon siap.${NC}"

# Persiapkan direktori workspace lokal untuk persistent storage
mkdir -p "${WORKSPACE_HOST}"

echo -e "\n${BLUE}=== [2/4] Membersihkan Container Lama ===${NC}"
# Hentikan container jika sedang berjalan
if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo -e "${YELLOW}Menghentikan container '${CONTAINER_NAME}'...${NC}"
    docker stop "${CONTAINER_NAME}"
fi

# Hapus container lama jika ada
if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
    echo -e "${YELLOW}Menghapus container '${CONTAINER_NAME}'...${NC}"
    docker rm -f "${CONTAINER_NAME}"
fi
echo -e "${GREEN}✓ Container lama telah dibersihkan.${NC}"

echo -e "\n${BLUE}=== [3/4] Membangun Docker Image '${IMAGE_NAME}' ===${NC}"
docker build -t "${IMAGE_NAME}" "${SCRIPT_DIR}"
echo -e "${GREEN}✓ Docker image berhasil dibangun.${NC}"

echo -e "\n${BLUE}=== [4/4] Menjalankan Container '${CONTAINER_NAME}' ===${NC}"
# Flag khusus untuk Termux di macOS Docker:
# --security-opt seccomp:unconfined : Dibutuhkan untuk kompatibilitas bionic syscall
# --ulimit nofile=1048576:1048576   : Mencegah dnsmasq 100% CPU hang di macOS
docker run -d -it \
    --name "${CONTAINER_NAME}" \
    --security-opt seccomp:unconfined \
    --ulimit nofile=1048576:1048576 \
    -p "${HOST_PORT}:${CONTAINER_PORT}" \
    -v "${WORKSPACE_HOST}:${WORKSPACE_CONTAINER}" \
    "${IMAGE_NAME}"

echo -e "${GREEN}✓ Container '${CONTAINER_NAME}' berhasil dijalankan!${NC}"

# Jalankan instalasi paket dasar jika diminta via --setup
if [ "$RUN_SETUP" = true ]; then
    echo -e "\n${YELLOW}Menjalankan setup paket dasar RnD di dalam container...${NC}"
    docker exec -it "${CONTAINER_NAME}" /entrypoint.sh sh -c \
        "pkg update -y && pkg install -y curl wget git python nano tar unzip jq openssh build-essential && pkg clean"
    echo -e "${GREEN}✓ Paket-paket dasar berhasil diinstal!${NC}"
fi

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${GREEN} Termux RnD Container Siap Digunakan!${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e " Container Name  : ${YELLOW}${CONTAINER_NAME}${NC}"
echo -e " Mounted Volume  : ${YELLOW}${WORKSPACE_HOST}${NC} -> ${YELLOW}${WORKSPACE_CONTAINER}${NC}"
echo -e " Port Forwarding : ${YELLOW}localhost:${HOST_PORT} -> ${CONTAINER_PORT}${NC}"
echo -e ""
echo -e " Perintah masuk ke shell Termux (User biasa - disarankan):"
echo -e "   ${GREEN}docker exec -it ${CONTAINER_NAME} /entrypoint.sh login${NC}"
echo -e ""
echo -e " Perintah masuk ke shell sebagai Root (jika diperlukan):"
echo -e "   ${GREEN}docker exec -it ${CONTAINER_NAME} /entrypoint_root.sh login${NC}"
echo -e ""
echo -e " Perintah instal paket dari host:"
echo -e "   ${GREEN}docker exec -it ${CONTAINER_NAME} /entrypoint.sh pkg install <nama-paket>${NC}"
echo -e "   atau jalankan: ${YELLOW}./setup-packages.sh${NC}"
echo -e ""
echo -e " Perintah melihat log container:"
echo -e "   ${GREEN}docker logs -f ${CONTAINER_NAME}${NC}"
echo -e "${BLUE}================================================================${NC}\n"

# Masuk otomatis jika opsi -i / --interactive diberikan
if [ "$AUTO_ATTACH" = true ]; then
    if [ "$AS_ROOT" = true ]; then
        echo -e "${YELLOW}Menghubungkan ke container sebagai root...${NC}"
        docker exec -it "${CONTAINER_NAME}" /entrypoint_root.sh login
    else
        echo -e "${YELLOW}Menghubungkan ke container sebagai Termux user...${NC}"
        docker exec -it "${CONTAINER_NAME}" /entrypoint.sh login
    fi
fi
