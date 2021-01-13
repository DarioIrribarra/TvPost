import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';

class Utils {
  static Future capture(GlobalKey key) async {
    try {
      //Listado para devolver dirección temporal e imagen
      //List datosImagen = [];
      if (key == null) return null;
      //Transforma la imagen original
      RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      return pngBytes;
    } catch (e){
      print('Error al tomar pantallazo${e.toString()}');
    }
  }

  static Future<Uint8List> redimensionarImg(Uint8List pngBytesOriginales,
      String divisionYPorcion
      ) async{
    //Crea imagen temporal para procesar
    String dir = (await getTemporaryDirectory()).path;
    File temporal = new File('$dir/img_temp_creada.png');
    await temporal.writeAsBytes(pngBytesOriginales);

    //Modifico valores dependiendo de la porción elegida y el tamaño real
    // de la pantalla
    int nuevaAltura = DatosEstaticos.alto_pantalla_seleccionada;
    int nuevoAncho = DatosEstaticos.ancho_pantalla_seleccionada;

    switch(divisionYPorcion){
      case '2-1':
        nuevoAncho = (DatosEstaticos.ancho_pantalla_seleccionada*0.5).toInt();
        break;
      case '2-2':
        nuevoAncho = (DatosEstaticos.ancho_pantalla_seleccionada*0.5).toInt();
        break;
      case '3-1':
        nuevoAncho = (DatosEstaticos.ancho_pantalla_seleccionada*0.8).toInt();
        nuevaAltura = (DatosEstaticos.alto_pantalla_seleccionada*0.9).toInt();
        break;
      case '3-2':
        nuevoAncho = (DatosEstaticos.ancho_pantalla_seleccionada*0.2).toInt();
        nuevaAltura = (DatosEstaticos.alto_pantalla_seleccionada*0.9).toInt();
        break;
      case '3-3':
        if (DatosEstaticos.relojEnPantalla){
          nuevoAncho = (DatosEstaticos.ancho_pantalla_seleccionada*0.8).toInt();
        }
        nuevaAltura = (DatosEstaticos.alto_pantalla_seleccionada*0.1).toInt();
        break;
    }

    //Redimensión
    ui.Image imagen_t = await redimencionarUiImage(temporal.path, nuevaAltura, nuevoAncho);
    final byteData2 = await imagen_t.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes_f = byteData2.buffer.asUint8List();

    return pngBytes_f;
  }

  //Devuelve la imagen redimensionada en bytes
  static Future<ui.Image> redimencionarUiImage(String imageAssetPath, int height, int width) async {
    try {
      Uint8List img = await File(imageAssetPath).readAsBytes();
      final ByteData assetImageByteData = ByteData.view(img.buffer);
      //final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
      image.Image baseSizeImage = image.decodeImage(assetImageByteData.buffer.asUint8List());
      image.Image resizeImage = image.copyResize(baseSizeImage, height: height, width: width);
      ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
      ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e){
      print('Error abrir img: ${e.toString()}');
    }

  }

  //Devuelve un archivo temporal con las nuevas dimensiones
  static Future<File> crearArchivoTemporalRedimensionado (Uint8List bytesImagenRedimensionada) async{

    String dir = (await getTemporaryDirectory()).path;
    File temporal = new File('$dir/img_temp_final.png');
    await temporal.writeAsBytes(bytesImagenRedimensionada);

    return temporal;
  }

}