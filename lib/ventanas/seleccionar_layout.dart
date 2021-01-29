import 'dart:convert';
//import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';
import 'package:tvpost_flutter/ventanas/reloj.dart';
import 'package:tvpost_flutter/ventanas/seleccionar_video.dart';
//import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SeleccionarLayout extends StatefulWidget {
  @override
  _SeleccionarLayoutState createState() => _SeleccionarLayoutState();
}

class _SeleccionarLayoutState extends State<SeleccionarLayout> {
  //Decoración que permite el poner un borde al seleccionar la porción de
  // pantalla
  BoxDecoration _decorationLayoutSeleccionado1;
  BoxDecoration _decorationLayoutSeleccionado2;
  BoxDecoration _decorationLayoutSeleccionado3;
  Color colorActivo1;
  Color colorActivo2;
  Color colorActivo3;
  Color colorSubrayado1;
  Color colorSubrayado2;
  Color colorSubrayado3;
  //ObtieneDatos nombreEquipo = ObtieneDatos();

  @override
  void initState() {
    // TODO: implement initState
    //recargarListadoEquipos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.popAndPushNamed(context, '/detalle_equipo', arguments: {
          "indexEquipoGrid": DatosEstaticos.indexSeleccionado,
        });
        return;
      },
      child: Scaffold(
        //Appbar viene de archivo custom_widgets.dart
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10),
              child: FutureBuilder(
                future: recargarListadoEquipos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data != null) {
                      PorcionSeleccionada(snapshot.data);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ObtieneDatos.listadoEquipos[
                                    DatosEstaticos.indexSeleccionado]['f_alias']
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(fontSize: 16.5),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 3),
                            child: Container(
                              decoration: _decorationLayoutSeleccionado1,
                              child: FlatButton(
                                child: Image.asset('imagenes/layout1a.png'),
                                onPressed: () {
                                  //Se asigna layout seleccionado a 1
                                  DatosEstaticos.layoutSeleccionado = 1;
                                  Navigator.popAndPushNamed(
                                      context, '/crear_layout1');
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 110),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: colorSubrayado1, width: 1))),
                            child: Center(
                              child: Text(
                                "LAYOUT ACTIVO",
                                style: TextStyle(
                                  fontFamily: 'textoMont',
                                  fontSize: 12,
                                  color: colorActivo1,
                                  /*decoration: TextDecoration.underline,
                                    decorationColor: colorSubrayado1*/
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 3),
                            child: Container(
                              decoration: _decorationLayoutSeleccionado2,
                              child: Column(
                                children: [
                                  FlatButton(
                                    child: Image.asset('imagenes/layout2b.png'),
                                    onPressed: () {
                                      //Se asigna layout seleccionado a 2
                                      DatosEstaticos.layoutSeleccionado = 2;
                                      Navigator.popAndPushNamed(
                                          context, '/crear_layout2');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 110),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: colorSubrayado2, width: 1))),
                            child: Center(
                              child: Text(
                                "LAYOUT ACTIVO",
                                style: TextStyle(
                                  fontFamily: 'textoMont',
                                  fontSize: 12,
                                  color: colorActivo2,
                                  /*decoration: TextDecoration.underline,
                                    decorationColor: colorSubrayado1*/
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 3),
                            child: Container(
                              decoration: _decorationLayoutSeleccionado3,
                              child: FlatButton(
                                child: Image.asset('imagenes/layout3c.png'),
                                onPressed: () {
                                  //Se asigna layout seleccionado a 3
                                  DatosEstaticos.layoutSeleccionado = 3;
                                  _reloj_estado(context);
                                  //Navigator.pushNamed(context, '/crear_layout3');
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 110),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: colorSubrayado3, width: 1))),
                            child: Center(
                              child: Text(
                                "LAYOUT ACTIVO",
                                style: TextStyle(
                                  fontFamily: 'textoMont',
                                  fontSize: 12,
                                  color: colorActivo3,
                                  /*decoration: TextDecoration.underline,
                                    decorationColor: colorSubrayado1*/
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Center(
                              child: Text(
                                "SELECCIONA LAYOUT",
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(HexColor("#FC4C8B")),
                    ),
                  );
                },
              )),
        ),
      ),
    );
  }

  Future<void> _reloj_estado(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
          backgroundColor: Colors.grey.withOpacity(0.0),
          /*
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          backgroundColor: HexColor('#f4f4f4'),*/
          content: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: HexColor('#f4f4f4')),
            height: 150,
            width: 250,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("¿DESEA ACTIVAR RELOJ?", style: TextStyle(fontSize: 13)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        child: Icon(
                          Icons.check_circle,
                          color: HexColor('#3EDB9B'),
                          size: 30,
                        ),
                        onTap: () {
                          //PopUps.PopUpConWidgetYEventos(context, EditarReloj);
                          //Se crea una clase para el reloj que maneja actualización
                          //de estados propia. Sigue la explicación de como manejar
                          //los 2 widget con y sin reloj en la línea: 115 del archivo
                          // 'reloj.dart'
                          Navigator.pop(context);

                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                barrierColor: Colors.black.withOpacity(0.5),
                                barrierDismissible: false,
                                opaque: false,
                                pageBuilder: (_, __, ___) => EditarReloj(),
                              ));
                          // _layout3_reloj(context);
                        },
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.cancel,
                          color: HexColor('#FC4C8B'),
                          size: 30,
                        ),
                        onTap: () {
                          DatosEstaticos.relojEnPantalla = false;
                          Navigator.popAndPushNamed(context, '/crear_layout3');
                          //_layout3_solito(context);
                        },
                      ),
                    ],
                  ),
                ]),
          ),
        );
      },
    );
  }

  recargarListadoEquipos() async {
    //Se actualizan los datos de equipo cada vez que se selecciona
    // un tipo de layout
    //Acá se realizan las consultas para obtener los datos de lo que se
    // está reproduciendo en el equipo
    int _layoutSeleccionado;
    String resp;
    //String tipoNuevoLayout;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];

    try {
      Socket socket;
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada,
              DatosEstaticos.puertoSocketRaspberry)
          .timeout(Duration(seconds: 5));
      socket.write('TVPOSTGETDATOSREPRODUCCIONACTUAL');
      socket.listen((event) {
        listadoRespuestas.addAll(event.toList());
      }).onDone(() {
        _respuesta = Uint8List.fromList(listadoRespuestas);
        socket.close();
        return;
      });

      //Se limpian los datos de seleccion de porcion a cambiar
      DatosEstaticos.reemplazarPorcion1 = false;
      DatosEstaticos.reemplazarPorcion2 = false;
      DatosEstaticos.reemplazarPorcion3 = false;

      await socket.done.whenComplete(() => resp = utf8.decode(_respuesta));
      //Al ya tener los datos, se convierten en diccionario y se pueden utilizar
      DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado =
          json.decode(resp);

      if (DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado.isNotEmpty) {
        //Se limpian los datos guardados
        DatosEstaticos.widget1 = null;
        DatosEstaticos.widget2 = null;
        DatosEstaticos.widget3 = null;
        DatosEstaticos.relojEnPantalla = false;

        _layoutSeleccionado = int.parse(
            DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['layout']);
        DatosEstaticos.nombreArchivoWidget1 =
            DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['archivo1'];
        DatosEstaticos.nombreArchivoWidget2 =
            DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['archivo2'];
        DatosEstaticos.nombreArchivoWidget3 =
            DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['archivo3'];

        //Se asignan los widgets correspondientes a los tipos y archivos
        switch (DatosEstaticos
            .mapaDatosReproduccionEquipoSeleccionado['tipoArchivo1']) {
          case 'Image':
            DatosEstaticos.widget1 = Image.network(
                _direccionArchivo(DatosEstaticos.nombreArchivoWidget1));
            break;
          case 'ReproductorVideos':
            DatosEstaticos.widget1 = ReproductorVideos(
                url: _direccionArchivo(DatosEstaticos.nombreArchivoWidget1));
            break;
          case 'WebView':
            DatosEstaticos.widget1 =
                WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget1);
            break;
          case 'WebViewPropio':
            DatosEstaticos.widget1 =
                WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget1);
            break;
        }

        switch (DatosEstaticos
            .mapaDatosReproduccionEquipoSeleccionado['tipoArchivo2']) {
          case 'Image':
            DatosEstaticos.widget2 = Image.network(
                _direccionArchivo(DatosEstaticos.nombreArchivoWidget2));
            break;
          case 'ReproductorVideos':
            DatosEstaticos.widget2 = ReproductorVideos(
                url: _direccionArchivo(DatosEstaticos.nombreArchivoWidget2));
            break;
          case 'WebView':
            DatosEstaticos.widget2 =
                WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget2);
            break;
          case 'WebViewPropio':
            DatosEstaticos.widget2 =
                WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget2);
            break;
        }

        switch (DatosEstaticos
            .mapaDatosReproduccionEquipoSeleccionado['tipoArchivo3']) {
          case 'Image':
            DatosEstaticos.widget3 = Image.network(
                _direccionArchivo(DatosEstaticos.nombreArchivoWidget3));
            break;
          case 'ReproductorVideos':
            DatosEstaticos.widget3 = ReproductorVideos(
                url: _direccionArchivo(DatosEstaticos.nombreArchivoWidget3));
            break;
          case 'WebView':
            DatosEstaticos.widget3 =
                WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget3);
            break;
          case 'WebViewPropio':
            DatosEstaticos.widget3 =
                WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget3);
            break;
        }

        //Se asigna de visibilidad del reloj
        String relojEnPantalla = DatosEstaticos
            .mapaDatosReproduccionEquipoSeleccionado['relojEnPantalla'];
        if (relojEnPantalla.contains("on")) {
          DatosEstaticos.relojEnPantalla = true;
        } else {
          DatosEstaticos.relojEnPantalla = false;
        }
      } else {
        _layoutSeleccionado = 0;

        ObtieneDatos actualiza = ObtieneDatos();
        actualiza.updateDatosMediaEquipo(
            serial: DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                ['f_serial']);
      }
    } catch (e) {
      print("Error al recargar listado equipos: " + e.toString());
      Navigator.pop(context);
    }
    return _layoutSeleccionado;
  }

  String _direccionArchivo(String direccionWidget) {
    String _direccionCompleta = "http://${DatosEstaticos.ipSeleccionada}"
        "$direccionWidget";
    return _direccionCompleta;
  }

