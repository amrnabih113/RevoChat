import 'package:animation/constants/colors.dart';
import 'package:flutter/material.dart';

class ConstantFuncs {
  TextStyle mainTextStyle() {
    return const TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle secondaryTextStyle() {
    return TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: grey);
  }
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    const String emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  void showErrorDialog(BuildContext context,String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}