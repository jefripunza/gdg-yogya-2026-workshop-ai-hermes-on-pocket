# 🧠 AGENT INSTRUCTIONS & ARCHITECTURE BRAIN

Dokumen ini adalah **Memory & Invariant Guide** bagi AI Agent / pengembang yang bekerja pada repositori `gdg-yogya-2026-workshop-ai-hermes-on-pocket`.

> **PENTING UNTUK AGENT**:
> 1. Baca dokumen ini sebelum melakukan perubahan arsitektur atau scripting.
> 2. Jaga pemisahan konteks: **Peserta Workshop** (Termux Android fisik) vs **RnD Simulator** (Docker di macOS/Linux).
> 3. Setiap kali menyelesaikan task baru, **wajib perbarui `build/TODO.md`**.

---

## 🎯 Gambaran Proyek

Repositori ini dibuat untuk kebutuhan Workshop **GDG Yogya 2026: AI Hermes on Pocket**. Tujuannya adalah menjalankan asisten AI mandiri (**Hermes Agent** dari Nous Research) dan gateway proxy LLM (**9Router**) langsung di dalam saku (smartphone Android) menggunakan **Termux**, ditenagai oleh **Google Gemini API**, dan dapat diajak berinteraksi kapan saja via **Telegram** (lengkap dengan fitur **Topics**).

---

## 🏗️ Peta Arsitektur File

| File | Target Environment | Fungsi Utama |
|---|---|---|
| `mobile.sh` | **Android Termux** | Script one-click installer otomatis yang dijalankan peserta workshop via `curl ... \| bash`. |
| `laptop.sh` | **macOS / Linux Host** | One-click setup & reset: unduh compose, kill & up ulang container, inject script, dan CLI manager. |
| `laptop.bat` | **Windows CMD Host** | One-click setup & reset Windows CMD via `certutil`: unduh compose, restart container, & inject script. |
| `laptop.ps1` | **Windows PowerShell** | One-click setup & reset native PowerShell via `irm ... \| iex`: unduh, restart container, & inject script. |
| `docker-compose.yml` | **Laptop Docker** | Spesifikasi compose multi-container (`decolua/9router` & `nousresearch/hermes-agent`). |
| `hc.sh` | **Termux & Laptop** | Script konfigurasi Hermes (`./hc.sh <combo> <api-key>`) untuk menghubungkan Hermes ke 9Router. |
| `ht.sh` | **Termux & Laptop** | Script integrasi Telegram (`./ht.sh <token> [userid]`) untuk mengaktifkan bot Hermes di Telegram. |
| `build/restart.sh` | **Host Docker (RnD)** | Script reset container Docker `termux-rnd` di macOS/Linux dengan port forwarding lengkap. |
| `build/install.sh` | **Host Docker (RnD)** | Script pengujian lokal: menyalin script ke container dan menjalankan `mobile.sh --local`. |
| `build/Dockerfile` | **Host Docker (RnD)** | Base image Termux container (`termux/termux-docker:latest`). |
| `build/diagnose.sh` | **Termux / Troubleshooting** | Script diagnosa kesehatan lingkungan Termux, binary Hermes, port, dan log service. |
| `README.md` | **Publik / Peserta** | Panduan ramah pemula untuk peserta workshop (100% bebas dari istilah Docker RnD). |
| `TITLE.md` | **Proposal / Event** | Generator & kurasi pilihan judul workshop untuk diajukan ke panitia GDG. |
| `PROMPT_PPT.md` | **Presentasi / Slide** | Blueprint pemetaan layout template PPTX DevFest 2026 & draft materi 19 slide workshop. |
| `assets/template.pptx` | **Master Style PPTX** | Salinan murni template asli (12 layout archetype) di folder `assets/` sebagai acuan permanen (Read-Only) pemetaan style oleh AI. |
| `DevFest Jogjakarta 2026 - Workshop AI.pptx` | **Output Slide PPTX** | File presentasi utama workshop yang berlokasi di root project (dikeluarkan dari `assets/`), di-generate/diperbarui berdasarkan `PROMPT_PPT.md` & `template.pptx`. |
| `assets/<slide>.<urut>.<judul>.png` | **Aset Visual Slide** | 24 aset gambar (`1.1` ikon tech stack, `2.1` foto profil, `4.1` diagram arsitektur `.svg`/`.png`, `7.1`, `9.1` QR code GitHub berlogo GDG, `9.2` logo GDG transparan, & `12.1`–`18.3` screenshot tutorial) sesuai nomor slide & urutan. |
| `build/TODO.md` | **Kontributor / Agent** | Catatan task yang sudah selesai dan daftar rencana backlog. |
| `CONTRIBUTING.md` | **Kontributor** | Panduan kontribusi open-source, standar script, dan tata cara testing. |

