#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# diagnose.sh - Diagnostic & Troubleshooting Script untuk Real Device (Termux)
# ==============================================================================

DIAGNOSE_SH_VERSION="v2.0.0"

REPORT_FILE="$HOME/diag_report.txt"
exec > >(tee "$REPORT_FILE") 2>&1

echo "================================================================"
echo "    DIAGNOSTIC REPORT - HERMES POCKET LAB (${DIAGNOSE_SH_VERSION})     "
echo "    Waktu: $(date)                                              "
echo "================================================================"

# 1. Environment & System
echo -e "\n--- [1] Environment & System ---"
echo "PREFIX : $PREFIX"
echo "HOME   : $HOME"
echo "PATH   : $PATH"
echo "ARCH   : $(uname -m 2>/dev/null || true)"
echo "OS     : $(uname -a 2>/dev/null || true)"
echo "Node   : $(node -v 2>/dev/null || echo 'Not installed')"
echo "NPM    : $(npm -v 2>/dev/null || echo 'Not installed')"
echo "Python : $(python3 --version 2>/dev/null || echo 'Not installed')"
echo "Socat  : $(command -v socat 2>/dev/null || echo 'Not installed')"

# 2. CLI & Binary Inspection
echo -e "\n--- [2] CLI & Binary Inspection ---"
HERMES_PATH=$(command -v hermes || true)
if [ -n "$HERMES_PATH" ]; then
    echo "✓ hermes found at: $HERMES_PATH"
    ls -la "$HERMES_PATH" 2>/dev/null || true
else
    echo "[!] Perintah 'hermes' TIDAK DITEMUKAN di PATH!"
fi

ROUTER_PATH=$(command -v 9router || true)
if [ -n "$ROUTER_PATH" ]; then
    echo "✓ 9router found at: $ROUTER_PATH"
    ls -la "$ROUTER_PATH" 2>/dev/null || true
else
    echo "[!] Perintah '9router' TIDAK DITEMUKAN di PATH (cek \$PREFIX/lib/node_modules/9router)"
fi

# 3. Status Proses yang Sedang Berjalan
echo -e "\n--- [3] Active Processes ---"
echo "Pemeriksaan proses hermes, socat, 9router, node:"
ps -ef 2>/dev/null | grep -E "hermes|socat|9router|node|next-server" | grep -v grep || \
ps aux 2>/dev/null | grep -E "hermes|socat|9router|node|next-server" | grep -v grep || \
echo "Gagal mengambil daftar proses ps"

# 4. Port yang Sedang Listening
echo -e "\n--- [4] Listening Ports ---"
if command -v netstat >/dev/null 2>&1; then
    netstat -tlpn 2>/dev/null | grep -E "20128|9118|9119|8642|Proto" || netstat -tlpn 2>/dev/null || true
elif [ -f /proc/net/tcp ]; then
    echo "Isi /proc/net/tcp (port 20128=4E90, 9118=239E, 9119=239F, 8642=21C2):"
    grep -E ":(4E90|239E|239F|21C2)" /proc/net/tcp 2>/dev/null || echo "Tidak ada port terkait di /proc/net/tcp"
fi

# 5. HTTP Connectivity Checks (Targeted Health Check)
echo -e "\n--- [5] HTTP Connectivity Checks ---"
echo -n "Test 9Router (http://127.0.0.1:20128): "
RES_9R=$(curl -sI --max-time 3 "http://127.0.0.1:20128" 2>&1 | head -n 1 || true)
if echo "$RES_9R" | grep -q "HTTP"; then
    echo "OK ($RES_9R)"
else
    echo "FAILED ($RES_9R)"
fi

echo -n "Test Hermes Internal (http://127.0.0.1:9118): "
RES_9118=$(curl -sI --max-time 3 "http://127.0.0.1:9118" 2>&1 | head -n 1 || true)
if echo "$RES_9118" | grep -q "HTTP"; then
    echo "OK ($RES_9118)"
else
    echo "FAILED ($RES_9118)"
fi

echo -n "Test Hermes Relay (http://127.0.0.1:9119): "
RES_9119=$(curl -sI --max-time 3 "http://127.0.0.1:9119" 2>&1 | head -n 1 || true)
if echo "$RES_9119" | grep -q "HTTP"; then
    echo "OK ($RES_9119)"
else
    echo "FAILED ($RES_9119)"
fi

# 6. Detail Diagnosis: 9Router (:20128)
echo -e "\n--- [6] 9Router Diagnostic ---"
if echo "$RES_9R" | grep -q "HTTP"; then
    echo "✓ 9Router merespon normal. Tidak ada masalah koneksi terdeteksi."
