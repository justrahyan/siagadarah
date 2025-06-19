import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'LoginScreen.dart';
import 'main_screen.dart';
import '../service/auth_service.dart';
import 'package:siaga_darah/themes/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    // Indonesian phone number validation
    return RegExp(r'^(\+62|62|0)[0-9]{9,13}$').hasMatch(phone);
  }

  Future<void> _handleRegister() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Mohon masukkan nama lengkap', isError: true);
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Mohon masukkan email', isError: true);
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      _showSnackBar('Format email tidak valid', isError: true);
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('Mohon masukkan nomor telepon', isError: true);
      return;
    }

    if (!_isValidPhone(_phoneController.text.trim())) {
      _showSnackBar('Format nomor telepon tidak valid', isError: true);
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showSnackBar('Mohon masukkan password', isError: true);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Password minimal 6 karakter', isError: true);
      return;
    }

    if (!_agreeToTerms) {
      _showSnackBar('Mohon setujui syarat dan ketentuan', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 Starting registration process...');
      print('📧 Email: ${_emailController.text.trim()}');
      print('👤 Name: ${_nameController.text.trim()}');
      print('📱 Phone: ${_phoneController.text.trim()}');

      final result = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      print('📊 Registration result: ${result.success}');
      print('💬 Message: ${result.message}');
      print('👤 User: ${result.user?.email}');

      if (mounted) {
        if (result.success && result.user != null) {
          await _authService.sendEmailVerification();

          print('✅ Registration successful');
          // _showSnackBar('Registrasi berhasil!', isError: false);

          // Small delay to ensure UI updates properly
          await Future.delayed(const Duration(milliseconds: 300));

          // Navigate to main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(showSuccessMessage: true),
            ),
          );
        } else {
          print('❌ Registration failed: ${result.message}');

          // Check if user is actually signed in despite the error
          final currentUser = _authService.currentUser;
          print(
              '🔄 Checking current user after registration: ${currentUser?.email}');

          if (currentUser != null) {
            print('🎯 User is actually registered! Proceeding...');
            _showSnackBar('Registrasi berhasil!', isError: false);

            await Future.delayed(const Duration(milliseconds: 500));

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          } else {
            _showSnackBar(result.message ?? 'Registrasi gagal', isError: true);
          }
        }
      }
    } catch (e) {
      print('💥 Exception during registration: $e');
      print('🔍 Exception type: ${e.runtimeType}');

      if (mounted) {
        // Check if user is signed in despite the exception
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          print('🎯 User registered despite exception! Proceeding...');
          _showSnackBar('Registrasi berhasil!', isError: false);

          await Future.delayed(const Duration(milliseconds: 500));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          _showSnackBar('Terjadi kesalahan: ${e.toString()}', isError: true);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithGoogle(isRegister: true);
      print('📊 Google Registration result: ${result.success}');
      print('💬 Message: ${result.message}');
      print('👤 User: ${result.user?.email}');

      if (result.success && result.user != null) {
        _showSnackBar("Registrasi berhasil!", isError: false);
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const MainScreen(
                    showSuccessMessage: true,
                    successMessage: 'Registrasi berhasil! Silahkan verifikasi email Anda.',
                  )),
        );
      } else {
        _showSnackBar(result.message ?? 'Registrasi gagal', isError: true);
      }
    } catch (e) {
      print('❌ Google Register Error: $e');
      _showSnackBar("Terjadi kesalahan: ${e.toString()}", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Title
              Center(
                child: Text(
                  'Daftar',
                  style: GoogleFonts.quicksand(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),

              const SizedBox(height: 4), // Reduced from 8

              // Subtitle
              Center(
                child: Text(
                  'Buat akun baru dan mulai berkontribusi.',
                  style: GoogleFonts.quicksand(
                    fontSize: 14, // Reduced from 16
                    color: AppColors.paragraph,
                  ),
                ),
              ),

              const SizedBox(height: 24), // Reduced from 40

              // Name Field
              Text(
                'Nama',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),

              const SizedBox(height: 6), // Reduced from 8

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  cursorColor: AppColors.primary,
                  style: GoogleFonts.quicksand(
                    color: AppColors.darkText,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama anda',
                    hintStyle: GoogleFonts.quicksand(
                      color: AppColors.paragraph,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12, // Reduced from 16
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16), // Reduced from 20

              // Email Field
              Text(
                'Email',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),

              const SizedBox(height: 6), // Reduced from 8

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: AppColors.primary,
                  style: GoogleFonts.quicksand(
                    color: AppColors.darkText,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Masukkan email anda',
                    hintStyle: GoogleFonts.quicksand(
                      color: AppColors.paragraph,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12, // Reduced from 16
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16), // Reduced from 20

              // Phone Field
              Text(
                'Nomor HP',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),

              const SizedBox(height: 6), // Reduced from 8

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  cursorColor: AppColors.primary,
                  style: GoogleFonts.quicksand(
                    color: AppColors.darkText,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Masukkan no hp anda',
                    hintStyle: GoogleFonts.quicksand(
                      color: AppColors.paragraph,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12, // Reduced from 16
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16), // Reduced from 20

              // Password Field
              Text(
                'Password',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),

              const SizedBox(height: 6), // Reduced from 8

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  cursorColor: AppColors.primary,
                  style: GoogleFonts.quicksand(
                    color: AppColors.darkText,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Masukkan password anda',
                    hintStyle: GoogleFonts.quicksand(
                      color: AppColors.paragraph,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12, // Reduced from 16
                    ),
                    suffixIcon: IconButton(
                      iconSize: 18,
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.paragraph,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12), // Reduced from 20

              // Terms and Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Ubah ke center untuk penyelarasan vertikal
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                    // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Hapus ini atau coba-coba
                    visualDensity:
                        VisualDensity.compact, // Pertahankan ini atau coba-coba
                  ),
                  Expanded(
                    // Hapus Padding di sini atau atur EdgeInsets.zero
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.quicksand(
                          fontSize: 12, // Reduced from 14
                          color: AppColors.paragraph,
                        ),
                        children: [
                          const TextSpan(text: 'Saya setuju dengan '),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: GoogleFonts.quicksand(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' dan '),
                          TextSpan(
                            text: 'Syarat & Ketentuan',
                            style: GoogleFonts.quicksand(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14), // Reduced from 30

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 48, // Reduced from 52
                child: ElevatedButton(
                  onPressed:
                      (_isLoading || !_agreeToTerms) ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_agreeToTerms)
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Daftar',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16), // Reduced from 24

              // Or divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Atau',
                      style: GoogleFonts.quicksand(
                        color: AppColors.paragraph,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16), // Reduced from 24

              // Google Register Button
              SizedBox(
                width: double.infinity,
                height: 48, // Reduced from 52
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleRegister,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Image.asset(
                          'assets/images/logo_google.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Daftar dengan Google',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20), // Reduced from 30

              // Login link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: GoogleFonts.quicksand(
                        color: AppColors.paragraph,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate back to login screen
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.quicksand(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20), // Reduced from 40
            ],
          ),
        ),
      ),
    );
  }
}