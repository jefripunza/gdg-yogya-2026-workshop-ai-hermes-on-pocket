# ==============================================================================
# laptop.ps1 - One-Click Setup & Runner untuk Laptop (Windows PowerShell)
#
# Penggunaan di PowerShell:
#   irm https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master/laptop.ps1 | iex
# ==============================================================================

$ErrorActionPreference = "Stop"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "    GDG Yogya 2026 - Hermes & 9Router Laptop One-Click Setup    " -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$RepoRawUrl = "https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master"

# ------------------------------------------------------------------------------
# 1. Periksa Docker & Docker Compose
# ------------------------------------------------------------------------------
Write-Host "[1/5] Memeriksa Docker & Docker Compose di laptop Anda..." -ForegroundColor Blue

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Docker belum terpasang di laptop Anda." -ForegroundColor Red
    Write-Host "Silakan pasang Docker Desktop: https://www.docker.com/products/docker-desktop/"
    Exit 1
}

try {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Docker daemon not running" }
} catch {
    Write-Host "[ERROR] Docker daemon tidak aktif atau tidak dapat diakses." -ForegroundColor Red
    Write-Host "Pastikan aplikasi Docker Desktop sedang menyala di laptop Anda."
    Exit 1
}

$ComposeCmd = "docker compose"
try {
    $composeVer = docker compose version 2>&1
    if ($LASTEXITCODE -ne 0) { $ComposeCmd = "docker-compose" }
} catch {
    $ComposeCmd = "docker-compose"
}
Write-Host "[V] Docker daemon & Compose ($ComposeCmd) siap digunakan." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 2. Unduh docker-compose.yml, hc.sh, dan ht.sh
# ------------------------------------------------------------------------------
Write-Host "`n[2/5] Menyiapkan file docker-compose.yml dan script helper..." -ForegroundColor Blue

if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "Mengunduh docker-compose.yml dari repository resmi..."
    Invoke-WebRequest -Uri "$RepoRawUrl/docker-compose.yml" -OutFile "docker-compose.yml"
} else {
    Write-Host "[V] File docker-compose.yml sudah ada." -ForegroundColor Green
}

if (-not (Test-Path "hc.sh")) {
    Write-Host "Mengunduh hc.sh..."
    Invoke-WebRequest -Uri "$RepoRawUrl/hc.sh" -OutFile "hc.sh"
}

if (-not (Test-Path "ht.sh")) {
    Write-Host "Mengunduh ht.sh..."
    Invoke-WebRequest -Uri "$RepoRawUrl/ht.sh" -OutFile "ht.sh"
}
Write-Host "[V] File konfigurasi & script helper siap." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 3. Jalankan Container via Docker Compose (Kill lama & Up ulang)
# ------------------------------------------------------------------------------
Write-Host "`n[3/5] Membersihkan container lama dan menjalankan ulang..." -ForegroundColor Blue
if ($ComposeCmd -eq "docker compose") {
    $null = docker compose down 2>&1
    docker compose up -d
} else {
    $null = docker-compose down 2>&1
    docker-compose up -d
}

Write-Host "Menunggu container siap..."
Start-Sleep -Seconds 5

# ------------------------------------------------------------------------------
# 4. Inject hc.sh & ht.sh ke Dalam Container hermes-agent
# ------------------------------------------------------------------------------
Write-Host "`n[4/5] Meng-inject file hc.sh dan ht.sh ke dalam container hermes-agent..." -ForegroundColor Blue

docker cp hc.sh hermes-agent:/opt/hermes/hc.sh
docker cp ht.sh hermes-agent:/opt/hermes/ht.sh
docker cp hc.sh hermes-agent:/root/hc.sh 2>$null
docker cp ht.sh hermes-agent:/root/ht.sh 2>$null

docker exec hermes-agent chmod +x /opt/hermes/hc.sh /opt/hermes/ht.sh /root/hc.sh /root/ht.sh 2>$null
docker exec hermes-agent sed -i 's|/data/data/com.termux/files/usr/bin/bash|/usr/bin/env bash|g' /opt/hermes/hc.sh /opt/hermes/ht.sh /root/hc.sh /root/ht.sh 2>$null
docker exec hermes-agent sh -c 'if [ -d "/opt/data" ] && [ ! -d "$HOME/.hermes" ]; then ln -s /opt/data "$HOME/.hermes" 2>/dev/null; fi' 2>$null

Write-Host "[V] hc.sh dan ht.sh berhasil di-inject ke dalam container hermes-agent." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 5. Ringkasan & Panduan Langkah Selanjutnya
# ------------------------------------------------------------------------------
Write-Host "`n================================================================" -ForegroundColor Cyan
Write-Host " Setup Selesai! Layanan AI Berjalan di Laptop Anda!             " -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dashboard yang Dapat Diakses di Browser Laptop Anda:"
Write-Host "  1. 9Router Web Dashboard :"
Write-Host "     URL      : http://localhost:20128" -ForegroundColor Yellow
Write-Host "     Password : 123456" -ForegroundColor Yellow
Write-Host ""
Write-Host "  2. Hermes Web Dashboard  :"
Write-Host "     URL      : http://localhost:9119" -ForegroundColor Yellow
Write-Host "     Login    : Username: admin | Password: 123456" -ForegroundColor Yellow
Write-Host ""
Write-Host "----------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Langkah Selanjutnya:"
Write-Host "  Step 1: Buka 9Router (http://localhost:20128), masukkan Gemini API Key,"
Write-Host "          buat combo 'gdg-yogya', lalu salin API Key 9Router Anda."
Write-Host ""
Write-Host "  Step 2: Hubungkan Hermes ke 9Router dengan perintah:"
Write-Host "          docker exec -it hermes-agent ./hc.sh gdg-yogya <api-key-9router>" -ForegroundColor Green
Write-Host ""
Write-Host "  Step 3: Hubungkan ke Telegram Bot dengan perintah:"
Write-Host "          docker exec -it hermes-agent ./ht.sh <token-telegram>" -ForegroundColor Green
Write-Host "================================================================`n" -ForegroundColor Cyan

