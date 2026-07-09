# Agent Execution Protocol - Project Anti-Gravity (SmartKasir Module)

Dokumen ini berisi panduan langkah-langkah (step-by-step execution) untuk pengujian atau eksekusi otomatis oleh agen sistem pada modul manajemen produk dan transaksi kasir.

## Alur Utama Pengujian (Base Flow)

### 1. Penambahan Produk (Add Product)
* **Aksi 1:** Klik tombol **Pengaturan** yang terletak di pojok kanan atas layar utama.
* **Aksi 2:** Masuk ke menu **Produk**.
* **Aksi 3:** Klik ikon tambah (**+**) untuk membuka form tambah produk baru.
* **Aksi 4:** Isi semua data produk yang diperlukan (Nama, Harga, Stok, dll.).
* **Aksi 5 (Opsional):** Gunakan fitur **Scan Barcode via Kamera** untuk menginput kode barcode secara otomatis ke dalam form.
* **Aksi 6:** Simpan data produk dan pastikan produk berhasil terdaftar.

### 2. Proses Pemindaian di Menu Utama (Product Scanning)
* **Aksi 1:** Keluar dari menu pengaturan dan kembali ke **Menu Utama** aplikasi.
* **Aksi 2:** Aktifkan atau nyalakan fitur kamera pemindai pada halaman utama.
* **Aksi 3:** Lakukan pemindaian (**Scan Barcode**) pada produk yang telah ditambahkan sebelumnya, atau lakukan **Input Manual** kode produk jika kamera tidak digunakan.
* **Aksi 4:** Pastikan produk masuk ke dalam keranjang belanja (cart) dengan informasi yang sesuai.

### 3. Tinjauan dan Pembayaran (Checkout & Review)
* **Aksi 1:** Masuk ke halaman **Review Belanja** untuk memastikan daftar item dan total harga sudah benar.
* **Aksi 2:** Pilih **Metode Pembayaran** yang digunakan oleh pembeli (misal: Cash, QRIS).
* **Aksi 3 (Khusus Cash):** Jika metode pembayaran berupa *Cash*, masukkan jumlah nominal uang yang dibayarkan dan hitung nilai kembalian untuk pembeli.
* **Aksi 4:** Selesaikan transaksi dan cetak/simpan struk belanja jika diperlukan.

### 4. Tambah Pegawai (Add Employee)
* **Aksi 1:** Klik tombol **Pengaturan** yang terletak di pojok kanan atas layar utama.
* **Aksi 2:** Masuk ke menu **Pegawai**.
* **Aksi 3:** Klik ikon tambah (**+**) untuk membuka form tambah pegawai baru.
* **Aksi 4:** Isi semua data pegawai yang diperlukan (Nama, Username, No Telp, Password, Role, dll.).
* **Aksi 5:** Simpan data pegawai dan pastikan pegawai berhasil terdaftar.
* **Aksi 6:** Kembali ke menu pengaturan

### 5. Analitik
* **Aksi 1:** Masuk ke menu Analitik
* **Aksi 2:** Tampilkan penjelasan dari menu analitik

### 6. Koneksi ke Printer Thermal (Optional)
* **Aksi 1:** Klik tombol **Pengaturan** yang terletak di pojok kanan atas layar utama.
* **Aksi 2:** Masuk ke menu **Printer Struk**.
* **Aksi 3:** Klik ikon gear untuk membuka form tambah printer thermal baru.
* **Aksi 4:** Koneksikan dengan blueetooth dan pilih printer Anda.