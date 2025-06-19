import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_darah/themes/colors.dart';

class InformasiScreen extends StatelessWidget {
  const InformasiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header dengan judul
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Center(
                child: Text(
                  'Informasi',
                  style: GoogleFonts.quicksand(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            // TabBar utama untuk Event Donor dan Artikel
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.darkText,
                labelStyle: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Event Donor'),
                  Tab(text: 'Artikel'),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Konten TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  // Konten untuk Tab 'Event Donor'
                  _buildEventDonorContent(),
                  // Konten untuk Tab 'Artikel'
                  _buildArticleContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDonorContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Colors.red.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Event Donor Darah',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Temukan event donor darah terbaru di sekitar Anda',
                    style: GoogleFonts.quicksand(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Event cards
            _buildEventCard(
              'Donor Darah Rutin PMI',
              '22 Juni 2025, 08:00 - 16:00',
              'PMI Kota Makassar',
              'Jl. Urip Sumoharjo No. 1',
              Colors.red.shade400,
            ),

            const SizedBox(height: 16),

            _buildEventCard(
              'Donor Darah Gratis',
              '25 Juni 2025, 09:00 - 15:00',
              'RS Wahidin Sudirohusodo',
              'Jl. Perintis Kemerdekaan KM 11',
              Colors.blue.shade400,
            ),

            const SizedBox(height: 16),

            _buildComingSoonCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
      String title, String date, String location, String address, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Event',
                  style: GoogleFonts.quicksand(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.bookmark_border,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.paragraph),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  date,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: AppColors.paragraph,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.paragraph),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: AppColors.paragraph,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      address,
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
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
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Event Lainnya Segera Hadir',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              color: AppColors.paragraph,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kami sedang menyiapkan lebih banyak event donor darah untuk Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: AppColors.paragraph,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.article,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Artikel Kesehatan',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pelajari lebih lanjut tentang donor darah dan kesehatan',
                    style: GoogleFonts.quicksand(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Article cards
            _buildArticleCard(
              'Persiapan Sebelum Donor Darah',
              'Tips penting yang harus Anda ketahui sebelum mendonorkan darah untuk pertama kali.',
              Colors.green.shade400,
            ),

            const SizedBox(height: 16),

            _buildArticleCard(
              'Manfaat Donor Darah Bagi Kesehatan',
              'Ternyata donor darah tidak hanya membantu orang lain, tapi juga bermanfaat untuk diri sendiri.',
              Colors.orange.shade400,
            ),

            const SizedBox(height: 16),

            _buildArticleCard(
              'Syarat dan Ketentuan Donor Darah',
              'Ketahui syarat-syarat yang harus dipenuhi untuk menjadi pendonor darah yang aman.',
              Colors.purple.shade400,
            ),

            const SizedBox(height: 16),

            _buildArticleCard(
              'Gaya Hidup Sehat untuk Pendonor',
              'Pola hidup sehat yang direkomendasikan bagi para pendonor darah aktif.',
              Colors.teal.shade400,
            ),

            const SizedBox(height: 16),

            _buildComingSoonArticleCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(String title, String excerpt, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Icon(
                Icons.bookmark_border,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            excerpt,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: AppColors.paragraph,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Baca selengkapnya',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonArticleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.article_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Artikel Lainnya Segera Hadir',
            style: GoogleFonts.quicksand(
              fontSize: 16,
              color: AppColors.paragraph,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kami sedang menyiapkan lebih banyak artikel edukatif untuk Anda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: AppColors.paragraph,
            ),
          ),
        ],
      ),
    );
  }
}
