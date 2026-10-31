# GDG Yogya 2026 - Workshop AI Hermes on Pocket

Workspace riset dan pengembangan (RnD) untuk menjalankan environment Termux via Docker container.

## 📁 Struktur File

- [`Dockerfile`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/Dockerfile) : Definisi image berbasis `termux/termux-docker`.
- [`restart.sh`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/restart.sh) : Script otomatis untuk menghentikan container lama, build ulang image, dan menjalankan container baru.
- [`setup-packages.sh`](file:///Users/jefripunza/Documents/Projects/gdg-yogya-2026-workshop-ai-hermes-on-pocket/setup-packages.sh) : Script untuk menginstal paket-paket dasar RnD (`python`, `build-essential`, `git`, dll.) ke dalam container yang aktif.
- `workspace/` : Folder lokal di host yang di-mount ke dalam container (`/data/data/com.termux/files/home/workspace`) agar hasil pekerjaan/kode tidak hilang saat container dihapus.

---

## 💡 Mengapa `pkg` tidak diinstal di dalam `Dockerfile`?

Termux secara arsitektural memblokir perintah `pkg` dan `apt` saat dijalankan sebagai `root` (`Error: Cannot run 'pkg' command as root`) untuk mencegah kerusakan hak akses file pada `$PREFIX`. 

Selain itu, DNS resolver bawaan Termux (`dnsmasq`) baru diaktifkan oleh `/entrypoint.sh` saat container dimulai (`docker run`), bukan pada proses `docker build`. Oleh karena itu, instalasi paket dilakukan di dalam container yang sudah aktif melalui `/entrypoint.sh`.

---

## 🚀 Cara Menjalankan

### 1. Jalankan Container (Background Mode)
```bash
./restart.sh
```

### 2. Jalankan Container + Otomatis Instal Paket RnD
```bash
./restart.sh --setup
# atau: ./restart.sh -s
```

### 3. Masuk ke Terminal Container yang Sedang Aktif
- **Sebagai User Termux (Direkomendasikan untuk `pkg` & pengembangan):**
  ```bash
  docker exec -it termux-rnd /entrypoint.sh login
  ```
- **Sebagai Root (Jika diperlukan):**
  ```bash
  docker exec -it termux-rnd /entrypoint_root.sh login
  ```

### 4. Instalasi Paket Tambahan
- Melalui script otomatis:
  ```bash
  ./setup-packages.sh
  ```
- Atau langsung dari terminal host:
  ```bash
  docker exec -it termux-rnd /entrypoint.sh pkg install <nama-paket>
  ```
- Atau dari dalam shell Termux:
  ```bash
  pkg install <nama-paket>
  ```
