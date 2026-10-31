# GDG Yogya 2026 - Workshop AI Hermes on Pocket

Workspace riset dan pengembangan (RnD) untuk menjalankan environment Termux, **Hermes Agent**, dan **9Router** via Docker container maupun native device Android.

## 📁 Struktur File

- [`Dockerfile`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/Dockerfile) : Definisi image berbasis `termux/termux-docker`.
- [`restart.sh`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/restart.sh) : Script otomatis untuk menghentikan container lama, build ulang image, membuka port (`20128`, `8642`, `9119`, `8080`), dan menyalakan kembali container beserta background services.
- [`install.sh`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/install.sh) : Script di host machine untuk mengeksekusi instalasi lengkap Hermes Agent dan 9Router di dalam container Termux.
- [`mobile.sh`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/mobile.sh) : One-click installer yang menginstal Hermes Agent, Node.js terbaru, 9Router via npm, dan mengonfigurasi auto-start services tanpa duplikasi proses.
- [`setup-packages.sh`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/setup-packages.sh) : Script untuk menginstal paket-paket dasar RnD (`python`, `build-essential`, `git`, dll.).
- `workspace/` : Folder lokal di host yang di-mount ke dalam container (`/data/data/com.termux/files/home/workspace`) agar data/kode persisten.

---

## 🚀 Cara Menjalankan & Instalasi

### 1. Menjalankan Instalasi di Container
Jalankan perintah berikut di terminal Mac Anda:
```bash
./install.sh
```
Script ini akan:
1. Memastikan container `termux-rnd` aktif.
2. Menginstal **Hermes Agent** (Nous Research).
3. Menginstal **Node.js versi terbaru** (`pkg install nodejs`).
4. Menginstal **9Router** via npm (`npm install -g 9router`).
5. Mengonfigurasi script auto-start `~/.autostart_services.sh` di `~/.bashrc` agar **9Router** dan **Hermes Gateway** otomatis aktif setiap kali Termux dijalankan ulang tanpa dobel proses.

---

## 🌐 Endpoints & Layanan

Setelah instalasi atau saat container di-restart, layanan otomatis dapat diakses dari browser/client host:

| Layanan | Endpoint / URL | Deskripsi |
| :--- | :--- | :--- |
| **9Router Web Dashboard** | `http://localhost:20128` | Dashboard UI untuk mengelola multi-provider API keys |
| **9Router OpenAI Proxy** | `http://localhost:20128/v1` | Endpoint OpenAI-compatible untuk routing LLM |
| **Hermes Gateway API** | `http://localhost:8642` | Gateway API Hermes Agent |
| **Hermes Web Dashboard** | `http://localhost:9119` | Dashboard bawaan Hermes Agent |

---

## 🔄 Auto-Start & Pencegahan Dobel Proses

Service dijalankan dan dimonitor oleh `~/.autostart_services.sh`:
- Memeriksa apakah `9router` sudah aktif via `pgrep`. Jika sudah ada, proses tidak akan dijalankan ulang (idempotent).
- Memeriksa apakah `hermes gateway` sudah aktif via `pgrep`. Jika sudah ada, tidak akan dijalankan dobel.
- File log tersimpan di:
  - 9Router: `~/.9router/logs/9router.log`
  - Hermes Gateway: `~/.hermes/logs/gateway.log`

---

## 🛠️ Perintah Tambahan

- **Masuk ke Terminal Termux:**
  ```bash
  docker exec -it termux-rnd /entrypoint.sh login
  ```
- **Konfigurasi Hermes Agent (Wizard):**
  ```bash
  docker exec -it termux-rnd /entrypoint.sh hermes setup
  ```
- **Buka Hermes TUI interaktif:**
  ```bash
  docker exec -it termux-rnd /entrypoint.sh hermes --tui
  ```
- **Restart Container:**
  ```bash
  ./restart.sh
  ```
