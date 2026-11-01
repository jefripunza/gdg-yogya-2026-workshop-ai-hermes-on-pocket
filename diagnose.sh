#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# diagnose.sh - Diagnostic & Troubleshooting Script untuk Real Device (Termux)
# ==============================================================================

DIAGNOSE_SH_VERSION="v1.3.0"

REPORT_FILE="$HOME/diag_report.txt"
exec > >(tee "$REPORT_FILE") 2>&1

echo "================================================================"
echo "    DIAGNOSTIC REPORT - HERMES POCKET LAB (${DIAGNOSE_SH_VERSION})     "
echo "    Waktu: $(date)                                              "
echo "================================================================"

# 1. Environment & Path
echo -e "\n--- [1] Environment & System ---"
echo "PREFIX: $PREFIX"
echo "HOME  : $HOME"
echo "PATH  : $PATH"
echo "ARCH  : $(uname -m 2>/dev/null || true)"
echo "OS    : $(uname -a 2>/dev/null || true)"
echo "Node  : $(node -v 2>/dev/null || echo 'Not installed')"
echo "Python: $(python3 --version 2>/dev/null || echo 'Not installed')"

# 2. Lokasi & Binary Hermes
echo -e "\n--- [2] Hermes CLI Inspection ---"
HERMES_PATH=$(command -v hermes || true)
if [ -n "$HERMES_PATH" ]; then
    echo "hermes found at: $HERMES_PATH"
    ls -la "$HERMES_PATH" 2>/dev/null || true
    echo "File type: $(file "$HERMES_PATH" 2>/dev/null || true)"
    echo "Head of hermes:"
    head -n 10 "$HERMES_PATH" 2>/dev/null || true
else
    echo "[!] Perintah 'hermes' TIDAK DITEMUKAN di PATH!"
fi

# 3. Status Proses yang Sedang Berjalan
echo -e "\n--- [3] Active Processes ---"
echo "Pemeriksaan proses hermes, socat, 9router:"
ps -ef 2>/dev/null | grep -E "hermes|socat|9router|node" | grep -v grep || \
ps aux 2>/dev/null | grep -E "hermes|socat|9router|node" | grep -v grep || \
echo "Gagal mengambil daftar proses ps"

# 4. Port yang Sedang Listening
echo -e "\n--- [4] Listening Ports ---"
if command -v netstat >/dev/null 2>&1; then
    netstat -tlpn 2>/dev/null | grep -E "20128|9118|9119|8642|Proto" || netstat -tlpn 2>/dev/null || true
elif [ -f /proc/net/tcp ]; then
    echo "Isi /proc/net/tcp (port 20128/9118/9119):"
    grep -E ":(4E90|239E|239F)" /proc/net/tcp 2>/dev/null || echo "Tidak ada port 20128/9118/9119 yang aktif di /proc/net/tcp"
fi

# 5. Isi Log Hermes Dashboard
echo -e "\n--- [5] Hermes Dashboard Log (~/.hermes/logs/dashboard.log) ---"
if [ -f "$HOME/.hermes/logs/dashboard.log" ]; then
    cat "$HOME/.hermes/logs/dashboard.log"
else
    echo "[!] File ~/.hermes/logs/dashboard.log tidak ditemukan!"
fi

# 6. Isi Log Hermes Gateway
echo -e "\n--- [6] Hermes Gateway Log (Last 15 lines) ---"
if [ -f "$HOME/.hermes/logs/gateway.log" ]; then
    tail -n 15 "$HOME/.hermes/logs/gateway.log"
else
    echo "[!] File ~/.hermes/logs/gateway.log tidak ditemukan!"
fi

# 7. Tes Langsung Eksekusi 'hermes dashboard --help'
echo -e "\n--- [7] Test Direct: hermes dashboard --help ---"
if command -v hermes >/dev/null 2>&1; then
    hermes dashboard --help 2>&1 || true
else
    echo "[!] 'hermes' tidak dapat dijalankan."
fi

# 8. Inspeksi Struktur File Hermes Web & Script Build (node-deps.mjs & web.mjs)
echo -e "\n--- [8] Hermes Web & Build Files Inspection ---"
HERMES_LIB="${PREFIX:-/data/data/com.termux/files/usr}/lib/hermes-agent"
NODE_DEPS="$HERMES_LIB/app/scripts/build/node-deps.mjs"
WEB_MJS="$HERMES_LIB/app/scripts/build/web.mjs"
WEB_DIST="$HERMES_LIB/app/hermes_cli/web_dist"

