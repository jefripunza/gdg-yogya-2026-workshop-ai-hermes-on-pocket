# syntax=docker/dockerfile:1
FROM termux/termux-docker:latest

# Atur working directory ke home directory Termux
WORKDIR /data/data/com.termux/files/home

# Environment variable standar Termux
ENV HOME=/data/data/com.termux/files/home
ENV PREFIX=/data/data/com.termux/files/usr
ENV PATH=/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets:$PATH

# Expose port untuk 9Router (20128), Hermes Dashboard (9119), Hermes Gateway API (8642), dan port umum (8080)
EXPOSE 20128 9119 8642 8080

# Catatan Penting:
# Di Termux, perintah `pkg` dan `apt` secara sengaja diblokir dari user `root`.
# Karena tahap build Dockerfile berjalan sebagai root tanpa entrypoint (tanpa dnsmasq & privilege drop),
# instalasi paket dilakukan setelah container berjalan melalui `/entrypoint.sh`.

# Default entrypoint & CMD dari termux-docker
# /entrypoint.sh bertugas menjalankan service DNS (dnsmasq) dan otomatis
# menurunkan privilege ke user standar Termux agar pkg/apt dapat berjalan normal.
ENTRYPOINT ["/entrypoint.sh"]
CMD ["login"]
