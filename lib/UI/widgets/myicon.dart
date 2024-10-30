import 'package:flutter/material.dart';

class MyIcon extends StatelessWidget {
  const MyIcon({super.key, required this.imageurl, this.onTap});
  final String imageurl;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Image.asset(
          imageurl,
          height: 50,
          width: 0,
        ),
      ),
    );
  }
}
