# 🩸 SiagaDarah – Platform Darurat Donor Darah

**SiagaDarah** adalah aplikasi mobile berbasis Flutter & Firebase yang dirancang untuk memfasilitasi koneksi cepat antara pencari darah dan pendonor dalam situasi darurat. Dibangun untuk mempercepat tindakan kemanusiaan dengan teknologi modern.

---

## 🚨 Fitur Utama

### 🔍 Pencari Darah
- Kirim permintaan darah berdasarkan golongan & lokasi
- Lihat pendonor aktif yang siap membantu
- Notifikasi real-time saat pendonor merespons

### 🦸‍♂️ Pendonor
- Aktifkan **Mode Siaga** untuk menjadi pendonor aktif
- Terima permintaan darah dari sekitar Anda
- Kirim lokasi & konfirmasi kehadiran

### 🛠 Admin
- Tambah & kelola event donor darah
- Unggah dan edit konten edukasi
- Verifikasi dan monitoring aktivitas pengguna

---

## 🧰 Teknologi

| Teknologi              | Fungsi                                         |
|------------------------|-----------------------------------------------|
| **Flutter**            | UI/UX dan pengembangan aplikasi mobile        |
| **Firebase Auth**      | Login dengan Email & Google                   |
| **Cloud Firestore**    | Penyimpanan data pengguna, permintaan, event |
| **Firebase Messaging** | Kirim notifikasi ke pendonor & pencari        |
| **Google Maps API**    | Lokasi pengguna & pelacakan real-time         |

---

## 🧭 Alur Navigasi

```mermaid
flowchart TD
  Splash --> AuthCheck
  AuthCheck -->|Login| MainApp
  AuthCheck -->|Belum Login| LoginPage
  MainApp -->|Pencari| PencariHome
  MainApp -->|Pendonor| PendonorHome
  MainApp -->|Admin| AdminDashboard
