import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:siaga_darah/themes/colors.dart';
import 'RegisterScreen.dart';
import 'main_screen.dart';
import '../dashboard/admin_main.dart'; 
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

  /// Navigasi pengguna berdasarkan peran mereka.
  Future<void> _navigateBasedOnRole(User user) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        if (mounted) {
          _showSnackBar('Data pengguna tidak ditemukan. Mohon coba lagi atau daftar ulang.', isError: true);
          await FirebaseAuth.instance.signOut(); // Logout pengguna yang tidak lengkap
          return;
        }
      }

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      String? userRole = userData?['role'] as String?;

      // Perbarui timestamp lastLogin
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        if (userRole == 'admin') {
          _showSnackBar('Selamat datang Admin!', isError: false);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AdminDashboard()),
            (Route<dynamic> route) => false,
          );
        } else {
          _showSnackBar('Login berhasil!', isError: false);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const MainScreen(
                      showSuccessMessage: false,
                    )),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Terjadi kesalahan saat mengecek peran. Melanjutkan sebagai pengguna biasa.', isError: true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Mohon isi email dan password.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success && result.user != null) {
        final user = FirebaseAuth.instance.currentUser;

        if (user != null && !user.emailVerified) {
          await FirebaseAuth.instance.signOut(); // Logout pengguna yang belum terverifikasi
          if (mounted) {
            _showSnackBar(
              'Email belum diverifikasi. Silakan cek email Anda. Apabila tidak ada di inbox, cek folder spam.',
              isError: true,
            );
          }
          return;
        }

        await _navigateBasedOnRole(result.user!);
      } else {
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          if (!currentUser.emailVerified) {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              _showSnackBar(
                'Email belum diverifikasi. Silakan cek email Anda.',
                isError: true,
              );
            }
            return;
          }
          await _navigateBasedOnRole(currentUser);
        } else {
          if (mounted) {
            _showSnackBar(result.message ?? 'Login gagal.', isError: true);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Tidak ada pengguna terdaftar dengan email tersebut.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Password salah.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Akun ini telah dinonaktifkan.';
      } else {
        errorMessage = e.message ?? 'Terjadi kesalahan autentikasi.';
      }
      if (mounted) {
        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
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
      final result = await _authService.signInWithGoogle(isRegister: false);

      if (result.message == 'email_exists_with_password') {
        final connect = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Email sudah digunakan"),
            content: const Text(
                "Email ini sudah digunakan untuk login dengan email & password. Ingin tautkan dengan akun Google?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Tautkan"),
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
            await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
              'signInMethods': FieldValue.arrayUnion(['google']),
              'updatedAt': FieldValue.serverTimestamp(),
            });

            if (mounted) {
              _showSnackBar('Akun Google berhasil ditautkan!', isError: false);
              await _navigateBasedOnRole(currentUser);
            }
            return;
          } else {
            if (mounted) {
              _showSnackBar('Harap login terlebih dahulu dengan email & password untuk menautkan akun.', isError: true);
            }
          }
        } else {
          if (mounted) {
            _showSnackBar('Login Google dibatalkan.', isError: true);
          }
          return;
        }
      }

      if (mounted) {
        if (result.success && result.user != null) {
          await _navigateBasedOnRole(result.user!);
        } else {
          final currentUser = _authService.currentUser;
          if (currentUser != null) {
            await _navigateBasedOnRole(currentUser);
          } else {
            _showSnackBar(result.message ?? 'Login Google gagal.', isError: true);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'Akun dengan email ini sudah ada dengan metode login berbeda.';
      } else if (e.code == 'popup-closed-by-user') {
        errorMessage = 'Login Google dibatalkan oleh pengguna.';
      } else {
        errorMessage = e.message ?? 'Terjadi kesalahan saat login Google.';
      }
      if (mounted) {
        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
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

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Mohon masukkan email terlebih dahulu.', isError: true);
      return;
    }

    try {
      final result = await _authService.resetPassword(_emailController.text.trim());
      if (mounted) {
        if (result.success) {
          _showSnackBar('Link reset password telah dikirim ke email Anda.', isError: false);
        } else {
          _showSnackBar(result.message ?? 'Gagal mengirim email reset.', isError: true);
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Tidak ada pengguna terdaftar dengan email ini.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid.';
      } else {
        errorMessage = e.message ?? 'Terjadi kesalahan saat reset password.';
      }
      if (mounted) {
        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: ${e.toString()}', isError: true);
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
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset(
                          'assets/images/logo_google.png', // Pastikan path asset ini benar
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Login dengan Google',
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}