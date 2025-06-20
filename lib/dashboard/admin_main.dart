import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_darah/dashboard/AdminDashboard.dart';
import 'package:siaga_darah/themes/theme.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

// GlobalKey untuk mengakses AdminMain
final GlobalKey<AdminMainState> menuScreenKey = GlobalKey<AdminMainState>();

class AdminMain extends StatefulWidget {
  final bool showSuccessMessage;
  final String successMessage;

  const AdminMain({
    Key? key,
    this.showSuccessMessage = false,
    this.successMessage = 'Selamat datang Admin!',
  }) : super(key: key);

  @override
  State<AdminMain> createState() => AdminMainState();
}

class AdminMainState extends State<AdminMain> {
  int indexMenu = 0;

  void setCategory(String category) {
    // contoh: simpan kategori, lalu navigasi/tab ke event
    print("Kategori dipilih: $category");
    setState(() {
      indexMenu = 1; // pindah ke tab Event
      // bisa tambahkan logic lanjut kalau perlu
    });
  }

  final List<Map<String, dynamic>> menu = [
    {
      'screen': const AdminDashboard(),
    },
    {
      'screen': const Center(
        child: Text(
          'Event',
          style: TextStyle(fontSize: 24),
        ),
      ),
    },
    {
      'iconActive': 'assets/images/icon/butuh-darah.png',
      'screen': const Center(
        child: Text(
          'Butuh Darah',
          style: TextStyle(fontSize: 24),
        ),
      ),
    },
    {
      'screen': const Center(
        child: Text(
          'Riwayat',
          style: TextStyle(fontSize: 24),
        ),
      ),
    },
    {
      // 'screen': const ProfileScreen(),
      'screen': const Center(
        child: Text(
          'Profil',
          style: TextStyle(fontSize: 24),
        ),
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.showSuccessMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(widget.successMessage, isError: false);
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    Flushbar(
      messageText: Text(
        message,
        style: GoogleFonts.quicksand(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      duration: Duration(seconds: isError ? 4 : 2),
      flushbarPosition: FlushbarPosition.TOP,
      icon: Icon(
        isError ? Icons.error : Icons.check_circle,
        color: Colors.white,
      ),
    ).show(context);
  }

  /// Untuk pindah tab (misalnya dari tombol "Semua")
  void switchToMenuTab(String category) {
    setState(() {
      indexMenu = 1;
    });
    menuScreenKey.currentState?.setCategory(category);
  }

  /// Untuk pindah tab biasa (misalnya saat klik alamat)
  void switchToTab(int index) {
    setState(() {
      indexMenu = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: menu[indexMenu]['screen'],
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: Container(
        height: 70,
        child: StylishBottomBar(
          option: AnimatedBarOptions(
            iconStyle: IconStyle.animated,
            barAnimation: BarAnimation.fade,
            iconSize: 26,
            opacity: 0.2,
          ),
          currentIndex: indexMenu,
          onTap: (index) {
            setState(() {
              indexMenu = index;
            });
          },
          items: [
            BottomBarItem(
              icon: Image.asset('assets/images/icon/beranda-secondary.png',
                  width: 26),
              selectedIcon: Image.asset(
                  'assets/images/icon/beranda-primary.png',
                  width: 26),
              title:
                  Text('Dashboard', style: GoogleFonts.poppins(fontSize: 10)),
              backgroundColor: AppColors.primary,
            ),
            BottomBarItem(
              icon: Image.asset('assets/images/icon/blood-secondary.png',
                  width: 26),
              selectedIcon: Image.asset('assets/images/icon/blood-primary.png',
                  width: 26),
              title:
                  Text('Permintaan', style: GoogleFonts.poppins(fontSize: 10)),
              backgroundColor: AppColors.primary,
            ),
            BottomBarItem(
              icon: Image.asset('assets/images/icon/profil-secondary.png',
                  width: 30),
              selectedIcon: Image.asset('assets/images/icon/profil-primary.png',
                  width: 30),
              title: Text('Pengguna', style: GoogleFonts.poppins(fontSize: 10)),
              backgroundColor: AppColors.primary,
            ),
            BottomBarItem(
              icon: Image.asset('assets/images/icon/konten-secondary.png',
                  width: 26),
              selectedIcon: Image.asset('assets/images/icon/konten-primary.png',
                  width: 26),
              title: Text('Konten', style: GoogleFonts.poppins(fontSize: 10)),
              backgroundColor: AppColors.primary,
            ),
            BottomBarItem(
              icon: Image.asset('assets/images/icon/settings-secondary.png',
                  width: 26),
              selectedIcon: Image.asset(
                  'assets/images/icon/settings-primary.png',
                  width: 26),
              title:
                  Text('Pengaturan', style: GoogleFonts.poppins(fontSize: 10)),
              backgroundColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
