#!/usr/bin/env bash
# ==============================================================================
# laptop.sh - One-Click Setup, Reset, Runner, & CLI Manager untuk Laptop
#
# Penggunaan:
#   ./laptop.sh             # Reset, jalankan ulang container, & inject script (default)
#   ./laptop.sh restart     # Sama dengan ./laptop.sh (kill container & up ulang)
#   ./laptop.sh stop        # Hentikan container sementara
#   ./laptop.sh down        # Hentikan dan bersihkan container
#   ./laptop.sh logs [srv]  # Pantau log container (opsional: 9router / hermes)
#   ./laptop.sh exec        # Masuk ke sesi terminal container hermes-agent
#   ./laptop.sh status      # Cek status container
#
# Eksekusi langsung via curl:
#   curl -fsSL https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master/laptop.sh | bash
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_RAW_URL="https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master"

# Deteksi perintah docker compose yang tersedia
if docker compose version >/dev/null 2>&1; then
    COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE="docker-compose"
else
    echo -e "${RED}[ERROR] Docker Compose tidak ditemukan.${NC}"
    echo "Pastikan Docker Desktop atau docker-compose sudah terpasang di laptop Anda."
    exit 1
fi

# Cek ketersediaan docker daemon
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}[ERROR] Docker daemon tidak aktif atau tidak dapat diakses.${NC}"
        echo "Pastikan aplikasi Docker Desktop sedang berjalan di laptop Anda."
        exit 1
    fi
}

show_info() {
    echo -e "\n${BLUE}================================================================${NC}"
    echo -e "${GREEN}🎉 Layanan AI Berhasil Berjalan di Laptop Anda!                  ${NC}"
    echo -e "${BLUE}================================================================${NC}"
    echo -e "Dashboard yang Dapat Diakses di Browser Laptop Anda:"
    echo -e "  1. ${YELLOW}9Router Web Dashboard${NC} :"
    echo -e "     URL      : ${GREEN}http://localhost:20128${NC}"
    echo -e "     Password : ${GREEN}123456${NC}"
    echo -e ""
    echo -e "  2. ${YELLOW}Hermes Web Dashboard${NC}  :"
    echo -e "     URL      : ${GREEN}http://localhost:9119${NC}"
    echo -e "     Login    : Username: ${GREEN}admin${NC} | Password: ${GREEN}123456${NC}"
    echo -e ""
    echo -e "  3. ${YELLOW}Hermes Gateway API${NC}    : ${GREEN}http://localhost:8642${NC}"
    echo -e ""
    echo -e "${BLUE}----------------------------------------------------------------${NC}"
    echo -e "Langkah Selanjutnya:"
    echo -e "  Step 1: Buka 9Router (http://localhost:20128), masukkan Gemini API Key,"
    echo -e "          buat combo 'gdg-yogya', lalu salin API Key 9Router Anda."
    echo -e ""
    echo -e "  Step 2: Hubungkan Hermes ke 9Router dengan perintah:"
    echo -e "          ${YELLOW}docker exec -it hermes-agent ./hc.sh gdg-yogya <api-key-9router>${NC}"
    echo -e ""
    echo -e "  Step 3: Hubungkan ke Telegram Bot dengan perintah:"
    echo -e "          ${YELLOW}docker exec -it hermes-agent ./ht.sh <token-telegram>${NC}"
    echo -e ""
    echo -e "Perintah Cepat CLI:"
    echo -e "  • Masuk ke shell hermes : ${GREEN}./laptop.sh exec${NC}"
    echo -e "  • Pantau logs           : ${GREEN}./laptop.sh logs${NC}"
    echo -e "  • Restart ulang bersih  : ${GREEN}./laptop.sh restart${NC}"
    echo -e "${BLUE}================================================================${NC}\n"
}

