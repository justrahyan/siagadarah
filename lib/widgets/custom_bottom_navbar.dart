// File: lib/widgets/custom_bottom_navbar.dart

import 'package:flutter/material.dart';
// Asumsikan AppColors ada di sini atau diimpor dari tempat lain
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
    const double fabSize = 60.0;

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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Row(
              children: [
                _buildNavItem(0, Icons.home_outlined, "Beranda"),
                // Mengubah item "Donor" menjadi "Informasi" dengan ikon yang sesuai
                _buildNavItem(
                    1, Icons.info_outline, "Informasi"), // Ikon untuk informasi
                const SizedBox(width: fabSize + 20),
                _buildNavItem(3, Icons.history, "Riwayat"),
                _buildNavItem(
                    4, Icons.person_outline, "Profil"), // Teks "Profil"
              ],
            ),
          ),
          Positioned(
            top: -(fabSize / 2 + 10),
            left: MediaQuery.of(context).size.width / 2 - (fabSize / 2),
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
                      offset: const Offset(0, 2),
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
                        height: 0.9,
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
                    fontSize: 12,
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
