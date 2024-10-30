import 'package:animation/constants/colors.dart';
import 'package:flutter/material.dart';

class MyNavigationBar extends StatelessWidget {
  const MyNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: gradientTeal2,
        borderRadius: BorderRadius.circular(100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              label: "Groups",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin_outlined),
              label: "Contacts",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: "Settings",
            ),
          ],
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          selectedItemColor: white,
          unselectedItemColor: black,
          showUnselectedLabels: true,
          iconSize: 25,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
