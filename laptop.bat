@echo off
REM ==============================================================================
REM laptop.bat - One-Click Setup & Runner untuk Laptop (Windows Host)
REM
REM Penggunaan:
REM   Double click file laptop.bat atau jalankan di CMD / PowerShell:
REM   .\laptop.bat
REM ==============================================================================

setlocal enabledelayedexpansion

echo ================================================================
echo     GDG Yogya 2026 - Hermes ^& 9Router Laptop One-Click Setup
echo ================================================================
echo.

set "REPO_RAW_URL=https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master"

REM ------------------------------------------------------------------------------
REM 1. Periksa Ketersediaan Docker Daemon
REM ------------------------------------------------------------------------------
echo [1/5] Memeriksa Docker ^& Docker Compose di laptop Anda...

where docker >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker belum terpasang di laptop Anda.
    echo Silakan unduh dan pasang Docker Desktop: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

docker info >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker daemon tidak aktif atau tidak dapat diakses.
    echo Pastikan aplikasi Docker Desktop sedang menyala di laptop Anda.
    pause
    exit /b 1
)

set "COMPOSE=docker compose"
docker compose version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    where docker-compose >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        set "COMPOSE=docker-compose"
    ) else (
        echo [ERROR] Docker Compose tidak ditemukan.
        pause
        exit /b 1
    )
)
echo [V] Docker daemon ^& Compose siap digunakan.

REM ------------------------------------------------------------------------------
REM 2. Siapkan File docker-compose.yml, hc.sh, dan ht.sh
REM ------------------------------------------------------------------------------
echo.
echo [2/5] Menyiapkan file docker-compose.yml dan script helper...

if not exist "docker-compose.yml" (
    echo Mengunduh docker-compose.yml dari repository resmi...
    certutil -urlcache -split -f "%REPO_RAW_URL%/docker-compose.yml" docker-compose.yml >nul 2>&1
) else (
    echo [V] File docker-compose.yml sudah ada.
)

if not exist "hc.sh" (
    echo Mengunduh hc.sh...
    certutil -urlcache -split -f "%REPO_RAW_URL%/hc.sh" hc.sh >nul 2>&1
)

if not exist "ht.sh" (
    echo Mengunduh ht.sh...
    certutil -urlcache -split -f "%REPO_RAW_URL%/ht.sh" ht.sh >nul 2>&1
)
echo [V] File konfigurasi ^& script helper siap.

REM ------------------------------------------------------------------------------
REM 3. Jalankan Container via Docker Compose (Kill lama & Up ulang)
REM ------------------------------------------------------------------------------
echo.
echo [3/5] Membersihkan container lama dan menjalankan ulang...
%COMPOSE% down >nul 2>&1
%COMPOSE% up -d

echo Menunggu container siap...
timeout /t 5 /nobreak >nul

REM ------------------------------------------------------------------------------
REM 4. Inject hc.sh & ht.sh ke Dalam Container hermes-agent
REM ------------------------------------------------------------------------------
echo.
echo [4/5] Meng-inject file hc.sh dan ht.sh ke dalam container hermes-agent...

docker cp hc.sh hermes-agent:/opt/hermes/hc.sh
docker cp ht.sh hermes-agent:/opt/hermes/ht.sh
docker cp hc.sh hermes-agent:/root/hc.sh >nul 2>&1
docker cp ht.sh hermes-agent:/root/ht.sh >nul 2>&1

docker exec hermes-agent chmod +x /opt/hermes/hc.sh /opt/hermes/ht.sh /root/hc.sh /root/ht.sh >nul 2>&1
docker exec hermes-agent sed -i "s|/data/data/com.termux/files/usr/bin/bash|/usr/bin/env bash|g" /opt/hermes/hc.sh /opt/hermes/ht.sh /root/hc.sh /root/ht.sh >nul 2>&1
docker exec hermes-agent sh -c "if [ -d '/opt/data' ] && [ ! -d '/root/.hermes' ]; then ln -s /opt/data /root/.hermes 2>/dev/null; fi" >nul 2>&1

echo [V] hc.sh dan ht.sh berhasil di-inject ke dalam container hermes-agent.

REM ------------------------------------------------------------------------------
REM 5. Ringkasan & Panduan Langkah Selanjutnya
REM ------------------------------------------------------------------------------
echo.
echo ================================================================
echo  Setup Selesai! Layanan AI Berjalan di Laptop Anda!
echo ================================================================
echo.
echo Dashboard yang Dapat Diakses di Browser Laptop Anda:
echo   1. 9Router Web Dashboard :
echo      URL      : http://localhost:20128
echo      Password : 123456
echo.
echo   2. Hermes Web Dashboard  :
echo      URL      : http://localhost:9119
echo      Login    : Username: admin ^| Password: 123456
echo.
echo ----------------------------------------------------------------
echo Langkah Selanjutnya:
echo   Step 1: Buka 9Router (http://localhost:20128), masukkan Gemini API Key,
echo           buat combo 'gdg-yogya', lalu salin API Key 9Router Anda.
echo.
echo   Step 2: Hubungkan Hermes ke 9Router dengan perintah:
echo           docker exec -it hermes-agent ./hc.sh gdg-yogya ^<api-key-9router^>
echo.
echo   Step 3: Hubungkan ke Telegram Bot dengan perintah:
echo           docker exec -it hermes-agent ./ht.sh ^<token-telegram^>
echo ================================================================
echo.
pause

