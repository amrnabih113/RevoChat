import 'package:animation/UI/screens/authScreen.dart';
import 'package:animation/UI/screens/onboardingscreen.dart';
import 'package:animation/constants/colors.dart';
import 'package:animation/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(_controller);

    _checkFirstTime();
    _navigateToNextScreen();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    isFirstTime = prefs.getBool('isFirstTime') ?? true;
    debugPrint('Is first time: $isFirstTime');

    if (isFirstTime) {
      debugPrint('Setting isFirstTime to false in SharedPreferences');
      await prefs.setBool('isFirstTime', false);
    }
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      debugPrint(
          'Navigating to: ${isFirstTime ? 'OnboardingScreen' : 'AuthScreen'}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isFirstTime ? const OnboardingScreen() : const AuthScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(gradient: gradientTeal2),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Assets.images.logo.image(
              height: 100,
              width: 100,
            ),
          ),
        ),
      ),
    );
  }
}
