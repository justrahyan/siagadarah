import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_darah/themes/colors.dart'; // Pastikan path ini benar

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    const double navbarHeight = 60.0;

    // Definisikan daftar item navigasi dengan pola iconActive/iconInactive
    final List<Map<String, dynamic>> navItems = [
      {
        'index': 0,
        'label': "Beranda",
        'iconActive': 'assets/images/beranda-primary.png',
        'iconInactive': 'assets/images/beranda-secondary.png',
      },
      {
        'index': 1,
        'label': "Event",
        'iconActive': 'assets/images/event-primary.png',
        'iconInactive': 'assets/images/event-secondary.png',
      },
      {
        'index': 2, // Item "Butuh Darah"
        'label': "Butuh\nDarah",
        // Anda bisa menentukan ikon khusus untuk ini, atau gunakan yang umum
        'iconActive':
            'assets/images/notifikasi.png', // Contoh: pakai ikon notifikasi
        'iconInactive':
            'assets/images/notifikasi.png', // Contoh: pakai ikon notifikasi
      },
      {
        'index': 3,
        'label': "Riwayat",
        'iconActive': 'assets/images/riwayat-primary.png',
        'iconInactive': 'assets/images/riwayat-secondary.png',
      },
      {
        'index': 4,
        'label': "Profil",
        'iconActive': 'assets/images/profil-primary.png',
        'iconInactive': 'assets/images/profil-secondary.png',
      },
    ];

    return Container(
      height: navbarHeight + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: navItems.map((item) {
            final int index = item['index'] as int;
            final String label = item['label'] as String;
            final String iconActivePath = item['iconActive'] as String;
            final String iconInactivePath = item['iconInactive'] as String;

            final bool isSelected = index == currentIndex;
            final String finalIconPath =
                isSelected ? iconActivePath : iconInactivePath;

            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Pusatkan secara vertikal
                      children: [
                        Image.asset(
                          finalIconPath,
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback jika gambar tidak ditemukan
                            // Untuk item "Butuh Darah", kita bisa pakai Icons.bloodtype sebagai fallback
                            if (index == 2) {
                              return Icon(
                                Icons.bloodtype,
                                color: AppColors.primary,
                                size: 24,
                              );
                            }
                            return Icon(
                              Icons.error,
                              size: 24,
                              color: AppColors.paragraph,
                            );
                          },
                        ),
                        Padding(
                          // Label selalu ditampilkan agar posisi item sama
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize:
                                  10, // Ukuran font sedikit lebih kecil agar pas
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors
                                      .paragraph, // Gunakan primaryColor dari themes/colors.dart
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
