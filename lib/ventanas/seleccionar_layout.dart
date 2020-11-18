import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/ventanas/seleccionar_video.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    //recargarListadoEquipos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0),
          child: FutureBuilder(
            future: recargarListadoEquipos(),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.done){
                if (snapshot.data!=null){
                  PorcionSeleccionada(snapshot.data);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Layout actualmente utilizado',textAlign: TextAlign.center,),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          decoration: _decorationLayoutSeleccionado1,
                          child: FlatButton(
                            child: Image.asset('imagenes/layout1a.png'),
                            onPressed: (){
                              //Se asigna layout seleccionado a 1
                              DatosEstaticos.layoutSeleccionado = 1;
                              Navigator.pushNamed(context, '/crear_layout1');
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          decoration: _decorationLayoutSeleccionado2,
                          child: FlatButton(
                            child: Image.asset('imagenes/layout2b.png'),
                            onPressed: (){
                              //Se asigna layout seleccionado a 2
                              DatosEstaticos.layoutSeleccionado = 2;
                              Navigator.pushNamed(context, '/crear_layout2');
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: _decorationLayoutSeleccionado3,
                          child: FlatButton(
                            child: Image.asset('imagenes/layout3c.png'),
                            onPressed: (){
                              //Se asigna layout seleccionado a 3
                              DatosEstaticos.layoutSeleccionado = 3;
                              Navigator.pushNamed(context, '/crear_layout3');
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }
              return Center(child: CircularProgressIndicator(),);
            },
          )
        ),
      ),
    );
  }

  recargarListadoEquipos() async{
    //Se actualizan los datos de equipo cada vez que se selecciona
    // un tipo de layout
    //Acá se realizan las consultas para obtener los datos de lo que se
    // está reproduciendo en el equipo
    int _layoutSeleccionado;
    String resp;
    //String tipoNuevoLayout;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];
    Socket socket;
    try{
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada, 
          DatosEstaticos.puertoSocketRaspberry).timeout(Duration(seconds: 5));
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
      DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado = json.decode(resp);

      if (DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado.isNotEmpty){
        //Se limpian los datos guardados
        DatosEstaticos.wiget1 = null;
        DatosEstaticos.wiget2 = null;
        DatosEstaticos.wiget3 = null;
        DatosEstaticos.relojEnPantalla = false;

        _layoutSeleccionado = int.parse(DatosEstaticos
            .mapaDatosReproduccionEquipoSeleccionado['layout']);
        DatosEstaticos.nombreArchivoWidget1 = DatosEstaticos
            .mapaDatosReproduccionEquipoSeleccionado['archivo1'];
        DatosEstaticos.nombreArchivoWidget2 = DatosEstaticos
            .mapaDatosReproduccionEquipoSeleccionado['archivo2'];
        DatosEstaticos.nombreArchivoWidget3 = DatosEstaticos
            .mapaDatosReproduccionEquipoSeleccionado['archivo3'];

        //Se asignan los widgets correspondientes a los tipos y archivos
        switch (DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['tipoArchivo1']){
          case 'Image':
            DatosEstaticos.wiget1 = Image.network(_direccionArchivo(DatosEstaticos.nombreArchivoWidget1));
            break;
          case 'ReproductorVideos':
            DatosEstaticos.wiget1 = ReproductorVideos(url: _direccionArchivo(DatosEstaticos.nombreArchivoWidget1));
            break;
          case 'WebView':
            DatosEstaticos.wiget1 = WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget1);
            break;
          case 'WebViewPropio':
            DatosEstaticos.wiget1 = WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget1);
            break;
        }

        switch (DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['tipoArchivo2']){
          case 'Image':
            DatosEstaticos.wiget2 = Image.network(_direccionArchivo(DatosEstaticos.nombreArchivoWidget2));
            break;
          case 'ReproductorVideos':
            DatosEstaticos.wiget2 = ReproductorVideos(url: _direccionArchivo(DatosEstaticos.nombreArchivoWidget2));
            break;
          case 'WebView':
            DatosEstaticos.wiget2 = WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget2);
            break;
          case 'WebViewPropio':
            DatosEstaticos.wiget2 = WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget2);
            break;
        }

        switch (DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['tipoArchivo3']){
          case 'Image':
            DatosEstaticos.wiget3 = Image.network(_direccionArchivo(DatosEstaticos.nombreArchivoWidget3));
            break;
          case 'ReproductorVideos':
            DatosEstaticos.wiget3 = ReproductorVideos(url: _direccionArchivo(DatosEstaticos.nombreArchivoWidget3));
            break;
          case 'WebView':
            DatosEstaticos.wiget3 = WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget3);
            break;
          case 'WebViewPropio':
            DatosEstaticos.wiget3 = WebViewPropio(urlPropia: DatosEstaticos.nombreArchivoWidget3);
            break;
        }

        //Se asigna de visibilidad del reloj
        String relojEnPantalla = DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['relojEnPantalla'];
        if (relojEnPantalla.contains("on")){
          DatosEstaticos.relojEnPantalla = true;
        } else {
          DatosEstaticos.relojEnPantalla = false;
        }
      } else {
        _layoutSeleccionado = 0;
      }

    } catch(e){
      print("Error al recargar listado equipos: " + e.toString());
    }
    return _layoutSeleccionado;
  }

  String _direccionArchivo(String direccionWidget){
    String _direccionCompleta = "http://${DatosEstaticos.ipSeleccionada}"
        "$direccionWidget";
    return _direccionCompleta;
  }

  void PorcionSeleccionada (int seleccionada){
    switch(seleccionada){
      case 0:
        _decorationLayoutSeleccionado1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 1:
        _decorationLayoutSeleccionado1 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        _decorationLayoutSeleccionado2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 2:
        _decorationLayoutSeleccionado1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado2 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        _decorationLayoutSeleccionado3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 3:
        _decorationLayoutSeleccionado1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado3 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        break;
    }
  }
}

