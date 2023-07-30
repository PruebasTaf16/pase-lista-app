import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pase_lista_app/helpers/alerta.dart';
import 'package:pase_lista_app/screens/login_page.dart';
import 'package:pase_lista_app/utils/validacion.dart';
import 'package:pase_lista_app/variables/api.dart';
import 'package:pase_lista_app/widgets/button1.dart';
import 'package:pase_lista_app/widgets/button2.dart';
import 'package:pase_lista_app/widgets/email_input.dart';

/**Pantalla para recuperar la cuenta de usuario trabajador */
class RecuperarPage extends StatelessWidget {
  RecuperarPage({super.key});

  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 42, 40, 59),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(42, 40, 59, 1),
            borderRadius: BorderRadius.circular(10),
          ),
          margin:
              const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 50),
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Recuperar Cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  "assets/logoapp.png",
                  height: 200,
                ),
                const SizedBox(height: 60),
                EmailField(
                  controller: email,
                  hintText: 'Correo del trabajador',
                ),
                const SizedBox(height: 60),
                Button1(
                    onPressed: () {
                      recuperar(context, email.text);
                    },
                    title: 'Recuperar'),
                const SizedBox(
                  height: 40,
                ),
                Button2(
                    onPressed: () {
                      Navigator.pushNamed(context, 'login');
                    },
                    title: 'Cancelar')
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void recuperar(BuildContext context, String email) async {
  if (!validarCorreo(email)) {
    return mostrarAlerta(context, 'Error', 'Email inválido');
  }
  showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text('¿Está seguro?'),
          actions: [
            TextButton(
                onPressed: () async {
                  try {
                    Response response = await Dio()
                        .post('$API_URL/auth/recuperar-cuenta', data: {
                      'email': email,
                    });

                    // ignore: use_build_context_synchronously
                    showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          return AlertDialog(
                            title: const Text('Enviado'),
                            content: Text(response.data['msg']),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pop();

                                    // ignore: use_build_context_synchronously
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginPage()),
                                      (Route<dynamic> route) =>
                                          false, // Eliminar todas las rutas anteriores
                                    );
                                  },
                                  child: const Text('Ok'))
                            ],
                          );
                        });
                  } catch (e) {
                    print(e);
                    if (e is DioException) {
                      if (e.response != null) {
                        Response? response = e.response;
                        String msg = response!.data['msg'];

                        mostrarAlerta(context, 'Error', msg);
                      }
                    } else {
                      print(e);
                      mostrarAlerta(context, 'Error', 'Hubo un error');
                    }
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
