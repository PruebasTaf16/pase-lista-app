import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pase_lista_app/helpers/alerta.dart';
import 'package:pase_lista_app/providers/auth_provider.dart';
import 'package:pase_lista_app/screens/private/home_page.dart';
import 'package:pase_lista_app/screens/recuperar_page.dart';
import 'package:pase_lista_app/utils/validacion.dart';
import 'package:pase_lista_app/variables/api.dart';
import 'package:pase_lista_app/widgets/button1.dart';
import 'package:pase_lista_app/widgets/email_input.dart';
import 'package:pase_lista_app/widgets/input.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**Pantalla para iniciar sesión como usuario trabajador */
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

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
                  'Iniciar Sesión',
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
                CustomTextField(
                  controller: password,
                  hintText: 'Contraseña',
                  isPasswordMode: true,
                ),
                Button1(
                    onPressed: () {
                      iniciarSesion(context, email.text, password.text);
                    },
                    title: 'Entrar'),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  onPressed: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => RecuperarPage()))
                  },
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void iniciarSesion(BuildContext context, String email, String password) async {
  if (!validarCorreo(email)) {
    return mostrarAlerta(context, 'Error', 'Email inválido');
  }
  if (password.isEmpty) {
    return mostrarAlerta(context, 'Error', 'Falta la contraseña');
  }

  try {
    Response response = await Dio().post('$API_URL/auth/iniciar-sesion', data: {
      'email': email,
      'password': password,
    });

    String jwt = response.data['data']['jwt'];

    AuthProvider().setJwt(jwt);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', jwt);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
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
}
