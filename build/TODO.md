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
  - Menyematkan seluruh aset gambar `.png` dengan rasio aspek proporsional (anti-gepeng/distorsi) dan bingkai bertema gelap `#0D1719` + aksen hijau `#55C182`.
- [x] **Revisi Layout, Ukuran Teks, Diagram SVG Arsitektur, & Slide Scan QR Repository (`PROMPT_PPT.md` & `DevFest Jogjakarta 2026 - Workshop AI.pptx`)**:
  - Menghapus `<a:normAutofit>` / `<a:spAutoFit>` dan *fixed line-spacing* bawaan template yang menyebabkan teks mengecil atau berjarak renggang, serta menerapkan `<a:noAutofit/>` dan proporsi *line-spacing* `115%` di seluruh 19 slide agar ukuran teks besar dan mudah terbaca.
  - Menghapus penyebutan `"Wajadi AI"` pada Slide 2 (Speaker Profile) dan merapikan posisi kartu `ENG` serta `R&D`.
  - Menghilangkan duplikasi teks 4-langkah pada Slide 4 dan membuat diagram arsitektur visual vektor & resolusi tinggi (`assets/4.1.diagram-arsitektur-pocket-agent.svg` & `assets/4.1.diagram-arsitektur-pocket-agent.png`).
  - Menghapus background putih pada `assets/logo_gdg.png` menjadi 100% transparan & *tight-cropped* (`assets/9.2.logo-gdg-transparent.png`), lalu membuat QR Code resmi menuju `https://github.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket` dengan logo GDG di tengah (`assets/9.1.qr-github-repo-gdg.png`, terverifikasi `cv2.QRCodeDetector`).
  - Menyisipkan **Slide 9 Baru (Step 01 — Scan QR & Copy Perintah)** di antara Slide 8 dan Slide 9 lama yang menggabungkan QR Code repositori dengan blok perintah instalasi lengkap (sehingga Slide 18 lama dipindahkan ke Slide 9).
  - Menjadikan **Slide 10 (sebelumnya Slide 9)** murni berisi 4 langkah tutorial setup **9Router** (`01` Login `:20128`, `02` Set Provider Gemini, `03` Buat Combo `gdg-yogya`, `04` Generate API Key `9r-...`).
  - Memperbaiki kotak judul pada Slide Visual (`Template Slide 6` clones & `Template Slide 10`) agar tidak ada lagi judul yang terpotong (*clipped*) atau menabrak logo DevFest, serta memperbarui penomoran nama file aset gambar (`12.1`–`18.3`).
