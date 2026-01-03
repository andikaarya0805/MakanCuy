# MakanCuy 🍔🔥

> **Skip drama _'terserah mau makan apa'_. Di sini menunya enak semua, no debat. Lo tinggal klik, bayar, perut aman, idup tentram.** ✨

**MakanCuy** adalah aplikasi pemesanan makanan berbasis web (Java Web) dengan desain **Gen Z / Acid Green** yang modern, _dark mode_, dan responsif. Dibangun untuk memudahkan mahasiswa memesan makanan dengan pengalaman yang cepat, interaktif, dan transparan.

---

## 🚀 Fitur Unggulan

### 👤 User (Pelanggan)
* **Gen Z UI/UX:** Tampilan _Dark Mode_ dengan aksen _Acid Green_, font _Space Grotesk_, dan animasi halus.
* **📱 Mobile Adaptive:** Tampilan responsif (Grid menyesuaikan) + Hamburger Menu untuk akses mudah di HP.
* **⚡ Real-time Notifications:** Status pesanan update otomatis (Polling 5 detik) dengan _Toast Popup_ ala aplikasi native (Dimasak/Diantar/Selesai).
* **🛒 Smart Cart:** Keranjang belanja interaktif tanpa reload halaman.
* **📜 Riwayat Transaksi:** Cek status dan histori jajan dengan detail UI yang rapi.

### 🛡️ Admin (Dashboard)
* **📊 Dashboard Analytics:** Grafik penjualan _real-time_ menggunakan **Chart.js**.
* **📄 Export Laporan Pro:** Download laporan transaksi ke **PDF** (Rapi, Auto-Total) dan **Excel** (Data mentah via SheetJS).
* **⚡ Kelola Pesanan:** Update status pesanan (Proses, Antar, Selesai, Tolak) dengan modal konfirmasi.
* **🍔 Manajemen Menu:** Tambah dan Hapus menu dengan mudah.

---

## 🛠️ Tech Stack

Project ini dibangun dengan teknologi yang _solid_ dan _lightweight_:

* **Backend:** Java Servlet, JSP (JavaServer Pages), MVC Architecture.
* **Database:** MySQL (JDBC).
* **Frontend:** HTML5, CSS3 (Custom Variables), JavaScript (Vanilla ES6).
* **Libraries:**
    * `Gson` (JSON API Response)
    * `JSTL` (JSP Tag Library)
    * `Chart.js` (Visualisasi Data)
    * `jspdf` & `jspdf-autotable` (PDF Reporting)
    * `SheetJS / xlsx` (Excel Export)
* **Deployment:** Railway / Tomcat Server.

---

---

## ⚙️ Cara Install & Jalankan (Localhost)

1.  **Clone Repository**
    ```bash
    git clone [https://github.com/andikaarya0805/MakanCuy.git](https://github.com/andikaarya0805/MakanCuy.git)
    ```

2.  **Setup Database**
    * Buat database baru di phpMyAdmin bernama `db_makancuy` (atau sesuaikan dengan `DBConnection.java`).
    * Import file `db_makancuy.sql` (jika ada) atau buat tabel `users`, `menu`, `orders`, `order_items`.

3.  **Buka di NetBeans / IDE**
    * Open Project -> Pilih folder `MakanCuy`.
    * Pastikan Library (MySQL JDBC, Gson, JSTL) sudah ter-load.

4.  **Clean & Build**
    * Klik kanan project -> **Clean and Build**.

5.  **Run**
    * Klik **Run** (Tombol Hijau). Server Tomcat akan berjalan.
    * Buka browser: `http://localhost:8080/MakanCuy`

---

## 📂 Struktur Folder Penting
