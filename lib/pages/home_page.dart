import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:siaga_darah/pages/ProfileScreen.dart';
import 'package:siaga_darah/pages/informasi_screen.dart';
import '../service/auth_service.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_darah/themes/colors.dart';

class HomePage extends StatefulWidget {
  final bool showSuccessMessage;
  final String successMessage;
  const HomePage({
    Key? key,
    this.showSuccessMessage = false,
    this.successMessage = 'Login berhasil!',
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Gagal memuat data pengguna.', isError: true);
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Potong nama pengguna jadi 2 kata pertama
  String getFirstTwoWords(String fullName) {
    final words = fullName.trim().split(' ');
    return words.length >= 2 ? '${words[0]} ${words[1]}' : words.join(' ');
  }

  // Logic Mode Siaga
  void _onToggleSiaga(bool newValue) async {
    final user = _authService.currentUser;
    if (user == null) {
      _showSnackBar('Anda harus login untuk mengaktifkan Mode Siaga.',
          isError: true);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
          {'isDonor': newValue, 'updatedAt': FieldValue.serverTimestamp()});

      if (mounted) {
        setState(() {
          _isSiagaActive = newValue;
        });
        _showSnackBar(
          newValue
              ? 'Mode Siaga telah diaktifkan. Terima kasih telah siap membantu!'
              : 'Mode Siaga dinonaktifkan.',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memperbarui status Mode Siaga.', isError: true);
      }
    }
  }

  // Konten untuk halaman Beranda (saat _currentIndex == 0)
  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
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
                  // Top bar with greeting and notification icon
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
                      GestureDetector(
                        onTap: () {
                          // Aksi ketika notification ditekan
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Fitur notifikasi akan segera hadir!'),
                            ),
                          );
                        },
                        child: Stack(
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
                            const Positioned(
                              right: 2,
                              top: 2,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Color(0xFFFF0000),
                                child: Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                  Flexible(
                                    child: Text(
                                      _userBloodType != null &&
                                              _userBloodType!.isNotEmpty
                                          ? _userBloodType!
                                          : 'Belum diatur',
                                      style: GoogleFonts.quicksand(
                                        fontSize: _userBloodType != null &&
                                                _userBloodType!.isNotEmpty
                                            ? 32
                                            : 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                      softWrap: true,
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
                                'Jumlah Donasi,',
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
                                    '$_donationCount',
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

          // Mode Siaga Section
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
            ),
          ),

          const SizedBox(height: 24),

          // Blood Stock Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bloodtype,
                        color: AppColors.primary, size: 20),
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

          // Bottom padding untuk navbar
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildMainContent(), // Menggunakan method yang diperbaiki
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
                    '${blood['percentage']}%',
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
    return GestureDetector(
      onTap: () {
        // Aksi ketika event card ditekan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Membuka detail event: $title'),
          ),
        );
        // Nanti bisa diganti dengan navigasi ke halaman detail event
      },
      child: Container(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      ),
    );
  }
}
