//import 'dart:js';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/shared_preferences.dart';
import 'package:tvpost_flutter/ventanas/crear_layout1.dart';
import 'package:tvpost_flutter/ventanas/crear_layout2.dart';
import 'package:tvpost_flutter/ventanas/crear_layout3.dart';
import 'package:tvpost_flutter/ventanas/login.dart';
import 'package:tvpost_flutter/ventanas/mi_perfil.dart';
import 'package:tvpost_flutter/ventanas/raspberries_conectadas.dart';
import 'package:tvpost_flutter/ventanas/detalle_equipo.dart';
import 'package:tvpost_flutter/ventanas/reloj.dart';
import 'package:tvpost_flutter/ventanas/seleccionar_imagen.dart';
import 'package:tvpost_flutter/ventanas/seleccionar_layout.dart';
import 'package:tvpost_flutter/ventanas/seleccionar_video.dart';
import 'package:tvpost_flutter/ventanas/crear_contenido.dart';
import 'package:tvpost_flutter/ventanas/soporte.dart';
import 'package:tvpost_flutter/ventanas/ventanaEnFondo.dart';

Future<void> main() async {
  //Se ejecuta el método de carga de shared preferences antes de que
  // inicie la app
  WidgetsFlutterBinding.ensureInitialized();
  await shared_preferences_tvPost.CargarSharedPreferences();
  //Se inicializa Firebase
  await Firebase.initializeApp();

  //Espera la orientación vertical
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
    //Inicia la app
    runApp(MaterialApp(
      theme: ThemeData(
          // accentColor: HexColor('#FC4C8B'),
          fontFamily: 'tituloAxis',
          textTheme: TextTheme(
            body1: TextStyle(fontSize: 12.5),
            title: TextStyle(fontSize: 12.5),
          )),
      debugShowCheckedModeBanner: false,

      //Rutas para navegar en las páginas
      routes: {
        //Ventana fantasma que se mantiene vacía
        '/': (context) => VentanaFondo(),
        '/login': (context) => Login(),
        '/raspberries_conectadas': (context) => RaspberriesConectadas(),
        '/detalle_equipo': (context) => DetalleEquipo(),
        '/seleccionar_layout': (context) => SeleccionarLayout(),
        '/crear_layout1': (context) => CrearLayout1(),
        '/crear_layout2': (context) => CrearLayout2(),
        '/crear_layout3': (context) => CrearLayout3(),
        '/seleccionar_imagen': (context) => SeleccionarImagen(),
        '/seleccionar_video': (context) => SeleccionarVideo(),
        '/crear_contenido': (context) => CrearContenido(),
        '/reloj': (context) => EditarReloj(),
        '/soporte': (context) => Soporte(),
        '/miPerfil': (context) => Perfil(),
      },
    ));
  });
}
