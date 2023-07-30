import 'package:flutter/material.dart';

/**Botón con diseño 2 */
class Button2 extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  bool deshabilitado;

  Button2(
      {required this.onPressed,
      required this.title,
      this.deshabilitado = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 42, 40, 59),
        borderRadius: BorderRadius.circular(10),
        border: deshabilitado
            ? null
            : Border.all(
                color: const Color.fromARGB(235, 9, 92, 246),
                width: 3,
              ),
      ),
      child: TextButton(
        onPressed: deshabilitado ? null : onPressed,
        child: Text(
          title,
          style: TextStyle(
            color: deshabilitado
                ? Colors.grey
                : const Color.fromARGB(255, 249, 249, 249),
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
