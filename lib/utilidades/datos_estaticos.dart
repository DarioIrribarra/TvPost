import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/cupertino.dart';

class DatosEstaticos {
  static String rutEmpresa;
  static int puertoSocketRaspberry = 5560;
  static String ipSeleccionada;
  static List<String> listadoNombresImagenes;
  static List<String> listadoNombresVideos;
  static List<int> listadoIndexEquiposConectados = [];
  static List<dynamic> listadoDatosEquipoSeleccionado;
  static Map<String,dynamic> mapaDatosReproduccionEquipoSeleccionado;
  static Widget widget1;
  static String nombreArchivoWidget1 = "";
  static Widget widget2;
  static String nombreArchivoWidget2 = "";
  static Widget widget3;
  static String nombreArchivoWidget3 = "";
  static WebViewController webViewControllerWidget1;
  static WebViewController webViewControllerWidget2;
  static WebViewController webViewControllerWidget3;
  static bool reproducirVideo = false;
  static bool primeraVezCargaVideo = true;
  static int layoutSeleccionado;
  //Valor para tomar screenshots del index correspondiente a la raspberry
  //en la pantalla raspberries conectadas
  static int indexSeleccionado;
  //Valor para ver si una porción es reemplazada o no
  static bool reemplazarPorcion1 = false;
  static bool reemplazarPorcion2 = false;
  static bool reemplazarPorcion3 = false;
  static bool relojEnPantalla = false;
  static String color_fondo_reloj = "#FFFFFD";
  static String color_texto_reloj = "#010000";
  //Tamaños base de pantalla
  static int ancho_pantalla_seleccionada = 0;
  static int alto_pantalla_seleccionada = 0;
}