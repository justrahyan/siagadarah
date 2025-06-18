import 'package:flutter/material.dart';
import 'LoginScreen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: "Butuh Darah Cepat?",
      description:
          "Ajukan permintaan darah dalam hitungan detik.\nKami bantu hubungkan dengan pendonor terdekat\nsecepat mungkin.",
      heroType: HeroType.bloodRequest,
    ),
    OnboardingData(
      title: "Jadi Pahlawan Kapan Saja",
      description:
          "Aktifkan status pendonor siaga dan bantu sesama\ndi saat darurat. Setiap tetes darahmu berarti\nkehidupan.",
      heroType: HeroType.hero,
    ),
    OnboardingData(
      title: "Info & Edukasi",
      description:
          "Dapatkan informasi penting seputar donor darah\ndan tips kesehatan langsung dari aplikasi.",
      heroType: HeroType.education,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF2F2), // Light pink background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
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
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          SizedBox(height: 40),

          // Hero Illustration
          Expanded(
            flex: 3,
            child: Center(child: _buildHeroIllustration(data.heroType)),
          ),

          SizedBox(height: 20),

          // Page Indicator
          _buildPageIndicator(),

          SizedBox(height: 40),

          // Title
          Text(
            data.title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16),

          // Description
          Text(
            data.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeroIllustration(HeroType type) {
    switch (type) {
      case HeroType.bloodRequest:
        return _buildBloodRequestHero();
      case HeroType.hero:
        return _buildSuperheroHero();
      case HeroType.education:
        return _buildEducationHero();
    }
  }

  Widget _buildBloodRequestHero() {
    return Container(
      width: 300,
      height: 320,
      child: Stack(
        children: [
          // Background building/hospital elements
          Positioned(
            left: 30,
            bottom: 40,
            child: Container(
              width: 50,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 40,
            child: Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            left: 80,
            bottom: 40,
            child: Container(
              width: 70,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Main character with phone
          Positioned(
            right: 80,
            bottom: 80,
            child: Container(
              width: 80,
              height: 160,
              child: Column(
                children: [
                  // Head
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFDBAE), // Skin tone
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        // Hair
                        Positioned(
                          top: 2,
                          left: 5,
                          right: 5,
                          child: Container(
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  // Body
                  Container(
                    width: 45,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 6),
                  // Legs
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Phone/notification in hand
          Positioned(
            right: 50,
            bottom: 140,
            child: Container(
              width: 20,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Notification bell icon
          Positioned(
            left: 60,
            bottom: 160,
            child: Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_active,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Alert lines
          Positioned(
            left: 45,
            bottom: 175,
            child: Container(
              width: 3,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.red.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            left: 50,
            bottom: 180,
            child: Container(
              width: 3,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperheroHero() {
    return Container(
      width: 300,
      height: 320,
      child: Stack(
        children: [
          // Background elements
          Positioned(
            left: 40,
            bottom: 60,
            child: Container(
              width: 40,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Main superhero character
          Positioned(
            left: 100,
            bottom: 60,
            child: Container(
              width: 100,
              height: 200,
              child: Column(
                children: [
                  // Head
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFDBAE), // Skin tone
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        // Hair
                        Positioned(
                          top: 2,
                          left: 5,
                          right: 5,
                          child: Container(
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // Body with cape
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cape
                      Positioned(
                        left: -30,
                        top: 0,
                        child: Container(
                          width: 90,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.pink.shade300,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(45),
                              bottomRight: Radius.circular(45),
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      // Body
                      Container(
                        width: 50,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Legs
                  Container(
                    width: 40,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationHero() {
    return Container(
      width: 300,
      height: 320,
      child: Stack(
        children: [
          // Background elements
          Positioned(
            left: 20,
            bottom: 80,
            child: Container(
              width: 50,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 60,
            child: Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Large Calendar
          Positioned(
            right: 60,
            bottom: 100,
            child: Container(
              width: 140,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.shade300, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Calendar header
                  Container(
                    width: double.infinity,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => Container(
                          width: 3,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Calendar body
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          // First row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCalendarDate(false),
                              _buildCalendarDate(true),
                              _buildCalendarDate(false),
                              _buildCalendarDate(false),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Second row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCalendarDate(false),
                              _buildCalendarDate(false),
                              _buildCalendarDate(true),
                              _buildCalendarDate(false),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Third row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCalendarDate(false),
                              _buildCalendarDate(false),
                              _buildCalendarDate(false),
                              _buildCalendarDate(true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Character pointing at calendar
          Positioned(
            left: 80,
            bottom: 60,
            child: Container(
              width: 80,
              height: 160,
              child: Column(
                children: [
                  // Head
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFDBAE), // Skin tone
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        // Hair
                        Positioned(
                          top: 2,
                          left: 5,
                          right: 5,
                          child: Container(
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  // Body
                  Container(
                    width: 45,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.brown.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 6),
                  // Legs
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pointing hand/arm
          Positioned(
            left: 125,
            bottom: 140,
            child: Container(
              width: 30,
              height: 8,
              decoration: BoxDecoration(
                color: Color(0xFFFFDBAE),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDate(bool isSelected) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isSelected ? Colors.red.shade400 : Colors.transparent,
        shape: BoxShape.circle,
        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: isSelected
          ? Icon(Icons.favorite, color: Colors.white, size: 10)
          : Container(),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.red.shade400
                : Colors.red.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(24),
      child: _currentPage == _onboardingData.length - 1
          ? SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to login screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Mulai Sekarang',
                  style: TextStyle(
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
                    // Skip to last page
                    _pageController.animateToPage(
                      _onboardingData.length - 1,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    icon: Icon(
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
  final HeroType heroType;

  OnboardingData({
    required this.title,
    required this.description,
    required this.heroType,
  });
}

enum HeroType { bloodRequest, hero, education }
