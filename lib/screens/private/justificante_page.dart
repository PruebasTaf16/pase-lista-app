import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pase_lista_app/helpers/alerta.dart';
import 'package:pase_lista_app/providers/dia_provider.dart';
import 'package:pase_lista_app/providers/usuario_provider.dart';
import 'package:pase_lista_app/screens/private/home_page.dart';
import 'package:pase_lista_app/variables/api.dart';
import 'package:pase_lista_app/widgets/button1.dart';
import 'package:workmanager/workmanager.dart';

/**Pantalla para genererar los justificantes por retraso */
class JustificantePage extends StatefulWidget {
  const JustificantePage({super.key});

  @override
  State<JustificantePage> createState() => _JustificantePageState();
}

class _JustificantePageState extends State<JustificantePage> {
  dynamic usuarioData = {"_id": null, "nombre": null};
  dynamic fechaData = "";

  String? _selectedOption;
  List<dynamic> opciones = [];
  String? _detalles;

  TextEditingController detalles = TextEditingController();

  /**Cargar el listado de motivos */
  fetchListadoMotivos() async {
    try {
      Response response =
          await Dio().get('$API_URL/varios/listado-motivos-inasistencia');

      setState(() {
        opciones = response.data['data'];
      });
    } catch (e) {}
  }

  @override
  initState() {
    super.initState();
    fetchListadoMotivos();

    setState(() {
      usuarioData = UsuarioProvider().usuarioData;
      fechaData = DiaProvider().fechaData;
    });
  }

  /**Enviar el justificante */
  enviarJustificante() async {
    if (_selectedOption == null) {
      return mostrarAlerta(context, 'Error', 'Elija un motivo');
    }
    if (detalles.text.isEmpty) {
      return mostrarAlerta(context, 'Error', 'Escriba los detalles');
    }

    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Confirmar'),
            content: const Text('¿Desea enviar el justificante?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    try {
                      /**Aquí va toda la información que se enviará al backend */
                      Response response = await Dio()
                          .post('$API_URL/asistencias/justificar', data: {
                        'idDia': fechaData['_id'],
                        'idUsuario': usuarioData['_id'],
                        'idMotivoInasistencia': _selectedOption,
                        'detalles': detalles.text,
                      });
                      mostrarAlerta(context, 'Enviado', response.data['msg']);

                      // ignore: use_build_context_synchronously
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                        (Route<dynamic> route) =>
                            false, // Eliminar todas las rutas anteriores
                      );
                    } catch (e) {
                      if (e is DioException) {
                        mostrarAlerta(
                            context, 'Error', e.response!.data['msg']);
                        return;
                      }
                      print(e);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();

                      // ignore: use_build_context_synchronously
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()),
                        (Route<dynamic> route) =>
                            false, // Eliminar todas las rutas anteriores
                      );
                    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Justificar Falta'),
        elevation: 0,
      ),
      body: Container(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Elija el motivo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedOption,
              onChanged: (newValue) {
                setState(() {
                  _selectedOption = newValue;
                });
              },
              items: opciones.map<DropdownMenuItem<String>>((dynamic value) {
                return DropdownMenuItem<String>(
                  value: value['_id'],
                  child: Text(value['nombre']),
                );
              }).toList(),
              style: const TextStyle(
                  color: Color.fromARGB(235, 9, 92, 246),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              underline: Container(
                height: 2,
                color: Color.fromARGB(235, 9, 92, 246),
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Color.fromARGB(235, 9, 92, 246),
              ),
              dropdownColor: Color.fromARGB(255, 70, 69, 69),
            ),
            const SizedBox(height: 40),
            const Text(
              'Explique los detalles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              // Utilizamos Expanded para que el TextField ocupe todo el espacio disponible
              child: TextField(
                controller: detalles,
                // Establecemos el estilo para el TextField
                style: const TextStyle(
                  color: Color.fromARGB(235, 9, 92, 246), // Color de texto
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(235, 9, 92,
                          246), // Color del borde cuando está enfocado
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(235, 9, 92,
                          246), // Color del borde cuando no está enfocado
                    ),
                  ),
                ),
              ),
            ),
            Button1(
                onPressed: () {
                  enviarJustificante();
                },
                title: 'Enviar Justificante'),
          ],
        ),
      ),
    );
  }
}
