import 'package:flutter/foundation.dart';

/**Provider para almacenar la información del QR */
class QRProvider with ChangeNotifier {
  static QRProvider _instance = QRProvider._internal();
  factory QRProvider() => _instance;

  QRProvider._internal();

  dynamic _qr = "";

  dynamic get qr => _qr;

  void setQR(dynamic qr) {
    _qr = qr;
    notifyListeners();
  }
}