if [ -f "$WEB_MJS" ]; then
    echo "Ditemukan web.mjs di: $WEB_MJS"
    cat "$WEB_MJS" 2>/dev/null || true
else
    echo "[!] $WEB_MJS tidak ditemukan."
fi

echo -e "\nStatus folder web_dist ($WEB_DIST):"
if [ -d "$WEB_DIST" ]; then
    echo "✓ Folder web_dist DITEMUKAN!"
    ls -la "$WEB_DIST" 2>/dev/null || true
else
    echo "[!] Folder web_dist TIDAK DITEMUKAN."
fi

echo -e "\nCek sisa proses kompilasi / web yang masih aktif:"
ps -ef 2>/dev/null | grep -E "node|web|tsc|vite|esbuild|hermes" | grep -v grep || true

# 9. Tes hermes dashboard DENGAN --skip-build (Mode Tanpa Kompilasi Ulang)
echo -e "\n--- [9] Test Direct: Launching hermes dashboard WITH --skip-build (6s trial) ---"
TMPDIR="${TMPDIR:-$PREFIX/tmp}"
mkdir -p "$TMPDIR"
TEST_LOG_SKIP="$TMPDIR/test_skip_build.log"
rm -f "$TEST_LOG_SKIP"

if command -v hermes >/dev/null 2>&1; then
    echo "Mencoba start: hermes dashboard --host 127.0.0.1 --port 9118 --no-open --skip-build ..."
    hermes dashboard --host 127.0.0.1 --port 9118 --no-open --skip-build > "$TEST_LOG_SKIP" 2>&1 &
    TEST_PID_SKIP=$!
    sleep 6
    if kill -0 $TEST_PID_SKIP 2>/dev/null; then
        echo "✓ hermes dashboard WITH --skip-build MASIH HIDUP (PID: $TEST_PID_SKIP)!"
        echo "Cek Port Listening saat ini:"
        netstat -tlpn 2>/dev/null | grep -E "9118|9119" || true
        echo "Response curl http://127.0.0.1:9118:"
        curl -sI "http://127.0.0.1:9118" 2>&1 | head -n 10 || true
        echo "Response curl http://127.0.0.1:9119:"
        curl -sI "http://127.0.0.1:9119" 2>&1 | head -n 10 || true
        kill -9 $TEST_PID_SKIP 2>/dev/null || true
    else
        echo "[!] hermes dashboard --skip-build mati setelah 6 detik."
    fi
    echo "Isi Log hermes dashboard --skip-build:"
    cat "$TEST_LOG_SKIP" 2>/dev/null || true
fi

# 10. Tes hermes dashboard STANDAR (Tanpa --skip-build)
echo -e "\n--- [10] Test Direct: Launching standard hermes dashboard (6s trial) ---"
TEST_LOG="$TMPDIR/test_dashboard.log"
rm -f "$TEST_LOG"
if command -v hermes >/dev/null 2>&1; then
    echo "Mencoba start: hermes dashboard --host 127.0.0.1 --port 9118 --no-open ..."
    hermes dashboard --host 127.0.0.1 --port 9118 --no-open > "$TEST_LOG" 2>&1 &
    TEST_PID=$!
    sleep 6
    if kill -0 $TEST_PID 2>/dev/null; then
        echo "✓ hermes dashboard standar MASIH HIDUP (PID: $TEST_PID)!"
        echo "Cek Port Listening:"
        netstat -tlpn 2>/dev/null | grep -E "9118|9119" || true
        echo "Response curl http://127.0.0.1:9118:"
        curl -sI "http://127.0.0.1:9118" 2>&1 | head -n 10 || true
        kill -9 $TEST_PID 2>/dev/null || true
    else
        echo "[!] hermes dashboard standar mati setelah 6 detik."
    fi
    echo "Isi Log hermes dashboard standar:"
    cat "$TEST_LOG" 2>/dev/null || true
fi

echo -e "\n================================================================"
echo "          DIAGNOSTIC SELESAI                                    "
echo "Laporan tersimpan di: $REPORT_FILE"
echo "Silakan copy isi teks di atas atau kirimkan foto hasilnya!"
echo "================================================================"

