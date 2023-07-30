import 'package:flutter/foundation.dart';

/**Provider para almacenar la información del usuario */
class UsuarioProvider with ChangeNotifier {
  static UsuarioProvider _instance = UsuarioProvider._internal();
  factory UsuarioProvider() => _instance;

  UsuarioProvider._internal();

  dynamic _usuarioData = {"_id": null, "nombre": null};

  dynamic get usuarioData => _usuarioData;

  void setUsuarioData(dynamic usuarioData) {
    _usuarioData = usuarioData;
    notifyListeners();
  }
}
