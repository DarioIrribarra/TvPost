import 'dart:ui';

import 'package:flutter/cupertino.dart';

class DatosEstaticos {
  static String rutEmpresa;
  static int puertoSocketRaspberry = 5560;
  static String ipSeleccionada;
  static List<String> listadoNombresImagenes;
  static List<String> listadoNombresVideos;
  static String rutaSubidaImagenes = 'http://' +ipSeleccionada + '/upload_one_image.php';
  static String rutaSubidaVideos = 'http://' +ipSeleccionada + '/upload_one_video.php';
  static Widget wiget1;
  static String nombreArchivoWidget1;
  static Widget wiget2;
  static String nombreArchivoWidget2;
  static Widget wiget3;
  static String nombreArchivoWidget3;
}