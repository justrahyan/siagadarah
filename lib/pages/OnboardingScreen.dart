import 'package:flutter/material.dart';
import 'LoginScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_darah/themes/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Butuh Darah Cepat?",
      description:
          "Ajukan permintaan darah dalam hitungan detik. Kami bantu hubungkan dengan pendonor terdekat secepat mungkin.",
      imagePath: "assets/images/onboarding-1.png",
    ),
    OnboardingData(
      title: "Jadi Pahlawan Kapan Saja",
      description:
          "Aktifkan status pendonor siaga dan bantu sesama di saat darurat. Setiap tetes darahmu berarti kehidupan.",
      imagePath: "assets/images/onboarding-2.png",
    ),
    OnboardingData(
      title: "Info & Edukasi",
      description:
          "Dapatkan informasi penting seputar donor darah dan tips kesehatan langsung dari aplikasi.",
      imagePath: "assets/images/onboarding-3.png",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() {
                      _currentPage = index;
                    });
                  }
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Hero Illustration dengan error handling
          Expanded(
            flex: 3,
            child: Center(
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback jika gambar tidak ditemukan
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Page Indicator
          _buildPageIndicator(),

          const SizedBox(height: 40),

          // Title
          Text(
            data.title,
            style: GoogleFonts.quicksand(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            style: GoogleFonts.quicksand(
              fontSize: 15,
              color: AppColors.paragraph,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                _currentPage == index ? AppColors.primary : AppColors.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: _currentPage == _onboardingData.length - 1
          ? SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to login screen dengan pengecekan mounted
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Mulai Sekarang',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Skip to last page dengan pengecekan
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                  child: Text(
                    'Lewati',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: AppColors.paragraph,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Next page dengan pengecekan
                      if (mounted && _pageController.hasClients) {
                        if (_currentPage < _onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// Data models
class OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
