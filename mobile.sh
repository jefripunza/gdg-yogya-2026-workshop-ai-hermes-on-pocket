#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================================
# mobile.sh - One-Click Installer Hermes Agent & 9Router di Termux
# - Hermes Agent: https://github.com/nousresearch/hermes-agent
# - 9Router: https://github.com/ AgusNarestha / npm: 9router
# ==============================================================================

set -e
umask 022

# Parsing Argumen
IS_LOCAL=false
for arg in "$@"; do
    case "$arg" in
        -l|--local)
            IS_LOCAL=true
            ;;
    esac
done

# Versi Script (Selalu naikkan versi ini setiap kali ada perubahan di mobile.sh
# agar saat dijalankan via curl terlihat jelas apakah sudah versi terbaru atau masih cache)
MOBILE_SH_VERSION="v2.9.0"

# Warna output terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================================================${NC}"
echo -e "${GREEN}   Hermes Agent & 9Router Auto-Installer for Termux (${MOBILE_SH_VERSION})  ${NC}"
echo -e "${BLUE}================================================================${NC}"

# Validasi environment Termux PREFIX & HOME
if [ -z "$PREFIX" ]; then
    export PREFIX="/data/data/com.termux/files/usr"
fi
if [ -z "$HOME" ]; then
    export HOME="/data/data/com.termux/files/home"
fi

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:$PREFIX/bin:$PATH"

# Aktifkan wakelock agar Termux tidak tertidur/dihentikan Android saat layar mati
if command -v termux-wake-lock >/dev/null 2>&1; then
    termux-wake-lock 2>/dev/null || true
    echo -e "${GREEN}✓ Termux Wake-Lock aktif (mencegah sleep di background).${NC}"
fi

