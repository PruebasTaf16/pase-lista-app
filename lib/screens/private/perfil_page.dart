import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pase_lista_app/screens/login_page.dart';
import 'package:pase_lista_app/screens/private/historial_page.dart';
import 'package:pase_lista_app/screens/private/home_page.dart';
import 'package:pase_lista_app/utils/fechas.dart';
import 'package:pase_lista_app/variables/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**Pantalla para ver el perfil (propósito meramente visual) */
class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  dynamic usuarioData = {"_id": null, "nombre": null};

  String nombreCompleto = "Cargando...";
  String rol = "Cargando...";
  String email = "Cargando...";
  String horarioEntrada = "Cargando...";
  String horarioSalida = "Cargando...";

  void fetchUsuarioData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt');

    if (jwt == null) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
      return;
    }

    try {
      Dio dio = Dio();
      dio.options.headers['Authorization'] = "Bearer ${jwt}";

      Response response = await dio.get('$API_URL/auth/obtener-info');

      setState(() {
        usuarioData = response.data['data'];

        setState(() {
          nombreCompleto =
              "${usuarioData['nombre']} ${usuarioData['paterno']} ${usuarioData['materno']}";
          rol = usuarioData['idRol']['nombre'];
          email = usuarioData['email'];

          horarioEntrada =
              "${formatTimeTo24Hours(DateTime.parse(usuarioData['idRol']['horarioEntrada']))} hrs";
          horarioSalida =
              "${formatTimeTo24Hours(DateTime.parse(usuarioData['idRol']['horarioSalida']))} hrs";
        });
      });
    } catch (e) {
      print(e);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  initState() {
    super.initState();
    fetchUsuarioData();
  }

  /**INDICE BOTTOM NAVIGATION BAR*/
  int _currentIndex = 2;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Usuario'),
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
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              nombreCompleto,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              rol,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Text(
              email,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.green),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Horario de Entrada',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  horarioEntrada,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Horario de Salida',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  horarioSalida,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