//Aca se activan los colores del texto y subrayado, del layout seleccionado
  void PorcionSeleccionada(int seleccionada) {
    switch (seleccionada) {
      case 0:
        //aca se comentan los bordes rojos de seleccionar layout
        /*_decorationLayoutSeleccionado1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));*/
        colorActivo1 = Colors.transparent;
        colorActivo2 = Colors.transparent;
        colorActivo3 = Colors.transparent;
        colorSubrayado1 = Colors.transparent;
        colorSubrayado2 = Colors.transparent;
        colorSubrayado3 = Colors.transparent;
        break;
      case 1:
        /*_decorationLayoutSeleccionado1 =
            BoxDecoration(border: Border.all(color: Colors.red, width: 10));
        _decorationLayoutSeleccionado2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));*/
        colorActivo1 = HexColor('#bdbdbd');
        colorActivo2 = Colors.transparent;
        colorActivo3 = Colors.transparent;
        colorSubrayado1 = HexColor('#0683FF');
        colorSubrayado2 = Colors.transparent;
        colorSubrayado3 = Colors.transparent;
        break;
      case 2:
        /* _decorationLayoutSeleccionado1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado2 =
            BoxDecoration(border: Border.all(color: Colors.red, width: 10));
        _decorationLayoutSeleccionado3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));*/
        colorActivo1 = Colors.transparent;
        colorActivo2 = HexColor('#bdbdbd');
        colorActivo3 = Colors.transparent;
        colorSubrayado1 = Colors.transparent;
        colorSubrayado2 = HexColor('#0683FF');
        colorSubrayado3 = Colors.transparent;
        break;
      case 3:
        /*_decorationLayoutSeleccionado1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado3 =
            BoxDecoration(border: Border.all(color: Colors.red, width: 10));*/
        colorActivo1 = Colors.transparent;
        colorActivo2 = Colors.transparent;
        colorActivo3 = HexColor('#bdbdbd');
        colorSubrayado1 = Colors.transparent;
        colorSubrayado2 = Colors.transparent;
        colorSubrayado3 = HexColor('#0683FF');
        break;
    }
  }
}
