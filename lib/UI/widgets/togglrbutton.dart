import 'package:flutter/material.dart';

class AuthToggleButtons extends StatelessWidget {
  final bool isLoginSelected;
  final Function(bool) onToggle; 

  const AuthToggleButtons({
    super.key,
    required this.isLoginSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 40,
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => onToggle(true), 
            child: Container(
              height: 40,
              width: 175,
              decoration: BoxDecoration(
                color:
                    isLoginSelected ? Colors.teal : Colors.transparent, 
                borderRadius: BorderRadius.circular(10),
                boxShadow: isLoginSelected
                    ? [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  "Log In",
                  style: TextStyle(
                    color: isLoginSelected ? Colors.white : Colors.teal,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onToggle(false), 
            child: Container(
              height: 40,
              width: 175,
              decoration: BoxDecoration(
                color:
                    !isLoginSelected ? Colors.teal : Colors.transparent, 
                borderRadius: BorderRadius.circular(10),
                boxShadow: !isLoginSelected
                    ? [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  "Register",
                  style: TextStyle(
                    color: !isLoginSelected ? Colors.white : Colors.teal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
