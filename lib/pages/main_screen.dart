import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_darah/pages/home_page.dart';
import 'package:siaga_darah/themes/theme.dart';
import 'ProfileScreen.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

// GlobalKey untuk mengakses MainScreen
final GlobalKey<MainScreenState> menuScreenKey = GlobalKey<MainScreenState>();

class MainScreen extends StatefulWidget {
  final bool showSuccessMessage;
  final String successMessage;

  const MainScreen({
    Key? key,
    this.showSuccessMessage = false,
    this.successMessage = 'Login berhasil!',
  }) : super(key: key);

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
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
      'screen': const HomePage(),
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
      'screen': const ProfileScreen(),
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
          hasNotch: true,
          notchStyle: NotchStyle.circle,
          fabLocation: StylishBarFabLocation.center,
          items: [
            BottomBarItem(
              icon: Image.asset('assets/images/icon/beranda-secondary.png',
                  width: 26),
              selectedIcon: Image.asset(
                  'assets/images/icon/beranda-primary.png',
                  width: 26),
              title: Text('Beranda', style: GoogleFonts.poppins(fontSize: 12)),
              backgroundColor: AppColors.primary,
            ),
            BottomBarItem(
              icon: Image.asset('assets/images/icon/event-secondary.png',
                  width: 26),
              selectedIcon: Image.asset('assets/images/icon/event-primary.png',
                  width: 26),
              title: Text('Event', style: GoogleFonts.poppins(fontSize: 12)),
              backgroundColor: AppColors.primary,
            ),
            BottomBarItem(
              icon: const SizedBox.shrink(), // Kosong, diganti dengan FAB
              title: const SizedBox.shrink(),
              backgroundColor: AppColors.primary,
            ),
            BottomBarItem(
              icon: Image.asset('assets/images/icon/riwayat-secondary.png',
                  width: 26),
              selectedIcon: Image.asset(
                  'assets/images/icon/riwayat-primary.png',
                  width: 26),
              title: Text('Riwayat', style: GoogleFonts.poppins(fontSize: 12)),
              backgroundColor: AppColors.primary,
            ),
            BottomBarItem(
              icon: Image.asset('assets/images/icon/profil-secondary.png',
                  width: 26),
              selectedIcon: Image.asset('assets/images/icon/profil-primary.png',
                  width: 26),
              title: Text('Profil', style: GoogleFonts.poppins(fontSize: 12)),
              backgroundColor: AppColors.primary,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          // Background transparan bulat
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFFCB0A4).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),

          // FAB utama
          SizedBox(
            width: 68,
            height: 68,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  indexMenu = 2;
                });
              },
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: const CircleBorder(),
              child: Image.asset(
                menu[2]['iconActive'],
                width: 72,
                height: 72,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Butuh\nDarah',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
