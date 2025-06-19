import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:siaga_darah/themes/colors.dart';
import 'RegisterScreen.dart';
import 'main_screen.dart';
import '../service/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  final bool showSuccessMessage;
  const LoginScreen({Key? key, this.showSuccessMessage = false})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.showSuccessMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar('Akun berhasil terdaftar!', isError: false);
      });
    }
  }

  Future<void> _handleLogin() async {
    print('🔍 DEBUG: Login attempt started');
    print('📧 Email: ${_emailController.text.trim()}');
    print('🔒 Password length: ${_passwordController.text.length}');

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Mohon isi email dan password', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🚀 Calling Firebase signInWithEmailAndPassword...');
      final result = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('📊 Login result: ${result.success}');
      print('💬 Message: ${result.message}');
      print('👤 User: ${result.user?.email}');
      print('🆔 User UID: ${result.user?.uid}');

      if (result.success && result.user != null) {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null && !user.emailVerified) {
          print('⚠️ Email belum diverifikasi');
          await FirebaseAuth.instance.signOut(); // keluarin user
          if (mounted) {
            _showSnackBar(
              'Email belum diverifikasi. Silakan cek email Anda.',
              isError: true,
            );
          }
          return;
        }

        print('✅ Login successful, navigating to main screen');
        if (mounted) {
          // _showSnackBar('Login berhasil!', isError: false);
          await Future.delayed(Duration(milliseconds: 300));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      showSuccessMessage: true,
                    )),
          );
        }
      } else {
        print('❌ Login failed: ${result.message}');

        // Try alternative method - check if user is actually signed in
        final currentUser = _authService.currentUser;
        print('🔄 Checking current user: ${currentUser?.email}');

        if (currentUser != null) {
          if (!currentUser.emailVerified) {
            print('⚠️ Email belum diverifikasi (alt check)');
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              _showSnackBar(
                'Email belum diverifikasi. Silakan cek email Anda.',
                isError: true,
              );
            }
            return;
          }

          print('🎯 User is actually signed in! Proceeding...');
          if (mounted) {
            _showSnackBar('Login berhasil!', isError: false);
            await Future.delayed(Duration(milliseconds: 300));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
        } else {
          if (mounted) {
            _showSnackBar(result.message ?? 'Login gagal', isError: true);
          }
        }
      }
    } catch (e) {
      print('💥 Exception during login: $e');
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 Starting Google Sign-In process...');
      final result = await _authService.signInWithGoogle(isRegister: false);

      print('📊 Google Sign-In result: ${result.success}');
      print('💬 Message: ${result.message}');
      print('👤 User: ${result.user?.email}');

      if (result.message == 'email_exists_with_password') {
        final connect = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Email sudah digunakan"),
            content: Text(
                "Email ini sudah digunakan untuk login dengan email & password. Ingin tautkan dengan akun Google?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text("Tautkan"),
              ),
            ],
          ),
        );

        if (connect == true) {
          final googleUser = await GoogleSignIn().signIn();
          final googleAuth = await googleUser?.authentication;
          final googleCredential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );

          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            await currentUser.linkWithCredential(googleCredential);
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .update({
              'signInMethods': FieldValue.arrayUnion(['google']),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            _showSnackBar('Berhasil menautkan akun Google!', isError: false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen()),
            );
            return;
          } else {
            _showSnackBar(
              'Harap login terlebih dahulu dengan email & password.',
              isError: true,
            );
          }
        } else {
          _showSnackBar('Login Google dibatalkan', isError: true);
          return;
        }
      }

      if (mounted) {
        if (result.success && result.user != null) {
          print('✅ Google Sign-In successful');
          _showSnackBar('Login berhasil!', isError: false);

          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          print('❌ Google Sign-In failed: ${result.message}');

          // Check if user is actually signed in despite the error
          final currentUser = _authService.currentUser;
          print(
              '🔄 Checking current user after Google Sign-In: ${currentUser?.email}');

          if (currentUser != null) {
            print('🎯 User is actually signed in with Google! Proceeding...');
            _showSnackBar('Login berhasil!', isError: false);

            await Future.delayed(const Duration(milliseconds: 500));

            // Check if user data exists and needs phone number
            final userData = await _authService.getUserData(currentUser.uid);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } else {
            _showSnackBar(result.message ?? 'Google login gagal',
                isError: true);
          }
        }
      }
    } catch (e) {
      print('💥 Exception during Google Sign-In: $e');
      print('🔍 Exception type: ${e.runtimeType}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Mohon masukkan email terlebih dahulu', isError: true);
      return;
    }

    try {
      final result =
          await _authService.resetPassword(_emailController.text.trim());
      if (mounted) {
        if (result.success) {
          _showSnackBar('Link reset password telah dikirim ke email Anda',
              isError: false);
        } else {
          _showSnackBar(result.message ?? 'Gagal mengirim email reset',
              isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: ${e.toString()}', isError: true);
      }
    }
  }

  // void _showSnackBar(String message, {required bool isError}) {
  //   if (!mounted) return;

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
  //       behavior: SnackBarBehavior.floating,
  //       margin: const EdgeInsets.all(16),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       duration: Duration(seconds: isError ? 4 : 2),
  //     ),
  //   );
  // }

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
      backgroundColor: Colors.white, // Light pink background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Title
              Center(
                child: Text(
                  'Login',
                  style: GoogleFonts.quicksand(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Subtitle
              Center(
                child: Text(
                  'Masuk untuk mulai menggunakan aplikasi.',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: AppColors.paragraph,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Email Field
              Text(
                'Email',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),

              const SizedBox(height: 6),

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
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password Field
              Text(
                'Password',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),

              const SizedBox(height: 6),

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
                      vertical: 12,
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

              const SizedBox(height: 4),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  child: Text(
                    'Lupa Password?',
                    style: GoogleFonts.quicksand(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
                          'Login',
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              // Google Login Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
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
                        'Login dengan Google',
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

              const SizedBox(height: 20),

              // Register link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: GoogleFonts.quicksand(
                        color: AppColors.paragraph,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to register screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                      child: Text(
                        'Daftar',
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
