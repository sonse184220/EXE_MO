import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF89B7C2), // SPRING SKY
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF89B7C2), // SPRING SKY
              Color(0xFFA8BF8A), // MEADOW
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha((0.9 * 255).round()),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).round()),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(20), // Add padding so the heart fits nicely in the circle
                    child: Image.asset(
                      'assets/images/appLogo.png', // Replace with your actual image path
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // const Icon(
                //   Icons.child_care,
                //   size: 60,
                //   color: Color(0xFFE37083), // RASPBERRY
                // ),
              ),

              const SizedBox(height: 40),

              // App Name
              const Text(
                'InnerChild',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'by Serenity Team',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha((0.9 * 255).round()),
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 60),

              // Loading Animation
              LoadingAnimationWidget.threeArchedCircle(
                color: const Color(0xFFFFB876), // PAPAYA
                size: 50,
              ),

              const SizedBox(height: 24),

              // Loading Text
              Text(
                'Initializing your wellness journey...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha((0.8 * 255).round()),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 80),

              // EXE201 Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withAlpha((0.3 * 255).round()),
                    width: 1,
                  ),
                ),
                child: Text(
                  'EXE201',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha((0.9 * 255).round()),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
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