import 'package:flutter/material.dart';
import 'dart:async';

class BannerSlide {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData decorIcon;
  final List<Color> gradientColors;

  BannerSlide({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.decorIcon,
    required this.gradientColors,
  });
}

class AppBanner extends StatefulWidget {
  const AppBanner({super.key});

  @override
  State<AppBanner> createState() => _AppBannerState();
}

class _AppBannerState extends State<AppBanner> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Timer? _autoSlideTimer;
  int _currentSlide = 0;

  bool _showTextAnimation = true;

  final List<BannerSlide> _slides = [
    BannerSlide(
      imagePath: 'assets/images/daily_mindfulness_background.png',
      title: 'Welcome to MyApp',
      subtitle:
          'Discover amazing features and unlock your potential with our innovative platform designed for modern users.',
      buttonText: 'Get Started',
      decorIcon: Icons.star,
      gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
    ),
    BannerSlide(
      imagePath: 'assets/images/audio_playing.png',
      title: 'Boost Your Productivity',
      subtitle:
          'Streamline your workflow with powerful tools and intuitive design that adapts to your needs.',
      buttonText: 'Learn More',
      decorIcon: Icons.rocket_launch,
      gradientColors: [Color(0xFFf093fb), Color(0xFFf5576c)],
    ),
    BannerSlide(
      imagePath: 'assets/images/daily_mindfulness_background.png',
      title: 'Join Our Community',
      subtitle:
          'Connect with thousands of users worldwide and share your experiences in our vibrant community.',
      buttonText: 'Join Now',
      decorIcon: Icons.people,
      gradientColors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    ),
    BannerSlide(
      imagePath: 'assets/images/audio_playing.png',
      title: 'Premium Features',
      subtitle:
          'Upgrade to unlock advanced features and get priority support for the ultimate experience.',
      buttonText: 'Upgrade',
      decorIcon: Icons.diamond,
      gradientColors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 1.1,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start initial animations
    _fadeController.forward();
    _slideController.forward();

    // Start auto-slide timer
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentSlide < _slides.length - 1) {
        _nextSlide();
      } else {
        _goToSlide(0);
      }
    });
  }

  void _restartAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _startAutoSlide();
  }

  void _nextSlide() {
    if (_currentSlide < _slides.length - 1) {
      _goToSlide(_currentSlide + 1);
    }
  }

  void _previousSlide() {
    if (_currentSlide > 0) {
      _goToSlide(_currentSlide - 1);
    }
  }

  void _goToSlide(int index) {
    _restartAutoSlideTimer();

    setState(() {
      _showTextAnimation = false;
      _currentSlide = index;
    });

    () async {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );

      setState(() {
        _showTextAnimation = true;
      });

      _slideController.reset();
      _slideController.forward();

      // _fadeController.reset();
      // _fadeController.forward();
    }();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildSlide(BannerSlide slide) {
    return Stack(
      children: [
        // Background Image with scale animation
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(slide.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),

        // Animated Text Content
        Visibility(
          visible: _showTextAnimation,
          child: Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Title - slides from left
                SlideTransition(
                  position: _titleSlideAnimation,
                  child: Text(
                    slide.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle - slides from right
                SlideTransition(
                  position: _subtitleSlideAnimation,
                  child: Text(
                    slide.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Call to Action Button - fades in
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(colors: slide.gradientColors),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print('${slide.buttonText} pressed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slide.buttonText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Decorative Elements
        Visibility(
          visible: _showTextAnimation,
          child: Positioned(
            top: 30,
            right: 30,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(slide.decorIcon, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // PageView for slides
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  _restartAutoSlideTimer();
                  setState(() {
                    _currentSlide = index;
                  });
                },
                children: _slides.map((slide) => _buildSlide(slide)).toList(),
              ),
              // PageView.builder(
              //   controller: _pageController,
              //   itemCount: _slides.length,
              //   onPageChanged: (index) {
              //     setState(() {
              //       _currentSlide = index;
              //     });
              //   },
              //   children: _slides.map((slide) => _buildSlide(slide)).toList(),
              // ),

              // Navigation Controls
              Positioned(
                top: 20,
                left: 20,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _previousSlide,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _nextSlide,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Slide Indicators
              Positioned(
                bottom: 16,
                right: 24,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _slides.length,
                    (index) => GestureDetector(
                      onTap: () => _goToSlide(index),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentSlide == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
