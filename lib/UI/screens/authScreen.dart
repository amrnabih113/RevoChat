import 'package:animation/UI/screens/loginscreen.dart';
import 'package:animation/UI/screens/signupscreen.dart';
import 'package:animation/UI/widgets/togglrbutton.dart';
import 'package:animation/constants/colors.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  bool isLoginSelected = true; 

  void _toggleAuth(bool isLoginSelected) {
    setState(() {
      this.isLoginSelected = isLoginSelected; 
    });

    _pageController.animateToPage(
      isLoginSelected ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: Column(
        children: [
          const SizedBox(height: 50),
          AuthToggleButtons(
            isLoginSelected: isLoginSelected, 
            onToggle: (isLoginSelected) => _toggleAuth(isLoginSelected),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                LogInScreen(),
                SignUpScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
