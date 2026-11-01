#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# diagnose.sh - Diagnostic & Troubleshooting Script untuk Real Device (Termux)
# ==============================================================================

DIAGNOSE_SH_VERSION="v1.0.0"

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

# 8. Tes Jalankan Hermes Dashboard Foreground (5 Detik)
echo -e "\n--- [8] Test Direct: Launching hermes dashboard (5s trial) ---"
TMPDIR="${TMPDIR:-$PREFIX/tmp}"
mkdir -p "$TMPDIR"
TEST_LOG="$TMPDIR/test_dashboard.log"
TEST_LOG2="$TMPDIR/test_9119.log"

if command -v hermes >/dev/null 2>&1; then
    echo "Mencoba start: hermes dashboard --host 127.0.0.1 --port 9118 --no-open ..."
    # Jalankan di background sementara selama 5 detik untuk menangkap outputnya
    hermes dashboard --host 127.0.0.1 --port 9118 --no-open > "$TEST_LOG" 2>&1 &
    TEST_PID=$!
    sleep 3
    if kill -0 $TEST_PID 2>/dev/null; then
        echo "✓ hermes dashboard BERHASIL HIDUP (PID: $TEST_PID)!"
        echo "Cek koneksi lokal curl http://127.0.0.1:9118:"
        curl -sI "http://127.0.0.1:9118" 2>&1 | head -n 5 || true
        kill -9 $TEST_PID 2>/dev/null || true
    else
        echo "[!] hermes dashboard MATI SEKETIKA setelah dijalankan!"
        echo "Isi error output $TEST_LOG:"
        cat "$TEST_LOG"
    fi
fi

# 9. Tes Alternatif: hermes dashboard langsung di port 9119
echo -e "\n--- [9] Test Direct: Launching on port 9119 directly (3s trial) ---"
if command -v hermes >/dev/null 2>&1; then
    hermes dashboard --host 127.0.0.1 --port 9119 --no-open > "$TEST_LOG2" 2>&1 &
    TEST_PID2=$!
    sleep 2
    if kill -0 $TEST_PID2 2>/dev/null; then
        echo "✓ hermes dashboard BERHASIL HIDUP di 9119 (PID: $TEST_PID2)!"
        echo "Response curl http://127.0.0.1:9119:"
        curl -sI "http://127.0.0.1:9119" 2>&1 | head -n 5 || true
        kill -9 $TEST_PID2 2>/dev/null || true
    else
        echo "[!] hermes dashboard di port 9119 mati. Error output:"
        cat "$TEST_LOG2"
    fi
fi

echo -e "\n================================================================"
echo "          DIAGNOSTIC SELESAI                                    "
echo "Laporan tersimpan di: $REPORT_FILE"
echo "Silakan copy isi teks di atas atau kirimkan foto hasilnya!"
echo "================================================================"

