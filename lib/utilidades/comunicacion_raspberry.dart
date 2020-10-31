import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';

class ComunicacionRaspberry{

  ///El orden del String para enviar a Raspberry es:
  ///1.- Comando (TVPOSTMODLAYOUT)
  ///2.- Tipo de layout (100, 5050, 802010)
  ///3.- Porciones a modificar (1-1, 2-1, 2-2, 3-1, 3-2, 3-3, 3-4, 3-5, 3-6,
  ///3-7)
  ///4.- Nombres de archivos (DatosEstaticos.nombrewidget1...)
  static Future<dynamic> ConfigurarLayout(
      String instruccion) async {
    String resp;
    //String tipoNuevoLayout;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];

    //String instruccion = "$restoInstruccion";

    Socket socket;
    try{
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada,
          DatosEstaticos.puertoSocketRaspberry).timeout(Duration(seconds: 5));
      socket.write(instruccion);
      socket.listen((event) {
        listadoRespuestas.addAll(event.toList());
      }).onDone(() {
        _respuesta = Uint8List.fromList(listadoRespuestas);
        socket.close();
        return;
      });

      await socket.done.whenComplete(() => resp = utf8.decode(_respuesta));

      return resp;
    }catch(e){
      print("Error al enviar nuevo layout ${e.toString()}");
    }

  }
}

