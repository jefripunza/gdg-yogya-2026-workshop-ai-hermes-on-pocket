# 📋 Project Roadmap & Task Progress

Dokumen ini mencatat seluruh riwayat pengerjaan task sejak awal proyek hingga saat ini, serta daftar pekerjaan yang akan datang (backlog).

> **Panduan Pengembang/Agent**: Setiap kali ada task baru yang diselesaikan, wajib memperbarui dokumen ini dengan menandai checklist `[x]` beserta deskripsi perubahannya.

---

## ✅ Riwayat Task yang Sudah Selesai (Completed Tasks)

### 1. Inisialisasi & Lingkungan Simulasi Termux (Docker Host RnD)
- [x] **Setup Docker Termux Environment**: Membuat `Dockerfile` berbasis `termux/termux-docker:latest` untuk simulasi lokal di macOS/Linux.
- [x] **Script Reset & Lifecycle (`restart.sh`)**:
  - Otomatisasi stop, remove container, rebuild image, dan running container baru.
  - Mengonfigurasi flag macOS Docker compatibility (`--security-opt seccomp:unconfined`, `--ulimit nofile=1048576:1048576`).
  - Binding port eksplisit `0.0.0.0`: `20128` (9Router), `9119` (Hermes Dashboard), `8642` (Hermes API Gateway), `8080` (Web API).
- [x] **Script Helper Host (`install.sh`)**:
  - Memeriksa ketersediaan Docker daemon dan port forward container.
  - Re-create otomatis jika container lama belum mengekspos port forwarding baru.
  - Menyalin script `mobile.sh`, `hc.sh`, dan `ht.sh` ke dalam container dan menjalankan mode lokal (`./mobile.sh --local`).
  - Menampilkan Cheatsheet copy-paste interaktif di akhir proses instalasi.

### 2. Auto-Installer Termux untuk Smartphone (`mobile.sh`)
- [x] **One-Liner Installation**: Dukungan curl pipelined install (`curl -fsSL <url> | bash`).
- [x] **Otomatisasi Termux Wake-Lock**: Memasukkan `termux-wake-lock` langsung ke dalam `mobile.sh` dan `~/.autostart_services.sh`, serta menyederhanakan blok instalasi di `README.md` menjadi satu baris murni (`curl ... | bash`) agar mudah disalin dalam 1 klik.
- [x] **Konsolidasi Paket & Dependensi**: Menggabungkan seluruh kebutuhan paket (`curl`, `wget`, `git`, `python`, `nano`, `tar`, `unzip`, `jq`, `openssh`, `build-essential`, `clang`, `make`, `procps`, `net-tools`, `socat`, `gnupg`) ke dalam `mobile.sh` dan menghapus `setup-packages.sh`.
- [x] **Dukungan Node.js Terbaru & 9Router**: Menginstal Node.js versi terbaru via `pkg install -y nodejs` dan menginstal `9router` via npm secara global.
- [x] **Pemasangan Hermes Agent yang Tangguh**:
  - Penanganan issue 404 upstream Nous Research stable GPG key dengan auto-fallback ke `canary` channel.
  - Fallback ke official installer script jika repository APT tidak tersedia.
- [x] **Solusi Shebang Termux**: Menjalankan `termux-fix-shebang` otomatis pada binary npm dan script lokal untuk menangani ketiadaan path `/usr/bin/env` di Termux.
- [x] **Idempotent Auto-Start Background Services (`~/.autostart_services.sh`)**:
  - Pengecekan proses anti-dobel (`pgrep`).
  - Auto-start 9Router di background.
  - Auto-start Hermes Dashboard di background.
  - Auto-start Hermes Gateway di background.
  - Terintegrasi dengan `~/.bashrc` agar otomatis aktif saat sesi Termux baru dibuka.

### 3. Solusi Akses Jaringan & Web UI Dashboard
- [x] **Pre-build Web UI Hermes**: Menginisialisasi build `web_dist` Hermes Agent pada saat setup awal sehingga saat autostart langsung instan (`--skip-build`) tanpa risiko timeout / SIGHUP.
- [x] **Arsitektur Port Relay Hermes (9118 -> 9119)**:
  - Mengatasi kebijakan keamanan Hermes yang menolak bind non-loopback `0.0.0.0` tanpa OAuth.
  - Hermes dashboard di-bind ke `127.0.0.1:9118`.
  - Relay `socat` di-bind ke `0.0.0.0:9119` meneruskan traffic ke `127.0.0.1:9118` tanpa konflik port.
