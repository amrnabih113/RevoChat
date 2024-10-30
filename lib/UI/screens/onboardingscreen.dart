import 'package:animation/constants/colors.dart';
import 'package:animation/constants/strings.dart';
import 'package:animation/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final List<String> words = [
    'Welcome to Chatboat, a great friend to chat with you',
    'If you are confused about what to do, just open the Chatboat app',
    'Chatboat will be ready to chat & make you happy',
  ];

  final List<Image> images = [
    Assets.images.welcome.image(height: 350, width: 350),
    Assets.images.welcome2.image(height: 350, width: 350),
    Assets.images.welcome3.image(height: 350, width: 350),
  ];

  final PageController _controller = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _alignAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _alignAnimation = Tween<Alignment>(
      begin: Alignment.centerRight,
      end: Alignment.center,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    _controller.addListener(() {
      int newIndex = _controller.page!.round();
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
          _animationController.forward(from: 0.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _imageWidget(Image image) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: image,
      ),
    );
  }

  Widget _skipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Opacity(
        opacity: 1,
        child: MaterialButton(
          onPressed: () {
            _controller.animateToPage(
              words.length - 1,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeIn,
            );
          },
          color: lightTeal,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
          child: const Text(
            "Skip",
            style: TextStyle(color: black, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _textWidget(String text) {
    return AlignTransition(
      alignment: _alignAnimation,
      child: SizedBox(
        width: 250,
        child: Text(
          text,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _nextButton(String text, int currentIndex) {
    return MaterialButton(
      onPressed: () {
        if (currentIndex < words.length - 1) {
          _controller.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            authscreen,
            (route) => false,
          );
        }
      },
      minWidth: double.infinity,
      color: teal,
      height: 55,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(50)),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: white,
        ),
      ),
    );
  }

  Widget _pageIndicatorWidget() {
    return Container(
      alignment: const Alignment(0, 0.85),
      child: SmoothPageIndicator(
        controller: _controller,
        count: words.length,
        effect: const WormEffect(
          dotHeight: 12,
          dotWidth: 12,
          activeDotColor: teal,
          dotColor: lightTeal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: List.generate(
              words.length,
              (index) => Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (index < 2) _skipButton(),
                    const SizedBox(height: 50),
                    _imageWidget(images[index]),
                    const SizedBox(height: 20),
                    _textWidget(words[index]),
                    const SizedBox(height: 95),
                    _nextButton(
                      index == words.length - 1 ? "Start" : "Next",
                      index,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _pageIndicatorWidget(),
        ],
      ),
    );
  }
}
