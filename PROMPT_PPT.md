# 🎨 PROMPT & CONTENT BLUEPRINT: PPT WORKSHOP GDG YOGYA 2026

Dokumen ini adalah **Blueprint & Draft Konten Presentasi** yang telah disesuaikan secara presisi dengan struktur shape, tipografi, dan gaya visual dari:
- 🔒 **Master Style Reference (JANGAN DIEDIT / READ-ONLY)**: [`assets/template.pptx`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/template.pptx) *(Salinan murni 12 archetype slide asli untuk acuan tema & pemetaan style oleh AI — file ini TIDAK BOLEH diubah/ditimpa)*
- ✏️ **Target File Presentasi (FILE YANG DIEDIT)**: [`DevFest Jogjakarta 2026 - Workshop AI.pptx`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/DevFest%20Jogjakarta%202026%20-%20Workshop%20AI.pptx) *(File presentasi utama telah dikeluarkan dari `assets/` ke root direktori. Seluruh hasil generate & update slide presentasi wajib ditulis ke file ini di root)*

> **⚠️ ATURAN WAJIB UNTUK AI AGENT:**
> - **DILARANG KERAS mengedit atau menimpa [`assets/template.pptx`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/template.pptx)**. Gunakan `assets/template.pptx` murni sebagai sumber acuan (*read-only source*) untuk menyontek layout/style slide.
> - **File yang wajib diedit/di-generate adalah [`DevFest Jogjakarta 2026 - Workshop AI.pptx`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/DevFest%20Jogjakarta%202026%20-%20Workshop%20AI.pptx)** yang berlokasi di **root direktori project** (bukan di dalam `assets/`). Template master tetap berada di dalam `assets/template.pptx`.

---

## 📐 BAGIAN 1: Pemetaan Desain & 19 Slide Presentasi terhadap `assets/template.pptx`

Berdasarkan pembacaan struktur XML dari [`assets/template.pptx`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/template.pptx), berikut adalah spesifikasi sistem desain template:

- **Dimensi Kanvas**: `20.00 in × 11.25 in` (Widescreen 16:9 Besar)
- **Palet Warna Utama**:
  - **Background Dark**: `#080C0D` (Hitam Kehijauan Khas DevFest / Google Tech)
  - **Primary Accent Green**: `#55C182` (Hijau Emerald untuk Subtitle, Angka Besar, & Card Header)
  - **Secondary Neon Green**: `#58E16B` & `#36AC6D` (Lingkaran Step & Pill Badge)
  - **Primary Text**: `#FFFFFF` (Putih Bersih, dengan `<a:noAutofit/>` dan proporsi *line-spacing* `115%` agar teks selalu besar & tajam)
- **Animasi & Transisi Slide**: Seluruh 19 slide dilengkapi transisi `<p:transition spd="med"><p:fade/></p:transition>` dan animasi masuk bertahap (*staggered automatic Fade entrance* `<p:timing>`) pada elemen kontennya.

### Tabel Pemetaan Urutan 19 Slide terhadap Master Layout (`assets/template.pptx`)

