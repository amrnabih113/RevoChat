import 'package:animation/constants/colors.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  MyButton({super.key, this.onPressed, required this.child, this.style});

  final void Function()? onPressed;
  final Widget child;
  bool? style;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: style== null?gradientTeal: gradientTeal2,
        borderRadius: BorderRadius.circular(20),
      ),
      height: 60,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