# ------------------------------------------------------------------------------
# 1. Konfigurasi Repo Cepat (Cloudflare Mirror) & Dependensi Dasar
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[1/6] [${MOBILE_SH_VERSION}] Mengatur repositori Termux ke Cloudflare Mirror (packages-cf.termux.dev)...${NC}"
export DEBIAN_FRONTEND=noninteractive
export TERMUX_APP_PACKAGE_MANAGER=apt
chmod 755 "$PREFIX/bin/bash" "$PREFIX/bin/sh" "$PREFIX/bin/termux-setup-package-manager" 2>/dev/null || true
chmod +x "$PREFIX/bin"/* 2>/dev/null || true

# Bersihkan total seluruh file di sources.list.d (seperti game.list, science.list, main.sources, dll.)
mkdir -p "$PREFIX/etc/apt/sources.list.d" "$PREFIX/etc/apt/apt.conf.d" "$PREFIX/etc/apt/trusted.gpg.d" "$PREFIX/share/keyrings"
rm -rf "$PREFIX/etc/apt/sources.list.d/"* 2>/dev/null || true

# Bersihkan seluruh mirror lama (termasuk termux.net) agar tidak pernah fallback ke termux.net
rm -rf "$PREFIX/etc/termux/mirrors" "$PREFIX/etc/termux/chosen_mirrors"
mkdir -p "$PREFIX/etc/termux/mirrors/default"
cat << 'EOF' > "$PREFIX/etc/termux/mirrors/default/packages-cf.termux.dev"
# This file is sourced by pkg
WEIGHT=10
MAIN="https://packages-cf.termux.dev/apt/termux-main"
ROOT="https://packages-cf.termux.dev/apt/termux-root"
X11="https://packages-cf.termux.dev/apt/termux-x11"
EOF
ln -sf "$PREFIX/etc/termux/mirrors/default/packages-cf.termux.dev" "$PREFIX/etc/termux/chosen_mirrors"

# Unduh langsung GPG Public Key resmi Termux (5A897D96E57CF20C - termux-autobuilds.gpg)
# agar verifikasi signature packages-cf.termux.dev tidak gagal NO_PUBKEY 5A897D96E57CF20C
echo -e "${BLUE}Mengunduh GPG Key resmi Termux (5A897D96E57CF20C)...${NC}"
if command -v wget >/dev/null 2>&1; then
    wget -qO "$PREFIX/etc/apt/trusted.gpg.d/termux-autobuilds.gpg" \
        "https://raw.githubusercontent.com/termux/termux-packages/master/packages/termux-keyring/termux-autobuilds.gpg" 2>/dev/null || true
else
    curl -fsSL "https://raw.githubusercontent.com/termux/termux-packages/master/packages/termux-keyring/termux-autobuilds.gpg" \
        -o "$PREFIX/etc/apt/trusted.gpg.d/termux-autobuilds.gpg" 2>/dev/null || true
fi
cp -f "$PREFIX/etc/apt/trusted.gpg.d/termux-autobuilds.gpg" "$PREFIX/share/keyrings/termux-autobuilds.gpg" 2>/dev/null || true

# Gunakan [trusted=yes] & AllowInsecureRepositories sebagai pengaman ganda
echo "deb [trusted=yes] https://packages-cf.termux.dev/apt/termux-main stable main" > "$PREFIX/etc/apt/sources.list"
cat << 'EOF' > "$PREFIX/etc/apt/apt.conf.d/99-termux-cloudflare"
Acquire::AllowInsecureRepositories "true";
Acquire::AllowDowngradeToInsecureRepositories "true";
APT::Get::AllowUnauthenticated "true";
APT::Ignore-Hold "true";
Dpkg::Options {
   "--force-confdef";
   "--force-confold";
   "--force-overwrite";
};
DPkg::Pre-Invoke {
   "chmod 755 /data/data/com.termux/files/usr/bin/bash /data/data/com.termux/files/usr/bin/sh /data/data/com.termux/files/usr/bin/termux-setup-package-manager 2>/dev/null || true";
};
DPkg::Post-Invoke {
   "chmod 755 /data/data/com.termux/files/usr/bin/bash /data/data/com.termux/files/usr/bin/sh /data/data/com.termux/files/usr/bin/termux-setup-package-manager /data/data/com.termux/files/usr/bin/* 2>/dev/null || true";
};
EOF
echo -e "${GREEN}✓ [${MOBILE_SH_VERSION}] Repo Termux dikunci ke: $(cat "$PREFIX/etc/apt/sources.list")${NC}"

# Auto-recovery dpkg jika ada sesi instalasi sebelumnya yang terhenti atau terjadi konflik file
# (misal: konflik libandroid-glob vs ndk-sysroot pada /usr/include/glob.h)
echo -e "${BLUE}Memeriksa dan memulihkan status dependensi dpkg...${NC}"
dpkg --configure -a --force-confdef --force-confold --force-overwrite 2>/dev/null || true
for adir in "/data/data/com.termux/cache/apt/archives" "$PREFIX/var/cache/apt/archives"; do
    if [ -d "$adir" ]; then
        if ls "$adir"/libandroid-glob*.deb >/dev/null 2>&1; then
            dpkg -i --force-overwrite --force-confdef --force-confold "$adir"/libandroid-glob*.deb 2>/dev/null || true
        fi
    fi
done
dpkg --configure -a --force-confdef --force-confold --force-overwrite 2>/dev/null || true

echo -e "\n${BLUE}[${MOBILE_SH_VERSION}] Memperbarui seluruh library sistem (dist-upgrade) agar curl & node sinkron...${NC}"
# Gunakan apt-get secara langsung (bukan wrapper pkg) agar sources.list tidak ditimpa balik ke termux.net
apt-get update -y \
    -o Acquire::AllowInsecureRepositories=true \
    -o Acquire::AllowDowngradeToInsecureRepositories=true \
    -o APT::Get::AllowUnauthenticated=true

# Perbaiki broken packages jika ada paket setengah terpasang
apt-get -f install -y --allow-unauthenticated \
    -o Acquire::AllowInsecureRepositories=true \
    -o APT::Get::AllowUnauthenticated=true \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    -o Dpkg::Options::="--force-overwrite" 2>/dev/null || true

apt-get install -y --allow-unauthenticated \
    -o Acquire::AllowInsecureRepositories=true \
    -o APT::Get::AllowUnauthenticated=true \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    -o Dpkg::Options::="--force-overwrite" \
    termux-keyring || true

# Kunci kembali sources.list ke Cloudflare Mirror setelah termux-keyring diperbarui
echo "deb [trusted=yes] https://packages-cf.termux.dev/apt/termux-main stable main" > "$PREFIX/etc/apt/sources.list"
rm -rf "$PREFIX/etc/apt/sources.list.d/"* 2>/dev/null || true

apt-get update -y \
    -o Acquire::AllowInsecureRepositories=true \
    -o APT::Get::AllowUnauthenticated=true

# WAJIB dist-upgrade agar libc++, libngtcp2, openssl, libcurl, dan bash ter-upgrade serentak
# (Mencegah error CANNOT LINK EXECUTABLE pada curl: ngtcp2_crypto_ossl_free & node: __hash_memory)
apt-get dist-upgrade -y --allow-unauthenticated \
    -o Acquire::AllowInsecureRepositories=true \
    -o APT::Get::AllowUnauthenticated=true \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    -o Dpkg::Options::="--force-overwrite"

# Pastikan kembali sources.list tetap di Cloudflare Mirror pasca dist-upgrade
echo "deb [trusted=yes] https://packages-cf.termux.dev/apt/termux-main stable main" > "$PREFIX/etc/apt/sources.list"
chmod 755 "$PREFIX/bin/bash" "$PREFIX/bin/sh" "$PREFIX/bin/termux-setup-package-manager" 2>/dev/null || true
chmod +x "$PREFIX/bin"/* 2>/dev/null || true

apt-get install -y --allow-unauthenticated \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" \
    -o Dpkg::Options::="--force-overwrite" \
    libc++ \
    libngtcp2 \
    libnghttp2 \
    libnghttp3 \
    openssl \
    libssh2 \
    libcurl \
    curl \
    wget \
    git \
    python \
    nano \
    tar \
    unzip \
    jq \
    openssh \
    build-essential \
    clang \
    make \
    procps \
    net-tools \
    socat \
    gnupg \
    pkg-config \
    libheif \
    && apt-get clean

# ------------------------------------------------------------------------------
# 2. Instalasi Hermes Agent (Nous Research)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[2/6] Menyiapkan dan menginstal Hermes Agent...${NC}"
mkdir -p "$PREFIX/etc/apt/keyrings"
KEY_FILE="$PREFIX/etc/apt/keyrings/hermes-agent.asc"
SOURCES_FILE="$PREFIX/etc/apt/sources.list.d/hermes-agent.list"

CANARY_KEY_URL="https://hermes-assets.nousresearch.com/releases/termux/canary/key.asc"
STABLE_KEY_URL="https://hermes-assets.nousresearch.com/releases/termux/stable/key.asc"

DOWNLOADED=false
CHANNEL=""
APT_SUCCESS=false

# Cek channel canary terlebih dahulu
if curl -fsSL "$CANARY_KEY_URL" -o "$KEY_FILE" 2>/dev/null; then
    DOWNLOADED=true
    CHANNEL="canary"
    REPO_URL="https://hermes-assets.nousresearch.com/releases/termux/canary"
    SUITE="hermes-canary"
    echo -e "${GREEN}✓ Menggunakan channel canary Nous Research${NC}"
elif curl -fsSL "$STABLE_KEY_URL" -o "$KEY_FILE" 2>/dev/null; then
    DOWNLOADED=true
    CHANNEL="stable"
    REPO_URL="https://hermes-assets.nousresearch.com/releases/termux/stable"
    SUITE="hermes-stable"
    echo -e "${GREEN}✓ Menggunakan channel stable Nous Research${NC}"
fi

if [ "$DOWNLOADED" = true ]; then
    mkdir -p "$PREFIX/etc/apt/sources.list.d"
    printf '%s\n' \
      "deb [signed-by=$KEY_FILE] $REPO_URL $SUITE main" \
      > "$SOURCES_FILE"
    
    if apt-get update -y -o Acquire::AllowInsecureRepositories=true -o APT::Get::AllowUnauthenticated=true 2>/dev/null; then
        if apt-get install -y --allow-unauthenticated \
            -o Dpkg::Options::="--force-confdef" \
            -o Dpkg::Options::="--force-confold" \
            -o Dpkg::Options::="--force-overwrite" hermes-agent; then
            APT_SUCCESS=true
            echo -e "${GREEN}✓ hermes-agent berhasil diinstal via APT (${CHANNEL})!${NC}"
        fi
    fi
fi

# Fallback ke official installer script jika APT repo tidak tersedia
if [ "$APT_SUCCESS" = false ]; then
    echo -e "${YELLOW}[INFO] Menggunakan Official Installer script Hermes Agent...${NC}"
    rm -f "$SOURCES_FILE"
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
fi

# Pastikan dependensi Telegram (python-telegram-bot) siap di venv Hermes
HERMES_VENV="$PREFIX/lib/hermes-agent/venv"
HERMES_UV="$PREFIX/lib/hermes-agent/tools/uv/data/data/com.termux/files/usr/bin/uv"
if [ -d "$HERMES_VENV" ]; then
    echo -e "${BLUE}Menyiapkan dependensi Telegram (python-telegram-bot)...${NC}"
    if [ -f "$HERMES_UV" ]; then
        VIRTUAL_ENV="$HERMES_VENV" "$HERMES_UV" pip install "python-telegram-bot[webhooks]==22.8" >/dev/null 2>&1 || true
    elif command -v uv >/dev/null 2>&1; then
        VIRTUAL_ENV="$HERMES_VENV" uv pip install "python-telegram-bot[webhooks]==22.8" >/dev/null 2>&1 || true
    fi
    echo -e "${GREEN}✓ Modul Telegram siap digunakan.${NC}"
fi

# Perbaiki shebang script internal Hermes (tools npm, node, scripts mjs)
# agar tidak memicu error Android linker64 (ELF executable too small)
HERMES_LIB="$PREFIX/lib/hermes-agent"
if [ -d "$HERMES_LIB" ] && command -v termux-fix-shebang >/dev/null 2>&1; then
    echo -e "${BLUE}Menyelaraskan shebang binary tools Hermes...${NC}"
    termux-fix-shebang "$HERMES_LIB/bin/"* "$HERMES_LIB/tools/npm/bin/"* 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# Universal Fix untuk Node.js di Android 15 (Bionic Linker & esbuild hook)
# Disiapkan lebih awal agar npm & child_process langsung terlindungi saat instalasi
# ------------------------------------------------------------------------------
PREFIX_PATH="${PREFIX:-/data/data/com.termux/files/usr}"
FIX_FILE="$PREFIX_PATH/lib/node_android_fix.cjs"
mkdir -p "$PREFIX_PATH/lib"

cat << 'EOF' > "$FIX_FILE"
const nodeBin = process.env.PREFIX ? (process.env.PREFIX + '/bin/node') : '/data/data/com.termux/files/usr/bin/node';

// 1. Override process.execPath agar tidak menunjuk ke linker64 di Android 15
if (process.execPath && process.execPath.includes('linker')) {
  try {
    Object.defineProperty(process, 'execPath', {
      value: nodeBin,
      writable: false,
      configurable: true,
      enumerable: true
    });
  } catch (e) {}
}

// 2. Intercept child_process (execFileSync, spawnSync, spawn)
try {
  const cp = require('node:child_process');

  const patchCall = (file, args) => {
    if (typeof file === 'string') {
      if (file.includes('linker')) {
        return [nodeBin, args];
      }
      if (file.includes('esbuild/bin/esbuild') || file.endsWith('npm-cli.js')) {
        return [nodeBin, [file, ...(args || [])]];
      }
    }
    return [file, args];
  };

  const origExecFileSync = cp.execFileSync;
  cp.execFileSync = function (file, args, ...rest) {
    const [pfile, pargs] = patchCall(file, args);
    return origExecFileSync.call(this, pfile, pargs, ...rest);
  };

  const origSpawnSync = cp.spawnSync;
  cp.spawnSync = function (file, args, ...rest) {
    const [pfile, pargs] = patchCall(file, args);
    return origSpawnSync.call(this, pfile, pargs, ...rest);
  };

  const origSpawn = cp.spawn;
  cp.spawn = function (file, args, ...rest) {
    const [pfile, pargs] = patchCall(file, args);
    return origSpawn.call(this, pfile, pargs, ...rest);
  };
} catch (e) {}
EOF

export NODE_OPTIONS="--require $FIX_FILE"
unset ESBUILD_BINARY_PATH 2>/dev/null || true

# Patch node-deps.mjs: Menyelaraskan resolusi Node agar tidak merujuk ke linker64 di Android 15
NODE_DEPS="$HERMES_LIB/app/scripts/build/node-deps.mjs"
if [ -f "$NODE_DEPS" ] && command -v node >/dev/null 2>&1; then
    node -e "
    const fs = require('fs');
    const file = process.argv[1];
    if (fs.existsSync(file)) {
      let content = fs.readFileSync(file, 'utf8');
      if (content.includes('return [process.execPath, cli]')) {
        const replacement = 'const nodeExec = (process.execPath && !process.execPath.includes(\"linker\")) ? process.execPath : (process.env.PREFIX ? process.env.PREFIX + \"/bin/node\" : \"/data/data/com.termux/files/usr/bin/node\"); return [nodeExec, cli]';
        content = content.replace('return [process.execPath, cli]', replacement);
        fs.writeFileSync(file, content);
        console.log('✓ node-deps.mjs berhasil diselaraskan dengan Android Bionic Node');
      }
    }
    " "$NODE_DEPS" 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 3. Instalasi & Verifikasi Node.js serta NPM (Multi-Tier Resolution)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[3/6] Menginstal dan memverifikasi Node.js & npm...${NC}"

# Pastikan bash dan bin selalu executable sebelum menjalankan paket baru
chmod 755 "$PREFIX/bin/bash" "$PREFIX/bin/sh" 2>/dev/null || true
chmod +x "$PREFIX/bin"/* 2>/dev/null || true

# Coba instal nodejs standar jika binary node belum ada
if ! command -v node >/dev/null 2>&1; then
    apt-get install -y --allow-unauthenticated \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        -o Dpkg::Options::="--force-overwrite" nodejs || \
    apt-get install -y --allow-unauthenticated \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        -o Dpkg::Options::="--force-overwrite" nodejs-lts || true
fi

# [Lapisan 1] Restorasi direktori core $PREFIX/lib/node_modules/npm dari bundled Hermes
SYS_NPM_DIR="$PREFIX/lib/node_modules/npm"
HERMES_NPM_DIR="$HERMES_LIB/tools/npm/lib/node_modules/npm"
if [ ! -d "$SYS_NPM_DIR" ] && [ -d "$HERMES_NPM_DIR" ]; then
    echo -e "${YELLOW}[INFO] Memulihkan direktori core npm dari bundled Hermes ke \$PREFIX/lib/node_modules/npm...${NC}"
    mkdir -p "$PREFIX/lib/node_modules"
    cp -rf "$HERMES_NPM_DIR" "$SYS_NPM_DIR" 2>/dev/null || true
fi

# [Lapisan 2] Bulletproof NPM & NPX Launcher Wrapper (kebal dari kegagalan symlink relatif)
mkdir -p "$PREFIX/bin"
cat << 'EOF' > "$PREFIX/bin/npm"
#!/data/data/com.termux/files/usr/bin/sh
PREFIX_BIN="${PREFIX:-/data/data/com.termux/files/usr}/bin"
NODE_BIN="$PREFIX_BIN/node"
SYS_CLI="${PREFIX:-/data/data/com.termux/files/usr}/lib/node_modules/npm/bin/npm-cli.js"
HERMES_CLI="${PREFIX:-/data/data/com.termux/files/usr}/lib/hermes-agent/tools/npm/lib/node_modules/npm/bin/npm-cli.js"

if [ -f "$SYS_CLI" ]; then
    exec "$NODE_BIN" "$SYS_CLI" "$@"
elif [ -f "$HERMES_CLI" ]; then
    exec "$NODE_BIN" "$HERMES_CLI" "$@"
else
    echo "Error: npm-cli.js tidak ditemukan di Termux." >&2
    exit 1
fi
EOF
chmod 755 "$PREFIX/bin/npm"

cat << 'EOF' > "$PREFIX/bin/npx"
#!/data/data/com.termux/files/usr/bin/sh
PREFIX_BIN="${PREFIX:-/data/data/com.termux/files/usr}/bin"
NODE_BIN="$PREFIX_BIN/node"
SYS_NPX="${PREFIX:-/data/data/com.termux/files/usr}/lib/node_modules/npm/bin/npx-cli.js"
HERMES_NPX="${PREFIX:-/data/data/com.termux/files/usr}/lib/hermes-agent/tools/npm/lib/node_modules/npm/bin/npx-cli.js"

if [ -f "$SYS_NPX" ]; then
    exec "$NODE_BIN" "$SYS_NPX" "$@"
elif [ -f "$HERMES_NPX" ]; then
    exec "$NODE_BIN" "$HERMES_NPX" "$@"
else
    echo "Error: npx-cli.js tidak ditemukan di Termux." >&2
    exit 1
fi
EOF
chmod 755 "$PREFIX/bin/npx"

if command -v termux-fix-shebang >/dev/null 2>&1; then
    termux-fix-shebang "$PREFIX/bin/npm" "$PREFIX/bin/npx" 2>/dev/null || true
fi

# [Lapisan 3] Verifikasi eksekusi npm & Reinstall fallback jika perlu
NPM_VER=$(npm -v 2>/dev/null || true)
if [ -z "$NPM_VER" ]; then
    echo -e "${YELLOW}[INFO] npm belum merespon. Menjalankan reinstall nodejs via APT...${NC}"
    apt-get install -y --reinstall --allow-unauthenticated \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        -o Dpkg::Options::="--force-overwrite" nodejs || true
    NPM_VER=$(npm -v 2>/dev/null || echo "Tidak terdeteksi")
fi

NODE_VER=$(node -v 2>/dev/null || echo "Tidak terdeteksi")
echo -e "${GREEN}✓ Node.js terinstal: ${NODE_VER}${NC}"
echo -e "${GREEN}✓ npm terinstal    : v${NPM_VER#v}${NC}"

echo -e "\n${BLUE}[4/6] Menginstal 9Router via npm secara global...${NC}"
npm install -g 9router
if command -v termux-fix-shebang >/dev/null 2>&1; then
    termux-fix-shebang "$PREFIX/bin/9router" "$PREFIX/lib/node_modules/9router/cli.js" 2>/dev/null || true
fi
echo -e "${GREEN}✓ 9Router berhasil diinstal!${NC}"

# Inisialisasi kredensial dasar Hermes
HERMES_DIR="${HERMES_HOME:-$HOME/.hermes}"
mkdir -p "$HERMES_DIR" "$HERMES_DIR/logs"
if [ ! -f "$HERMES_DIR/.env" ]; then
    cat << 'EOF' > "$HERMES_DIR/.env"
HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=123456
EOF
elif ! grep -q "HERMES_DASHBOARD_BASIC_AUTH_USERNAME" "$HERMES_DIR/.env" 2>/dev/null; then
    cat << 'EOF' >> "$HERMES_DIR/.env"
HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=123456
EOF
fi

# ------------------------------------------------------------------------------
# 4. Menyiapkan Script Pembantu (hc.sh & ht.sh)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[5/6] Menyiapkan script konfigurasi (hc.sh & ht.sh)...${NC}"
REPO_RAW_URL="https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master"

if [ "$IS_LOCAL" = true ]; then
    echo -e "${YELLOW}Mode --local terdeteksi: Menggunakan file hc.sh & ht.sh lokal (skip unduhan GitHub).${NC}"
    if [ -f "./hc.sh" ] && [ "$(pwd)" != "$HOME" ]; then
        cp -f ./hc.sh "$HOME/hc.sh"
    fi
    if [ -f "./ht.sh" ] && [ "$(pwd)" != "$HOME" ]; then
        cp -f ./ht.sh "$HOME/ht.sh"
    fi
    chmod +x "$HOME/hc.sh" "$HOME/ht.sh" 2>/dev/null || true
    command -v termux-fix-shebang >/dev/null 2>&1 && termux-fix-shebang "$HOME/hc.sh" "$HOME/ht.sh" 2>/dev/null || true
    echo -e "${GREEN}✓ hc.sh dan ht.sh lokal siap digunakan di: ${HOME}/${NC}"
else
    echo "Mengunduh hc.sh dan ht.sh dari repository resmi..."
    curl -fsSL "${REPO_RAW_URL}/hc.sh" -o "$HOME/hc.sh"
    curl -fsSL "${REPO_RAW_URL}/ht.sh" -o "$HOME/ht.sh"
    chmod +x "$HOME/hc.sh" "$HOME/ht.sh"
    command -v termux-fix-shebang >/dev/null 2>&1 && termux-fix-shebang "$HOME/hc.sh" "$HOME/ht.sh" 2>/dev/null || true
    echo -e "${GREEN}✓ hc.sh dan ht.sh berhasil diunduh ke: ${HOME}/${NC}"
fi

# ------------------------------------------------------------------------------
# 5. Setup Auto-Run Script & Pencegah Duplicate Process
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[6/6] Mengonfigurasi auto-start untuk 9Router dan Hermes Dashboard/Gateway...${NC}"

mkdir -p "$HOME/.9router/logs"
mkdir -p "$HOME/.hermes/logs"
AUTOSTART_SCRIPT="$HOME/.autostart_services.sh"

cat << 'EOF' > "$AUTOSTART_SCRIPT"
#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================================
# .autostart_services.sh - Auto-run 9router & hermes services (tanpa dobel proses)
# ==============================================================================

export PATH="$HOME/.local/bin:$HOME/.hermes/bin:/data/data/com.termux/files/usr/bin:$PATH"
export INITIAL_PASSWORD="${INITIAL_PASSWORD:-123456}"

# Android 15 Node.js fix
if [ -f "$PREFIX/lib/node_android_fix.cjs" ]; then
    export NODE_OPTIONS="--require $PREFIX/lib/node_android_fix.cjs"
fi

# Pastikan wakelock aktif agar background services tidak tertidur
if command -v termux-wake-lock >/dev/null 2>&1; then
    termux-wake-lock 2>/dev/null || true
fi

mkdir -p "$HOME/.9router/logs"
mkdir -p "$HOME/.hermes/logs"

# 1. Pastikan 9router berjalan (bind 0.0.0.0 agar dapat diakses dari host/browser)
if pgrep -f "next-server|[9]router" >/dev/null 2>&1; then
    PID_9R=$(pgrep -f "next-server|[9]router" | head -n 1)
    echo "[✓] 9router sudah berjalan (PID: $PID_9R) -> http://localhost:20128"
else
    echo "[+] Menjalankan 9router di background (INITIAL_PASSWORD=123456)..."
    ROUTER_SERVER="$PREFIX/lib/node_modules/9router/app/server.js"
    ROUTER_CLI="$PREFIX/lib/node_modules/9router/cli.js"
    if [ -f "$ROUTER_SERVER" ]; then
        INITIAL_PASSWORD="123456" HOSTNAME="0.0.0.0" HOST="0.0.0.0" PORT="20128" nohup node "$ROUTER_SERVER" > "$HOME/.9router/logs/9router.log" 2>&1 &
    elif [ -f "$ROUTER_CLI" ]; then
        INITIAL_PASSWORD="123456" HOSTNAME="0.0.0.0" HOST="0.0.0.0" PORT="20128" nohup node "$ROUTER_CLI" --host 0.0.0.0 --port 20128 --no-browser --skip-update > "$HOME/.9router/logs/9router.log" 2>&1 &
    elif command -v 9router >/dev/null 2>&1; then
        INITIAL_PASSWORD="123456" HOSTNAME="0.0.0.0" HOST="0.0.0.0" PORT="20128" nohup 9router --host 0.0.0.0 --port 20128 --no-browser --skip-update > "$HOME/.9router/logs/9router.log" 2>&1 &
    fi
    sleep 2
    PID_9R=$(pgrep -f "next-server|[9]router" | head -n 1 || true)
    echo "[✓] 9router berhasil aktif (PID: $PID_9R) -> http://localhost:20128"
fi

# 2. Pastikan Hermes Web Dashboard berjalan (internal :9118 -> relay ke :9119)
if pgrep -f "hermes.*dashboard" >/dev/null 2>&1; then
    PID_HD=$(pgrep -f "hermes.*dashboard" | head -n 1)
    echo "[✓] Hermes Web Dashboard sudah berjalan (PID: $PID_HD) -> http://localhost:9119"
elif command -v hermes >/dev/null 2>&1; then
    echo "[+] Menjalankan Hermes Web Dashboard di background..."
    DASHBOARD_FLAGS="--host 127.0.0.1 --port 9118 --no-open"
    if [ -d "$PREFIX/lib/hermes-agent/app/hermes_cli/web_dist" ]; then
        DASHBOARD_FLAGS="$DASHBOARD_FLAGS --skip-build"
    fi
    nohup hermes dashboard $DASHBOARD_FLAGS > "$HOME/.hermes/logs/dashboard.log" 2>&1 &
    sleep 3
    PID_HD=$(pgrep -f "hermes.*dashboard" | head -n 1 || true)
    if [ -n "$PID_HD" ]; then
        echo "[✓] Hermes Web Dashboard berhasil aktif (PID: $PID_HD) -> http://localhost:9119"
    else
        echo "[!] Hermes Web Dashboard gagal mulai. Cek log: cat ~/.hermes/logs/dashboard.log"
    fi
fi

# 3. Pastikan Hermes Gateway berjalan (Telegram / Messaging Backend)
if pgrep -f "hermes.*gateway" >/dev/null 2>&1; then
    PID_HG=$(pgrep -f "hermes.*gateway" | head -n 1)
    echo "[✓] Hermes Gateway sudah berjalan (PID: $PID_HG)"
elif command -v hermes >/dev/null 2>&1; then
    echo "[+] Menjalankan Hermes Gateway di background..."
    nohup hermes gateway > "$HOME/.hermes/logs/gateway.log" 2>&1 &
    sleep 1
    PID_HG=$(pgrep -f "hermes.*gateway" | head -n 1 || true)
    echo "[✓] Hermes Gateway berhasil aktif (PID: $PID_HG)"
fi

# 4. Network Relay via socat (Membuka akses port loopback 9118 ke 0.0.0.0:9119)
if command -v socat >/dev/null 2>&1; then
    if ! pgrep -f "socat.*9119" >/dev/null 2>&1; then
        nohup socat TCP-LISTEN:9119,fork,reuseaddr,bind=0.0.0.0 TCP:127.0.0.1:9118 >/dev/null 2>&1 &
    fi
fi
EOF

chmod +x "$AUTOSTART_SCRIPT"

# Daftarkan ke ~/.bashrc agar jalan otomatis saat Termux dibuka / login ulang
BASHRC="$HOME/.bashrc"
if ! grep -q "autostart_services.sh" "$BASHRC" 2>/dev/null; then
    cat << 'EOF' >> "$BASHRC"

# Auto-start 9router & Hermes Gateway
export INITIAL_PASSWORD="123456"
if [ -f "$PREFIX/lib/node_android_fix.cjs" ]; then
    export NODE_OPTIONS="--require $PREFIX/lib/node_android_fix.cjs"
fi
if [ -f "$HOME/.autostart_services.sh" ]; then
    bash "$HOME/.autostart_services.sh"
fi
EOF
fi

# Jalankan service sekarang juga
echo -e "\n${BLUE}=== Menjalankan Service Pertama Kali ===${NC}"
bash "$AUTOSTART_SCRIPT"

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${GREEN}✓ Setup Instalasi Selesai & Service Aktif!                      ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "🔹 ${YELLOW}9Router Web Dashboard${NC} : http://localhost:20128 (Password: ${GREEN}123456${NC})"
echo -e "🔹 ${YELLOW}Hermes Web Dashboard${NC}  : http://localhost:9119"
echo -e ""
echo -e "${YELLOW}👉 LANGKAH SELANJUTNYA (IKUTI URUTAN BERIKUT):${NC}"
echo -e ""
echo -e "1. ${GREEN}Buka 9Router dari Browser HP/Host:${NC}"
echo -e "   - Akses: ${YELLOW}http://localhost:20128${NC} (Password: ${GREEN}123456${NC})"
echo -e "   - Buka menu ${YELLOW}Providers${NC} -> Integrasikan ${GREEN}Gemini API Key${NC} Anda."
echo -e "   - Buka menu ${YELLOW}Combos${NC}    -> Buat combo bernama ${GREEN}gdg-yogya${NC} (pilih model Gemini)."
echo -e "   - Buka menu ${YELLOW}API Keys${NC}  -> Generate API Key baru, simpan & copy key tersebut."
echo -e ""
echo -e "2. ${GREEN}Konfigurasi Hermes dengan 9Router:${NC}"
echo -e "   - Jalankan perintah berikut di Termux:"
echo -e "     ${GREEN}./hc.sh gdg-yogya <api-key-9router>${NC}"
echo -e "     (Script ini otomatis menghubungkan Hermes ke 9Router lokal)."
echo -e ""
echo -e "3. ${GREEN}Test Chat Hermes dari Browser:${NC}"
echo -e "   - Buka: ${YELLOW}http://localhost:9119${NC}"
echo -e "   - Coba kirim pesan chat pertama ke Hermes untuk memastikan respon model bekerja."
echo -e ""
echo -e "4. ${GREEN}Integrasi ke Telegram Bot:${NC}"
echo -e "   - Buka aplikasi Telegram, chat ke ${YELLOW}@BotFather${NC} -> ketik ${YELLOW}/newbot${NC}."
echo -e "   - Ikuti petunjuk sampai selesai, lalu copy ${GREEN}HTTP API Token${NC} yang diberikan."
echo -e "   - Jalankan perintah ini di Termux:"
echo -e "     ${GREEN}./ht.sh <token-telegram>${NC}"
echo -e "     (Script ini akan meminta Telegram User ID untuk whitelist & mengaktifkan bot)."
echo -e ""
echo -e "5. ${GREEN}Buat Forum Group & Topik Produktif:${NC}"
echo -e "   - Buat Grup baru di Telegram (misal: 'Hermes Pocket Lab')."
echo -e "   - Masukkan Bot Anda ke dalam grup dan jadikan Admin."
echo -e "   - Buka Info Grup -> Edit -> Aktifkan menu ${YELLOW}'Topics' (Forum)${NC}."
echo -e "   - Mulai buat topik-topik produktif Anda (misal: #Coding, #Research, #Daily-Task)."
echo -e ""
echo -e "🎉 Selesai! Anda kini memiliki AI Assistant mandiri yang running di saku Anda 24/7!"
echo -e "${BLUE}================================================================${NC}\n"
