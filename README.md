# GDG Yogya 2026: Workshop AI Hermes on Pocket

Selamat datang di workshop **AI Hermes on Pocket**! Di sini, Anda akan belajar cara membangun asisten AI mandiri (**Hermes Agent**) yang berjalan langsung di dalam saku (smartphone Android) Anda menggunakan **Termux**, ditenagai oleh **Google Gemini API** melalui **9Router**, dan dapat diajak berinteraksi kapan saja melalui **Telegram** lengkap dengan fitur **Topics (Forum)**.

---

## 🎯 Gambaran Cara Kerja Sistem

Berikut adalah alur bagaimana pesan Anda diproses oleh AI langsung dari smartphone Anda:

```mermaid
flowchart TD
    User["📱 Pengguna di Telegram"] -->|Kirim Pesan ke Topik| TG["🤖 Telegram Bot (@BotFather)"]
    TG -->|Meneruskan Pesan| HG["⚡ Hermes Agent Gateway (Termux di HP)"]
    HG -->|Routing Model| NR["🔄 9Router Local Proxy (:20128)"]
    NR -->|Request LLM| GEMINI["✨ Google Gemini API"]
    GEMINI -->|Hasil Jawaban AI| NR
    NR -->|Kirim Respon| HG
    HG -->|Kirim Jawaban ke Chat| TG
    TG -->|Tampil di Topik Grup| User
```

---

## 📋 Persiapan Sebelum Mulai

Pastikan Anda telah menyiapkan hal-hal berikut di smartphone Anda:

