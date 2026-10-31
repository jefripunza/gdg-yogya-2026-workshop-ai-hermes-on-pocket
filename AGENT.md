# 🧠 AGENT INSTRUCTIONS & ARCHITECTURE BRAIN

Dokumen ini adalah **Memory & Invariant Guide** bagi AI Agent / pengembang yang bekerja pada repositori `gdg-yogya-2026-workshop-ai-hermes-on-pocket`.

> **PENTING UNTUK AGENT**:
> 1. Baca dokumen ini sebelum melakukan perubahan arsitektur atau scripting.
> 2. Jaga pemisahan konteks: **Peserta Workshop** (Termux Android fisik) vs **RnD Simulator** (Docker di macOS/Linux).
> 3. Setiap kali menyelesaikan task baru, **wajib perbarui `TODO.md`**.

---

## 🎯 Gambaran Proyek

Repositori ini dibuat untuk kebutuhan Workshop **GDG Yogya 2026: AI Hermes on Pocket**. Tujuannya adalah menjalankan asisten AI mandiri (**Hermes Agent** dari Nous Research) dan gateway proxy LLM (**9Router**) langsung di dalam saku (smartphone Android) menggunakan **Termux**, ditenagai oleh **Google Gemini API**, dan dapat diajak berinteraksi kapan saja via **Telegram** (lengkap dengan fitur **Topics**).

---

## 🏗️ Peta Arsitektur File

| File | Target Environment | Fungsi Utama |
|---|---|---|
| `mobile.sh` | **Android Termux** | Script one-click installer otomatis yang dijalankan peserta workshop via `curl ... \| bash`. |
| `hc.sh` | **Android Termux** | Script konfigurasi Hermes (`./hc.sh <combo> <api-key>`) untuk menghubungkan Hermes ke 9Router lokal (`:20128/v1`). |
| `ht.sh` | **Android Termux** | Script integrasi Telegram (`./ht.sh <token> [userid]`) untuk mengaktifkan bot Hermes di Telegram. |
| `restart.sh` | **Host Docker (RnD)** | Script reset container Docker `termux-rnd` di macOS/Linux dengan port forwarding lengkap. |
| `install.sh` | **Host Docker (RnD)** | Script pengujian lokal: menyalin script ke container dan menjalankan `mobile.sh --local`. |
| `Dockerfile` | **Host Docker (RnD)** | Base image Termux container (`termux/termux-docker:latest`). |
| `README.md` | **Publik / Peserta** | Panduan ramah pemula untuk peserta workshop (100% bebas dari istilah Docker RnD). |
| `TODO.md` | **Kontributor / Agent** | Catatan task yang sudah selesai dan daftar rencana backlog. |
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
- Antarmuka web UI membutuhkan perintah: `hermes dashboard`.
- **Pre-build Step**: Pada kali pertama dijalankan, Hermes membangun aset web (`npm/node-deps` + build) yang memakan waktu ~15-20 detik. Pre-build harus dipicu saat instalasi di `mobile.sh`, dan sesi background harian harus memakai flag `--skip-build`.

### 6. Kebijakan Keamanan Hermes Dashboard & Solusi Socat Relay
- Hermes dashboard menolak di-bind ke non-loopback `0.0.0.0` jika belum ada auth provider external (OAuth/Nous Portal).
- Di Linux, proses tidak bisa membinding `0.0.0.0:9119` jika port `127.0.0.1:9119` sudah terisi oleh proses lain (`Address already in use`).
- **Arsitektur Relay yang Benar**:
  1. Hermes dashboard di-bind ke loopback port internal: `127.0.0.1:9118`.
  2. `socat` di-bind ke `0.0.0.0:9119` meneruskan koneksi ke `127.0.0.1:9118`.
  3. Dengan pemisahan port ini, baik browser di HP (`localhost:9119`) maupun browser di Docker host (`localhost:9119`) dapat mengakses dashboard dengan lancar.

---

## 🔄 Alur Kerja Pemeliharaan & Testing

1. **Pengujian Lokal (RnD)**:
   ```bash
   ./install.sh
   ```
2. **Validasi Port**:
   - `http://localhost:20128` -> 9Router Dashboard (Password: `123456`)
   - `http://localhost:9119` -> Hermes Web Dashboard
3. **Validasi Sintaks Script**:
   ```bash
   bash -n mobile.sh && bash -n hc.sh && bash -n ht.sh && bash -n install.sh && bash -n restart.sh
   ```
4. **Pembaruan Task**:
   - Setelah selesai mengimplementasikan fitur atau perbaikan bug, perbarui checklist dan riwayat di `TODO.md`.

