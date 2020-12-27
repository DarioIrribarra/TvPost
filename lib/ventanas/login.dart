import 'dart:ui';

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
      body: Container(
        height: double.infinity,
        decoration: new BoxDecoration(
            gradient: LinearGradient(
                colors: [HexColor("#3edb9b"), HexColor("#0683ff")],
                stops: [0.5, 1],
                begin: Alignment.topLeft,
                end: FractionalOffset.bottomRight)),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.fromLTRB(40.0, 100.0, 40.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      width: 135,
                      height: 135,
                      child: Image.asset(
                        'imagenes/logovertical.png',
                      ),
                    ),
                    SizedBox(
                      height: 45,
                    ),
                    Container(
                      height: 33.5,
                      margin: EdgeInsets.fromLTRB(18, 0, 18, 0),
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: Colors.white),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "RUT EMPRESA",
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.only(
                                  bottom: 9, left: 15, right: 15),
                              child: new TextFormField(
                                style: TextStyle(
                                    fontFamily: 'textoMont',
                                    fontSize: 12,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                                initialValue: rutEmpresa,
                                decoration: InputDecoration(
                                    errorStyle: TextStyle(height: 2),
                                    //   labelText: 'Rut Empresa',
                                    //hintText:'Rut Empresa (sin puntos ni guión)',
                                    //labelStyle: TextStyle(color: Colors.white),
                                    enabledBorder: new UnderlineInputBorder(
                                        borderSide: new BorderSide(
                                            color: HexColor('#bdbdbd')))),
                                onChanged: (texto) {
                                  rutEmpresa = texto;
                                },
                                validator: (texto) => validaRutEmpresa,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 33.5,
                      margin: EdgeInsets.fromLTRB(18, 0, 18, 0),
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: Colors.white),
                      child: Row(children: [
                        Expanded(
                            flex: 2,
                            child: Text(
                              "USUARIO",
                              textAlign: TextAlign.right,
                            )),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding:
                                EdgeInsets.only(bottom: 9, left: 15, right: 15),
                            child: TextFormField(
                              style: TextStyle(
                                  fontFamily: 'textoMont',
                                  fontSize: 12,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  errorStyle: TextStyle(height: 2),
                                  // hintText: 'Nombre de usuario',
                                  enabledBorder: new UnderlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: HexColor('#bdbdbd')))),
                              //Se asigna lo que se escribe a la variable
                              initialValue: nombreUsuario,
                              onChanged: (texto) {
                                nombreUsuario = texto;
                              },
                              validator: (texto) => validaNombreUsuario,
                            ),
                          ),
                        )
                      ]),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 33.5,
                      margin: EdgeInsets.fromLTRB(18, 0, 18, 0),
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(45),
                          color: Colors.white),
                      child: Row(children: [
                        Expanded(
                            flex: 2,
                            child: Text(
                              "CONTRASEÑA",
                              textAlign: TextAlign.right,
                            )),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding:
                                EdgeInsets.only(bottom: 9, left: 15, right: 15),
                            child: TextFormField(
                              style: TextStyle(
                                  fontFamily: 'textoMont',
                                  fontSize: 12,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                              obscureText: true,
                              decoration: InputDecoration(
                                  errorStyle: TextStyle(height: 2),
                                  //hintText: 'Contraseña',
                                  enabledBorder: new UnderlineInputBorder(
                                      borderSide: new BorderSide(
                                          color: HexColor('#bdbdbd')))),
                              initialValue: password,
                              onChanged: (texto) {
                                password = texto;
                              },
                              validator: (password) => validaPasword,
                            ),
                          ),
                        ),
                      ]),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
                      child: RaisedButton(
                          color: HexColor('#0683FF'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide(
                              width: 2.3,
                              color: Colors.white,
                            ),
                          ),
                          child: Text(
                            'ENTRAR',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            //Se crea popup de cargando
                            PopUps.popUpCargando(context, 'Cargando...');
                            //Se cambia el estado para asignar valor de rut empresa a la
                            //variable local. Ir a buscar el dato de empresa
                            ObtieneDatos datos = ObtieneDatos();
                            if (rutEmpresa != null) {
                              await datos.getDatosEmpresa(rutEmpresa.trim());
                            }
                            if (nombreUsuario != null) {
                              await datos.getDatosUsuario(nombreUsuario.trim());
                            }

                            //Espera el resultado de la función async para validar rut
                            await datos.ValidaRutEmpresa();
                            //Espera el resultado de la función async para validar
                            // nombre de usuario
                            await datos.ValidaNombreUsuario();
                            //Espera el resultado de la función async para validar
                            // password
                            if (password != null && nombreUsuario != null) {
                              await datos.ValidaPasswordUsuario(
                                  password.trim(), nombreUsuario.trim());
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
                            if (_formKey.currentState.validate()) {
                              GuardarSharedPreferences();
                              Navigator.pop(context);
                              //Al guardar to do se va a la otra ventana
                              Navigator.pushNamed(
                                  context, '/raspberries_conectadas');
                            } else {
                              Navigator.pop(context);
                            }

                            //print(validaRutEmpresa);
                          }),
                    ),
                  ],
                ),
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
