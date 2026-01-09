import 'package:flutter/material.dart';

import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const Color primaryBlue = Color(0xFF3F63F3);

  static const TextStyle kTitleStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.3,
    color: Color(0xFF111827),
  );

  static const TextStyle kSubtitleStyle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    height: 1.75,
    color: Color(0xFF6B7280),
  );

  final pages = const [
    _OnbData(
      imagePath: "assets/images/onb1.jpg",
      title: "Empower Your Home,\nSimplify Your Life",
      subtitle:
          "Transform your living space into a smarter,\nmore connected home with Smartify.\nAll at your fingertips.",
      primaryText: "Continue",
    ),
    _OnbData(
      imagePath: "assets/images/onb2.jpg",
      title: "Effortless Control,\nAutomate, & Secure",
      subtitle:
          "Smartify empowers you to control your\ndevices, & automate your routines. Embrace a\nworld where your home adapts to your needs",
      primaryText: "Continue",
    ),
    _OnbData(
      imagePath: "assets/images/onb3.jpg",
      title: "Efficiency that Saves,\nComfort that Lasts.",
      subtitle:
          "Take control of your home's energy usage, set\npreferences, and enjoy a space that adapts to\nyour needs while saving power.",
      primaryText: "Let’s Get Started",
    ),
  ];

  void _goNext() {
    if (_index < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _goAuth();
    }
  }

  void _skip() => _goAuth();

  void _goAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = pages[_index];
    final bool isLast = _index == pages.length - 1;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final h = c.maxHeight;
            final cardH = h * 0.44;
            final overlap = 40.0;

            return Stack(
              children: [
                // ===== IMAGE AREA =====
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: cardH - overlap),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (_, i) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Center(
                            child: FractionallySizedBox(
                              widthFactor: 0.78,
                              child: Image.asset(
                                pages[i].imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ===== WHITE CARD =====
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -overlap,
                  height: cardH + overlap,
                  child: Transform.translate(
                    offset: Offset(0, -overlap),
                    child: ClipPath(
                      clipper: _TopArcClipper(),
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 60, 24, 22),
                          child: Column(
                            children: [
                              Text(
                                data.title,
                                textAlign: TextAlign.center,
                                style: kTitleStyle,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                data.subtitle,
                                textAlign: TextAlign.center,
                                style: kSubtitleStyle,
                              ),
                              const Spacer(),

                              // DOTS
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(pages.length, (i) {
                                  final active = i == _index;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    width: active ? 34 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? primaryBlue
                                          : const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 22),

                              // BUTTONS
                              if (!isLast) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 54,
                                        child: ElevatedButton(
                                          onPressed: _skip,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                          ),
                                          child: const Text(
                                            "Skip",
                                            style: TextStyle(
                                              color: primaryBlue,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: SizedBox(
                                        height: 54,
                                        child: ElevatedButton(
                                          onPressed: _goNext,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryBlue,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                          ),
                                          child: Text(
                                            data.primaryText,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _goNext,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                    ),
                                    child: Text(
                                      data.primaryText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnbData {
  final String imagePath;
  final String title;
  final String subtitle;
  final String primaryText;

  const _OnbData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.primaryText,
  });
}

class _TopArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double dip = size.height * 0.18;

    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, dip, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
