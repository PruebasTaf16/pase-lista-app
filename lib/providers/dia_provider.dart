import 'package:flutter/foundation.dart';

/**Provider para almacenar toda la data del dia de hoy */
class DiaProvider with ChangeNotifier {
  static DiaProvider _instance = DiaProvider._internal();
  factory DiaProvider() => _instance;

  DiaProvider._internal();

  dynamic _fechaData = "";

  dynamic get fechaData => _fechaData;

  void setFechaData(dynamic fechaData) {
    _fechaData = fechaData;
    notifyListeners();
  }
}