# Fungsi Utama: Reset / Run / Up Ulang Container & Inject Script
action_run_or_restart() {
    check_docker

    echo -e "${BLUE}================================================================${NC}"
    echo -e "${GREEN}    GDG Yogya 2026 - Hermes & 9Router Laptop Setup / Reset      ${NC}"
    echo -e "${BLUE}================================================================${NC}"

    # 1. Siapkan file konfigurasi & script helper
    echo -e "\n${BLUE}[1/5] Menyiapkan file docker-compose.yml dan script helper...${NC}"
    if [ ! -f "docker-compose.yml" ]; then
        echo "Mengunduh docker-compose.yml..."
        curl -fsSL "${REPO_RAW_URL}/docker-compose.yml" -o docker-compose.yml
    fi

    if [ ! -f "hc.sh" ]; then
        echo "Mengunduh hc.sh..."
        curl -fsSL "${REPO_RAW_URL}/hc.sh" -o hc.sh
    fi
    chmod +x hc.sh 2>/dev/null || true

    if [ ! -f "ht.sh" ]; then
        echo "Mengunduh ht.sh..."
        curl -fsSL "${REPO_RAW_URL}/ht.sh" -o ht.sh
    fi
    chmod +x ht.sh 2>/dev/null || true

    # 2. Kill / Down container lama jika sedang berjalan (idempotent reset)
    echo -e "\n${BLUE}[2/5] Membersihkan container lama (kill & down)...${NC}"
    if docker ps -q -f name=^/hermes-agent$ >/dev/null 2>&1 || docker ps -q -f name=^/9router$ >/dev/null 2>&1; then
        echo -e "${YELLOW}Menghentikan dan membersihkan container yang sedang aktif...${NC}"
        $COMPOSE down || true
    fi
    echo -e "${GREEN}✓ Lingkungan siap untuk dijalankan ulang.${NC}"

    # 3. Up ulang container via Docker Compose
    echo -e "\n${BLUE}[3/5] Menjalankan ulang container 9Router dan Hermes Agent...${NC}"
    $COMPOSE up -d

    echo "Menunggu container siap..."
    RETRY=0
    MAX_RETRY=15
    while [ $RETRY -lt $MAX_RETRY ]; do
        if docker ps -q -f name=^/hermes-agent$ >/dev/null 2>&1 && docker ps -q -f name=^/9router$ >/dev/null 2>&1; then
            break
        fi
        sleep 1
        RETRY=$((RETRY + 1))
    done

    # 4. Inject hc.sh & ht.sh ke dalam container hermes-agent
    echo -e "\n${BLUE}[4/5] Meng-inject file hc.sh dan ht.sh ke dalam container hermes-agent...${NC}"
    docker cp hc.sh hermes-agent:/opt/hermes/hc.sh
    docker cp ht.sh hermes-agent:/opt/hermes/ht.sh
    docker cp hc.sh hermes-agent:/root/hc.sh 2>/dev/null || true
    docker cp ht.sh hermes-agent:/root/ht.sh 2>/dev/null || true

    docker exec hermes-agent chmod +x /opt/hermes/hc.sh /opt/hermes/ht.sh /root/hc.sh /root/ht.sh 2>/dev/null || true
    docker exec hermes-agent sed -i 's|/data/data/com.termux/files/usr/bin/bash|/usr/bin/env bash|g' /opt/hermes/hc.sh /opt/hermes/ht.sh 2>/dev/null || true
    docker exec hermes-agent sh -c 'if [ -d "/opt/data" ] && [ ! -d "$HOME/.hermes" ]; then ln -s /opt/data "$HOME/.hermes" 2>/dev/null; fi' 2>/dev/null || true

    echo -e "${GREEN}✓ Script hc.sh dan ht.sh berhasil di-inject ke dalam container hermes-agent.${NC}"

    # 5. Tampilkan info dashboard
    echo -e "\n${BLUE}[5/5] Selesai!${NC}"
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
        echo "Jalankan './laptop.sh' terlebih dahulu."
        exit 1
    fi
}

show_help() {
    echo -e "${GREEN}GDG Yogya 2026 - Laptop Docker Manager (laptop.sh)${NC}"
    echo ""
    echo "Penggunaan: ./laptop.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  (tanpa argumen)    Reset, jalankan container, & inject script (rekomendasi)"
    echo "  run | restart | up Kill container lama dan jalankan ulang secara bersih"
    echo "  stop               Hentikan seluruh container sementara"
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
    run|restart|up|start)
        action_run_or_restart
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
