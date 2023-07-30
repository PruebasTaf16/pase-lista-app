import 'package:flutter/foundation.dart';

/**Provider encargado de almacenar el token jwt */
class AuthProvider with ChangeNotifier {
  static AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;

  AuthProvider._internal();

  String? _jwt;

  String? get jwt => _jwt;

  void setJwt(String jwt) {
    _jwt = jwt;
    notifyListeners(); // Notifica a los listeners (observadores) sobre el cambio en el JWT
  }
}
