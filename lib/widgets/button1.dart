import 'package:flutter/material.dart';

/**Botón con diseño 1 */
class Button1 extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  bool deshabilitado;

  Button1(
      {required this.onPressed,
      required this.title,
      this.deshabilitado = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 70),
      width: 400,
      decoration: BoxDecoration(
        color:
            deshabilitado ? Colors.grey : const Color.fromARGB(235, 9, 92, 246),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: deshabilitado ? null : onPressed,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
