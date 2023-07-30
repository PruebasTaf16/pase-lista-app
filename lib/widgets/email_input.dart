import 'package:flutter/material.dart';

/**TextInput para correo */
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  EmailField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
