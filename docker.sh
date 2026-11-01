#!/usr/bin/env bash
# ==============================================================================
# docker.sh - Helper CLI untuk Run, Restart, dan Kelola Container Docker
#
# Penggunaan:
#   ./docker.sh run       # Menjalankan container (docker compose up -d)
#   ./docker.sh restart   # Merestart container (docker compose restart)
#   ./docker.sh stop      # Menghentikan container
#   ./docker.sh down      # Menghentikan dan menghapus container
#   ./docker.sh logs      # Melihat log container
#   ./docker.sh exec      # Masuk ke sesi bash container hermes-agent
#   ./docker.sh status    # Memeriksa status container
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Deteksi perintah docker compose yang tersedia
if docker compose version >/dev/null 2>&1; then
    COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE="docker-compose"
else
    echo -e "${RED}[ERROR] Docker Compose tidak ditemukan.${NC}"
    echo "Pastikan Docker Desktop atau docker-compose sudah terpasang di sistem Anda."
    exit 1
fi

# Cek ketersediaan docker daemon
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}[ERROR] Docker daemon tidak aktif atau tidak dapat diakses.${NC}"
        echo "Pastikan aplikasi Docker Desktop sedang berjalan."
        exit 1
    fi
}

show_info() {
    echo -e "\n${BLUE}================================================================${NC}"
    echo -e "${GREEN}   Container Berhasil Berjalan!                                 ${NC}"
    echo -e "${BLUE}================================================================${NC}"
    echo -e "🔹 9Router Web Dashboard : ${YELLOW}http://localhost:20128${NC} (Password: 123456)"
    echo -e "🔹 Hermes Web Dashboard  : ${YELLOW}http://localhost:9119${NC} (User: admin / Pass: 123456)"
    echo -e "🔹 Hermes Gateway API    : ${YELLOW}http://localhost:8642${NC}"
    echo -e ""
    echo -e "Langkah Selanjutnya (Setup Helper di Dalam Container):"
    echo -e "  ${GREEN}docker exec -it hermes-agent bash -c \"curl -fsSL https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master/laptop.sh | bash\"${NC}"
    echo -e ""
    echo -e "Atau masuk ke dalam shell hermes-agent:"
    echo -e "  ${YELLOW}./docker.sh exec${NC}"
    echo -e "${BLUE}================================================================${NC}\n"
}

action_run() {
    check_docker
    echo -e "${BLUE}[+] Menjalankan container via ${COMPOSE}...${NC}"
    $COMPOSE up -d
    echo -e "${GREEN}✓ Container aktif!${NC}"
    show_info
}

action_restart() {
    check_docker
    echo -e "${YELLOW}[!] Merestart container via ${COMPOSE}...${NC}"
    $COMPOSE restart
    echo -e "${GREEN}✓ Container berhasil direstart!${NC}"
    show_info
}

action_stop() {
    check_docker
    echo -e "${YELLOW}[!] Menghentikan container via ${COMPOSE}...${NC}"
    $COMPOSE stop
    echo -e "${GREEN}✓ Container dihentikan.${NC}"
}

action_down() {
    check_docker
    echo -e "${RED}[!] Mematikan dan membersihkan container via ${COMPOSE}...${NC}"
    $COMPOSE down
    echo -e "${GREEN}✓ Container dan network berhasil dibersihkan.${NC}"
}

action_logs() {
    check_docker
    SERVICE="$1"
    if [ -n "$SERVICE" ]; then
        $COMPOSE logs -f "$SERVICE"
    else
        $COMPOSE logs -f
    fi
}

action_status() {
    check_docker
    echo -e "${BLUE}=== Status Container ===${NC}"
    $COMPOSE ps
}

action_exec() {
    check_docker
    echo -e "${BLUE}[+] Menghubungkan ke container hermes-agent...${NC}"
    if docker ps -q -f name=^/hermes-agent$ >/dev/null 2>&1; then
        docker exec -it hermes-agent bash
    else
        echo -e "${RED}[ERROR] Container 'hermes-agent' sedang tidak berjalan.${NC}"
        echo "Jalankan './docker.sh run' terlebih dahulu."
        exit 1
    fi
}

show_help() {
    echo -e "${GREEN}Helper Pengelolaan Docker Container - GDG Yogya 2026${NC}"
    echo ""
    echo "Penggunaan: ./docker.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  run | up | start   Jalankan seluruh service di background (docker compose up -d)"
    echo "  restart            Restart seluruh service (docker compose restart)"
    echo "  stop               Hentikan seluruh service sementara"
    echo "  down               Hentikan dan bersihkan container & network"
    echo "  logs [service]     Pantau log container (opsional: 9router / hermes)"
    echo "  exec               Masuk ke sesi terminal bash container hermes-agent"
    echo "  status | ps        Tampilkan status container yang sedang berjalan"
    echo "  help | -h          Tampilkan pesan bantuan ini"
    echo ""
}

# Routing perintah
COMMAND="${1:-run}"
shift 2>/dev/null || true

case "$COMMAND" in
    run|up|start)
        action_run
        ;;
    restart)
        action_restart
        ;;
    stop)
        action_stop
        ;;
    down)
        action_down
        ;;
    logs)
        action_logs "$1"
        ;;
    status|ps)
        action_status
        ;;
    exec|bash|sh)
        action_exec
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        echo -e "${RED}Perintah tidak dikenal: ${COMMAND}${NC}"
        show_help
        exit 1
        ;;
esac

