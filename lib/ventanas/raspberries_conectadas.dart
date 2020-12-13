import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';


class RaspberriesConectadas extends StatefulWidget {
  @override
  _RaspberriesConectadasState createState() => _RaspberriesConectadasState();
}

class _RaspberriesConectadasState extends State<RaspberriesConectadas> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: Container(
        //Para refrescar la grid al arrastrar hacia abajo
        child: LiquidPullToRefresh(
          springAnimationDurationInMilliseconds: 450,
          onRefresh: () =>_recargarGrid(),
          child: GridView.count(
              crossAxisCount: 2,
            children: List.generate(ObtieneDatos.listadoEquipos.length, (index) {

              return new FutureBuilder(
                future: _estadoEquipo(index),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done){
                    if (snapshot.data == null){
                      return Card(
                        child: Center(
                          child: Text(
                              'SIN DATOS'
                          ),
                        ),
                      );
                    }
                    //Cuando ya se cargó la data, se crea el widget
                    else {
                      //Si tiene conexión o está activo se puede hacer click
                      //Y se le pasa la ip
                      if (snapshot.data[2] == true){
                        return GestureDetector(
                          onTap: () {
                            //Libera los widgets y datos creados
                            LimpiarDatosEstaticos();
                            DatosEstaticos.indexSeleccionado = index;
                            return Navigator.pushNamed(
                              context,
                              '/detalle_equipo',
                              arguments: {
                                "indexEquipoGrid" : index,
                              });
                            },
                          child: Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(snapshot.data[1].toString()),
                                Text('${snapshot.data[0]}'),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(snapshot.data[1].toString()),
                              Text('${snapshot.data[0]}'),
                            ],
                          ),
                        );
                      }
                    }
                  } else if(snapshot.hasError){
                    return Card(
                      child: Center(
                        child: Text(
                          'ERROR: ${snapshot.error.toString()}',
                        ),
                      ),
                    );
                  } else {
                    return Card(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  ///Retorna una lista futura con los detalles para el widget Card
  Future<List> _estadoEquipo(int _index) async{
    //Listado de datos que maneja el snapshot del FutureBuilder
    //El dato [0] es alias
    //El dato [1] es dirección de imagen
    //El dato [2] es activo o con conexión
    List datos = List();
    String alias = await ObtieneDatos.listadoEquipos[_index]['f_alias'];
    if (alias == null){
      alias = 'Sin Conexión';
    }
    datos.add(alias);
    bool activo = false;
    //Ver si la raspberry en esa posición está activa
    var equipoActivo = await ObtieneDatos.listadoEquipos[_index]['f_equipoActivo'];
    if (equipoActivo.toString() == '1'){
      activo = true;
    }
    var layoutEquipo = await ObtieneDatos.listadoEquipos[_index]['f_layoutActual'];
    String ip = await ObtieneDatos.listadoEquipos[_index]['f_ip'];

    //Veo si la raspberry en esa posición tiene conexión
    bool conectado = await _ping(ip);

    if (activo && conectado){
      if (layoutEquipo.toString() == '1'){
        datos.add('imagenes/layout1a.png');
        datos.add(true);
        return datos;
      } else if(layoutEquipo.toString() == '2'){
        datos.add('imagenes/layout2b.png');
        datos.add(true);
        return datos;
      } else if(layoutEquipo.toString() == '3'){
        datos.add('imagenes/layout3c.png');
        datos.add(true);
        return datos;
      }
    } else {
      if (layoutEquipo.toString() == '1'){
        datos.add('imagenes/layoutdeshabilitado1.png');
        datos.add(false);
        return datos;
      } else if(layoutEquipo.toString() == '2'){
        datos.add('imagenes/layoutdeshabilitado2.png');
        datos.add(false);
        return datos;
      } else if(layoutEquipo.toString() == '3'){
        datos.add('imagenes/layoutdeshabilitado3.png');
        datos.add(false);
        return datos;
      }
    }
    return datos;
  }

  ///Prueba de ping con tiempo de espera máximo de 5 segundos
  Future<bool> _ping(String ip) async {
    Socket socket;
    String resp;
    //String tipoNuevoLayout;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];
    try{
      socket = await Socket.connect(ip,DatosEstaticos.puertoSocketRaspberry)
          .timeout(Duration(seconds: 5));
      socket.write('TVPOSTPING');
      socket.listen((event) {
        listadoRespuestas.addAll(event.toList());
      }).onDone(() {
        _respuesta = Uint8List.fromList(listadoRespuestas);
        socket.close();
        return;
      });

      await socket.done.whenComplete(() => resp = utf8.decode(_respuesta));
      if (resp!="") return true;
    }catch(e){
      if (socket!=null){
        socket.close();
      }
      return false;
    }
    /*try{
      socket = await Socket.connect(ip,DatosEstaticos.puertoSocketRaspberry)
          .timeout(Duration(seconds: 5));
      /*socket.write('TVPOSTPING');
      socket.close();*/
      return true;
    } catch(e) {
      return false;
    }*/
  }

  Future<void> _recargarGrid() async {
    setState(() {

    });
  }

  void LimpiarDatosEstaticos() {
    DatosEstaticos.widget1 = null;
    DatosEstaticos.widget2 = null;
    DatosEstaticos.widget3 = null;
    DatosEstaticos.nombreArchivoWidget1 = "";
    DatosEstaticos.nombreArchivoWidget2 = "";
    DatosEstaticos.nombreArchivoWidget3 = "";
    DatosEstaticos.color_fondo_reloj = "#FFFFFD";
    DatosEstaticos.color_texto_reloj = "#010000";
  }

}