---

## ⚠️ Aturan Teknis Kritis & Invariant (Lessons Learned)

### 1. Larangan Menjalankan `pkg`/`apt` sebagai Root di Termux
- Di Termux, perintah `pkg` dan `apt` secara sengaja diblokir dari user `root` (`id -u == 0`), memunculkan error: `Cannot run 'pkg' command as root`.
- **Aturan**: Jangan pernah menaruh perintah `RUN pkg install ...` di dalam `Dockerfile`. Semua instalasi paket harus dijalankan di dalam sesi `/entrypoint.sh login` atau melalui script runtime.

### 2. Ketiadaan Path `/usr/bin/env` di Termux
- Android dan Termux **tidak memiliki** `/usr/bin/env`, `/bin/sh`, atau `/bin/bash` standar Linux.
- Binary Termux berada di `$PREFIX/bin/` (yaitu `/data/data/com.termux/files/usr/bin/`).
- **Aturan**:
  - Gunakan shebang: `#!/data/data/com.termux/files/usr/bin/bash`.
  - Untuk script global npm (seperti 9Router), selalu jalankan `termux-fix-shebang` atau jalankan via binary node secara langsung: `node "$PREFIX/lib/node_modules/9router/app/server.js"`.

### 3. Upstream Nous Research GPG Key Fallback
- URL release stable Nous Research (`https://hermes-assets.nousresearch.com/releases/termux/stable/key.asc`) kerap mengembalikan HTTP 404.
- **Aturan**: `mobile.sh` harus selalu memeriksa channel `canary` terlebih dahulu, lalu `stable`, dan jika keduanya gagal langsung beralih ke official install script (`curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash`).

### 4. 9Router: Standalone Server & Autentikasi Remote
- **CLI vs Server**: `9router` CLI (`cli.js`) dirancang untuk desktop dengan menu TTY dan systray icon. Di background Termux, jalankan standalone server Next.js-nya: `node "$PREFIX/lib/node_modules/9router/app/server.js"`.
- **Remote Access Lock**: Saat diakses lewat Docker port forward, 9Router membaca IP gateway (`172.17.0.1`) sebagai akses remote dan mengunci login default.
- **Solusi**: Set environment variable `INITIAL_PASSWORD=123456`. Hal ini membuat backend 9Router mengizinkan login awal dengan password `123456` tanpa blokir.

### 5. Hermes Agent: Web UI Dashboard vs Gateway API
- Perintah `hermes gateway` **hanya** menjalankan backend pesan (Telegram/Discord/Cron).
- Antarmuka web UI membutuhkan perintah: `hermes dashboard --host 127.0.0.1 --port 9118 --no-open`. (Catatan: CLI `hermes dashboard` tidak memiliki flag `--skip-build`; menyertakan flag tersebut menyebabkan crash `unrecognized arguments`).

### 6. Kebijakan Keamanan Hermes Dashboard & Solusi Binding (Termux vs Docker Compose)
- Hermes dashboard menolak di-bind ke non-loopback `0.0.0.0` jika belum ada auth provider external (OAuth/Nous Portal) atau Basic Auth.
- **Di Termux (Android)**:
  1. Hermes dashboard di-bind ke loopback port internal: `127.0.0.1:9118` via `hermes dashboard --host 127.0.0.1 --port 9118 --no-open`.
  2. `socat` di-bind ke `0.0.0.0:9119` meneruskan koneksi ke `127.0.0.1:9118`.
  3. Kredensial basic auth (`HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin` & `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=123456`) disimpan di `~/.hermes/.env`.
  4. Dengan pemisahan port ini, baik browser di HP (`localhost:9119`) maupun browser di Docker host (`localhost:9119`) dapat mengakses dashboard tanpa memicu policy auth non-loopback Hermes.
