import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pase_lista_app/providers/notificaciones_provider.dart';
import 'package:pase_lista_app/providers/ubicacion_provider.dart';
import 'package:pase_lista_app/providers/dia_provider.dart';
import 'package:pase_lista_app/providers/usuario_provider.dart';
import 'package:pase_lista_app/screens/login_page.dart';
import 'package:pase_lista_app/screens/private/historial_page.dart';
import 'package:pase_lista_app/screens/private/justificante_page.dart';
import 'package:pase_lista_app/screens/private/perfil_page.dart';
import 'package:pase_lista_app/screens/private/qr.dart';
import 'package:pase_lista_app/utils/fechas.dart';
import 'package:pase_lista_app/variables/api.dart';
import 'package:pase_lista_app/widgets/button1.dart';
import 'package:pase_lista_app/widgets/button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/**Núcleo central de la aplicación, pantalla principal */
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic usuarioData = {"_id": null, "nombre": null};

  dynamic fechaData = "";
  String _fecha = "cargando...";

  bool _puedeRegistrarAsistencia = false;
  bool _puedeMandarJustificante = false;

  dynamic asistenciaData = {"_id": null};
  String _estadoAsistencia = "Cargando...";

  /**Obtener la fecha de hoy desde la base de datos */
  void fetchDataHoy() async {
    try {
      Response response = await Dio().get('$API_URL/dias/hoy');

      setState(() {
        fechaData = response.data['data'];
        DiaProvider().setFechaData(fechaData);
        _fecha = fechaData['fecha'].toString().split('T')[0];
      });
    } catch (e) {
      print(e);
      setState(() {
        fechaData = null;
      });
    }
  }

  /**Obtener los datos del usuario */
  void fetchUsuarioData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwt = prefs.getString('jwt') ?? "{}";

    /**Si no encuentra el token, manda a la pantalla de login */
    if (jwt == "{}") {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }

    /** Se obtiene la información desde el token, y en caso de que no sirva, mandará a la pantalla del login*/
    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = "Bearer ${jwt}";

      Response response = await dio.get('$API_URL/auth/obtener-info');

      /**ALMACENAR DE FORMA LOCAL ESTE DATO */
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jsonString = json.encode(response.data['data']);
      await prefs.setString('user', jsonString);

      setState(() {
        usuarioData = response.data['data'];
        UsuarioProvider().setUsuarioData(usuarioData);

        /**Disparar la actividad en segundo plano para calcular la notif de asistencia*/
        Workmanager().registerOneOffTask('pase-lista', 'asistencia',
            initialDelay: const Duration(minutes: 1));

        /**Obtenido la info del usuario, se obtiene su estado de asistencia y de acuerdo al horario, determinar si puede realizar su registro de asistencia o generación de justificante*/
        fetchEstadoAsistencia();
        _verifificarSiPuedeRegistrarAsistencia();
        _verificarSiPuedeMandarJustificante();
      });
    } catch (e) {
      print('error');
      print(e);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  /**Obtener el estado de la asistencia */
  void fetchEstadoAsistencia() async {
    try {
      Response response = await Dio().get(
          "$API_URL/asistencias/hoy/${usuarioData['_id']}/${fechaData['_id']}");

      setState(() {
        asistenciaData = response.data['data'];
        _estadoAsistencia =
            asistenciaData['idEstadoAsistencia']['nombre'] ?? "Sin registrar";

        _verifificarSiPuedeRegistrarAsistencia();
        _verificarSiPuedeMandarJustificante();
      });
    } catch (e) {
      setState(() {
        _estadoAsistencia = "";
      });
    }
  }

  @override
  initState() {
    super.initState();
    UbicacionService()
        .validarUbicacion(context)
        .then((value) => {NotificationService().solicitarPermisos(context)});

    fetchDataHoy();
    fetchUsuarioData();
  }

  /**Calcular el horario para ver si se puede registrar */
  void _verifificarSiPuedeRegistrarAsistencia() {
    DateTime horarioEntrada =
        obtenerHorarioLocal(usuarioData['idRol']['horarioEntrada']);
    int tiempoAntesEntrada = usuarioData['idRol']['tiempoAntesEntrada'];
    int tiempoMaxTolerancia = usuarioData['idRol']['tiempoMaxTolerancia'];

    DateTime horarioMin =
        horarioEntrada.subtract(Duration(minutes: tiempoAntesEntrada));
    DateTime horarioMax =
        horarioEntrada.add(Duration(minutes: tiempoMaxTolerancia));

    DateTime horaFechaActual = DateTime.now();

    if (asistenciaData['_id'] != null) {
      setState(() {
        _puedeRegistrarAsistencia = false;
      });
      return;
    }

    if (horaFechaActual.isAfter(horarioMin) &&
        horaFechaActual.isBefore(horarioMax)) {
      setState(() {
        _puedeRegistrarAsistencia = true;
      });
    } else {
      setState(() {
        _puedeRegistrarAsistencia = false;
        _estadoAsistencia = "Inasistencia";
      });
    }
  }

  /**Calcular el horario para determinar si se mandará justificante */
  void _verificarSiPuedeMandarJustificante() async {
    DateTime horarioEntrada =
        obtenerHorarioLocal(usuarioData['idRol']['horarioEntrada']);
    int tiempoAntesEntrada = usuarioData['idRol']['tiempoAntesEntrada'];
    DateTime horarioMin =
        horarioEntrada.subtract(Duration(minutes: tiempoAntesEntrada));

    DateTime horarioSalida =
        obtenerHorarioLocal(usuarioData['idRol']['horarioSalida']);

    DateTime horaFechaActual = DateTime.now();

    if (horarioSalida.isBefore(horarioEntrada)) {
      horarioSalida = horarioSalida.add(Duration(days: 1));
    }

    print(horarioSalida);

    if (asistenciaData['_id'] != null) {
      setState(() {
        _puedeMandarJustificante = false;
      });
      return;
    }

    if (horaFechaActual.isAfter(horarioMin) &&
        horaFechaActual.isBefore(horarioSalida)) {
      setState(() {
        _puedeMandarJustificante = true;
      });
    } else {
      setState(() {
        _puedeMandarJustificante = false;
      });
    }
  }

  /**Cerrar la sesión */
  void _cerrarSesion(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Confirmar'),
            content: const Text('Desea cerrar la sesión'),
            actions: [
              TextButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    await prefs.remove('jwt');
                    await prefs.remove('user');
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();

                    // ignore: use_build_context_synchronously
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) =>
                          false, // Eliminar todas las rutas anteriores
                    );
                  },
                  child: const Text('Si')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'))
            ],
          );
        });
  }

  /**INDICE BOTTOM NAVIGATION BAR*/
  int _currentIndex = 0;

  /**LISTADO DE PÁGINAS*/
  final List<Widget> _pantallas = [
    const HomePage(),
    const HistorialPage(),
    const PerfilPage(),
  ];

  /**EVENTO PRESIONAR ITEM BOTTOM NAVIGATION BAR */
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => _pantallas[_currentIndex]),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia QR'),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                _cerrarSesion(context);
              },
              icon: const Icon(
                Icons.login_outlined,
                color: Color.fromARGB(235, 9, 92, 246),
              ))
        ],
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      body: Container(
        padding:
            const EdgeInsets.only(right: 20, left: 20, top: 40, bottom: 40),
        child: Column(
          children: [
            Column(
              children: [
                const Text(
                  'Asistencia de hoy',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _fecha,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                const Text(
                  'Estado de la Asistencia:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _estadoAsistencia,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Button1(
              onPressed: () async {
                if (await UbicacionService().validarUbicacion(context)) {
                  // ignore: use_build_context_synchronously
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => QRScannerScreen()));
                }
              },
              title: 'Registrar Asistencia',
              deshabilitado: !_puedeRegistrarAsistencia,
            ),
            const SizedBox(height: 40),
            Button2(
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const JustificantePage()));
              },
              title: 'Enviar Justificante',
              deshabilitado: !_puedeMandarJustificante,
            ),
            // ElevatedButton(
            //   child: const Text('Show notifications'),
            //   onPressed: () async {
            //     Workmanager().registerOneOffTask('pase-lista', 'asistencia',
            //         initialDelay: const Duration(seconds: 10));
            //   },
            // )
          ],
        ),
      ),
    );
  }
}