else
    echo "[!] 9Router tidak merespon pada port 20128."
    echo "Cek isi file log ~/.9router/logs/9router.log (20 baris terakhir):"
    if [ -f "$HOME/.9router/logs/9router.log" ]; then
        tail -n 20 "$HOME/.9router/logs/9router.log"
    else
        echo "[!] File ~/.9router/logs/9router.log tidak ditemukan!"
    fi
    echo "Mencoba tes eksekusi 9router:"
    9router --version 2>&1 || true
fi

# 7. Detail Diagnosis: Hermes Dashboard (:9118 & :9119)
echo -e "\n--- [7] Hermes Dashboard Diagnostic ---"
if echo "$RES_9119" | grep -q "HTTP"; then
    echo "✓ Hermes Dashboard (port 9119) merespon normal. Tidak ada error koneksi."
else
    echo "[!] Hermes Dashboard tidak dapat diakses pada port 9119."
    
    # Periksa socat relay
    if ! pgrep -f "socat.*9119" >/dev/null 2>&1; then
        echo "[!] Process socat untuk port 9119 TIDAK BERJALAN!"
    else
        echo "✓ Process socat relay 9119 aktif."
    fi

    # Periksa port internal 9118
    if echo "$RES_9118" | grep -q "HTTP"; then
        echo "✓ Hermes internal :9118 aktif, masalah kemungkinan ada pada relay socat."
    else
        echo "[!] Hermes internal :9118 TIDAK MERESPON. Hermes Dashboard belum siap atau mati."
    fi

    echo -e "\nCek isi file log ~/.hermes/logs/dashboard.log (25 baris terakhir):"
    if [ -f "$HOME/.hermes/logs/dashboard.log" ]; then
        tail -n 25 "$HOME/.hermes/logs/dashboard.log"
    else
        echo "[!] File ~/.hermes/logs/dashboard.log tidak ditemukan!"
    fi

    # Inspeksi web_dist
    HERMES_LIB="${PREFIX:-/data/data/com.termux/files/usr}/lib/hermes-agent"
    WEB_DIST="$HERMES_LIB/app/hermes_cli/web_dist"
    echo -e "\nStatus folder web_dist ($WEB_DIST):"
    if [ -d "$WEB_DIST" ]; then
        echo "✓ Folder web_dist DITEMUKAN ($(ls -1 "$WEB_DIST" 2>/dev/null | wc -l) item)."
    else
        echo "[!] Folder web_dist TIDAK DITEMUKAN (Hermes kemungkinan sedang atau gagal kompilasi UI)."
    fi

    # Cek kredensial .env
    if [ -f "$HOME/.hermes/.env" ]; then
        echo "✓ File ~/.hermes/.env ditemukan. Memeriksa auth vars:"
        grep -E "HERMES_DASHBOARD_BASIC_AUTH" "$HOME/.hermes/.env" | sed 's/PASSWORD=.*/PASSWORD=******/' || echo "[!] Variabel auth dashboard tidak lengkap!"
    else
        echo "[!] File ~/.hermes/.env TIDAK DITEMUKAN!"
    fi

    # Direct trial jika hermes dashboard mati
    if ! pgrep -f "hermes.*dashboard" >/dev/null 2>&1 && command -v hermes >/dev/null 2>&1; then
        echo -e "\nMencoba uji coba eksekusi langsung 'hermes dashboard' selama 5 detik untuk menangkap error crash..."
        TMPDIR="${TMPDIR:-$PREFIX/tmp}"
        mkdir -p "$TMPDIR"
        TEST_LOG="$TMPDIR/hermes_dash_test.log"
        rm -f "$TEST_LOG"
        hermes dashboard --host 127.0.0.1 --port 9118 --no-open > "$TEST_LOG" 2>&1 &
        TEST_PID=$!
        sleep 5
        if kill -0 $TEST_PID 2>/dev/null; then
            echo "✓ hermes dashboard berhasil berjalan saat diuji coba langsung."
            kill -9 $TEST_PID 2>/dev/null || true
        else
            echo "[!] hermes dashboard langsung CRASH saat dijalankan. Output log:"
            cat "$TEST_LOG"
        fi
    fi
fi

# 8. Detail Diagnosis: Hermes Gateway
echo -e "\n--- [8] Hermes Gateway Diagnostic ---"
if pgrep -f "hermes.*gateway" >/dev/null 2>&1; then
    echo "✓ Hermes Gateway aktif."
else
    echo "[!] Hermes Gateway tidak berjalan."
fi
if [ -f "$HOME/.hermes/logs/gateway.log" ]; then
    echo "Isi log ~/.hermes/logs/gateway.log (10 baris terakhir):"
    tail -n 10 "$HOME/.hermes/logs/gateway.log"
fi

echo -e "\n================================================================"
echo "          DIAGNOSTIC SELESAI                                    "
echo "Laporan tersimpan di: $REPORT_FILE"
echo "================================================================"
