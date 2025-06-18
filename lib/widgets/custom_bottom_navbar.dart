// lib/widgets/custom_bottom_navbar.dart
import 'package:flutter/material.dart';

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
    // Menggunakan MediaQuery.of(context).padding.bottom untuk menyesuaikan dengan safe area
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double navbarHeight = 60.0; // Tinggi dasar navbar
    final double fabSize = 60.0; // Ukuran FAB

    return Container(
      // Tinggi total navbar, termasuk padding bawah untuk safe area
      height: navbarHeight + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        // Penting: Memungkinkan widget anak melampaui batas Stack
        clipBehavior: Clip.none,
        children: [
          // Row untuk item navigasi utama
          Padding(
            padding: EdgeInsets.only(
                bottom: bottomPadding), // Padding bawah untuk safe area
            child: Row(
              children: [
                _buildNavItem(0, Icons.home_outlined, "Beranda"),
                _buildNavItem(1, Icons.favorite_outline, "Donor"),
                // Placeholder untuk FAB di tengah
                SizedBox(
                    width:
                        fabSize + 20), // Memberikan ruang lebih dari ukuran FAB
                _buildNavItem(3, Icons.history, "Riwayat"),
                _buildNavItem(4, Icons.person_outline, "Profile"),
              ],
            ),
          ),

          // Floating Action Button (FAB)
          Positioned(
            // Posisikan FAB sedikit di atas navbar
            top: -(fabSize / 2 +
                10), // -30 (half FAB size) - 10 (extra lift) = -40
            left: MediaQuery.of(context).size.width / 2 -
                (fabSize / 2), // Pusatkan FAB
            child: GestureDetector(
              onTap: () => onTap(2), // Index 2 untuk aksi FAB "Butuh Darah"
              child: Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade200.withOpacity(0.5),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bloodtype,
                      color: Colors.white,
                      size: 20,
                    ),
                    Text(
                      'Butuh\nDarah',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height:
                            0.9, // Mengurangi tinggi baris untuk teks 2 baris
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = index == currentIndex;
    final Color iconColor =
        isSelected ? Colors.red.shade400 : Colors.grey.shade600;
    final FontWeight fontWeight =
        isSelected ? FontWeight.w600 : FontWeight.normal;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          // splashFactory: NoSplash.splashFactory, // Uncomment jika tidak ingin efek splash
          // highlightColor: Colors.transparent, // Uncomment jika tidak ingin efek highlight
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12, // Ukuran font yang sedikit lebih besar
                    fontWeight: fontWeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
