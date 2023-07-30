import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pase_lista_app/providers/notificaciones_provider.dart';
import 'package:pase_lista_app/providers/auth_provider.dart';
import 'package:pase_lista_app/screens/login_page.dart';
import 'package:pase_lista_app/screens/private/historial_page.dart';
import 'package:pase_lista_app/screens/private/home_page.dart';
import 'package:pase_lista_app/screens/private/perfil_page.dart';
import 'package:pase_lista_app/screens/private/qr.dart';
import 'package:pase_lista_app/screens/recuperar_page.dart';
import 'package:pase_lista_app/utils/fechas.dart';
import 'package:pase_lista_app/variables/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() async {
  /**Ejecutar tareaen segundo plano (notificaciones de asistencia) */
  Workmanager().executeTask((taskName, inputData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJSONString = prefs.getString('user') ?? '{}';

    /** Si detecta que hay datos del usuario, calculará la hora y disparará la notificación de acuerdo a las condiciones*/
    if (userJSONString != '{}') {
      Map<String, dynamic> userData = json.decode(userJSONString);
      DateTime horarioEntrada =
          obtenerHorarioLocal(userData['idRol']['horarioEntrada']);
      int tiempoAntesEntrada = userData['idRol']['tiempoAntesEntrada'];
      int tiempoMaxTolerancia = userData['idRol']['tiempoMaxTolerancia'];

      DateTime horarioMin =
          horarioEntrada.subtract(Duration(minutes: tiempoAntesEntrada));
      DateTime horarioMax =
          horarioEntrada.add(Duration(minutes: tiempoMaxTolerancia));

      DateTime ahora = DateTime.now();

      if (ahora.isAfter(horarioMin) &&
          ahora.isBefore(horarioMin.add(const Duration(minutes: 1)))) {
        await NotificationService().enviarNotificacion(
            id: 0,
            title: 'Esperando asistencia...',
            body: 'Ya puede registrar su asistencia');
      } else {
        print('Esperando...');
      }
      /**GENERACIÓN RECURSIVA */
      int randomID = DateTime.now().millisecondsSinceEpoch;
      /**Cada minuto volverá a ejectuar esta tarea */
      Workmanager().registerOneOffTask(
          'pase-lista${randomID.toString()}', 'asistencia',
          initialDelay: const Duration(seconds: 30));

      return Future.value(true);
    } else {
      return Future.value(true);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /** Iniciar el servicio de notificaciones*/
  NotificationService().iniciarNotificaciones();
  /**Iniciar el servicio de tareas de segundo plao */
  Workmanager().initialize(callbackDispatcher);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String jwt = prefs.getString('jwt') ?? "{}";

  /**Si detecta el JWT Token, manda a home */
  if (jwt == "{}") {
    runApp(MyApp(initialRoute: 'login'));
  } else {
    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = "Bearer ${jwt}";

      Response response = await dio.get('$API_URL/auth/obtener-info');

      /**ALMACENAR DE FORMA LOCAL ESTE DATO */
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jsonString = json.encode(response.data['data']);

      await prefs.setString('user', jsonString);
      runApp(MyApp(initialRoute: 'home'));
    } catch (e) {
      print('error');
      print(e);
      runApp(MyApp(initialRoute: 'login'));
    }
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pase de lista',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: ThemeData.dark(),
      routes: {
        'login': (BuildContext context) => LoginPage(),
        'recuperar': (BuildContext context) => RecuperarPage(),
        'home': (BuildContext context) => HomePage(),
        'scanner': (BuildContext context) => QRScannerScreen(),
        'historial': (BuildContext context) => HistorialPage(),
        'perfil': (BuildContext context) => PerfilPage(),
      },
    );
  }
}