| No. Slide | Acuan Layout di `template.pptx` | Nama Archetype Layout | Judul / Fungsi Slide | Gambar dari `assets/` |
| :--- | :--- | :--- | :--- | :--- |
| **Slide 1** | `Template Slide 1` | **Hero Cover Slide + Tech Icons** | Cover Pembuka Workshop (`TITLE.md` #1) + 6 Ikon Teknologi | `1.1` |
| **Slide 2** | `Template Slide 5` | **Speaker Profile (Left Photo/Title + 3 Cards)** | Pengenalan Pemateri: Jefri Herdi Triyanto, S.T., C.Me | `2.1` |
| **Slide 3** | `Template Slide 2` | **Split Intro (Left Heading + Right Body)** | Latar Belakang: Kenapa AI Harus Hidup di Saku Kita? | — |
| **Slide 4** | `Template Slide 3` | **Left Narrative + Right SVG/PNG Diagram** | Gambaran Arsitektur Sistem (Telegram ↔ Hermes ↔ 9Router ↔ Gemini) | `4.1` (`.svg` & `.png`) |
| **Slide 5** | `Template Slide 4` | **Purpose Banner + 3 Feature Blocks** | 3 Pilar Teknologi Utama (Hermes Agent, Telegram Bot & Topics, 9Router with Gemini) | — |
| **Slide 6** | `Template Slide 5` | **Left Heading + Right 3 Big-Stat Cards** | Port Layanan & Kemudahan Akses (`1-Click`, `:20128`, `:9119`) | — |
| **Slide 7** | `Template Slide 6` | **3-Column Visual / Feature Cards** | Persiapan & Pilihan Jalur Perangkat (Android vs Laptop) | `7.1` |
| **Slide 8** | `Template Slide 7` | **6-Step Numbered Grid (`01` – `06`)** | Peta Jalan Praktikum (6 Langkah End-to-End) | — |
| **Slide 9** | `Template Slide 11` | **Left QR Code + Right 4 Command Blocks** | **Step 01: Scan QR Repository GitHub & One-Liner Installer** | `9.1`, `9.2` |
| **Slide 10** | `Template Slide 8` | **Left Title + Right 4-Step Vertical (`01`–`04`)** | **Step 02: Tutorial Murni Setup 9Router (`:20128`)** | — |
| **Slide 11** | `Template Slide 9` | **5-Card Ecosystem / Command Showcase** | Step 03 & 04: Koneksi `hc.sh`, Web UI `:9119`, & `ht.sh` | — |
| **Slide 12** | `Template Slide 6` | **3-Column Visual Screenshot Cards** | Visual Step 4A: Membuat Bot & Token di `@BotFather` | `12.1`, `12.2`, `12.3` |
| **Slide 13** | `Template Slide 6` | **3-Column Visual Screenshot Cards** | Visual Step 4B: Cek User ID Whitelist & Cari Bot | `13.1`, `13.2`, `13.3` |
| **Slide 14** | `Template Slide 6` | **3-Column Visual Screenshot Cards** | Visual Step 4C & 5A: Tes Chat DM & Mulai Buat Grup | `14.1`, `14.2`, `14.3` |
| **Slide 15** | `Template Slide 10` | **3-Step Horizontal Flow (`1`, `2`, `3`)** | Step 05: Ringkasan Organisasi AI dengan Telegram Topics | — |
| **Slide 16** | `Template Slide 6` | **3-Column Visual Screenshot Cards** | Visual Step 5B: Beri Nama Grup & Buka Menu Edit Admin | `16.1`, `16.2`, `16.3` |
| **Slide 17** | `Template Slide 6` | **3-Column Visual Screenshot Cards** | Visual Step 5C: Set Bot Jadi Admin, `/sethome`, & Enable Topics | `17.1`, `17.2`, `17.3` |
| **Slide 18** | `Template Slide 6` | **3-Column Visual Screenshot Cards** | Visual Step 5D: Buat Topik Baru & Diskusi Aktif di Topics | `18.1`, `18.2`, `18.3` |
| **Slide 19** | `Template Slide 12` | **Giant Closing / Q&A Slide + QR Code** | Penutup, Selamat, Link Repo/Sosmed & Tanya Jawab (Q&A) | `9.1` |

---

## 🖼️ BAGIAN 2: Katalog Aset Gambar di Folder `assets/` (100% Terpetakan)

Seluruh file gambar di folder [`assets/`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets) dinamai sesuai `<nomor-slide>.<urutan>.<judul-gambar>`:

| Slide & Urutan | Nama File di `assets/` | Deskripsi Visual pada Slide |
| :--- | :--- | :--- |
| **Slide 1 — Gambar 1** | [`1.1.tech-stack-icons.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/1.1.tech-stack-icons.png) | Strip badge 6 ikon teknologi utama (**Hermes**, **Android**, **Termux**, **9Router**, **Gemini AI**, **Telegram**) di bawah nama pemateri pada Slide 1 |
| **Slide 2 — Gambar 1** | [`2.1.foto-profil-jefri-herdi-triyanto.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/2.1.foto-profil-jefri-herdi-triyanto.png) | Foto potret resmi pemateri (**Jefri Herdi Triyanto, S.T., C.Me**) mengenakan jas untuk area kiri Slide 2 |
| **Slide 4 — Gambar 1** | [`4.1.diagram-arsitektur-pocket-agent.svg`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/4.1.diagram-arsitektur-pocket-agent.svg) & [`.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/4.1.diagram-arsitektur-pocket-agent.png) | Diagram visual 4-tahap Arsitektur End-to-End Pocket Agent (Telegram ↔ Hermes `:9119` ↔ 9Router `:20128` ↔ Google Gemini API) |
| **Slide 7 — Gambar 1** | [`7.1.persiapan-botfather-new-bot.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/7.1.persiapan-botfather-new-bot.png) | Preview pembuatan bot `GDG Yogya Workshop AI` di Mini App `@BotFather` pada kartu persiapan |
| **Slide 9 — Gambar 1** | [`9.1.qr-github-repo-gdg.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/9.1.qr-github-repo-gdg.png) | QR Code menuju `https://github.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket` dengan logo GDG transparan di tengah |
| **Slide 9 — Gambar 2** | [`9.2.logo-gdg-transparent.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/9.2.logo-gdg-transparent.png) & [`logo_gdg.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/logo_gdg.png) | Ikon logo GDG yang telah dihapus background putihnya (100% transparan & *tight-cropped*) untuk disematkan di tengah QR Code |
| **Slide 12 — Gambar 1** | [`12.1.botfather-buka-mini-app.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/12.1.botfather-buka-mini-app.png) | Profil akun resmi `@BotFather` dengan tombol biru **Open App** |
| **Slide 12 — Gambar 2** | [`12.2.botfather-isi-nama-dan-username-bot.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/12.2.botfather-isi-nama-dan-username-bot.png) | Form **New bot**: mengisi nama `GDG Yogya`, username `t.me/gdg_yogya_bot`, klik **Create Bot** |
| **Slide 12 — Gambar 3** | [`12.3.botfather-salin-api-token.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/12.3.botfather-salin-api-token.png) | Halaman manajemen bot `@gdg_yogya_bot` dengan tombol **Copy** untuk menyalin API Token |
| **Slide 13 — Gambar 1** | [`13.1.cari-bot-userinfobot.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/13.1.cari-bot-userinfobot.png) | Pencarian `@userinfobot` (`User Info • Get ID • idbot`) di kolom search Telegram |
| **Slide 13 — Gambar 2** | [`13.2.salin-telegram-user-id.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/13.2.salin-telegram-user-id.png) | Balasan `/start` dari `@userinfobot` yang menampilkan angka `Id: 1228921740` untuk whitelist |
| **Slide 13 — Gambar 3** | [`13.3.cari-bot-hermes-di-telegram.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/13.3.cari-bot-hermes-di-telegram.png) | Mencari bot `@gdg_yogya_bot` di Global Search Telegram setelah `ht.sh` dijalankan |
| **Slide 14 — Gambar 1** | [`14.1.tes-chat-dm-pertama-bot.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/14.1.tes-chat-dm-pertama-bot.png) | Chat DM pertama (`/start` & `Halo`) dibalas langsung oleh Hermes Agent + info `/sethome` |
| **Slide 14 — Gambar 2** | [`14.2.pilih-menu-new-group.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/14.2.pilih-menu-new-group.png) | Membuka menu **New Message** lalu memilih **New Group** di Telegram |
| **Slide 14 — Gambar 3** | [`14.3.undang-bot-ke-grup-baru.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/14.3.undang-bot-ke-grup-baru.png) | Mencari dan memilih `@gdg_yogya_bot` untuk dimasukkan ke dalam grup baru |
| **Slide 16 — Gambar 1** | [`16.1.beri-nama-dan-create-grup.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/16.1.beri-nama-dan-create-grup.png) | Memberi nama grup `Jefri and GDG Yogya` lalu menekan tombol **Create** |
| **Slide 16 — Gambar 2** | [`16.2.buka-info-dan-edit-grup.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/16.2.buka-info-dan-edit-grup.png) | Halaman profil grup `Jefri and GDG Yogya`, menekan tombol **Edit** di kanan atas |
| **Slide 16 — Gambar 3** | [`16.3.pilih-menu-administrators-grup.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/16.3.pilih-menu-administrators-grup.png) | Halaman **Edit Group** yang menampilkan opsi **Topics** dan **Administrators** |
| **Slide 17 — Gambar 1** | [`17.1.jadikan-bot-admin-grup.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/17.1.jadikan-bot-admin-grup.png) | Menu **Chat Admins**: mempromosikan `GDG Yogya` (`@gdg_yogya_bot`) menjadi **admin** |
| **Slide 17 — Gambar 2** | [`17.2.tes-chat-grup-dan-sethome.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/17.2.tes-chat-grup-dan-sethome.png) | Mengirim `Halo` di grup & menjalankan `/sethome` (`✅ Home channel set to Jefri and GDG Yogya`) |
| **Slide 17 — Gambar 3** | [`17.3.aktifkan-toggle-enable-topics.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/17.3.aktifkan-toggle-enable-topics.png) | Menu **Topics**: mengaktifkan toggle **Enable Topics** dan memilih tampilan **Tabs** / **List** |
| **Slide 18 — Gambar 1** | [`18.1.pilih-menu-new-topic.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/18.1.pilih-menu-new-topic.png) | Menekan tombol menu (`...`) di pojok kanan atas grup lalu memilih **New Topic** |
| **Slide 18 — Gambar 2** | [`18.2.buat-topik-home-dan-pilih-ikon.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/18.2.buat-topik-home-dan-pilih-ikon.png) | Membuat topik baru bernama `Home` beserta pemilihan ikon topik |
| **Slide 18 — Gambar 3** | [`18.3.chat-aktif-di-topik-general.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/18.3.chat-aktif-di-topik-general.png) | Berdiskusi dengan AI di dalam topik `# General` dan menjalankan `/sethome@gdg_yogya_bot` |

---

## 📝 BAGIAN 3: Konten Slide demi Slide (Slide 1 s.d. Slide 19)

### 🖥️ SLIDE 1 — Cover / Judul Resmi Workshop (`Template Slide 1` + `1.1`)
- **Logo DevFest Jogjakarta 2026**: Dinaikkan ke `y=1.80"` agar memiliki jarak lega dengan judul utama di bawahnya.
- **Main Title (`50pt Bold #FFFFFF`)**: `Pocket Agent: Build Your 24/7 Autonomous AI Assistant on Android with Gemini & Hermes`
- **Subtitle (`26pt Bold #55C182`)**: `Menjalankan Gateway LLM dan Agent AI Mandiri Langsung dari Smartphone via Termux & Telegram`
- **Speaker (`22pt #FFFFFF`)**: `Jefri Herdi Triyanto, S.T., C.Me`
- **Bottom Tech Icons Strip**: [`assets/1.1.tech-stack-icons.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/1.1.tech-stack-icons.png) (`Hermes` • `Android` • `Termux` • `9Router` • `Gemini AI` • `Telegram`)

### 🖥️ SLIDE 2 — Pengenalan Pemateri / Speaker Profile (`Template Slide 5`)
- **Left Portrait Photo**: [`assets/2.1.foto-profil-jefri-herdi-triyanto.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/2.1.foto-profil-jefri-herdi-triyanto.png)
- **Left Heading (`40pt Bold #FFFFFF`)**: `Jefri Herdi Triyanto, S.T., C.Me`
- **Left Role (`23pt Bold #55C182`)**: `CEO PT. Sawang Teknologi Indonesia & Principal Software Engineer`
- **Left Social Links (`20pt #FFFFFF`)**:
  - `• LinkedIn : linkedin.com/in/jefri-herdi-triyanto`
  - `• Instagram : @jefripunza (instagram.com/jefripunza)`
  - `• GitHub : github.com/jefripunza`
  - `• Web : sawang.tech • jefripunza.com`
- **Right Experience List (`PENGALAMAN PROFESIONAL — LINKEDIN`)**:
  1. `CEO & Founder — PT. Sawang Teknologi Indonesia (Sawang Tech)` — `Memimpin pengembangan solusi IT enterprise, arsitektur cloud, IoT, serta platform AI & otomasi bisnis untuk instansi pemerintah & korporasi di Yogyakarta.`
  2. `Principal Software Engineer & Open-Source Creator (@jefripunza)` — `Arsitek sistem backend, Agentic AI & Model Context Protocol (Core Agent MCP), serta kreator ekosistem Go & Docker Hub.`
  3. `Co-Founder & Lead Developer — Lapak Merangin (Local E-Commerce)` — `Membangun aplikasi jual-beli online (e-commerce alternatif Shopee) & direktori layanan UMKM, produk lokal, jasa, serta kurir di Kab. Merangin, Jambi.`
  4. `CEO & Co-Founder — SakuTani (Agritech Startup)` — `Membangun platform e-commerce pertanian berbasis Android & teknologi Industry 4.0 untuk menghubungkan petani, peternak, dan UMKM ke pasar digital.`
  5. `R&D Engineer & Inventor — Paten/HKI Instrumen Pintar IoT (DJKI)` — `Perancang instrumen pintar berteknologi sensor & mikrokontroler terpadu yang terdaftar resmi di Direktorat Jenderal Kekayaan Intelektual (DJKI).`

### 🖥️ SLIDE 3 — Bukti Pengalaman & Portofolio Lapangan (`Template Slide 6` Bento Layout + `3.1` s.d. `3.5`)
- **Subtitle (`21pt Bold #55C182`)**: `TRACK RECORD & PORTFOLIO LAPANGAN`
- **Heading (`44pt Bold #FFFFFF`)**: `Jejak Karya`
- **Left Column (3 Landscape Cards)**:
  1. [`3.1.bukti-sakutani.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/3.1.bukti-sakutani.png) — `AGRITECH STARTUP • 2019`: `SakuTani — Startup Business Matching`
  2. [`3.2.bukti-lapak-merangin.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/3.2.bukti-lapak-merangin.png) — `LOCAL E-COMMERCE • 2020`: `Lapak Merangin — Marketplace Lokal Jambi`
  3. [`3.3.pengalaman-meeting-kementerian-pu.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/3.3.pengalaman-meeting-kementerian-pu.png) — `GOVERNMENT SECTOR • KEMENTERIAN PU`: `Presentasi & Diskusi Solusi IT Pemerintahan`
- **Right Area (2 Cropped Middle Cards)**:
  4. [`3.4.pengalaman-client-minarta.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/3.4.pengalaman-client-minarta.png) (crop atas & bawah, fokus tengah) — `ENTERPRISE CLIENT`: `PT Minarta Dutahutama`
  5. [`3.5.pengalaman-pasang-server-client.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/3.5.pengalaman-pasang-server-client.png) (crop atas & bawah, fokus tengah) — `ON-PREMISE INFRASTRUCTURE`: `Deployment Rack Server`

### 🖥️ SLIDE 3 — Mengapa AI Harus Hidup di Saku Kita? (`Template Slide 2`)
- **Left Heading (`68pt Bold #FFFFFF`)**: `Kenapa AI Harus Hidup di Saku Kita?`
- **Right Body (`29pt #55C182` & `25pt #FFFFFF`)**: `Bagaimana jika smartphone di saku Anda bisa menjadi server AI mandiri yang aktif 24/7 tanpa menyewa cloud VPS untuk kaum “in this economy”? Dengan menggabungkan Termux (atau Docker), 9Router, dan Hermes Agent yang ditenagai Google Gemini API, perangkat Anda berubah menjadi asisten AI otonom yang punya memori jangka panjang, puluhan tools eksekusi, dan siap diajak berkolaborasi kapan saja lewat forum topik Telegram.`

### 🖥️ SLIDE 4 — Gambaran Arsitektur Sistem (`Template Slide 3` + SVG/PNG Diagram `4.1`)
- **Left Summary (`42pt Bold #FFFFFF` & `22pt #FFFFFF`)**:
  - `Arsitektur End-to-End Pocket Agent`
  - `100% Berjalan Lokal di Perangkat Anda`
  - `Seluruh orkestrasi memori, 50+ built-in skills, dan routing model LLM berjalan mandiri di Termux (Android) atau Docker (Laptop) tanpa biaya sewa server cloud.`
  - `• Port :9119 — Hermes Agent & Web UI`
  - `• Port :20128 — 9Router Local LLM Proxy`
- **Right Visual Diagram**: [`assets/4.1.diagram-arsitektur-pocket-agent.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/4.1.diagram-arsitektur-pocket-agent.png) (beserta file sumber vektor [`assets/4.1.diagram-arsitektur-pocket-agent.svg`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/4.1.diagram-arsitektur-pocket-agent.svg)).

### 🖥️ SLIDE 5 — 3 Pilar Teknologi Utama (`Template Slide 4`)
- **Top Heading (`76pt Bold #FFFFFF`)**: `Tiga Mesin Utama di Balik Layar`
- **3 Columns (`32pt #55C182` Title + `20pt #FFFFFF` Body)**:
  1. `Hermes Agent`: `Autonomous AI Agent dari Nous Research dengan 50+ built-in skills, memori persisten, cron scheduler, dan web dashboard (:9119).`
  2. `Telegram Bot & Topics`: `Antarmuka komando AI dari saku Anda dengan fitur Forum Topics (#Learning, #Research, #Daily-Planner, #Coding) agar konteks rapi.`
  3. `9Router with Gemini`: `Local LLM Proxy (:20128) dengan fitur Combo Model yang mengubah Google Gemini API menjadi endpoint OpenAI-compatible lokal super cepat.`

### 🖥️ SLIDE 6 — Port Layanan & Kemudahan Akses (`Template Slide 5`)
- **Left Heading (`68pt Bold #FFFFFF`)**: `Satu Baris Perintah, Semua Siap`
- **Right 3 Stat Cards**:
  1. `1-Click` — `Auto-Installer Script`
  2. `:20128` — `9Router Web Dashboard` (Password: `123456`)
  3. `:9119` — `Hermes Web UI` (Akses langsung tanpa login tambahan)

### 🖥️ SLIDE 7 — Persiapan & Pilihan Jalur Perangkat (`Template Slide 6` + `7.1`)
- **Heading (`38pt Bold #FFFFFF`)**: `Bisa di HP Android Maupun di Laptop Anda!`
- **3 Columns**:
  1. `Jalur 1: HP Android` (`Aplikasi Termux Google Play Store` — `mobile.sh`)
  2. `Jalur 2: Laptop` (`macOS, Linux, atau Windows Docker` — `laptop.sh` / `laptop.ps1`)
  3. `Tiket Masuk Wajib` (`Google AI Studio & Akun Telegram` + gambar `7.1.persiapan-botfather-new-bot.png`)

### 🖥️ SLIDE 8 — Peta Jalan Praktikum 6 Langkah (`Template Slide 7`)
- **Heading (`66pt Bold #FFFFFF`)**: `6 Langkah Membangun AI di Saku Anda`
- **Steps `01` – `06`**:
  - `01 Scan QR & Install`
  - `02 Setup 9Router`
  - `03 Koneksi Hermes (hc.sh)`
  - `04 Buat Bot Telegram`
  - `05 Integrasi Bot (ht.sh)`
  - `06 Forum Group & Topics`

### 🖥️ SLIDE 9 — Step 01: Scan QR Repository & One-Liner Installer (`Template Slide 11` + `9.1` & `9.2`)
- **Left QR Code**: [`assets/9.1.qr-github-repo-gdg.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/9.1.qr-github-repo-gdg.png) (QR Code menuju `https://github.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket` dengan logo [`assets/9.2.logo-gdg-transparent.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/9.2.logo-gdg-transparent.png) di tengah).
- **Left Title (`46pt Bold #FFFFFF`)**: `Scan QR & Copy Perintah`
- **Right 3 Platform Installer Blocks (Tanpa `CLI`)**:
  1. **`APK` — 1. Untuk Termux (Smartphone Android)**: `curl -fsSL .../mobile.sh | bash` (dijalankan di aplikasi Termux Google Play Store)
  2. **`SH` — 2. Untuk Linux & macOS**: `curl -fsSL .../laptop.sh | bash` (dijalankan di Terminal Laptop, Restart: `./laptop.sh`)
  3. **`WIN` — 3. Untuk Windows**: `irm .../laptop.ps1 | iex` (dijalankan di PowerShell Windows, atau `laptop.bat` di CMD)

### 🖥️ SLIDE 10 — Step 02: Tutorial Murni Setup 9Router (`Template Slide 8`)
- **Left Title (`62pt Bold #FFFFFF`)**: `Tutorial Setup 9Router`
- **4 Steps (`01` – `04`)**:
  - `01 Buka Dashboard 9Router (:20128)`: `Buka http://localhost:20128 di browser Anda, lalu login menggunakan password default: 123456.`
  - `02 Set Provider Google / Gemini`: `Buka menu Providers -> pilih Google / Gemini Studio -> tempel Gemini API Key dari Google AI Studio.`
  - `03 Buat Combo Model "gdg-yogya"`: `Buka menu Combos -> klik Create Combo -> beri nama persis gdg-yogya & pilih model Gemini Anda.`
  - `04 Generate API Key 9Router (9r-...)`: `Buka menu API Keys -> klik Generate API Key -> salin key berawalan 9r-... untuk Hermes Agent.`

### 🖥️ SLIDE 11 — Step 03 & 04: Menghubungkan Hermes ke 9Router & Telegram (`Template Slide 9`)
- **Heading (`56pt Bold #FFFFFF`)**: `Menghubungkan Hermes ke 9Router & Telegram`
- **5 Cards**: `STEP 3A JALANKAN HC.SH`, `STEP 3B UJI WEB UI (:9119)`, `STEP 4A BOTFATHER APP`, `STEP 4B USER ID WHITELIST`, `STEP 4C JALANKAN HT.SH`.

### 🖥️ SLIDE 12 — Visual Step 4A: Membuat Bot Baru di `@BotFather` Mini App (`Template Slide 6`)
- Gambar: `12.1.botfather-buka-mini-app.png`, `12.2.botfather-isi-nama-dan-username-bot.png`, `12.3.botfather-salin-api-token.png`.

### 🖥️ SLIDE 13 — Visual Step 4B: Amankan Bot dengan User ID & Aktifkan `ht.sh` (`Template Slide 6`)
- Gambar: `13.1.cari-bot-userinfobot.png`, `13.2.salin-telegram-user-id.png`, `13.3.cari-bot-hermes-di-telegram.png`.

### 🖥️ SLIDE 14 — Visual Step 4C & 5A: Tes Respons Pertama & Buat Grup Baru (`Template Slide 6`)
- Gambar: `14.1.tes-chat-dm-pertama-bot.png`, `14.2.pilih-menu-new-group.png`, `14.3.undang-bot-ke-grup-baru.png`.

### 🖥️ SLIDE 15 — Step 05: Organisasi AI dengan Telegram Topics (`Template Slide 10`)
- **Heading (`52pt Bold #FFFFFF`, lebar `12.2"` tidak menabrak logo DevFest)**: `Organisasi AI dengan Telegram Topics`
- **Subtitle (`24pt Bold #55C182`)**: `Pisahkan konteks obrolan AI Anda ke dalam 4 topik: #Learning, #Research, #Daily-Planner, dan #Coding menggunakan fitur Forum Topics.`
- **3 Horizontal Cards**: `1. Buat Grup & Bot`, `2. Admin & Topics`, `3. Set Home & 4 Topik (#Learning, #Research, #Daily-Planner, #Coding)`.

### 🖥️ SLIDE 16 — Visual Step 5B: Membuat Grup & Membuka Pengaturan Grup (`Template Slide 6`)
- Gambar: `16.1.beri-nama-dan-create-grup.png`, `16.2.buka-info-dan-edit-grup.png`, `16.3.pilih-menu-administrators-grup.png`.

### 🖥️ SLIDE 17 — Visual Step 5C: Promosikan Bot Jadi Admin & Aktifkan Topics (`Template Slide 6`)
- Gambar: `17.1.jadikan-bot-admin-grup.png`, `17.2.tes-chat-grup-dan-sethome.png`, `17.3.aktifkan-toggle-enable-topics.png`.

### 🖥️ SLIDE 18 — Visual Step 5D: Buat Ruang Topik Produktif & Mulai Berkolaborasi! (`Template Slide 6`)
- Gambar: `18.1.pilih-menu-new-topic.png`, `18.2.buat-topik-home-dan-pilih-ikon.png`, `18.3.chat-aktif-di-topik-general.png`.

### 🖥️ SLIDE 19 — Penutup, Selamat & Q&A (`Template Slide 12` + `9.1`)
- **Heading (`78pt Bold #FFFFFF`)**: `AI Anda Sudah Hidup di Saku!`
- **Subtitle & QR Code**: Menampilkan link repositori, profil LinkedIn & IG `@jefripunza`, serta QR Code [`assets/9.1.qr-github-repo-gdg.png`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/assets/9.1.qr-github-repo-gdg.png) di sisi kanan.
