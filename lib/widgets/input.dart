import 'package:flutter/material.dart';

/**TextInput personalizado  */
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPasswordMode;

  CustomTextField(
      {required this.controller,
      required this.hintText,
      required this.isPasswordMode});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: isPasswordMode ? true : false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