- [x] **Penambahan Ikon Tech Stack Slide 1, Animasi Seluruh Slide, Perbaikan Tabrakan Teks, & Update Topik (`#Learning`, `#Research`, `#Daily-Planner`, `#Coding`)**:
  - Membuat aset [`assets/1.1.tech-stack-icons.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/1.1.tech-stack-icons.png) dan menyematkan 6 ikon teknologi (**Hermes**, **Android**, **Termux**, **9Router**, **Gemini AI**, **Telegram**) tepat di bawah nama pemateri pada **Slide 1**.
  - Menambahkan transisi *Fade* (`<p:transition>`) dan animasi masuk bertahap (*staggered automatic Fade entrance* `<p:timing>`) di seluruh **19 slide** pada `assets/DevFest Jogjakarta 2026 - Workshop AI.pptx`.
  - Mengubah pilar ke-3 pada **Slide 5** menjadi **`9Router with Gemini`** (bersama `Hermes Agent` dan `Telegram Bot & Topics`).
  - Memperbaiki lebar kotak judul dan posisi vertikal pada **Slide 8, 9, 10, 11, dan 17** agar judul 1 baris tidak lagi terlipat (*wrapping*) dan bertabrakan dengan subjudul/deskripsi di bawahnya.
  - Memperbarui daftar 4 topik Telegram Forum di **Slide 4, 5, 14, 15, 18**, `README.md`, dan `PROMPT_PPT.md` menjadi **`#Learning`**, **`#Research`**, **`#Daily-Planner`**, dan **`#Coding`**.
  - Menambahkan profil pemateri beserta tautan **LinkedIn** (`https://id.linkedin.com/in/jefri-herdi-triyanto`) dan **Instagram** (`@jefripunza`) ke dalam `README.md`.
- [x] **Revisi Final Slide 1, 2, 9, 11, 15, 19 & Auto-Switch Repo Termux ke Cloudflare Mirror (`packages-cf.termux.dev`)**:
  - Menggunakan 6 file logo asli di `assets/` pada `assets/1.1.tech-stack-icons.png` untuk Slide 1 (murni berjajar tanpa badge/teks) dan menghapus garis pemisah putih di dalam kartu bawah Slide 7, 12, 13, 14, 16, 17, 18.
  - Memisahkan baris `GitHub` dan `Web` pada Slide 2 serta mengganti kotak `CEO`/`ENG`/`R&D` di kanan dengan daftar vertikal **Pengalaman Profesional (LinkedIn)**.
  - Menghapus blok `CLI` pada Slide 9 dan memperjelas label perintah instalasi untuk **Termux (HP Android)**, **Linux & macOS**, dan **Windows**.
  - Menambahkan label `STEP 03` pada Slide 11, memperjelas persiapan Mobile & Laptop di `README.md`, dan memisahkan baris teks sosial pemateri di Slide 19.
  - Mengonfigurasi `mobile.sh` agar otomatis mengarahkan repo APT Termux (`$PREFIX/etc/apt/sources.list` dan `$PREFIX/etc/termux/chosen_mirrors`) dari `termux.net` ke mirror cepat Cloudflare (`https://packages-cf.termux.dev/apt/termux-main stable main`) sebelum `pkg update`.
- [x] **Penambahan Pengalaman Lapak Merangin di Slide 2 & Slide 3 Baru (Bukti Dokumentasi SakuTani, Lapak Merangin, Kementerian PU, PT Minarta, & Pasang Server)**:
  - Menambahkan **Lapak Merangin** (*Co-Founder & Lead Developer — Local E-Commerce & Direktori UMKM Kab. Merangin, Jambi*) tepat di antara posisi *Principal Software Engineer* dan *CEO & Co-Founder SakuTani* pada **Slide 2**.
  - Mengonversi 5 foto bukti pengalaman ke format PNG standar (`3.1.bukti-sakutani.png`, `3.2.bukti-lapak-merangin.png`, `3.3.pengalaman-meeting-kementerian-pu.png`, `3.4.pengalaman-client-minarta.png`, `3.5.pengalaman-pasang-server-client.png`) dan menyisipkan **Slide 3 Baru** (*Jejak Karya: Startup Lokal, Instansi & Infrastruktur Enterprise*) di antara Slide 2 dan Slide 3 lama (total menjadi **20 slide**).
- [x] **Perbaikan Hermes Dashboard ERR_EMPTY_RESPONSE & Permissions Script (`v2.2.0`)**:
  - Menghapus flag invalid `--skip-build` dari pemanggilan `hermes dashboard` di `mobile.sh` dan `hc.sh` yang menyebabkan Hermes Dashboard crash seketika dan membuat `localhost:9119` mengembalikan `ERR_EMPTY_RESPONSE`.
  - Memperbaiki izin eksekusi (`chmod 755 $PREFIX/bin/bash $PREFIX/bin/sh $PREFIX/bin/termux-setup-package-manager`) untuk menanggulangi traceback `py3compile Permission denied`.
  - Menambahkan auto-restart socat relay dan health check interaktif pada `hc.sh` yang otomatis menampilkan log jika dashboard gagal aktif.
- [x] **Perbaikan Android 15 Bionic Linker, esbuild Hook, & Refactoring Folder `build/` (`v2.4.0`)**:
  - Memperbaiki error Android 15 `has bad ELF magic: 23212f64` / `23212f75` pada `node-deps.mjs` dan `esbuild` dengan membuat Universal Android Node Hook (`$PREFIX/lib/node_android_fix.cjs`) yang dimuat otomatis via `NODE_OPTIONS`.
  - Mengeliminasi freeze/stuck berjam-jam pada tahap `Menyelaraskan shebang` dengan membatasi `termux-fix-shebang` hanya pada binary tools utama (`bin/*`, `tools/npm/bin/*`) tanpa memindai rekursif ke dalam 50.000+ file `node_modules`.
  - Merapikan struktur repositori dengan memindahkan file pendukung build & RnD ke folder `build/`: `build/diagnose.sh`, `build/Dockerfile`, `build/install.sh`, `build/restart.sh`, dan `build/TODO.md`.
  - Menyesuaikan referensi path project root di `build/install.sh` & `build/restart.sh`, serta memperbarui `CONTRIBUTING.md` dan `AGENT.md`.
- [x] **Relokasi File PPT Target ke Root Project**:
  - Mengeluarkan file presentasi utama (`DevFest Jogjakarta 2026 - Workshop AI.pptx`) dari folder `assets/` ke root direktori repositori agar mudah diakses.
  - Mempertahankan `assets/template.pptx` tetap di dalam `assets/` sebagai master style reference yang berstatus murni Read-Only.
  - Memperbarui dokumentasi instruksi dan path target di `PROMPT_PPT.md` dan `AGENT.md`.
- [x] **Pembaruan Sumber Aplikasi Termux (Google Play Store vs F-Droid)**:
  - Membalik rekomendasi instalasi Termux di `README.md` menjadi mengarahkan peserta ke [Google Play Store](https://play.google.com/store/apps/details?id=com.termux) (versi terbaru/paling update) dan tidak menggunakan F-Droid.
  - Menyelaraskan referensi teks pada `PROMPT_PPT.md` dan file presentasi `DevFest Jogjakarta 2026 - Workshop AI.pptx` (Slide 7 & 9).
- [x] **Perbaikan Konflik File Dpkg Termux (libandroid-glob vs ndk-sysroot) (v2.7.0)**:
  - Mengatasi error dpkg file overwrite conflict: `dpkg: error processing archive ... libandroid-glob: trying to overwrite '/data/data/com.termux/files/usr/include/glob.h', which is also in package ndk-sysroot 27c`.
  - Menambahkan `--force-overwrite` ke konfigurasi `Dpkg::Options` di `99-termux-cloudflare` dan seluruh pemanggilan `apt-get` (`dist-upgrade`, `install`, `-f install`).
  - Menambahkan auto-recovery dpkg di awal eksekusi `mobile.sh` untuk menyelesaikan broken/half-installed packages dari sesi sebelumnya.
- [x] **Perbaikan 'npm: command not found' & Permission Denied py3compile (v2.8.0)**:
  - Mengatasi crash `py3compile Permission denied: '/data/data/com.termux/files/usr/bin/bash'` dengan menambahkan `DPkg::Pre-Invoke` dan `DPkg::Post-Invoke` hooks untuk otomatis `chmod 755` pada `$PREFIX/bin/bash` dan seluruh binary saat proses package trigger APT.
  - Mengatasi error `line 283: npm: command not found` dengan menerapkan resolusi bertingkat (multi-tier resolution) yang memeriksa PATH, `$PREFIX/bin/npm`, symlink ke `$PREFIX/lib/node_modules/npm`, dan fallback langsung ke bundled npm milik Hermes Agent (`$HERMES_LIB/tools/npm`).
  - Menginisialisasi Universal Android 15 Node Hook (`node_android_fix.cjs`) sebelum perintah instalasi 9Router agar child processes terlindungi dari crash linker Android 15.
- [x] **Perbaikan 'MODULE_NOT_FOUND npm-cli.js' & Launcher Wrapper Mandiri (v2.9.0)**:
  - Mengatasi error `Cannot find module '.../lib/node_modules/npm/bin/npm-cli.js'` yang diakibatkan oleh jebakan symlink relatif antar direktori root yang berbeda.
  - Mengimplementasikan pemulihan otomatis direktori core npm (`$PREFIX/lib/node_modules/npm`) dari bundled Hermes Agent jika sistem tidak memiliki npm.
  - Menggantikan symlink rentan dengan executable launcher wrapper mandiri di `$PREFIX/bin/npm` dan `$PREFIX/bin/npx` yang langsung mengeksekusi `node <path-to-cli.js>`.
- [x] **Perbaikan 'SyntaxError Unexpected token [' di npm-cli.js (v2.10.0)**:
  - Mengeliminasi kontaminasi file `npm-cli.js` yang disebabkan oleh shell redirection ke symlink `$PREFIX/bin/npm`.
  - Menambahkan deteksi dan pembersihan otomatis file `npm-cli.js` yang korup dari sesi sebelumnya.
  - Memastikan paket resmi Termux `nodejs` dan `npm` diinstal secara bersih via APT dan menyelaraskan shebang resmi tanpa merusak struktur file JavaScript asli.
- [x] **Penyimpanan diagnose.sh Saat Setup & Conditional Auto-Diagnostics Port 9119/20128 (v2.11.0)**:
  - Menyimpan `diagnose.sh` secara otomatis ke `$HOME/diagnose.sh` bersama `hc.sh` dan `ht.sh` di `mobile.sh` (baik mode `--local` maupun remote `curl` via GitHub) dengan izin executable dan shebang terselaras.
  - Menghapus flag invalid `--skip-build` pada `hermes dashboard` di `mobile.sh` dan `hc.sh` yang menyebabkan Hermes Dashboard langsung crash saat `web_dist` tersedia.
  - Mengimplementasikan polling verifikasi kesehatan layanan (hingga 30s) di akhir proses instalasi sebelum info banner final.
  - Logika diagnostik kondisional: Jika `9Router (:20128)` dan `Hermes Dashboard (:9119)` berhasil di-hit OK, sistem **tidak** menjalankan `diagnose.sh`. Jika salah satu atau kedua port gagal diakses, sistem secara otomatis mengeksekusi `diagnose.sh` untuk menghasilkan laporan diagnosa mendalam (`~/diag_report.txt`).

---

## 📌 Daftar Rencana Task Selanjutnya (Backlog / Upcoming)

- [ ] **Multi-Model Fallback di 9Router**: Panduan mengonfigurasi fallback provider (misal: Gemini -> Groq/OpenAI) jika kuota API utama habis.
- [ ] **Backup & Restore Konfigurasi**: Script helper untuk mengekspor & mengimpor folder `~/.hermes` dan `~/.9router` agar mudah dipindahkan ke smartphone baru.
- [ ] **Monitoring Resource CPU & RAM**: Menambahkan utilitas pemantauan konsumsi baterai dan memori ringan di Termux.
- [ ] **Custom System Prompt Preset**: Menyediakan pilihan persona awal untuk Hermes (Coding Assistant, Research Partner, Daily Organizer) langsung dari `hc.sh`.

