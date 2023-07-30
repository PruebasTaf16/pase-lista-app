import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:pase_lista_app/helpers/alerta.dart';
import 'package:pase_lista_app/providers/usuario_provider.dart';
import 'package:pase_lista_app/screens/private/home_page.dart';
import 'package:pase_lista_app/variables/api.dart';
import 'package:permission_handler/permission_handler.dart';

/**Pantalla para ejectuar el scanner QR y hacer el registro de la asistencia */
class QRScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final permissionStatus = await Permission.camera.request();

            if (!permissionStatus.isGranted) {
              mostrarAlerta(context, "Faltan permisos",
                  "Habilite los permisos para usar la cámara");
              return;
            }

            String result = await FlutterBarcodeScanner.scanBarcode(
              '#FF0000',
              'Cancelar',
              true,
              ScanMode.QR,
            );

            /**Si detecta algo en el QR, validar que sí sea un ID válido */
            if (result != '-1') {
              print('Código QR leído: $result');

              RegExp objectIdRegex = RegExp(r"^[0-9a-fA-F]{24}$");

              if (!objectIdRegex.hasMatch(result)) {
                mostrarAlerta(context, 'Error', 'QR inválido');
                return;
              }

              /**Obtenido el ID, se procede a registrar la asistencia del usuario */
              String diaID = result;
              try {
                dynamic userData = UsuarioProvider().usuarioData;

                Response response =
                    await Dio().post('$API_URL/asistencias/registrar', data: {
                  'idUsuario': userData['_id'],
                  'idDia': result,
                });

                mostrarAlerta(context, 'Correcto', 'Asistencia registrada');

                Navigator.of(context).pop();

                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) =>
                      false, // Eliminar todas las rutas anteriores
                );
              } catch (e) {
                if (e is DioException) {
                  print(e.response!.data);
                } else {
                  print(e);
                }
              }
            }
          },
          child: Text('Comenzar'),
        ),
      ),
    );
  }
}
