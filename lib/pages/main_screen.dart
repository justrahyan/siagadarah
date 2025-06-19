import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:siaga_darah/pages/ProfileScreen.dart';
import '../service/auth_service.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_darah/themes/theme.dart';

class MainScreen extends StatefulWidget {
  final bool showSuccessMessage;
  final String successMessage;
  const MainScreen({
    Key? key,
    this.showSuccessMessage = false,
    this.successMessage = 'Login berhasil!',
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;
  int _currentIndex = 0;

  // User data variables
  String _userName = 'Pengguna SiagaDarah';
  String _userBloodType = '-';
  int _donationCount = 0;
  bool _isLoading = true;
  bool _isSiagaActive = false;

  @override
  void initState() {
    super.initState();
    if (widget.showSuccessMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(widget.successMessage, isError: false);
      });
    }
    _loadUserData();
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

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        final userData = await _authService.getUserData(user.uid);
        if (mounted) {
          setState(() {
            _userName =
                userData?['name'] ?? user.displayName ?? 'Pengguna SiagaDarah';
            _userBloodType = userData?['bloodType'] ?? '-';
            _donationCount = userData?['stats']?['donationsCompleted'] ?? 0;
            _isSiagaActive = userData?['isDonor'] ?? false;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNavbarTap(int index) {
    if (index == 2) {
      // Butuh Darah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fitur Butuh Darah akan segera hadir!'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    if (index == 4) {
      // Navigasi ke halaman Profil
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Donor akan segera hadir!')),
        );
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Halaman Riwayat akan segera hadir!')),
        );
        break;
    }
  }

  // Potong nama pengguna jadi 2 kata pertama
  String getFirstTwoWords(String fullName) {
    final words = fullName.trim().split(' ');
    return words.length >= 2 ? '${words[0]} ${words[1]}' : words.join(' ');
  }

  // Logic Mode Siaga
  // bool _isSiagaActive = snapshot['isDonor'] ?? false;
  void _onToggleSiaga(bool newValue) async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'isDonor': newValue});

      setState(() {
        _isSiagaActive = newValue;
      });

      Flushbar(
        message: newValue
            ? 'Mode Siaga telah diaktifkan. Terima kasih telah siap membantu!'
            : 'Mode Siaga dinonaktifkan.',
        backgroundColor: Colors.green.shade700,
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      ).show(context);
    } catch (e) {
      Flushbar(
        message: 'Gagal memperbarui status Mode Siaga',
        backgroundColor: Colors.red.shade700,
        margin: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(8),
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      ).show(context);
    }
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Colors.red.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, top: 32, right: 16, bottom: 16),
              child: Column(
                children: [
                  // Top bar with greeting and logout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Logo di kiri
                                Image.asset(
                                  'assets/images/logo/siaga-darah-logo-white.png',
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 12),

                                // Teks di kanan logo (dua baris)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Selamat datang di ',
                                            style: GoogleFonts.quicksand(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'SiagaDarah',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Halo, ',
                                            style: GoogleFonts.quicksand(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          TextSpan(
                                            text: getFirstTwoWords(_userName),
                                            style: GoogleFonts.quicksand(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '!',
                                            style: GoogleFonts.quicksand(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD02B33),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/images/icon/notifikasi.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF0000),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '3', // Dummy jumlah notifikasi
                                  style: GoogleFonts.quicksand(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Info Cards Row
                  Row(
                    children: [
                      // Blood Type Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 16, top: 16, right: 16),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Golongan Darahmu,',
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'B+',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    'assets/images/blood-bag.png',
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Donation Count Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 16, top: 16, right: 16),
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Golongan Darahmu,',
                                style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '6',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    'assets/images/list.png',
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Mode Siaga
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding:
                  const EdgeInsets.only(left: 4, top: 16, right: 4, bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade300, Colors.orange.shade400],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mode Siaga Aktif!',
                          style: GoogleFonts.quicksand(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Hidupkan Mode Siaga & Jadi Penolong Sesama',
                          style: GoogleFonts.quicksand(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isSiagaActive,
                    onChanged: _onToggleSiaga,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.red.shade400,
                    inactiveThumbColor: Colors.grey.shade300,
                    inactiveTrackColor: Colors.grey.shade500,
                  ),
                ],
              )),

          const SizedBox(height: 24),

          // Blood Stock Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bloodtype, color: AppColors.primary, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Stok Darah PMI Makassar',
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Terakhir diperbarui: ${_getFormattedDate()}',
                  style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: AppColors.paragraph,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                _buildBloodStockChart(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Events Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event,
                            color: Colors.blue.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Event Terdekat',
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Melihat semua event akan segera hadir!')),
                        );
                      },
                      child: Text(
                        'Lihat semua',
                        style: GoogleFonts.quicksand(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildEventCard(
                        'Awal Donor Darah',
                        '16 Jun 2025, 08:00 - selesai',
                        'Beranda',
                        AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _buildEventCard(
                        'Donor Darah Gratis',
                        '18 Jun 2025, 08:00 - selesai',
                        'Butuh',
                        Colors.green.shade400,
                      ),
                      const SizedBox(width: 12),
                      _buildEventCard(
                        'Awal Donor Darah',
                        '20 Jun 2025, 08:00 - selesai',
                        'Beranda',
                        AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom padding for navbar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child:
            _currentIndex == 0 ? _buildMainContent() : _buildPlaceholderPage(),
      ),
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavbarTap,
      ),
    );
  }

  Widget _buildPlaceholderPage() {
    String pageTitle = '';
    switch (_currentIndex) {
      case 1:
        pageTitle = 'Halaman Donor';
        break;
      case 3:
        pageTitle = 'Halaman Riwayat';
        break;
      case 4:
        pageTitle = 'Halaman Profil';
        break;
      default:
        pageTitle = 'Halaman';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            pageTitle,
            style: GoogleFonts.quicksand(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Fitur ini akan segera hadir!',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              color: AppColors.paragraph,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodStockChart() {
    final bloodTypes = [
      {'type': 'A', 'percentage': 56, 'color': Colors.blue.shade400},
      {'type': 'B', 'percentage': 64, 'color': Colors.green.shade400},
      {'type': 'AB', 'percentage': 76, 'color': Colors.orange.shade400},
      {'type': 'O', 'percentage': 78, 'color': Colors.cyan.shade400},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: bloodTypes.map((blood) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    blood['type'] as String,
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (blood['percentage'] as int) / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: blood['color'] as Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${blood['percentage']}',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventCard(
      String title, String date, String tag, Color tagColor) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.quicksand(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: AppColors.paragraph,
            ),
          ),
        ],
      ),
    );
  }
}
