import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'LoginScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;
  int _currentIndex = 0;

  // User data variables
  String _userName = 'Pengguna SiagaDarah';
  String _userBloodType = '-';
  int _donationCount = 0;
  bool _isLoading = true;

  // Mode Siaga variables
  bool _isSiagaMode = false;
  bool _isTogglingMode = false;

  // Removed AnimationController and Animation for the pulsing effect,
  // as the new design does not require it.
  // late AnimationController _pulseController;
  // late Animation<double> _pulseAnimation;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Removed _initializeAnimations() call as pulsing effect is removed
  }

  // Removed _initializeAnimations() method as pulsing effect is removed
  // void _initializeAnimations() {
  //   _pulseController = AnimationController(
  //     duration: Duration(seconds: 2),
  //     vsync: this,
  //   );
  //   _pulseAnimation = Tween<double>(
  //     begin: 1.0,
  //     end: 1.2,
  //   ).animate(CurvedAnimation(
  //     parent: _pulseController,
  //     curve: Curves.easeInOut,
  //   ));

  //   _pulseController.repeat(reverse: true);
  // }

  @override
  void dispose() {
    // Dispose the controller only if it was initialized.
    // If you decide to bring back animations later, uncomment this line.
    // _pulseController.dispose();
    super.dispose();
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
            _isSiagaMode = userData?['siagaMode'] ?? false;
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

  Future<void> _toggleSiagaMode() async {
    if (_isTogglingMode) return;

    // Show confirmation dialog
    bool? shouldToggle = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _isSiagaMode ? Icons.notification_important : Icons.notifications_active,
                color: _isSiagaMode ? Colors.orange : Colors.red.shade400,
              ),
              SizedBox(width: 8),
              Text(_isSiagaMode ? 'Nonaktifkan Mode Siaga?' : 'Aktifkan Mode Siaga?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isSiagaMode
                  ? 'Anda tidak akan menerima notifikasi darurat kebutuhan donor darah.'
                  : 'Anda akan menerima notifikasi darurat saat ada kebutuhan donor darah sesuai golongan darah Anda.'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_isSiagaMode ? Colors.orange : Colors.red.shade400).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: _isSiagaMode ? Colors.orange.shade700 : Colors.red.shade600,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isSiagaMode
                            ? 'Mode siaga akan dinonaktifkan'
                            : 'Pastikan notifikasi aplikasi sudah diaktifkan',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isSiagaMode ? Colors.orange.shade700 : Colors.red.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSiagaMode ? Colors.orange : Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_isSiagaMode ? 'Nonaktifkan' : 'Aktifkan'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );

    if (shouldToggle == true) {
      setState(() => _isTogglingMode = true);

      try {
        final user = _authService.currentUser;
        if (user != null) {
          // Update mode siaga di database
          await _authService.updateUserSiagaMode(user.uid, !_isSiagaMode);

          if (mounted) {
            setState(() {
              _isSiagaMode = !_isSiagaMode;
              _isTogglingMode = false;
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      _isSiagaMode ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(_isSiagaMode
                        ? 'Mode Siaga Diaktifkan! Anda akan mendapat notifikasi darurat.'
                        : 'Mode Siaga Dinonaktifkan.'),
                  ],
                ),
                backgroundColor: _isSiagaMode ? Colors.green.shade600 : Colors.orange.shade600,
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isTogglingMode = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengubah mode siaga: ${e.toString()}'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:
                  Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child:
                  Text('Logout', style: TextStyle(color: Colors.red.shade600)),
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );

    if (shouldLogout == true) {
      setState(() => _isLoggingOut = true);
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoggingOut = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: ${e.toString()}'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
  }

  void _onNavbarTap(int index) {
    if (index == 2) {
      // Handle "Butuh Darah" action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fitur Butuh Darah akan segera hadir!'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    // Show placeholder messages for other tabs
    switch (index) {
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Halaman Donor akan segera hadir!')),
        );
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Halaman Riwayat akan segera hadir!')),
        );
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Halaman Profil akan segera hadir!')),
        );
        break;
    }
  }

  // NEW: Widget for the combined Siaga Mode banner
  Widget _buildSiagaBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade300, Colors.orange.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        // Added shadow for consistency with other cards/banners
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade400.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siaga Donor, Siap Bantu Kapan Saja!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Hidupkan Mode Siaga & Jadi Penolong Sesama',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          // Sized box to constrain the height of the switch visually
          SizedBox(
            height: 30, // Adjust as needed to align with text
            child: Switch(
              value: _isSiagaMode,
              onChanged: _isTogglingMode ? null : (value) => _toggleSiagaMode(),
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withOpacity(0.7),
              inactiveThumbColor: Colors.grey.shade400, // Make it look off
              inactiveTrackColor: Colors.grey.shade600, // Make it look off
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMainContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade400),
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
                colors: [Colors.red.shade400, Colors.red.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
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
                              children: [
                                Icon(Icons.favorite,
                                    color: Colors.white, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Selamat datang di SiagaDarah',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Halo, $_userName!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoggingOut ? null : _handleLogout,
                        icon: _isLoggingOut
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(Icons.logout, color: Colors.white, size: 24),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Info Cards Row
                  Row(
                    children: [
                      // Blood Type Card
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Golongan Darahmu,',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    _userBloodType,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.medical_services_outlined,
                                      color: Colors.red.shade400,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      // Donation Count Card
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jumlah Kontribusimu,',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '$_donationCount',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.assignment_turned_in,
                                      color: Colors.blue.shade600,
                                      size: 20,
                                    ),
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
          
          SizedBox(height: 24),
          _buildSiagaBanner(),
          SizedBox(height: 24),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bloodtype, color: Colors.red.shade400, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Stok Darah PMI Makassar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Terakhir diperbarui: ${_getFormattedDate()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 16),
                _buildBloodStockChart(),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Events Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event,
                            color: Colors.blue.shade600, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Event Terdekat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Melihat semua event akan segera hadir!')),
                        );
                      },
                      child: Text(
                        'Lihat semua',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildEventCard(
                        'Awal Donor Darah',
                        '16 Jun 2025, 08:00 - selesai',
                        'Beranda',
                        Colors.red.shade400,
                      ),
                      SizedBox(width: 12),
                      _buildEventCard(
                        'Donor Darah Gratis',
                        '18 Jun 2025, 08:00 - selesai',
                        'Butuh',
                        Colors.green.shade400,
                      ),
                      SizedBox(width: 12),
                      _buildEventCard(
                        'Awal Donor Darah',
                        '20 Jun 2025, 08:00 - selesai',
                        'Beranda',
                        Colors.red.shade400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom padding for navbar
          SizedBox(height: 100),
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
          SizedBox(height: 20),
          Text(
            pageTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Fitur ini akan segera hadir!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: bloodTypes.map((blood) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 30, // Adjust width as needed for type label
                  child: Text(
                    blood['type'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (blood['percentage'] as int) / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(blood['color'] as Color),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${blood['percentage']}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Corrected _buildEventCard method
  Widget _buildEventCard(String title, String date, String tag, Color tagColor) {
    return Container(
      width: 250, // Fixed width for event cards
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}