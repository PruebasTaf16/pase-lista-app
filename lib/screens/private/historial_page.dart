import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pase_lista_app/providers/usuario_provider.dart';
import 'package:pase_lista_app/screens/private/home_page.dart';
import 'package:pase_lista_app/screens/private/perfil_page.dart';
import 'package:pase_lista_app/utils/fechas.dart';
import 'package:pase_lista_app/variables/api.dart';

/**Pantalla para ver el historial del usuario referente a las asistencias de esta semana*/
class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  dynamic semanalData = {
    "asistenciaUsuario": [],
    "listadoSemanal": [],
  };
  dynamic usuarioData = {};

  /**INDICE BOTTOM NAVIGATION BAR*/
  int _currentIndex = 1;

  /**LISTADO DE PÁGINAS*/
  final List<Widget> _pantallas = [
    HomePage(),
    HistorialPage(),
    PerfilPage(),
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

  fetchData() async {
    try {
      Response response = await Dio()
          .get("$API_URL/asistencias/listado-semanal/${usuarioData['_id']}");
      setState(() {
        semanalData = response.data['data'];
      });
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null);
    usuarioData = UsuarioProvider().usuarioData;
    fetchData();
  }

  // 1. Función para mostrar el modal
  void _mostrarModal(BuildContext context, dynamic dia, dynamic asistencia) {
    String fechaFormateada =
        DateFormat('d MMMM y', 'es').format(DateTime.parse(dia['fecha']));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la asistencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID asistencia: ${asistencia['_id']}'),
              const SizedBox(height: 10),
              Text('Fecha: ${fechaFormateada}'),
              Text(
                  'Hora: ${formatTimeTo24Hours(obtenerHorarioLocal(asistencia['horaAsistencia']))}'),
              const SizedBox(height: 10),
              Text('Estado: ${asistencia['idEstadoAsistencia']['nombre']}'),
              // ...otros detalles que quieras mostrar...
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semanal'),
        elevation: 0,
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
      body: ListView.builder(
        padding: EdgeInsets.only(top: 40.0, left: 20, right: 20),
        itemCount: semanalData['listadoSemanal'].length,
        itemBuilder: (context, index) {
          dynamic dia = semanalData['listadoSemanal'][index];
          dynamic asistenciaFound = {};
          bool coincide = false;

          for (dynamic asistencia in semanalData['asistenciaUsuario']) {
            if (dia['_id'] == asistencia['idDia']) {
              /**SI ENCUENTRA COINCIDENCIA */
              asistenciaFound = asistencia;
              coincide = true;
              break;
            }
          }

          String fechaFormateada =
              DateFormat('d MMMM y', 'es').format(DateTime.parse(dia['fecha']));

          return Card(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: GestureDetector(
              onTap: !coincide
                  ? null
                  : () => {_mostrarModal(context, dia, asistenciaFound)},
              child: ListTile(
                tileColor: coincide
                    ? (asistenciaFound['idEstadoAsistencia']['nombre'] ==
                            'Asistencia normal'
                        ? Colors.green
                        : Colors.orange)
                    : null,
                title: Text('Fecha: ${fechaFormateada}'),
                subtitle: Text(
                    'Estado: ${coincide ? asistenciaFound['idEstadoAsistencia']['nombre'] : 'Inasistencia'}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
