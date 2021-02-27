import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:http/http.dart' as http;

class ComunicacionRaspberry{

  ///El orden del String para enviar a Raspberry es:
  ///1.- Comando (TVPOSTMODLAYOUT)
  ///2.- Tipo de layout (100, 5050, 802010)
  ///3.- Porciones a modificar (1-1, 2-1, 2-2, 3-1, 3-2, 3-3, 3-4, 3-5, 3-6,
  ///3-7)
  ///4.- Nombres de archivos (DatosEstaticos.nombrewidget1...)
  static Future<dynamic> ConfigurarLayout(String instruccion) async {
    String resp;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];
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

  static Future<dynamic> EliminarContenido({
    @required
    String tipoContenido,
    @required
    List<String> nombresAEliminar}) async{
    String resp;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];
    String instruccion;
    if (tipoContenido == 'imagenes'){
      instruccion = "TVPOSTDELIMGS";
    }
    if (tipoContenido == 'videos'){
      instruccion = "TVPOSTDELVIDEOS";
    }
    nombresAEliminar.forEach((element) {
      instruccion += ' "'+ element + '"';
    });
    //print ("Instrucción: $instruccion");

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
      return null;
    }
  }

  static Future<dynamic> EditarContenido({
    @required
    String tipoContenido,
    @required
    List<String> nombresAEliminar}) async{
    String resp;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];
    String instruccion;
    if (tipoContenido == 'imagenes'){
      instruccion = "TVPOSTEDITIMGS";
    }
    if (tipoContenido == 'videos'){
      instruccion = "TVPOSTEDITVIDEOS";
    }
    nombresAEliminar.forEach((element) {
      instruccion += ' "'+ element + '"';
    });
    //print ("Instrucción: $instruccion");

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
      return null;
    }
  }

  static Future<dynamic> ReplicarImagen(String nombre) async{
    String nombreFormateado = nombre.replaceAll(RegExp(' +'), '<!-!>');
    String resp;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];
    String instruccion = 'TVPOSTREPLICAIMAGEN $nombreFormateado';

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
      return null;
    }

  }

  static Future<bool> EnviarImagenPorHTTP(String nombre, File imagen) async {
    String imabenBytes = base64Encode(imagen.readAsBytesSync());
    String rutaSubidaImagenes =
        'http://' + DatosEstaticos.ipSeleccionada + '/upload_one_image.php';
    bool resultado = await http.post(rutaSubidaImagenes, body: {
      "image": imabenBytes,
      "name": nombre,
    }).then((result) {
      //print("Resultado: " + result.statusCode.toString());
      if (result.statusCode == 200) {
        return true;
      }
    }).catchError((error) {
      return false;
    });
    return resultado;
  }

  static Future<bool> EnviarVideoPorHTTP(String nombre, File video) async {
    String videoBytes = base64Encode(video.readAsBytesSync());
    String rutaSubidaVideos =
        'http://' + DatosEstaticos.ipSeleccionada + '/upload_one_video.php';
    bool resultado = await http.post(rutaSubidaVideos, body: {
      "video": videoBytes,
      "name": nombre,
    }).then((result) {
      if (result.statusCode == 200) {
        return true;
      }
    }).catchError((error) {
      return false;
    });
    return resultado;
  }

  static Future<List> getNombresImagenes() async {
    List<int> listadoValoresBytes = [];
    List datos;
    Socket socket;
    try {
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada,
          DatosEstaticos.puertoSocketRaspberry)
          .timeout(Duration(seconds: 5));
      socket.write('TVPOSTGETNOMBREIMAGENES');
      socket.listen((event) {
        listadoValoresBytes.addAll(event.toList());
      }).onDone(() {
        datos = utf8.decode(listadoValoresBytes).split(",");
        DatosEstaticos.listadoNombresImagenes = datos;
        socket.close();
      });

      await socket.done.whenComplete(() => datos);
      return datos;
    } catch (e) {
      print("Error " + e.toString());
    }
  }

  static Future<List> getNombresVideos() async {
    List<int> listadoValoresBytes = [];
    List datos;
    Socket socket;
    try {
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada,
          DatosEstaticos.puertoSocketRaspberry)
          .timeout(Duration(seconds: 5));
      socket.write('TVPOSTGETNOMBREVIDEOS');
      socket.listen((event) {
        listadoValoresBytes.addAll(event.toList());
        //socket.flush();
        //print(listadoValoresBytes.length);
      }).onDone(() {
        //DatosEstaticos.listadoNombresString = utf8.decode(listadoValoresBytes).split(",");
        datos = utf8.decode(listadoValoresBytes).split(",");
        DatosEstaticos.listadoNombresVideos = datos;
        socket.close();
      });

      await socket.done.whenComplete(() => datos);
      return datos;
    } catch (e) {
      print("Error " + e.toString());
    }
  }

  //Prepara datos para enviar a raspberry.
  //Comprueba datos con base de datos para archivos de media
  static Future<String> PreparaDatosMediaEnvioEquipo() async {
    String _Instruccion;
    String relojEnPantalla;
    String tipoLayoutAEnviar = "";
    String layoutEnEquipo = DatosEstaticos.layoutSeleccionado.toString();

    //Nombres de widgets hasta el momento
    String tipoWidget1AEnviar = DatosEstaticos.widget1.runtimeType.toString();
    String tipoWidget2AEnviar = DatosEstaticos.widget2.runtimeType.toString();
    String tipoWidget3AEnviar = DatosEstaticos.widget3.runtimeType.toString();
    if (tipoWidget1AEnviar == 'Null') {
      tipoWidget1AEnviar = "0";
    }
    if (tipoWidget2AEnviar == 'Null') {
      tipoWidget2AEnviar = "0";
    }
    if (tipoWidget3AEnviar == 'Null') {
      tipoWidget3AEnviar = "0";
    }

    //nombres de archivos a enviar
    String link1AEnviar =
    DatosEstaticos.nombreArchivoWidget1.replaceAll(RegExp(' +'), '<!-!>');
    String link2AEnviar =
    DatosEstaticos.nombreArchivoWidget2.replaceAll(RegExp(' +'), '<!-!>');
    String link3AEnviar =
    DatosEstaticos.nombreArchivoWidget3.replaceAll(RegExp(' +'), '<!-!>');
    if (link1AEnviar.isEmpty) {
      link1AEnviar = "0";
    }
    if (link2AEnviar.isEmpty) {
      link2AEnviar = "0";
    }
    if (link3AEnviar.isEmpty) {
      link3AEnviar = "0";
    }
    //valor de reloj en pantalla
    if (DatosEstaticos.relojEnPantalla) {
      relojEnPantalla = "on";
    } else {
      relojEnPantalla = "off";
    }
    //Se añaden los colores del reloj
    relojEnPantalla = relojEnPantalla +
        DatosEstaticos.color_fondo_reloj +
        DatosEstaticos.color_texto_reloj;

    if (layoutEnEquipo == "1") {
      tipoLayoutAEnviar = "100";
      if (link1AEnviar != "0" &&
          !link1AEnviar.contains('/var/www/html') &&
          !link1AEnviar.contains('http')) {
        link1AEnviar = '/var/www/html$link1AEnviar';
      }
      _Instruccion =
      "$tipoWidget1AEnviar 0 0 $link1AEnviar 0 0 $relojEnPantalla";
    }
    if (layoutEnEquipo == "2") {
      tipoLayoutAEnviar = "5050";
      if (link1AEnviar != "0" &&
          !link1AEnviar.contains('/var/www/html') &&
          !link1AEnviar.contains('http')) {
        link1AEnviar = '/var/www/html$link1AEnviar';
      }
      if (link2AEnviar != "0" &&
          !link2AEnviar.contains('/var/www/html') &&
          !link2AEnviar.contains('http')) {
        link2AEnviar = '/var/www/html$link2AEnviar';
      }
      _Instruccion = "$tipoWidget1AEnviar $tipoWidget2AEnviar "
          "0 $link1AEnviar $link2AEnviar 0 $relojEnPantalla";
    }
    if (layoutEnEquipo == "3") {
      tipoLayoutAEnviar = "802010";
      if (link1AEnviar != "0" &&
          !link1AEnviar.contains('/var/www/html') &&
          !link1AEnviar.contains('http')) {
        link1AEnviar = '/var/www/html$link1AEnviar';
      }
      if (link2AEnviar != "0" &&
          !link2AEnviar.contains('/var/www/html') &&
          !link2AEnviar.contains('http')) {
        link2AEnviar = '/var/www/html$link2AEnviar';
      }
      if (link3AEnviar != "0" &&
          !link3AEnviar.contains('/var/www/html') &&
          !link3AEnviar.contains('http')) {
        link3AEnviar = '/var/www/html$link3AEnviar';
      }

      //Envío de instrucción final
      _Instruccion = "$tipoWidget1AEnviar $tipoWidget2AEnviar "
          "$tipoWidget3AEnviar $link1AEnviar $link2AEnviar $link3AEnviar $relojEnPantalla";
    }

    List<String> listadoArchivosAEnviar = new List<String>();
    if (link1AEnviar!="0")
      listadoArchivosAEnviar.add(link1AEnviar);
    if (link2AEnviar!="0")
      listadoArchivosAEnviar.add(link2AEnviar);
    if (link3AEnviar!="0")
      listadoArchivosAEnviar.add(link3AEnviar);

    /****************************************************************/
    //VERIFICA SI EL LINK EXISTE EN EL EQUIPO Y DESCARGA SI NO
    await CompruebaArchivosRaspberry(pLinksAEnviar: listadoArchivosAEnviar);

    String _porcionACambiar = DefinirPorcionACambiar();

    _Instruccion =
    "TVPOSTMODLAYOUT $tipoLayoutAEnviar $_porcionACambiar $_Instruccion";
    return _Instruccion;
  }

  static String DefinirPorcionACambiar() {
    int ls = DatosEstaticos.layoutSeleccionado;

    switch (ls) {
      case 1:
        if (DatosEstaticos.reemplazarPorcion1) {
          return "1-1";
        }
        break;
      case 2:
        if (DatosEstaticos.reemplazarPorcion1 &&
            DatosEstaticos.reemplazarPorcion2) {
          return "2-3";
        }
        if (DatosEstaticos.reemplazarPorcion1) {
          return "2-1";
        }
        if (DatosEstaticos.reemplazarPorcion2) {
          return "2-2";
        }
        break;
      case 3:
        if (DatosEstaticos.reemplazarPorcion1 &&
            DatosEstaticos.reemplazarPorcion2 &&
            DatosEstaticos.reemplazarPorcion3) {
          return "3-4";
        }
        if (DatosEstaticos.reemplazarPorcion1 &&
            DatosEstaticos.reemplazarPorcion2) {
          return "3-5";
        }
        if (DatosEstaticos.reemplazarPorcion1 &&
            DatosEstaticos.reemplazarPorcion3) {
          return "3-7";
        }
        if (DatosEstaticos.reemplazarPorcion2 &&
            DatosEstaticos.reemplazarPorcion3) {
          return "3-6";
        }
        if (DatosEstaticos.reemplazarPorcion1) {
          return "3-1";
        }
        if (DatosEstaticos.reemplazarPorcion2) {
          return "3-2";
        }
        if (DatosEstaticos.reemplazarPorcion3) {
          return "3-3";
        }
        break;
    }
  }

  static CompruebaArchivosRaspberry({
    @required
    List<String> pLinksAEnviar}) async{
    //Actualiza el listado de videos e imágenes actual en la raspberry
    await ComunicacionRaspberry.getNombresImagenes();
    await ComunicacionRaspberry.getNombresVideos();
    int carpetaImagenes = "/var/www/html/ImagenesPostTv/".length;
    int carpetaImagenes10 = "/var/www/html/ImagenesPostTv10/".length;
    int carpetaVideos = "/var/www/html/VideosPostTv/".length;

    //Se recorre cada archivo a enviar y se verifica que su archivo
    //exista en la raspberry
    for (String link in pLinksAEnviar){

      //Se limpia de caracteres especiales
      link.replaceAll(RegExp('<!-!>'), ' +');

      //Se verifica el link en su correspondiente listado
      if (link.contains('ImagenesPostTv')){

        //Se remueve el nombre y deja solo el archivo
        link = link.substring(carpetaImagenes);

        if (!DatosEstaticos.listadoNombresImagenes.contains(link)){

          //Si no existe en el listado se actualiza imagen
          await ActualizaArchivosRaspberry(link);
        }
      } else if (link.contains('VideosPostTv')){

        //Se remueve el nombre y deja solo el archivo
        link = link.substring(carpetaVideos);

        if (!DatosEstaticos.listadoNombresVideos.contains(link)){

          //Si no existe en el listado se actualiza video
          await ActualizaArchivosRaspberry(link);
        }
      }
    }

  }

  ///CONECTA A RASPBERRY Y UTILIZA PYREBASE PARA OBTENER EL ARCHIVO
  static ActualizaArchivosRaspberry(String pArchivoAEnviar)async{

  }

}

