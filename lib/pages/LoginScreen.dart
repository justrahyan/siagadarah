import 'package:flutter/material.dart';
import 'RegisterScreen.dart';
import 'main_screen.dart';
import 'phone_input_screen.dart';
import '../service/auth_service.dart';

class LoginScreen extends StatefulWidget {
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
        print('✅ Login successful, navigating to main screen');
        if (mounted) {
          _showSnackBar('Login berhasil!', isError: false);
          // Navigate to main screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      } else {
        print('❌ Login failed: ${result.message}');

        // Try alternative method - check if user is actually signed in
        final currentUser = _authService.currentUser;
        print('🔄 Checking current user: ${currentUser?.email}');

        if (currentUser != null) {
          print('🎯 User is actually signed in! Proceeding...');
          if (mounted) {
            _showSnackBar('Login berhasil!', isError: false);
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
      final result = await _authService.signInWithGoogle();

      print('📊 Google Sign-In result: ${result.success}');
      print('💬 Message: ${result.message}');
      print('👤 User: ${result.user?.email}');

      if (mounted) {
        if (result.success && result.user != null) {
          print('✅ Google Sign-In successful');
          _showSnackBar('Login berhasil!', isError: false);

          // Small delay to ensure UI updates properly
          await Future.delayed(Duration(milliseconds: 500));

          // Check if user needs to input phone number
          if (result.needsPhoneNumber) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PhoneInputScreen(
                  userId: result.user!.uid,
                  userName: result.user!.displayName ?? 'User',
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
        } else {
          print('❌ Google Sign-In failed: ${result.message}');

          // Check if user is actually signed in despite the error
          final currentUser = _authService.currentUser;
          print(
              '🔄 Checking current user after Google Sign-In: ${currentUser?.email}');

          if (currentUser != null) {
            print('🎯 User is actually signed in with Google! Proceeding...');
            _showSnackBar('Login berhasil!', isError: false);

            await Future.delayed(Duration(milliseconds: 500));

            // Check if user data exists and needs phone number
            final userData = await _authService.getUserData(currentUser.uid);
            if (userData != null &&
                (userData['needsPhoneNumber'] == true ||
                    userData['phone'] == '' ||
                    userData['phone'] == null)) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PhoneInputScreen(
                    userId: currentUser.uid,
                    userName: currentUser.displayName ?? 'User',
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            }
          } else {
            _showSnackBar(result.message ?? 'Google login gagal',
                isError: true);
          }
        }
      }
    } catch (e) {
      print('💥 Exception during Google Sign-In: $e');
      print('🔍 Exception type: ${e.runtimeType}');

      if (mounted) {
        // Check if user is signed in despite the exception
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          print('🎯 User signed in despite exception! Proceeding...');
          _showSnackBar('Login berhasil!', isError: false);

          await Future.delayed(Duration(milliseconds: 500));

          // Check if user data exists and needs phone number
          final userData = await _authService.getUserData(currentUser.uid);
          if (userData != null &&
              (userData['needsPhoneNumber'] == true ||
                  userData['phone'] == '' ||
                  userData['phone'] == null)) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PhoneInputScreen(
                  userId: currentUser.uid,
                  userName: currentUser.displayName ?? 'User',
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          }
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

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF2F2), // Light pink background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),

              // Title
              Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: 8),

              // Subtitle
              Center(
                child: Text(
                  'Masuk untuk mulai menggunakan aplikasi.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              SizedBox(height: 50),

              // Email Field
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'ival_p@gmail.com',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Password Field
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade600,
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

              SizedBox(height: 16),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  child: Text(
                    'Lupa Password?',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 24),

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
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Atau',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
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

              SizedBox(height: 24),

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
                      // Simple Google Icon
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Login dengan Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Register link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
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
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