- **Di Docker Compose (`nousresearch/hermes-agent`)**:
  - Image resmi Hermes mengaktifkan s6-overlay service `dashboard`. Jika environment auth tidak disetel, dashboard otomatis membatasi diri ke loopback container `127.0.0.1:9119`, menyebabkan request dari host Docker drop dengan error **`ERR_CONNECTION_RESET`**.
  - **Solusi**: Wajib menyuntikkan environment:
    ```yaml
    - HERMES_DASHBOARD=1
    - HERMES_DASHBOARD_HOST=0.0.0.0
    - HERMES_DASHBOARD_PORT=9119
    - HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin
    - HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=123456
    ```
    Hal ini membuat dashboard mengekspos `0.0.0.0:9119` secara aman dengan Basic Auth (`admin` / `123456`).
  - **Service Daemon vs Interactive CLI**: Image resmi secara default menyalakan sesi interactive chat jika dijalankan tanpa argumen. Saat berjalan di background Docker Compose tanpa TTY, proses chat langsung keluar (`Warning: Input is not a terminal`). Wajib memberikan argumen `command: gateway run` agar container berjalan sebagai gateway daemon permanen di bawah supervisi `s6-overlay`.

### 7. Dependensi Platform Telegram (`python-telegram-bot` & `libheif`)
- Hermes Agent membutuhkan `python-telegram-bot[webhooks]==22.8` agar adapter Telegram dapat berjalan.
- Jika modul tersebut belum ada di virtual environment (`$PREFIX/lib/hermes-agent/venv`), Hermes mencoba melakukan lazy-install via `pm` (`uv sync`).
- Namun, proses compile full workspace via `uv` akan gagal di Android karena mencoba mengompilasi `pillow-heif` (memerlukan `libheif`) dan `jiter`/`maturin` (memerlukan Rust).
- **Solusi**:
  1. Pasang `libheif` dan `pkg-config` di level Termux (`pkg install`).
  2. Suntikkan instalasi `python-telegram-bot[webhooks]==22.8` langsung ke dalam virtual environment Hermes menggunakan binary `uv` internal (`$PREFIX/lib/hermes-agent/tools/uv/.../uv pip install ...`).
  3. Hal ini memastikan `TELEGRAM_AVAILABLE = True` secara instan tanpa memicu kompilasi ulang kode sumber.

### 8. Telegram Group Privacy & Admin Permissions
- Secara default, bot yang dibuat via `@BotFather` memiliki **Group Privacy Mode: Enabled**.
- Dalam mode ini, server Telegram **tidak mengirimkan** chat teks biasa di grup ke bot, kecuali:
  1. Bot dijadikan **Admin** di grup.
  2. Atau pesan me-mention username bot (`@nama_bot`).
  3. Atau pengguna me-reply pesan dari bot.
  4. Atau Group Privacy di-disable via `@BotFather` (`/setprivacy` -> `Disable`).
- Hermes Agent juga menerapkan aturan `require_mention` di grup agar tidak menyampah ke obrolan umum.

### 9. Aturan Pemetaan & Generasi Slide Presentasi (`assets/template.pptx` vs `DevFest Jogjakarta 2026 - Workshop AI.pptx`)
- **DILARANG MENGEDIT `assets/template.pptx`**: File `assets/template.pptx` adalah **Master Style Reference (100% Read-Only)** yang menyimpan 12 archetype layout asli dari panitia DevFest Jogjakarta 2026 (`20.0" x 11.25"`, tema gelap `#080C0D`, aksen hijau `#55C182` / `#58E16B`). File template ini tetap di dalam `assets/` dan tidak boleh diubah, diedit, atau ditimpa dalam kondisi apa pun.
- **FILE TARGET YANG DIEDIT ADALAH `./DevFest Jogjakarta 2026 - Workshop AI.pptx` (Root Project)**: File presentasi utama telah dikeluarkan dari folder `assets/` ke root direktori. Saat AI diminta membuat atau memperbarui slide presentasi, AI wajib membaca/`clone` struktur slide dari `assets/template.pptx` (sebagai sumber acuan style, 100% Read-Only), menyuntikkan konten teks serta gambar sesuai `PROMPT_PPT.md`, lalu menyimpan hasilnya ke `./DevFest Jogjakarta 2026 - Workshop AI.pptx` di root.
- Seluruh file gambar `.png` di dalam `assets/` wajib mengikuti konvensi penamaan `<nomor-slide>.<urutan>.<judul-gambar>.png` (contoh: `2.1.foto-profil-jefri-herdi-triyanto.png`, `7.1.persiapan-botfather-new-bot.png`, `11.1.botfather-buka-mini-app.png`) dan dipastikan 100% masuk ke dalam slide yang sesuai.