- [x] **Autentikasi Remote 9Router (`INITIAL_PASSWORD=123456`)**:
  - Mengatasi remote access lock dari 9Router saat diakses melalui Docker network.
  - Menyuntikkan `INITIAL_PASSWORD=123456` pada environment 9Router standalone server.
  - Menjalankan 9Router via Next.js standalone server (`app/server.js`) untuk stabilitas background tanpa dependensi TTY / desktop systray.

### 4. Script Pembantu Konfigurasi (Helper Scripts)
- [x] **Konfigurasi Hermes ke 9Router (`hc.sh`)**:
  - Format perintah: `./hc.sh <combo-name> <api-key-9router>`.
  - Mengonfigurasi `~/.hermes/config.yaml` dan `~/.hermes/.env` agar terhubung ke OpenAI-compatible endpoint 9Router (`http://127.0.0.1:20128/v1`).
  - Merestart Hermes Gateway dan Hermes Dashboard secara otomatis.
- [x] **Integrasi Telegram Bot (`ht.sh`)**:
  - Format perintah: `./ht.sh <telegram-token> [allowed-user-id]`.
  - Validasi token langsung via Telegram Bot API (`getMe`).
  - Konfigurasi platform Telegram di `config.yaml` dan penyimpanan token di `.env`.
  - Otomatisasi instalasi paket `libheif`, `pkg-config`, dan dependensi `python-telegram-bot[webhooks]==22.8` ke dalam virtual environment Hermes.
  - Dokumentasi aturan Telegram Group Privacy Mode (wajib Admin / disable privacy / mention) di `README.md` dan output terminal `ht.sh`.
  - Merestart Hermes Gateway agar bot langsung online dan polling aktif.
- [x] **Mode RnD vs Remote**: Dukungan flag `--local` di `mobile.sh` untuk menggunakan script lokal saat pengujian RnD tanpa harus menunggu push ke GitHub.

### 5. Dokumentasi Workshop Peserta & Proposal
- [x] **`README.md` Bersih & Fokus Workshop**:
  - 100% berorientasi pada peserta workshop (bebas jargon Docker RnD).
  - Dilengkapi Diagram Alur Arsitektur menggunakan Mermaid.
  - Panduan 5 langkah praktis (Instalasi one-liner, Konfigurasi 9Router Gemini, Integrasi Hermes, Bot Telegram, dan Pembuatan Forum Group Topics).
  - Tips wakelock, baterai, dan troubleshooting lengkap.
- [x] **Generator Judul Proposal (`TITLE.md`) & Integrasi ke `AGENT.md`**:
  - Menyusun 10 variasi judul workshop dengan beragam angle (Google Tech, DIY Hacker, Edge AI, Zero-Cost, Developer Productivity).
  - Menyertakan sub-judul, target audiens, dan blurb proposal siap pakai untuk diajukan ke panitia GDG Yogya 2026.
  - Mendaftarkan `TITLE.md` sebagai file arsitektur resmi di `AGENT.md`.
- [x] **Dukungan Lingkungan Laptop / Non-Android (Docker Compose & `laptop.sh`)**:
  - Menyiapkan `docker-compose.yml` menggunakan image resmi `decolua/9router` dan `nousresearch/hermes-agent`.
  - Membuat script helper `laptop.sh` yang dieksekusi via `curl` di dalam `docker exec hermes-agent` untuk menempelkan `hc.sh` dan `ht.sh`.
  - Menyesuaikan `hc.sh` dan `ht.sh` agar portable (shebang `#!/usr/bin/env bash`, auto-detect DNS docker `9router`, `$HERMES_HOME=/opt/data`).
  - Menambahkan panduan step-by-step di `README.md` (bagian *"Alternatif Laptop / Non-Android"* tepat di bawah section Selamat).
- [x] **Docker Helper CLI (Dipusatkan ke `laptop.sh`)**:
  - Awalnya membuat `docker.sh`, kemudian dikonsolidasikan langsung ke `laptop.sh` agar satu script dapat menangani reset, start, dan manajemen container secara terpadu.
  - Dokumentasi diperbarui di `CONTRIBUTING.md` (Cara 3).
- [x] **Perbaikan Hermes Dashboard Docker Compose (`ERR_CONNECTION_RESET`)**:
  - Menyelesaikan issue connection reset pada `localhost:9119` akibat kebijakan keamanan Hermes yang membatasi dashboard ke loopback `127.0.0.1` jika tidak ada basic auth.
  - Menyuntikkan environment `HERMES_DASHBOARD=1`, `HERMES_DASHBOARD_HOST=0.0.0.0`, `HERMES_DASHBOARD_PORT=9119`, `HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin`, dan `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=123456` pada `docker-compose.yml`.
  - Menambahkan argumen `command: gateway run` agar container berjalan sebagai gateway daemon permanen di bawah supervisi s6-overlay tanpa shutdown otomatis akibat ketiadaan terminal TTY.
  - Memperbarui dokumentasi di `README.md` dan `AGENT.md`.
