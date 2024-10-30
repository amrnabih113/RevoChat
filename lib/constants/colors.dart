import 'package:flutter/material.dart';

const Color teal = Color(0xff36B8B8);
const Color lightTeal = Color.fromARGB(92, 54, 184, 184);
Color? darkTeal = Colors.teal[800];
Color? medTeal = Colors.teal[300];
Color? grey = Colors.grey[700];
const Color white = Colors.white;
Color? lightGrey = Colors.grey[200];
Color? medGrey = Colors.grey[400];

const Color black = Colors.black;
const Gradient gradientTeal = LinearGradient(
  colors: [teal, lightTeal, black],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
Gradient gradientTeal2 = LinearGradient(
    colors: [teal, medTeal!, darkTeal!],
    end: Alignment.centerLeft,
    begin: Alignment.centerRight,
    stops: const [0.2, 0.4, 0.9]);
