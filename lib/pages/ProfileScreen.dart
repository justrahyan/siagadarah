import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_darah/pages/LoginScreen.dart';
import 'LoginScreen.dart'; // Ganti jika nama file login kamu berbeda

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoggingOut = false;
  bool _isLoading = true;

  // Data user dari Firestore
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        print('🔍 Loading user data for UID: ${user.uid}');

        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data();
            _isLoading = false;
          });
          print('✅ User data loaded: ${_userData?['email']}');
        } else {
          setState(() {
            _errorMessage = 'Data pengguna tidak ditemukan di database';
            _isLoading = false;
          });
          print('❌ User document not found');
        }
      } else {
        setState(() {
          _errorMessage = 'Tidak ada pengguna yang login';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });
      print('💥 Error loading user data: $e');
    }
  }

  Future<void> _handleLogout() async {
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      setState(() => _isLoggingOut = true);
      try {
        await _auth.signOut();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
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

  Widget _buildProfileImage() {
    final profilePicture = _userData?['profilePicture'] as String?;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: ClipOval(
        child: profilePicture != null && profilePicture.isNotEmpty
            ? Image.network(
                profilePicture,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey.shade600,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red.shade600,
                    ),
                  );
                },
              )
            : Icon(
                Icons.person,
                size: 50,
                color: Colors.grey.shade600,
              ),
      ),
    );
  }

  Widget _buildSignInMethodIndicator() {
    final signInMethod = _userData?['signInMethod'] as String?;

    if (signInMethod == 'google') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_google.png',
              width: 16,
              height: 16,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.g_mobiledata,
                  size: 16,
                  color: Colors.red.shade600,
                );
              },
            ),
            const SizedBox(width: 4),
            Text(
              'Google',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.email,
              size: 16,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              'Email',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.red.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _loadUserData();
                  },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _loadUserData();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Picture
                        Center(child: _buildProfileImage()),
                        const SizedBox(height: 16),

                        // Sign In Method Indicator
                        Center(child: _buildSignInMethodIndicator()),
                        const SizedBox(height: 32),

                        // User Info
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                label: 'Nama',
                                value: _userData?['name'] as String? ??
                                    'Tidak diketahui',
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                label: 'Email',
                                value: _userData?['email'] as String? ??
                                    'Tidak diketahui',
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                label: 'Nomor Telepon',
                                value: (_userData?['phone'] as String?)
                                            ?.isNotEmpty ==
                                        true
                                    ? _userData!['phone'] as String
                                    : 'Belum diisi',
                              ),
                              const SizedBox(height: 20),
                              _buildInfoRow(
                                label: 'Status Verifikasi',
                                value:
                                    (_userData?['isVerified'] as bool?) == true
                                        ? 'Terverifikasi'
                                        : 'Belum terverifikasi',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoggingOut ? null : _handleLogout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoggingOut
                                ? const CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                    strokeWidth: 2,
                                  )
                                : const Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
