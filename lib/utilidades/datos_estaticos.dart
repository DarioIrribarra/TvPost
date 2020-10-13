import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/cupertino.dart';

class DatosEstaticos {
  static String rutEmpresa;
  static int puertoSocketRaspberry = 5560;
  static String ipSeleccionada;
  static List<String> listadoNombresImagenes;
  static List<String> listadoNombresVideos;
  static List<dynamic> listadoDatosEquipoSeleccionado;
  static Map<String,dynamic> mapaDatosReproduccionEquipoSeleccionado;
  static String rutaSubidaImagenes = 'http://' +ipSeleccionada + '/upload_one_image.php';
  static String rutaSubidaVideos = 'http://' +ipSeleccionada + '/upload_one_video.php';
  static Widget wiget1;
  static String nombreArchivoWidget1 = "";
  static Widget wiget2;
  static String nombreArchivoWidget2 = "";
  static Widget wiget3;
  static String nombreArchivoWidget3 = "";
  static WebViewController webViewControllerWidget1;
  static WebViewController webViewControllerWidget2;
  static WebViewController webViewControllerWidget3;
  static int layoutSeleccionado;
  //Valor para tomar screenshots del index correspondiente a la raspberry
  //en la pantalla raspberries conectadas
  static int indexSeleccionado;
}