- [x] **Konsolidasi CLI Manager ke `laptop.sh` & Penghapusan `docker.sh`**:
  - Memindahkan seluruh fitur manajemen container (`run`, `restart`, `stop`, `down`, `logs`, `exec`, `status`) dari `docker.sh` ke `laptop.sh`.
  - Menghapus file redundan `docker.sh`.
  - Menambahkan kapabilitas reset & up ulang bersih (kill container lama lalu up ulang fresh & re-inject) pada eksekusi berulang `laptop.sh` (mirip `restart.sh`).
  - Menambahkan alur reset bersih yang sama pada `laptop.bat` dan `laptop.ps1` untuk pengguna Windows.
  - Memperbarui dokumentasi di `CONTRIBUTING.md`, `AGENT.md`, dan `README.md`.
- [x] **Pemetaan Template PPTX & Pembuatan Blueprint Slide (`PROMPT_PPT.md`)**:
  - Menyalin `assets/DevFest Jogjakarta 2026 - Workshop AI.pptx` menjadi `assets/template.pptx` sebagai acuan permanen (**Read-Only / Tidak Boleh Diedit**) untuk AI, sementara target file yang diedit adalah `assets/DevFest Jogjakarta 2026 - Workshop AI.pptx`, serta mendokumentasikan aturan keras ini di `AGENT.md` dan `PROMPT_PPT.md`.
  - Menganalisis struktur XML, dimensi (`20" x 11.25"`), palet warna (`#080C0D`, `#55C182`, `#58E16B`, `#FFFFFF`), dan 12 archetype layout slide dari `assets/template.pptx`.
  - Menggunakan judul resmi workshop dari `TITLE.md` Opsi 1 (*"Pocket Agent: Build Your 24/7 Autonomous AI Assistant on Android with Gemini & Hermes"*).
  - Menyisipkan **Slide 2 Baru (Pengenalan Pemateri)**: **Jefri Herdi Triyanto, S.T., C.Me** (*CEO PT. Sawang Teknologi Indonesia & Principal Software Engineer*), lengkap dengan hasil scraping rekam jejak pengalaman profesional, open-source, serta tautan LinkedIn (`https://id.linkedin.com/in/jefri-herdi-triyanto`) dan Instagram (`@jefripunza`).
  - Me-rename seluruh 20 file `.png` di folder `assets/` mengikuti pola `<nomor-slide>.<urutan>.<judul-gambar>.png` (`2.1` foto profil pemateri, `7.1`, `11.1`–`11.3`, `12.1`–`12.3`, `13.1`–`13.3`, `15.1`–`15.3`, `16.1`–`16.3`, `17.1`–`17.3`).
  - Mengintegrasikan seluruh slide visual (Bagian 4 lama) langsung ke dalam urutan utama **19 Slide** di `PROMPT_PPT.md` sehingga 100% gambar masuk ke dalam slide yang relevan.
- [x] **Eksekusi Generasi File Presentasi (`assets/DevFest Jogjakarta 2026 - Workshop AI.pptx`)**:
  - Menyontek struktur XML 12 layout dari `assets/template.pptx` (tanpa mengubah `template.pptx` sedikit pun) dan menyusun **19 Slide lengkap** beserta Speaker Notes ke dalam `assets/DevFest Jogjakarta 2026 - Workshop AI.pptx`.
  - Menyematkan seluruh 20 aset gambar `.png` (`2.1`, `7.1`, `11.1`–`11.3`, `12.1`–`12.3`, `13.1`–`13.3`, `15.1`–`15.3`, `16.1`–`16.3`, `17.1`–`17.3`) dengan rasio aspek proporsional (anti-gepeng/distorsi) dan bingkai bertema gelap `#0D1719` + aksen hijau `#55C182`.

---

## 📌 Daftar Rencana Task Selanjutnya (Backlog / Upcoming)

- [ ] **Multi-Model Fallback di 9Router**: Panduan mengonfigurasi fallback provider (misal: Gemini -> Groq/OpenAI) jika kuota API utama habis.
- [ ] **Backup & Restore Konfigurasi**: Script helper untuk mengekspor & mengimpor folder `~/.hermes` dan `~/.9router` agar mudah dipindahkan ke smartphone baru.
- [ ] **Monitoring Resource CPU & RAM**: Menambahkan utilitas pemantauan konsumsi baterai dan memori ringan di Termux.
- [ ] **Custom System Prompt Preset**: Menyediakan pilihan persona awal untuk Hermes (Coding Assistant, Research Partner, Daily Organizer) langsung dari `hc.sh`.

