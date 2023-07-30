bool validarCorreo(String correo) {
  final patronCorreo = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  return patronCorreo.hasMatch(correo);
}
