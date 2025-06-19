import 'package:flutter/material.dart';
import 'package:siaga_darah/themes/colors.dart';
import 'dart:async';
import 'OnboardingScreen.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Text fade animation
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    // Loading animation
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.notification,
      Permission.storage,
      // Tambahan: Permission.photos jika kamu butuh akses galeri (iOS)
    ].request();

    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Diperlukan'),
            content: const Text(
                'Beberapa izin ditolak permanen. Silakan buka pengaturan aplikasi untuk mengaktifkan secara manual.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                },
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _startAnimations() async {
    // Start logo animation
    await _logoController.forward();

    // Start text animation after logo
    await _textController.forward();

    // Start loading animation
    _loadingController.repeat();

    await Future.delayed(const Duration(milliseconds: 500));

    // Minta izin
    await _requestPermissions();

    // Lanjut ke Onboarding
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo dengan animasi
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoFadeAnimation.value,
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Image.asset(
                          'assets/images/logo/siaga-darah-logo-red.png', // Logo asli Anda
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Text dengan animasi fade in
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFadeAnimation.value,
                    child: const Text(
                      'SiagaDarah',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        letterSpacing: 1.2,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),

              // Subtitle
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFadeAnimation.value * 0.7,
                    child: Text(
                      'Donor Darah Digital',
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.paragraph,
                        letterSpacing: 0.5,
                        fontFamily: 'QuickSand',
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 2),

              // Loading indicator
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFadeAnimation.value,
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _loadingAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