1. **Aplikasi Termux**: Unduh dan pasang dari [F-Droid](https://f-droid.org/en/packages/com.termux/) (Disarankan: jangan gunakan versi Google Play Store karena sudah tidak diperbarui).
2. **Koneksi Internet**: Diperlukan untuk mengunduh paket dan mengakses API.
3. **Google Gemini API Key**: Dapatkan API Key gratis di [Google AI Studio](https://aistudio.google.com/).
4. **Akun Telegram**: Untuk membuat Bot dan ruang obrolan asisten AI Anda.

---

## 🚀 Panduan Langkah demi Langkah

### Langkah 1: Instalasi Sekali Jalan (`mobile.sh`)

Buka aplikasi **Termux** di smartphone Anda, lalu cukup salin dan jalankan perintah satu baris (one-liner) berikut:

```bash
curl -fsSL https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master/mobile.sh | bash
```

> **Apa yang dilakukan oleh script ini secara otomatis?**
> - Mengaktifkan izin wakelock (`termux-wake-lock`) secara otomatis agar proses tetap berjalan di background saat layar mati.
> - Menginstal paket dasar Termux dan Node.js versi terbaru.
> - Mengunduh dan memasang **Hermes Agent** (Nous Research).
> - Menginstal **9Router** secara global via npm.
> - Mengunduh script helper konfigurasi (**`hc.sh`** dan **`ht.sh`**) langsung ke direktori home Termux Anda.
> - Mengaktifkan fitur **Auto-Start**: Setiap kali Termux dibuka kembali, 9Router dan Hermes Gateway akan otomatis menyala di background tanpa terjadi proses ganda (anti-duplikasi).

---

### Langkah 2: Konfigurasi 9Router & Gemini API

Setelah script selesai berjalan:

1. Buka browser di smartphone Anda (Chrome / Firefox).
2. Buka alamat: **`http://localhost:20128`**
   - Masukkan password default: **`123456`**
3. Masuk ke menu **Providers**:
   - Pilih provider **Google / Gemini**.
   - Masukkan **Gemini API Key** yang sudah Anda dapatkan dari Google AI Studio.
4. Masuk ke menu **Combos**:
   - Klik **Create Combo**.
   - Beri nama combo: `gdg-yogya`
   - Pilih model (contoh: `gemini-2.0-flash` atau `gemini-1.5-pro`).
   - Simpan combo.
5. Masuk ke menu **API Keys**:
   - Klik **Generate API Key**.
   - Salin (copy) API Key yang muncul (dimulai dengan `9r-...`).

---

### Langkah 3: Hubungkan Hermes ke 9Router (`hc.sh`)

Kembali ke aplikasi **Termux**, lalu jalankan script konfigurasi Hermes:

```bash
./hc.sh gdg-yogya <paste-api-key-9router-anda>
```

*Contoh:*
```bash
./hc.sh gdg-yogya 9r-abc123xyz789
```

> Script ini secara otomatis mengonfigurasi Hermes agar berkomunikasi dengan 9Router lokal dan merestart Hermes Gateway dengan setelan baru.

#### 🧪 Uji Coba Chat Pertama:
Buka browser HP Anda ke alamat **`http://localhost:9119`** untuk membuka antarmuka web Hermes. Coba kirimkan pesan sapaan seperti *"Halo Hermes, perkenalkan dirimu!"* untuk memastikan AI sudah merespon dengan baik.

---

### Langkah 4: Integrasikan ke Telegram (`ht.sh`)

Sekarang saatnya menghubungkan AI Anda ke Telegram agar bisa diakses kapan saja:

1. Buka aplikasi **Telegram**, cari akun resmi **`@BotFather`**.
2. Ketik perintah: `/newbot`
3. Beri nama bot Anda (misal: `My Pocket Hermes`) dan username bot yang berakhiran `bot` (misal: `hermes_pocket_bot`).
4. `@BotFather` akan memberikan **HTTP API Token** (format: `123456789:ABCdefGHIjklMNOpqrSTUvwxYZ`). Salin token tersebut.
5. Kembali ke **Termux**, lalu jalankan script integrasi Telegram:

```bash
./ht.sh <paste-token-telegram-anda>
```

> **Tips Keamanan (Opsional):** Script akan menanyakan User ID Telegram Anda untuk whitelist. Anda bisa mengecek User ID Anda di Telegram lewat bot `@userinfobot`. Jika tidak ingin dibatasi, tekan `[Enter]`.

---

### Langkah 5: Buat Forum Group Telegram dengan Topik Produktif

Agar asisten AI Anda semakin rapi dan terorganisir:

1. Di Telegram, **Buat Grup Baru** (misal: *"Hermes Pocket Lab"*).
2. Masukkan bot Telegram Anda ke dalam grup tersebut dan **Jadikan sebagai Admin** (Wajib agar bot memiliki izin membaca pesan di dalam grup).
   > **Catatan Penting untuk Grup**:
   > - Secara bawaan Telegram, bot hanya bisa membaca pesan di grup jika dijadikan **Admin**, atau jika Anda memanggilnya dengan **mention** (`@nama_bot pesan`), atau jika Anda me-reply pesan bot.
   > - Agar bot bisa merespons semua pesan di grup tanpa perlu dijadikan Admin atau di-mention: buka `@BotFather` -> ketik `/setprivacy` -> pilih bot Anda -> pilih **`Disable`**.
3. Buka **Info Grup** -> pilih **Edit (ikon pensil)** -> aktifkan menu **Topics** (Forum).
4. Buat topik-topik produktif sesuai kebutuhan Anda, contohnya:
   - **`#General`** : Diskusi santai, tanya jawab umum, dan ide cepat.
   - **`#Coding-Helper`** : Konsultasi arsitektur kode, debugging, dan pembuatan fungsi.
   - **`#Research`** : Ringkasan materi, analisis paper, dan eksplorasi konsep.
   - **`#Daily-Planner`** : Perencanaan jadwal harian, to-do list, dan refleksi tugas.

Kini Anda dapat berdiskusi di setiap topik secara terpisah, dan Hermes akan menjawab sesuai konteks topik tersebut!

---

## 🎉 Selamat!

Anda telah berhasil membangun **AI Assistant pribadi** yang hidup langsung di dalam saku smartphone Anda. AI ini selalu siap membantu Anda kapan pun dan di mana pun tanpa bergantung pada langganan server pihak ketiga!

---

## 💻 Alternatif Laptop / Non-Android (Docker Compose)

Bagi rekan-rekan peserta workshop yang **tidak menggunakan smartphone Android** (misalnya pengguna iPhone / iOS, atau yang ingin langsung mencoba di laptop Windows, macOS, atau Linux), Anda tetap dapat mengikuti seluruh materi workshop menggunakan **Docker Compose**.

Kita akan menggunakan image Docker resmi berikut:
- 🔄 **9Router**: [`decolua/9router`](https://hub.docker.com/r/decolua/9router) (LLM Proxy & Gateway)
- ⚡ **Hermes Agent**: [`nousresearch/hermes-agent`](https://hub.docker.com/r/nousresearch/hermes-agent) (Autonomous AI Agent)

---

### Langkah 1: Jalankan Docker Compose di Laptop

Pastikan aplikasi **Docker Desktop** (atau Docker Engine) sudah aktif di laptop Anda. 

Jika Anda telah meng-clone repository ini, cukup jalankan perintah:

```bash
docker compose up -d
```

*(Atau jika Anda belum meng-clone repository, cukup buat file bernama `docker-compose.yml` di laptop Anda dengan isi berikut lalu jalankan `docker compose up -d`):*

<details>
<summary><b>📄 Lihat isi docker-compose.yml</b></summary>

```yaml
services:
  9router:
    image: decolua/9router:latest
    container_name: 9router
    restart: unless-stopped
    ports:
      - "20128:20128"
    environment:
      - INITIAL_PASSWORD=123456
      - DATA_DIR=/app/data
      - HOST=0.0.0.0
      - PORT=20128
    volumes:
      - 9router_data:/app/data

  hermes:
    image: nousresearch/hermes-agent:latest
    container_name: hermes-agent
    restart: unless-stopped
    command: gateway run
    ports:
      - "9119:9119"
      - "8642:8642"
    environment:
      - HERMES_HOME=/opt/data
      - HERMES_DASHBOARD=1
      - HERMES_DASHBOARD_HOST=0.0.0.0
      - HERMES_DASHBOARD_PORT=9119
      - HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin
      - HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=123456
      - INITIAL_PASSWORD=123456
    volumes:
      - hermes_data:/opt/data
    depends_on:
      - 9router

volumes:
  9router_data:
  hermes_data:
```
</details>

---

### Langkah 2: Konfigurasi 9Router & Gemini API

1. Buka browser di laptop Anda: **`http://localhost:20128`**
2. Masukkan password awal: **`123456`**
3. Masuk ke menu **Providers** -> Masukkan **Gemini API Key** Anda.
4. Masuk ke menu **Combos** -> Buat combo bernama **`gdg-yogya`** (pilih model Gemini).
5. Masuk ke menu **API Keys** -> Klik **Generate API Key** dan salin API Key tersebut (berawalan `9r-...`).

---

### Langkah 3: Pasang Helper Script via `laptop.sh` (Exec Hermes)

Masuk ke dalam container `hermes-agent` dan jalankan script **`laptop.sh`** via `curl` untuk menempelkan (**paste**) script `hc.sh` dan `ht.sh` secara otomatis:

```bash
docker exec -it hermes-agent bash -c "curl -fsSL https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master/laptop.sh | bash"
```

*Atau jika Anda lebih suka masuk ke terminal interaktif container terlebih dahulu:*
```bash
docker exec -it hermes-agent bash
curl -fsSL https://raw.githubusercontent.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket/master/laptop.sh | bash
```

> **Apa yang dilakukan oleh script `laptop.sh`?**
> - Mengunduh dan menempelkan file **`hc.sh`** dan **`ht.sh`** langsung ke direktori kerja container.
> - Mengatur permission eksekusi (`chmod +x`).
> - Menyesuaikan konfigurasi jaringan container agar langsung mengenali service `9router`.

---

### Langkah 4: Hubungkan Hermes & Bot Telegram

Masuk ke dalam sesi bash container Hermes:

```bash
docker exec -it hermes-agent bash
```

Lalu jalankan langkah konfigurasi yang sama persis seperti di ponsel Android:

1. **Hubungkan Hermes ke 9Router (`hc.sh`)**:
   ```bash
   ./hc.sh gdg-yogya <paste-api-key-9router-anda>
   ```

2. **Hubungkan ke Bot Telegram (`ht.sh`)**:
   ```bash
   ./ht.sh <paste-token-telegram-anda>
   ```

3. **Buka Web UI Dashboard**:
   Buka browser laptop Anda ke **`http://localhost:9119`** (Masukkan Username: **`admin`** dan Password: **`123456`**) untuk berinteraksi langsung via Web Dashboard, atau buka aplikasi Telegram dan ajak bot Anda mengobrol!

---

## 💡 Troubleshooting & Tips Tambahan

- **Termux ditutup oleh sistem Android saat layar mati?**
  Pastikan baterai untuk aplikasi Termux diatur ke **"Unrestricted" / "Tidak Dibatasi"** pada setelan ponsel Anda, dan pastikan sudah menjalankan `termux-wake-lock`.
- **Melihat status service:**
  Layanan 9Router dan Hermes Gateway otomatis dicek dan dijalankan ulang setiap kali Termux dibuka. Anda bisa memantau log jika terjadi kendala:
  - Log 9Router: `cat ~/.9router/logs/9router.log`
  - Log Hermes Gateway: `cat ~/.hermes/logs/gateway.log`
- **Mengubah API Key / Model:**
  Cukup jalankan kembali `./hc.sh <nama-combo-baru> <api-key-baru>` kapan saja tanpa perlu mengulang dari awal.
