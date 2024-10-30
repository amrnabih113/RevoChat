import 'package:animation/constants/colors.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  const MyTextField(
      {super.key,
      required this.controller,
      required this.isPassword,
      required this.hint,
      required this.icon,
      required this.label,
      this.validator});
  final TextEditingController controller;
  final bool isPassword;
  final String hint;
  final IconData icon;
  final String label;
  final String? Function(String?)? validator;
  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool showPassword = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.controller,
      obscureText: widget.isPassword ? showPassword : false,
      cursorColor: black,
      decoration: InputDecoration(
        hintText: widget.hint,
        icon: Icon(
          widget.icon,
          size: 30,
        ),
        iconColor: teal,
        label: Text(widget.label),
        labelStyle: const TextStyle(
            color: teal, fontSize: 18, fontWeight: FontWeight.bold),
        hintStyle: TextStyle(color: lightGrey),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
                icon: showPassword
                    ? const Icon(
                        Icons.visibility_outlined,
                        color: teal,
                      )
                    : const Icon(
                        Icons.visibility_off_outlined,
                        color: teal,
                      ))
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: white,
      ),
    );
  }
}
