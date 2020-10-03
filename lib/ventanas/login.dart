import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tvpost_flutter/utilidades/shared_preferences.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String rutEmpresa = "";
  String nombreUsuario = "";
  String password = "";
  String validaRutEmpresa = "";
  String validaNombreUsuario = "";
  String validaPasword = "";
  ProgressDialog progressDialog;

  @override
  void initState() {
    // TODO: implement initState
    //Se asignan los valores del sharedpreferences en el init
    rutEmpresa = shared_preferences_tvPost.rutEmpresa;
    nombreUsuario = shared_preferences_tvPost.nombreUsuario;
    password = shared_preferences_tvPost.password;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.amber,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.fromLTRB(40.0, 100.0, 40.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('imagenes/logovertical.png'),
                  TextFormField(
                    initialValue: rutEmpresa,
                    maxLength: 12,
                    decoration: InputDecoration(
                      hintText: 'Sin puntos ni guión',
                      labelText: 'Rut Empresa',),
                    onChanged: (texto){rutEmpresa = texto;},
                    validator: (texto) => validaRutEmpresa,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nombre de usuario',),
                    //Se asigna lo que se escribe a la variable
                    initialValue: nombreUsuario,
                    onChanged: (texto){nombreUsuario = texto;},
                    validator: (texto) => validaNombreUsuario,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Contraseña',),
                    initialValue: password,
                    onChanged: (texto){password = texto;},
                    validator: (password) => validaPasword,
                  ),
                  RaisedButton(
                    child: Text('Entrar'),
                      onPressed: () async{
                        //Se crea popup de cargando
                        PopUps.popUpCargando(context, 'Cargando...');
                    //Se cambia el estado para asignar valor de rut empresa a la
                    //variable local. Ir a buscar el dato de empresa
                    ObtieneDatos datos = ObtieneDatos();
                    if (rutEmpresa!=null){
                      await datos.getDatosEmpresa(rutEmpresa.trim());
                    }
                    if (nombreUsuario!=null){
                      await datos.getDatosUsuario(nombreUsuario.trim());
                    }

                    //Espera el resultado de la función async para validar rut
                    await datos.ValidaRutEmpresa();
                    //Espera el resultado de la función async para validar
                    // nombre de usuario
                    await datos.ValidaNombreUsuario();
                    //Espera el resultado de la función async para validar
                    // password
                    if(password != null && nombreUsuario != null){
                      await datos.ValidaPasswordUsuario(password.trim(),
                          nombreUsuario.trim());
                    }

                    //Se inicializa el listado de equipos
                    await datos.getDatosEquipos();

                    //Set state para cambiar los valores del validador
                    setState(() {
                      validaRutEmpresa = datos.rutEmpresaDevuelto;
                      validaNombreUsuario = datos.nombreUsuarioDevuelto;
                      validaPasword = datos.passwordDevuelto;
                    });
                    //Al pasar todas las validaciones se utiliza el shared
                    //preferences
                    if(_formKey.currentState.validate()){
                        GuardarSharedPreferences();
                        Navigator.pop(context);
                        //Al guardar to do se va a la otra ventana
                      Navigator.pushNamed(context, '/raspberries_conectadas');
                    } else {
                      Navigator.pop(context);
                    }

                    //print(validaRutEmpresa);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///Guarda las preferencias de usuario si se ha validado correctamente
  Future<void> GuardarSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('rutEmpresa', rutEmpresa.trim());
    sharedPreferences.setString('nombreUsuario', nombreUsuario.trim());
    sharedPreferences.setString('password', password.trim());
  }
}