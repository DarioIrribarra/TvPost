import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/shared_preferences.dart';
import 'package:tvpost_flutter/ventanas/crear_layout1.dart';
import 'package:tvpost_flutter/ventanas/crear_layout2.dart';
import 'package:tvpost_flutter/ventanas/crear_layout3.dart';
import 'package:tvpost_flutter/ventanas/login.dart';
import 'package:tvpost_flutter/ventanas/raspberries_conectadas.dart';
import 'package:tvpost_flutter/ventanas/detalle_equipo.dart';
import 'package:tvpost_flutter/ventanas/seleccionar_imagen.dart';
import 'package:tvpost_flutter/ventanas/seleccionar_layout.dart';
import 'package:tvpost_flutter/ventanas/seleccionar_video.dart';
import 'package:tvpost_flutter/ventanas/crear_contenido.dart';


Future<void> main() async {
  //Se ejecuta el método de carga de shared preferences antes de que
  // inicie la app
  WidgetsFlutterBinding.ensureInitialized();
  await shared_preferences_tvPost.CargarSharedPreferences();
  //Inicia la app
  runApp(MaterialApp(
    //Rutas para navegar en las páginas
    routes: {
      '/': (context) => Login(),
      '/raspberries_conectadas': (context) => RaspberriesConectadas(),
      '/detalle_equipo': (context) => DetalleEquipo(),
      '/seleccionar_layout': (context) => SeleccionarLayout(),
      '/crear_layout1': (context) => CrearLayout1(),
      '/crear_layout2': (context) => CrearLayout2(),
      '/crear_layout3': (context) => CrearLayout3(),
      '/seleccionar_imagen': (context) => SeleccionarImagen(),
      '/seleccionar_video': (context) => SeleccionarVideo(),
      '/crear_contenido': (context) => CrearContenido(),
    },
  ));
}