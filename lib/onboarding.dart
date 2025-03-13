import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "animation": "assets/lottie/access.json",
      "title": "Set Your Secure PIN",
      "description":
          "Protect your credentials with a 5-digit PIN to ensure maximum security."
    },
    {
      "animation": "assets/lottie/add_cred.json",
      "title": "Add Your Credentials",
      "description":
          "Store your important credentials in one secure place, easily accessible anytime."
    },
    {
      "animation": "assets/lottie/security.json",
      "title": "Use Your Credentials",
      "description":
          "Retrieve and manage your credentials securely whenever you need them."
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    // Redirect to Agreement Page instead of PIN setup
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/agreement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingData.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return _buildOnboardingPage(
                  _onboardingData[index]["animation"]!,
                  _onboardingData[index]["title"]!,
                  _onboardingData[index]["description"]!,
                );
              },
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(
      String animation, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(animation, width: 250, height: 250, fit: BoxFit.contain),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: () {
              if (_currentPage == _onboardingData.length - 1) {
                _completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE566),
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            _buildButton("Back", () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            }),
          _buildButton(
              _currentPage == _onboardingData.length - 1
                  ? "Get Started"
                  : "Next", () {
            if (_currentPage == _onboardingData.length - 1) {
              _completeOnboarding();
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE566),
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4))
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
