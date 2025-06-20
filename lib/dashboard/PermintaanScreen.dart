import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_darah/themes/colors.dart';
import '../service/auth_service.dart';
import '../pages/LoginScreen.dart';

class PermintaanScreen extends StatefulWidget {
  final bool showSuccessMessage;
  final String successMessage;

  const PermintaanScreen({
    super.key,
    this.showSuccessMessage = false,
    this.successMessage = 'Selamat datang Admin!',
  });

  @override
  _PermintaanScreenState createState() => _PermintaanScreenState();
}

class _PermintaanScreenState extends State<PermintaanScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();

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

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser != null) {
        _userData = await _authService.getUserData(_currentUser!.uid);
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Konfirmasi Logout',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun admin?',
            style: GoogleFonts.quicksand(
              color: AppColors.paragraph,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: GoogleFonts.quicksand(
                  color: AppColors.paragraph,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          },
        );

        // Perform logout
        await _authService.signOut();

        // Hide loading
        Navigator.of(context).pop();

        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logout berhasil',
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } catch (e) {
        // Hide loading if still showing
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal logout: ${e.toString()}',
              style: GoogleFonts.quicksand(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.admin_panel_settings,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selamat Datang, Admin!',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userData?['name'] ??
                                        _currentUser?.displayName ??
                                        'Admin',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 14,
                                      color: AppColors.paragraph,
                                    ),
                                  ),
                                  Text(
                                    _currentUser?.email ?? '',
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      color: AppColors.paragraph,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Stats
                  Text(
                    'Statistik Cepat',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people,
                          title: 'Total Users',
                          value: '150',
                          color: Colors.blue.shade400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.bloodtype,
                          title: 'Blood Requests',
                          value: '23',
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.favorite,
                          title: 'Active Donors',
                          value: '89',
                          color: Colors.green.shade400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.notifications,
                          title: 'Pending',
                          value: '7',
                          color: Colors.orange.shade400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Admin Menu
                  Text(
                    'Menu Admin',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildMenuCard(
                    icon: Icons.people_outline,
                    title: 'Kelola Pengguna',
                    subtitle: 'Lihat dan kelola semua pengguna',
                    onTap: () {
                      // TODO: Navigate to user management
                      _showComingSoon('Kelola Pengguna');
                    },
                  ),

                  const SizedBox(height: 8),

                  _buildMenuCard(
                    icon: Icons.bloodtype_outlined,
                    title: 'Permintaan Darah',
                    subtitle: 'Kelola permintaan donor darah',
                    onTap: () {
                      // TODO: Navigate to blood request management
                      _showComingSoon('Permintaan Darah');
                    },
                  ),

                  const SizedBox(height: 8),

                  _buildMenuCard(
                    icon: Icons.local_hospital_outlined,
                    title: 'Data Donor',
                    subtitle: 'Lihat data donor dan riwayat',
                    onTap: () {
                      // TODO: Navigate to donor data
                      _showComingSoon('Data Donor');
                    },
                  ),

                  const SizedBox(height: 8),

                  _buildMenuCard(
                    icon: Icons.analytics_outlined,
                    title: 'Laporan & Analitik',
                    subtitle: 'Lihat laporan dan statistik',
                    onTap: () {
                      // TODO: Navigate to analytics
                      _showComingSoon('Laporan & Analitik');
                    },
                  ),

                  const SizedBox(height: 8),

                  _buildMenuCard(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan Sistem',
                    subtitle: 'Konfigurasi aplikasi',
                    onTap: () {
                      // TODO: Navigate to system settings
                      _showComingSoon('Pengaturan Sistem');
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              color: AppColors.paragraph,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.quicksand(
            fontSize: 12,
            color: AppColors.paragraph,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.paragraph,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Coming Soon',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          content: Text(
            'Fitur $feature sedang dalam pengembangan dan akan segera tersedia.',
            style: GoogleFonts.quicksand(
              color: AppColors.paragraph,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
