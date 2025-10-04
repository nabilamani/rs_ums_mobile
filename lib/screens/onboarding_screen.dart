import 'package:flutter/material.dart';
import 'package:rs_ums_test/screens/login_screen.dart';
import 'package:rs_ums_test/utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = const [
    OnboardingData(
      title: "Selamat Datang di RS UMS",
      description:
          "Kelola jadwal kerja, presensi, dan informasi rumah sakit dengan mudah dalam satu aplikasi",
      icon: Icons.local_hospital,
      color: Color(0xFF009688),
    ),
    OnboardingData(
      title: "Jadwal & Presensi",
      description:
          "Lihat jadwal kerja Anda dan lakukan presensi dengan cepat menggunakan sistem fingerprint digital",
      icon: Icons.calendar_today,
      color: Color(0xFF00796B),
    ),
    OnboardingData(
      title: "Informasi Terkini",
      description:
          "Dapatkan berita dan informasi terbaru seputar RS UMS langsung di genggaman Anda",
      icon: Icons.notifications_active,
      color: Color(0xFF004D40),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

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
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    "Lewati",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
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
                  return OnboardingPage(data: _onboardingData[index]);
                },
              ),
            ),

            // Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          _currentPage - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_back, size: 20),
                          SizedBox(width: 4),
                          Text("Kembali"),
                        ],
                      ),
                    )
                  else
                    const SizedBox(),

                  // Next/Start button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _currentPage == _onboardingData.length - 1
                              ? "Mulai"
                              : "Lanjut",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animated container
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon,
                  size: 80,
                  color: data.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}