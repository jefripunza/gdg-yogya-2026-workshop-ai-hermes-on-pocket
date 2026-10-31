# GDG Yogya 2026 - Workshop AI Hermes on Pocket

Workspace riset dan pengembangan (RnD) untuk menjalankan environment Termux dan **Hermes Agent** via Docker container maupun native device Android.

## 📁 Struktur File

- [`Dockerfile`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/Dockerfile) : Definisi image berbasis `termux/termux-docker`.
- [`restart.sh`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/restart.sh) : Script otomatis untuk menghentikan container lama, build ulang image, dan menjalankan container baru.
- [`install.sh`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/install.sh) : Script di host machine untuk mengeksekusi instalasi Hermes Agent (`mobile.sh`) di dalam container Termux.
- [`mobile.sh`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/mobile.sh) : Script sekali jalan (one-click installer) untuk menginstal Hermes Agent sesuai tutorial resmi Termux Nous Research. Dapat dijalankan langsung di container atau di aplikasi Termux HP Android.
- [`setup-packages.sh`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/setup-packages.sh) : Script untuk menginstal paket-paket dasar RnD (`python`, `build-essential`, `git`, dll.).
- `workspace/` : Folder lokal di host yang di-mount ke dalam container (`/data/data/com.termux/files/home/workspace`) agar data/kode persisten.

---

## 🤖 Instalasi & Penggunaan Hermes Agent

Tutorial Resmi: [Nous Research - Termux Guide](https://github.com/nousresearch/hermes-agent/blob/main/website/docs/getting-started/termux.md)

### A. Menjalankan di Docker Container (Host Mac / PC)

1. **Jalankan installer ke dalam container:**
   ```bash
   ./install.sh
   ```
   *(Script ini otomatis memastikan container aktif, menyalin `mobile.sh`, dan menjalankan instalasi).*

2. **Setup LLM Provider / API Keys:**
   ```bash
   docker exec -it termux-rnd /entrypoint.sh hermes setup
   ```

3. **Buka antarmuka interaktif Hermes TUI:**
   ```bash
   docker exec -it termux-rnd /entrypoint.sh hermes --tui
   ```

---

### B. Menjalankan Langsung di HP Android (Native Termux)

Salin file `mobile.sh` ke perangkat Android Anda atau jalankan langsung di aplikasi Termux:

```bash
bash mobile.sh
```

Setelah instalasi selesai:
```bash
hermes setup
hermes --tui
```

---

## 🛠️ Manajemen Container Termux

- **Start / Restart Container:**
  ```bash
  ./restart.sh
  ```
- **Masuk ke Shell Termux (User standar):**
  ```bash
  docker exec -it termux-rnd /entrypoint.sh login
  ```
- **Cek Log Container:**
  ```bash
  docker logs -f termux-rnd
  ```