### 10. Penanganan Konflik File Dpkg di Termux (`--force-overwrite`)
- Pada perangkat Android/Termux yang telah memiliki paket terinstal sebelumnya (seperti `clang`, `ndk-sysroot 27c`, dsb.), proses `apt-get dist-upgrade` rentan mengalami kegagalan akibat file conflict antara paket lama dan paket baru (contoh kasus riil: paket `libandroid-glob_0.6-3` mencoba menimpa `/data/data/com.termux/files/usr/include/glob.h` yang terdaftar sebagai milik `ndk-sysroot 27c`).
- **Aturan**:
  1. Seluruh operasi `apt-get` (`dist-upgrade`, `install`, `-f install`) dan konfigurasi `apt.conf.d/99-termux-cloudflare` **WAJIB** menyertakan opsi `Dpkg::Options { "--force-overwrite"; };`.
  2. `mobile.sh` harus selalu melakukan *auto-recovery* pada awal eksekusi dengan menjalankan `dpkg --configure -a --force-overwrite` dan menginstal file arsip `.deb` yang mengalami konflik dengan `--force-overwrite` sebelum memulai upgrade.

---

## 📖 Step-by-Step Runbook (Mulai dari Nol hingga Siap Pakai)

Jika Anda membuka sesi baru atau menguji dari awal, ikuti urutan berikut:

### Skenario A: Di Komputer Developer (Simulasi Docker macOS/Linux)
1. **Reset & Jalankan Container**:
   ```bash
   ./build/restart.sh
   ```
2. **Jalankan Instalasi Otomatis (Mode Lokal)**:
   ```bash
   ./build/install.sh
   ```
3. **Verifikasi Web Dashboard di Browser Host**:
   - Buka `http://localhost:20128` (Password: `123456`) -> Tambahkan Provider Gemini API & buat Combo `gdg-yogya` -> Salin API Key.
   - Buka `http://localhost:9119` (Hermes Web Dashboard).
4. **Hubungkan Hermes & Telegram dari Host**:
   ```bash
   docker exec -it termux-rnd /entrypoint.sh bash -c "./hc.sh gdg-yogya <api-key-9router>"
   docker exec -it termux-rnd /entrypoint.sh bash -c "./ht.sh <token-telegram>"
   ```

### Skenario B: Di Smartphone Peserta Workshop (Android Termux Asli)
1. Buka Termux, jalankan one-liner:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master/mobile.sh | bash
   ```
2. Buka browser HP: `http://localhost:20128` (Password: `123456`), setel Gemini API Key, buat combo `gdg-yogya`, salin API Key 9Router.
3. Kembali ke Termux, jalankan:
   ```bash
   ./hc.sh gdg-yogya <api-key-9router>
   ```
4. Hubungkan ke Bot Telegram:
   ```bash
   ./ht.sh <token-telegram>
   ```
5. Buat grup dengan Topics di Telegram, masukkan bot, jadikan Admin, dan nikmati asisten AI di saku Anda!

---

## 🔄 Alur Kerja Pemeliharaan & Testing

1. **Pengujian Lokal (RnD)**:
   ```bash
   ./build/install.sh
   ```
2. **Validasi Port**:
   - `http://localhost:20128` -> 9Router Dashboard (Password: `123456`)
   - `http://localhost:9119` -> Hermes Web Dashboard
3. **Validasi Sintaks Script**:
   ```bash
   bash -n mobile.sh && bash -n hc.sh && bash -n ht.sh && bash -n build/install.sh && bash -n build/restart.sh && bash -n build/diagnose.sh && bash -n laptop.sh
   ```
4. **Aturan Versi `mobile.sh` (`MOBILE_SH_VERSION`)**:
   - Setiap kali ada perubahan pada `mobile.sh`, wajib menaikkan nomor versi pada variabel `MOBILE_SH_VERSION` di bagian atas `mobile.sh` (saat ini `v2.6.0`) agar saat dijalankan via `curl` di Termux terlihat jelas di judul banner apakah yang dieksekusi sudah versi terbaru atau masih terkena cache CDN GitHub.
5. **Pembaruan Task**:
   - Setelah selesai mengimplementasikan fitur atau perbaikan bug, perbarui checklist dan riwayat di `build/TODO.md`.

