# 🤝 Panduan Kontribusi (Contributing Guidelines)

Terima kasih telah meluangkan waktu untuk berkontribusi pada proyek **GDG Yogya 2026: Workshop AI Hermes on Pocket**! 

Repositori ini bersifat **open-source**, dan kami sangat menyambut kontribusi dari siapa saja—baik mentor, peserta workshop, maupun komunitas developer yang tertarik pada implementasi AI on-device di Android.

---

## 🌟 Cara Anda Dapat Berkontribusi

Anda dapat berkontribusi dalam berbagai bentuk:
1. **Melaporkan Masalah (Bug Reports)**: Menemukan URL repo yang mati, dependensi Termux yang usang, atau service yang gagal start.
2. **Perbaikan Script**: Mengoptimalkan performa script shell, menangani edge-case Android, atau meningkatkan efisiensi penggunaan baterai/RAM.
3. **Penyempurnaan Dokumentasi**: Memperbaiki penjelasan di `README.md`, menambahkan diagram, atau memperjelas langkah-langkah bagi pemula.
4. **Pengujian Multi-Device**: Menguji script pada berbagai merek ponsel Android (Samsung OneUI, Xiaomi MIUI/HyperOS, Pixel, Oppo, dll.) dan membagikan hasilnya.

---

## 🛠️ Lingkungan Pengembangan & Testing

Anda dapat menguji perubahan Anda dengan dua cara:

### Cara 1: Menggunakan Simulasi Docker Termux (macOS / Linux Host)
Sangat direkomendasikan untuk pengembangan cepat di komputer tanpa perlu menyambungkan ponsel:

```bash
# 1. Clone repositori:
git clone https://github.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket.git
cd gdg-yogya-2026-workshop-ai-hermes-on-pocket

# 2. Reset dan jalankan simulator Termux Docker:
./restart.sh

# 3. Jalankan pengujian instalasi lokal:
./install.sh

# 4. Buka dashboard di browser untuk memverifikasi:
#    - 9Router : http://localhost:20128 (Password: 123456)
#    - Hermes  : http://localhost:9119
```

### Cara 2: Menguji Langsung di Smartphone Android
1. Buka aplikasi **Termux** di smartphone Anda.
2. Jalankan perintah git clone dan uji script lokal:
   ```bash
   git clone https://github.com/jefripunza/gdg-yogya-2026-workshop-ai-hermes-on-pocket.git
   cd gdg-yogya-2026-workshop-ai-hermes-on-pocket
   bash mobile.sh --local
   ```

---

## 📐 Standar Kode & Aturan Khusus Termux

Sebelum mengajukan Pull Request (PR), pastikan kode Anda mematuhi standar berikut:

1. **Shebang Termux**:
   - Ingat bahwa Termux **tidak memiliki** `/usr/bin/env` di kernel level.
   - Gunakan shebang: `#!/data/data/com.termux/files/usr/bin/bash`.
   - Jika membuat script yang dipanggil via npm, sertakan penanganan `termux-fix-shebang`.
2. **Validasi Sintaks Script**:
   Pastikan tidak ada kesalahan sintaksis bash sebelum commit:
   ```bash
   bash -n mobile.sh && bash -n hc.sh && bash -n ht.sh && bash -n install.sh && bash -n restart.sh
   ```
3. **Pemisahan Konteks `README.md`**:
   - `README.md` ditujukan khusus untuk **peserta workshop**. Jangan memasukkan perintah Docker host ke dalam `README.md`.
   - Detail teknis simulator Docker dan catatan arsitektur disimpan di `AGENT.md` dan `CONTRIBUTING.md`.
4. **Pembaruan `TODO.md`**:
   - Jika PR Anda menyelesaikan suatu task atau menambahkan kapabilitas baru, pastikan untuk memperbarui daftar checklist di `TODO.md`.

---

## 🚀 Alur Pengajuan Pull Request (PR)

1. **Fork** repositori ini ke akun GitHub Anda.
2. Buat branch baru dari branch `master`:
   ```bash
   git checkout -b feat/nama-fitur-baru
   # atau
   git checkout -b fix/deskripsi-perbaikan
   ```
3. Lakukan perubahan kode dan uji coba hingga berhasil.
4. Buat commit dengan format [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat: tambah dukungan multi-model fallback di 9Router`
   - `fix: perbaiki relay socat pada restart dashboard`
   - `docs: perjelas langkah integrasi telegram di README`
5. Push branch ke fork Anda:
   ```bash
   git push origin feat/nama-fitur-baru
   ```
6. Buka **Pull Request** di GitHub dengan menjelaskan:
   - Apa yang diubah?
   - Mengapa perubahan ini diperlukan?
   - Hasil pengujian (di perangkat Android apa atau simulator Docker).

---

## 💡 Ada Pertanyaan atau Butuh Diskusi?
Jika Anda memiliki pertanyaan arsitektur atau ingin mendiskusikan ide sebelum membuat kode, silakan buka **Issue** baru di GitHub dengan label `enhancement` atau `question`.

Selamat berkontribusi! 🎉
