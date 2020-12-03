import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;


class Utils {
  static Future capture(GlobalKey key) async {
    //Listado para devolver dirección temporal e imagen
    //List datosImagen = [];
    if (key == null) return null;

    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData.buffer.asUint8List();
    return pngBytes;
  }
}