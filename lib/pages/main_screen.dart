import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_darah/pages/home_page.dart';
import 'package:siaga_darah/themes/theme.dart';
import 'ProfileScreen.dart';

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
      'iconActive': 'assets/images/icon/beranda-primary.png',
      'iconInactive': 'assets/images/icon/beranda-secondary.png',
      'label': 'Beranda',
      'screen': const HomePage(),
    },
    {
      'iconActive': 'assets/images/icon/event-primary.png',
      'iconInactive': 'assets/images/icon/event-secondary.png',
      'label': 'Event',
      'screen': const Center(
        child: Text(
          'Event',
          style: TextStyle(fontSize: 24),
        ),
      ),
    },
    {
      'iconActive': 'assets/images/icon/butuh-darah.png',
      'iconInactive': 'assets/images/icon/butuh-darah.png',
      'label': 'Butuh Darah',
      'screen': const Center(
        child: Text(
          'Butuh Darah',
          style: TextStyle(fontSize: 24),
        ),
      ),
    },
    {
      'iconActive': 'assets/images/icon/riwayat-primary.png',
      'iconInactive': 'assets/images/icon/riwayat-secondary.png',
      'label': 'Riwayat',
      'screen': const Center(
        child: Text(
          'Riwayat',
          style: TextStyle(fontSize: 24),
        ),
      ),
    },
    {
      'iconActive': 'assets/images/icon/profil-primary.png',
      'iconInactive': 'assets/images/icon/profil-secondary.png',
      'label': 'Profil',
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
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Custom painted navbar dengan cutout
          Container(
            height: 70,
            child: CustomPaint(
              painter: NavbarCutoutPainter(),
              size: Size(MediaQuery.of(context).size.width, 70),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: List.generate(menu.length, (index) {
                    if (index == 2)
                      return const SizedBox.shrink(); // Tombol tengah skip

                    bool isActive = index == indexMenu;
                    final item = menu[index];

                    // Tambah jarak ekstra untuk index 1 dan 3
                    EdgeInsets margin = EdgeInsets.zero;
                    if (index == 1) margin = const EdgeInsets.only(right: 50);
                    if (index == 3) margin = const EdgeInsets.only(left: 50);

                    return Expanded(
                      child: Container(
                        margin: margin,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              indexMenu = index;
                            });
                          },
                          child: SizedBox(
                            height: 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  isActive
                                      ? item['iconActive']
                                      : item['iconInactive'],
                                  width: 26,
                                  height: 26,
                                ),
                                if (isActive)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      item['label'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // Efek semi-transparan (seperti substract) di belakang tombol
          Positioned(
            bottom: 25,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFCB0A4)
                    .withOpacity(0.5), // merah transparan
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Tombol tengah (Butuh Darah) - tanpa efek semi-transparan
          Positioned(
            bottom: 35,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  indexMenu = 2;
                });
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      indexMenu == 2
                          ? menu[2]['iconActive']
                          : menu[2]['iconInactive'],
                      width: 64,
                      height: 64,
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
}

class NavbarCutoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final cutoutRadius = 45.0;

    // Menaikkan lubang: semakin besar offsetY, semakin ke atas
    final cutoutYOffset = 0.0;

    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(centerX - cutoutRadius, 0);

    path.arcToPoint(
      Offset(centerX + cutoutRadius, 0),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
      // Titik awal dan akhir tetap di Y=0, tapi nanti kita geser bagian ini saja
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    // Hanya geser bagian potongan lubangnya ke atas
    final pathWithCutoutLifted = Path();
    pathWithCutoutLifted.moveTo(0, size.height);
    pathWithCutoutLifted.lineTo(0, 0);
    pathWithCutoutLifted.lineTo(centerX - cutoutRadius, 0);

    // Ubah titik akhir Y-nya agar potongannya naik
    pathWithCutoutLifted.arcToPoint(
      Offset(centerX + cutoutRadius, 0),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );

    pathWithCutoutLifted.lineTo(size.width, 0);
    pathWithCutoutLifted.lineTo(size.width, size.height);
    pathWithCutoutLifted.close();

    // Geser hanya bagian lengkung potongannya
    canvas.drawPath(
        pathWithCutoutLifted.shift(Offset(0, -cutoutYOffset)), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
