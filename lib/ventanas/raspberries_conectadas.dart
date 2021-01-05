import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:fswitch/fswitch.dart';
//import 'package:tvpost_flutter/ventanas/detalle_equipo.dart';
//import 'package:lite_rolling_switch/lite_rolling_switch.dart';

int cantidad;
bool valorSwitchTodos;
bool valorSwitchUno;
bool estadoToogle;
Text onOff = Text("ON");
Color on;
Color off;

class RaspberriesConectadas extends StatefulWidget {
  @override
  _RaspberriesConectadasState createState() => _RaspberriesConectadasState();
}

class _RaspberriesConectadasState extends State<RaspberriesConectadas> {
  Image _screenshotProcesada = Image.asset(
    'imagenes/logohorizontal.png',
    fit: BoxFit.fill,
  );

  @override
  void initState() {
    super.initState();
    LimpiarDatosEstaticos();
  }

  @override
  Widget build(BuildContext context) {
    ObtieneDatos datos = ObtieneDatos();

    return WillPopScope(
      onWillPop: (){
        Widget contenidoPopUp = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Desea salir de TvPost?', textAlign: TextAlign.center,),
            SizedBox(height: 10,),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: RaisedButton(
                    onPressed: (){
                      if (Platform.isAndroid){
                        SystemNavigator.pop();
                        return;
                      } else {
                        exit(0);
                      }
                    },
                    child: Text('Aceptar', textAlign: TextAlign.center,),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  flex: 1,
                  child: RaisedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar', textAlign: TextAlign.center,),
                  ),
                ),
              ],
            )
          ],
        );
        PopUps.PopUpConWidget(context, contenidoPopUp);
        return;
      },
      child: Scaffold(
        //Appbar viene de archivo custom_widgets.dart
        appBar: CustomAppBarSinFlechaBack(),
        body: FutureBuilder(
            future: datos.getDatosEquipos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  valorSwitchTodos = TodosEquiposDesactivados();
                  //Cambio de color de texto on off
                  if (valorSwitchTodos) {
                    on = Colors.white;
                    off = Colors.black;
                  } else {
                    on = Colors.black;
                    off = Colors.white;
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 20),
                        child: Text(
                          "MIS PANTALLAS",
                          style: TextStyle(fontSize: 16.5),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: LiquidPullToRefresh(
                          springAnimationDurationInMilliseconds: 450,
                          onRefresh: () => _recargarGrid(),
                          child: GridView.count(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            mainAxisSpacing: 20,
                            crossAxisCount: 2,
                            children: List.generate(
                                ObtieneDatos.listadoEquipos.length, (index) {
                              return new FutureBuilder(
                                future: _estadoEquipo(index),
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.data == null) {
                                      return Center(
                                        child: Text(
                                            'DESLICE PARA ACTUALIZAR RECEPTOR'),
                                      );
                                    }
                                    //Cuando ya se cargó la data, se crea el widget
                                    else {
                                      //Si tiene conexión o está activo se puede hacer click
                                      //Y se le pasa el index a un listado de equipos conectados
                                      if (snapshot.data[2] == true &&
                                          snapshot.data[3] == true) {
                                        //Se añade el index a los equipos conectados
                                          if (DatosEstaticos.listadoIndexEquiposConectados.contains(index) == false){
                                            DatosEstaticos.listadoIndexEquiposConectados.add(index);
                                          }
                                        //print(DatosEstaticos.listadoIndexEquiposConectados.length);
                                        return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  //Libera los widgets y datos creados
                                                  LimpiarDatosEstaticos();
                                                  DatosEstaticos.indexSeleccionado = index;
                                                  DatosEstaticos.ipSeleccionada = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
                                                  /*return Navigator.push(
                                                      context,
                                                      PageRouteBuilder(
                                                        barrierDismissible: false,
                                                        opaque: true,

                                                        pageBuilder: (_, __, ___) => DetalleEquipo(),
                                                      ),
                                                  );*/

                                                  return Navigator.popAndPushNamed(
                                                      context, '/detalle_equipo',
                                                      arguments: {
                                                        "indexEquipoGrid": index,
                                                      }
                                                    );
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      snapshot.data[1].toString(),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.3,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.3,
                                                //color:Colors.red,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              6.5,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      VistaPreviaReproduccion(
                                                                          index);
                                                                    },
                                                                    child: Center(
                                                                      child: Icon(
                                                                        Icons
                                                                            .remove_red_eye_sharp,
                                                                        color: Colors
                                                                            .blueAccent,
                                                                        size: 30,
                                                                      ),
                                                                    )),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      //AlertaDesactivar(index: index);
                                                                      //Libera los widgets y datos creados
                                                                      LimpiarDatosEstaticos();
                                                                      DatosEstaticos
                                                                              .indexSeleccionado =
                                                                          index;
                                                                      DatosEstaticos.ipSeleccionada = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
                                                                      return Navigator.popAndPushNamed(
                                                                          context,
                                                                          '/detalle_equipo',
                                                                          arguments: {
                                                                            "indexEquipoGrid":
                                                                                index,
                                                                          });
                                                                    },
                                                                    child: Center(
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            Colors
                                                                                .blueAccent,
                                                                        radius:
                                                                            10,
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .edit,
                                                                          size:
                                                                              17,
                                                                          color: Colors
                                                                              .white,
                                                                        ),
                                                                      ),
                                                                    )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                      child: Text(
                                                        '${snapshot.data[0].toString().toUpperCase()}',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          fontFamily: 'textoMont',
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]);
                                      }
                                      //Equipo conectado pero desactivado por el usuario
                                      else if (snapshot.data[2] == true &&
                                          snapshot.data[3] == false) {
                                        //Se añade el index a los equipos conectados
                                        if (DatosEstaticos.listadoIndexEquiposConectados.contains(index) == false){
                                          DatosEstaticos.listadoIndexEquiposConectados.add(index);
                                        }
                                        return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  //MensajeActivarEquipo(index);
                                                  LimpiarDatosEstaticos();
                                                  DatosEstaticos
                                                      .indexSeleccionado = index;
                                                  DatosEstaticos.ipSeleccionada = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
                                                  return Navigator.popAndPushNamed(
                                                      context, '/detalle_equipo',
                                                      arguments: {
                                                        "indexEquipoGrid": index,
                                                      });
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      snapshot.data[1].toString(),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.3,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.3,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              6.5,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                                GestureDetector(
                                                                    onTap: null,
                                                                    child: Center(
                                                                      child: Icon(
                                                                        Icons
                                                                            .remove_red_eye_sharp,
                                                                        color: Colors
                                                                            .transparent,
                                                                        size: 30,
                                                                      ),
                                                                    )),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      //AlertaActivar(index: index);
                                                                      /*MensajeActivarEquipo(
                                                                      index);*/
                                                                      //Libera los widgets y datos creados
                                                                      LimpiarDatosEstaticos();
                                                                      DatosEstaticos
                                                                              .indexSeleccionado =
                                                                          index;
                                                                      DatosEstaticos.ipSeleccionada = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
                                                                      return Navigator.popAndPushNamed(
                                                                          context,
                                                                          '/detalle_equipo',
                                                                          arguments: {
                                                                            "indexEquipoGrid":
                                                                                index,
                                                                          });
                                                                    },
                                                                    child: Center(
                                                                      child:
                                                                          CircleAvatar(
                                                                        backgroundColor:
                                                                            HexColor(
                                                                                '#FC4C8B'),
                                                                        radius:
                                                                            10,
                                                                        child:
                                                                            Icon(
                                                                          Icons
                                                                              .edit,
                                                                          size:
                                                                              17,
                                                                          color: Colors
                                                                              .white,
                                                                        ),
                                                                      ),
                                                                    )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                      child: Text(
                                                        '${snapshot.data[0].toString().toUpperCase()}',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          fontFamily: 'textoMont',
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]);
                                      } else {
                                        //Se remueve el index a los equipos conectados
                                        if (DatosEstaticos.listadoIndexEquiposConectados.contains(index) == false){
                                          DatosEstaticos.listadoIndexEquiposConectados.remove(index);
                                        }
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                EquipoSinConexion(index);
                                              },
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    snapshot.data[1].toString(),
                                                    width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        2.3,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.3,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        6.5,
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: GestureDetector(
                                                              onTap: null,
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .do_disturb_on_rounded,
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                              )),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: GestureDetector(
                                                              onTap: () {
                                                                EquipoSinConexion(
                                                                    index);
                                                              },
                                                              child: Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .do_disturb_on_rounded,
                                                                  color: HexColor(
                                                                      '#FC4C8B'),
                                                                ),
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        4,
                                                    child: Text(
                                                      '${snapshot.data[0].toString().toUpperCase()}',
                                                      textAlign: TextAlign.right,
                                                      style: TextStyle(
                                                        fontFamily: 'textoMont',
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                        /*return Card(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(snapshot.data[1].toString()),
                                          Text('${snapshot.data[0]}'),
                                        ],
                                      ),
                                    );*/
                                      }
                                    }
                                  } else if (snapshot.hasError) {
                                    //Se remueve el index a los equipos conectados
                                    if (DatosEstaticos.listadoIndexEquiposConectados.contains(index) == false){
                                      DatosEstaticos.listadoIndexEquiposConectados.remove(index);
                                    }
                                    return Center(
                                      child: Text(
                                        'ERROR: ${snapshot.error.toString()}',
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(40.0),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            HexColor("#FC4C8B")),
                                      ),
                                    );
                                  }
                                },
                              );
                            }),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 35,
                              child: Container(
                                /*decoration: new BoxDecoration(
                                  gradient: new LinearGradient(
                                      colors: [Colors.white, Colors.transparent],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      stops: [0.5, 0.5],
                                  ),
                                ),*/
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      var dato = ObtieneDatos.listadoEquipos;
                                      if (valorSwitchTodos == false) {
                                        AlertaDeshabilitar(
                                            listadoEquipos: dato,
                                            valorSwitch: valorSwitchTodos);
                                      } else {
                                        AlertaHabilitar(
                                            listadoEquipos: dato,
                                            valorSwitch: valorSwitchTodos);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Stack(children: [
                                        Positioned(
                                          child: Container(
                                            decoration: new BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                gradient: LinearGradient(
                                                    colors: [
                                                      HexColor("#3edb9b"),
                                                      HexColor("#0683ff")
                                                    ],
                                                    stops: [
                                                      0.4,
                                                      1
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: FractionalOffset
                                                        .bottomRight)),
                                            child: IgnorePointer(
                                              child: FSwitch(
                                                offset: 10,
                                                open: valorSwitchTodos,
                                                onChanged: (bool v) {},
                                                sliderColor: Colors.white,
                                                color: Colors.transparent,
                                                openColor: Colors.transparent,
                                                width: 200,
                                                height: 40,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 13,
                                          left: 17,
                                          child: Text(
                                            "ON",
                                            style: TextStyle(color: on),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 13,
                                          left: 159,
                                          child: Text(
                                            "OFF",
                                            style: TextStyle(color: off),
                                          ),
                                        )
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Actualizando pantallas"),
                  ],
                ),
              );
            }),
      ),
    );
  }

  ///Retorna una lista futura con los detalles para el widget
  Future<List> _estadoEquipo(int _index) async {
    //Listado de datos que maneja el snapshot del FutureBuilder
    //El dato [0] es alias
    //El dato [1] es dirección de imagen
    //El dato [2] es activo o con conexión
    //Actualiza datos de equipos
    ObtieneDatos actualizaDatos = ObtieneDatos();
    await actualizaDatos.getDatosEquipos();
    List datos = List();
    String alias = await ObtieneDatos.listadoEquipos[_index]['f_alias'];
    if (alias == null) {
      alias = 'Sin Conexión';
    }
    datos.add(alias);
    bool activo = false;
    //Ver si la raspberry en esa posición está activa
    var equipoActivo =
        await ObtieneDatos.listadoEquipos[_index]['f_equipoActivo'];
    if (equipoActivo.toString() == '1') {
      activo = true;
    }
    var layoutEquipo =
        await ObtieneDatos.listadoEquipos[_index]['f_layoutActual'];
    String ip = await ObtieneDatos.listadoEquipos[_index]['f_ip'];

    //Veo si la raspberry en esa posición tiene conexión
    bool conectado = await _ping(ip);

    //Acá se permiten botones si hay ping pero está desactivado
    if (activo == false && conectado) {
      if (layoutEquipo.toString() == '1') {
        datos.add('imagenes/layoutdeshabilitado1.png');
        datos.add(true);
        datos.add(false);
      } else if (layoutEquipo.toString() == '2') {
        datos.add('imagenes/layoutdeshabilitado2.png');
        datos.add(true);
        datos.add(false);
      } else if (layoutEquipo.toString() == '3') {
        datos.add('imagenes/layoutdeshabilitado3.png');
        datos.add(true);
        datos.add(false);
      }
      return datos;
    } else if (activo && conectado) {
      //Future<int> layout= obtieneDatosLayout(ip);

      if (layoutEquipo.toString() == '1') {
        datos.add('imagenes/layout1a.png');
        datos.add(true);
        datos.add(true);
      } else if (layoutEquipo.toString() == '2') {
        datos.add('imagenes/layout2b.png');
        datos.add(true);
        datos.add(true);
      } else if (layoutEquipo.toString() == '3') {
        datos.add('imagenes/layout3c.png');
        datos.add(true);
        datos.add(true);
      }
    } else {
      datos.add('imagenes/layoutdeshabilitado1.png');
      datos.add(false);
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
    try {
      socket = await Socket.connect(ip, DatosEstaticos.puertoSocketRaspberry)
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
      if (resp != "") return true;
    } catch (e) {
      if (socket != null) {
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
      LimpiarDatosEstaticos();
      DatosEstaticos.listadoIndexEquiposConectados = [];
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
    DatosEstaticos.ipSeleccionada = null;
    DatosEstaticos.divisionLayout = null;
  }

  void listarEquipos() async {
    ObtieneDatos datos = ObtieneDatos();
    await datos.getDatosEquipos();
  }

  VistaPreviaReproduccion(int index) async {
    Color onPopUp;
    Color offPopUp;
    String ip = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
    String valorActivo =
        ObtieneDatos.listadoEquipos[index]['f_equipoActivo'].toString();
    if (valorActivo == '1') {
      valorSwitchUno = false;
      onPopUp = Colors.black;
      offPopUp = Colors.white;
    } else {
      valorSwitchUno = true;
      onPopUp = Colors.white;
      offPopUp = Colors.black;
    }

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.6), // Color de fondo
      barrierDismissible: true,
      barrierLabel: "Captura_en_vivo", // Etiqueta obligatoria
      transitionDuration:
          Duration(milliseconds: 400), //Cuanto demora en desaparecer
      pageBuilder: (_, __, ___) {
        //widgets
        return Scaffold(
          appBar: CustomAppBar(),
          body: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(children: [
              Positioned(
                top: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  child: Center(
                    child: Text(
                      "MIS PANTALLAS",
                      style: TextStyle(fontSize: 16.5),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 70,
                right: 20,
                left: 20,
                child: Container(
                  //Vista previa completa
                  height: MediaQuery.of(context).size.height / 3.2,
                  width: MediaQuery.of(context).size.width - 50,
                  padding: EdgeInsets.all(20),
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: HexColor('#3EDB9B')
                      /*gradient: LinearGradient(
                                    colors: [HexColor("#3edb9b"), HexColor("#0683ff")],
                                    stops: [0.5, 1],
                                    begin: Alignment.topLeft,
                                    end: FractionalOffset.bottomRight)*/
                      ),
                  child: Center(
                    child: Container(
                      //marco blanco de vista previa
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white),
                      /*width: MediaQuery.of(context).size.width / 1.2,
                      height: MediaQuery.of(context).size.height / 3.8,*/
                      padding: EdgeInsets.all(10),
                      //margin: EdgeInsets.only(right: 35, left: 35),
                      child: FutureBuilder(
                        future: _getScreenShot(ip),
                        builder: (context, snapshot) {
                          Widget widgetError = Column(
                            children: [
                              _screenshotProcesada,
                            ],
                          );
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data == null) {
                              return widgetError;
                            } else {
                              //Retorna el widget con la imagen de screenshot
                              var tipoimage = _screenshotProcesada
                                  .image.runtimeType
                                  .toString();
                              if (tipoimage == "AssetImage") {
                                return widgetError;
                              }
                              return Container(
                                  child: Center(child: _screenshotProcesada));
                            }
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: 60,
                  right: 18,
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: HexColor('#FC4C8B'),
                  )
                  /* Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 20,
                ),*/
                  ),
              Positioned(
                  top: 49,
                  right: 7,
                  child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })),
              GestureDetector(
                onTap: () {
                  if (valorSwitchUno == false) {
                    AlertaDeshabilitar(
                        index: index, valorSwitch: valorSwitchUno);
                  } else {
                    AlertaHabilitar(index: index, valorSwitch: valorSwitchUno);
                  }
                },
                child: Stack(
                  children: [
                    Positioned(
                        bottom: 50,
                        right: 100,
                        left: 100,
                        child: Container(
                          decoration: new BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                  colors: [
                                    HexColor("#3edb9b"),
                                    HexColor("#0683ff")
                                  ],
                                  stops: [
                                    0.4,
                                    1
                                  ],
                                  begin: Alignment.topLeft,
                                  end: FractionalOffset.bottomRight)),
                          child: Stack(
                            children: [
                              IgnorePointer(
                                child: FSwitch(
                                  offset: 10,
                                  open: valorSwitchUno,
                                  onChanged: (bool v) {},
                                  sliderColor: Colors.white,
                                  color: Colors.transparent,
                                  openColor: Colors.transparent,
                                  width: 200,
                                  height: 40,
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 13,
                                child: Text(
                                  "ON",
                                  style: TextStyle(color: onPopUp),
                                ),
                              ),
                              Positioned(
                                right: 18,
                                bottom: 13,
                                child: Text(
                                  "OFF",
                                  style: TextStyle(color: offPopUp),
                                ),
                              ),
                            ],
                          ),
                        ) /*AnimatedContainer(
                      duration: Duration(milliseconds: 1000),
                      height: 40,
                      width: 100,
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                              colors: [HexColor("#3edb9b"), HexColor("#0683ff")],
                              stops: [0.5, 1],
                              begin: Alignment.topLeft,
                              end: FractionalOffset.bottomRight)),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            child: InkWell(
                              onTap: toggleButton,
                            ),
                            duration: Duration(milliseconds: 1000),
                            curve: Curves.easeIn,
                            top: 3.0,
                            left: estadoToogle ? 60.0 : 0.0,
                            right: estadoToogle ? 0.0 : 60.0,

                          )
                        ],
                      ),
                    ),*/
                        ),
                    /*Positioned(
                      bottom: 63,
                      left: 90,
                      child: Text("ON"),
                    ),
                    Positioned(
                      bottom: 63,
                      left: 247,
                      child: Text("OFF"),
                    )*/
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Future _getScreenShot(String ip) async {
    //Utilizar el memoizer hace que la función de Future solo ocurra una vez
    String host = ip;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];
    //int _largoEvent = 0;
    //Hacer llamada al socket con comando de screenshot
    Socket socket;
    try {
      socket = await Socket.connect(host, DatosEstaticos.puertoSocketRaspberry)
          .timeout(Duration(seconds: 5));
      socket.write('TVPOSTGETSCREEN');
      socket.listen((event) {
        listadoRespuestas.addAll(event);
        socket.flush();
      }).onDone(() {
        socket.close();
        return;
      });

      //El retornar esto, hace que el FutureBuilder espere al "done"
      //Si no se retorna el whencomplete, se salta al final
      return socket.done.whenComplete(() {
        _respuesta = Uint8List.fromList(listadoRespuestas);
        if (_respuesta.isEmpty) {
          _screenshotProcesada = Image.asset('imagenes/logohorizontal.png');
        } else {
          _screenshotProcesada = Image.memory(_respuesta);
        }
        //print(listadoRespuestas.length);
      });
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  void AlertaDeshabilitar(
      {int index = 0,
      List<dynamic> listadoEquipos,
      bool valorSwitch = true}) async {
    String ip = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
    String serial = ObtieneDatos.listadoEquipos[index]['f_serial'].toString();
    String alias = ObtieneDatos.listadoEquipos[index]['f_alias'].toString();
    ObtieneDatos actualizarEstado = ObtieneDatos();

    Widget contenido;

    if (listadoEquipos == null) {
      contenido = new AlertDialog(
        title: Text(
          'Deshabilitar Equipo',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Alias: ${alias}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Serial: ${serial}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Ip: ${ip}',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: RaisedButton(
                      child: Text(
                        'Aceptar',
                        textScaleFactor: 1.3,
                      ),
                      onPressed: () async {
                        PopUps.popUpCargando(
                            context, 'Deshabilitando equipo...');
                        var resultado = await actualizarEstado
                            .updateEstadoEquipo(serial: serial, estado: "0");
                        if (resultado == 1) {
                          setState(() {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            valorSwitchUno = true;
                            Widget contenidoPopUp = Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Equipo $alias deshabilitado'),
                                SizedBox(
                                  width: 10,
                                ),
                                RaisedButton(
                                  child: Text(
                                    'Aceptar',
                                    textScaleFactor: 1.3,
                                  ),
                                  onPressed: () {
                                    //Navigator.pop(context);
                                    Navigator.pop(context);
                                    //Libera los widgets y datos creados
                                    LimpiarDatosEstaticos();
                                    DatosEstaticos.indexSeleccionado = index;
                                    DatosEstaticos.ipSeleccionada = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
                                    return Navigator.popAndPushNamed(
                                        context, '/detalle_equipo',
                                        arguments: {
                                          "indexEquipoGrid": index,
                                        });
                                  },
                                ),
                              ],
                            );
                            PopUps.PopUpConWidget(context, contenidoPopUp);
                          });
                        }
                      },
                    )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 1,
                    child: RaisedButton(
                      child: Text(
                        'Cancelar',
                        textScaleFactor: 1.3,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        /*setState(() {
                          Navigator.pop(context);
                          valorSwitchUno = valorSwitch;
                        });*/
                      },
                    )),
              ],
            ),
          ],
        ),
      );
    } else {
      contenido = new AlertDialog(
        title: Text(
          'Deshabilitar Equipos',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Desea deshabilitar todos los equipos?',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: RaisedButton(
                      child: Text(
                        'Aceptar',
                        textScaleFactor: 1.3,
                      ),
                      onPressed: () async {
                        PopUps.popUpCargando(
                            context, 'Deshabilitando equipos...');
                        var resultado =
                            await actualizarEstado.updateEstadoEquipo(
                                serial: "-1",
                                estado: "0",
                                listadoEquipos: listadoEquipos);
                        if (resultado == 1) {
                          setState(() {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            valorSwitchTodos = true;
                            Widget contenidoPopUp = Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Todos los equipos deshabilitados'),
                                SizedBox(
                                  width: 10,
                                ),
                                RaisedButton(
                                  child: Text(
                                    'Aceptar',
                                    textScaleFactor: 1.3,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                            PopUps.PopUpConWidget(context, contenidoPopUp);
                          });
                        }
                      },
                    )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 1,
                    child: RaisedButton(
                      child: Text(
                        'Cancelar',
                        textScaleFactor: 1.3,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        /*setState(() {
                          valorSwitchTodos = valorSwitch;
                        });*/
                      },
                    )),
              ],
            ),
          ],
        ),
      );
    }

    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      child: contenido,
    );
  }

  void CambiarTexto(bool estado) {
    setState(() {
      if (estado = true) {
        onOff = Text("GG");
      } else {
        onOff = Text("qq");
      }
    });
  }

  void AlertaHabilitar(
      {int index = 0,
      List<dynamic> listadoEquipos,
      bool valorSwitch = true}) async {
    String ip = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
    String serial = ObtieneDatos.listadoEquipos[index]['f_serial'].toString();
    String alias = ObtieneDatos.listadoEquipos[index]['f_alias'].toString();
    ObtieneDatos actualizarEstado = ObtieneDatos();

    Widget contenido;

    if (listadoEquipos == null) {
      contenido = new AlertDialog(
        title: Text(
          'Habilitar Equipo',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Alias: ${alias}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Serial: ${serial}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Ip: ${ip}',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: RaisedButton(
                      child: Text(
                        'Aceptar',
                        textScaleFactor: 1.3,
                      ),
                      onPressed: () async {
                        PopUps.popUpCargando(context, 'Habilitando equipo...');
                        var resultado = await actualizarEstado
                            .updateEstadoEquipo(serial: serial, estado: "1");
                        if (resultado == 1) {
                          setState(() {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            valorSwitchUno = false;
                            Widget contenidoPopUp = Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Equipo $alias habilitado'),
                                SizedBox(
                                  width: 10,
                                ),
                                RaisedButton(
                                  child: Text(
                                    'Aceptar',
                                    textScaleFactor: 1.3,
                                  ),
                                  onPressed: () {
                                    //Navigator.pop(context);
                                    Navigator.pop(context);
                                    //Libera los widgets y datos creados
                                    LimpiarDatosEstaticos();
                                    DatosEstaticos.indexSeleccionado = index;
                                    DatosEstaticos.ipSeleccionada = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
                                    return Navigator.popAndPushNamed(
                                        context, '/detalle_equipo',
                                        arguments: {
                                          "indexEquipoGrid": index,
                                        });
                                  },
                                ),
                              ],
                            );
                            PopUps.PopUpConWidget(context, contenidoPopUp);
                          });
                        }
                      },
                    )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 1,
                    child: RaisedButton(
                      child: Text(
                        'Cancelar',
                        textScaleFactor: 1.3,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        /*setState(() {
                          Navigator.pop(context);
                          valorSwitchUno = valorSwitch;
                        });*/
                      },
                    )),
              ],
            ),
          ],
        ),
      );
    } else {
      contenido = new AlertDialog(
        title: Text(
          'Habilitar Equipos',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Desea habilitar todos los equipos?',
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: RaisedButton(
                      child: Text(
                        'Aceptar',
                        textScaleFactor: 1.3,
                      ),
                      onPressed: () async {
                        PopUps.popUpCargando(context, 'Habilitando equipos...');
                        var resultado =
                            await actualizarEstado.updateEstadoEquipo(
                                serial: "-1",
                                estado: "1",
                                listadoEquipos: listadoEquipos);
                        if (resultado == 1) {
                          setState(() {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            valorSwitchTodos = false;
                            Widget contenidoPopUp = Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Todos los equipos habilitados'),
                                SizedBox(
                                  width: 10,
                                ),
                                RaisedButton(
                                  child: Text(
                                    'Aceptar',
                                    textScaleFactor: 1.3,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                            PopUps.PopUpConWidget(context, contenidoPopUp);
                          });
                        }
                      },
                    )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 1,
                    child: RaisedButton(
                      child: Text(
                        'Cancelar',
                        textScaleFactor: 1.3,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        /*setState(() {
                          valorSwitchTodos = valorSwitch;
                        });*/
                      },
                    )),
              ],
            ),
          ],
        ),
      );
    }

    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      child: contenido,
    );
  }

  void EquipoSinConexion(int index) {
    String ip = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
    String serial = ObtieneDatos.listadoEquipos[index]['f_serial'].toString();
    String alias = ObtieneDatos.listadoEquipos[index]['f_alias'].toString();
    Widget contenidoPopUp = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //Título
        Text(
          'Receptor sin comunicación',
          textAlign: TextAlign.center,
          textScaleFactor: 1.2,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Alias: ${alias}',
          textAlign: TextAlign.center,
        ),
        Text(
          'Serial: ${serial}',
          textAlign: TextAlign.center,
        ),
        Text(
          'Ip: ${ip}',
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Compruebe conexión de red y energía',
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 10,
        ),
        RaisedButton(
          child: Text(
            'Aceptar',
            textScaleFactor: 1.3,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    PopUps.PopUpConWidget(context, contenidoPopUp);
  }

  void MensajeActivarEquipo(int index) {
    String alias = ObtieneDatos.listadoEquipos[index]['f_alias'].toString();
    Widget contenidoPopUp = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //Título
        Text(
          'Función no permitida',
          textAlign: TextAlign.center,
          textScaleFactor: 1.2,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        /*SizedBox(height:10,),
        Text('Alias: ${alias}', textAlign: TextAlign.center,),
        Text('Serial: ${serial}', textAlign: TextAlign.center,),
        Text('Ip: ${ip}', textAlign: TextAlign.center,),
        SizedBox(
          height: 10,
        ),*/
        SizedBox(
          height: 10,
        ),
        Text(
          "Active equipo ' $alias ' y vuelva a intentarlo",
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 10,
        ),
        RaisedButton(
          child: Text(
            'Aceptar',
            textScaleFactor: 1.3,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    PopUps.PopUpConWidget(context, contenidoPopUp);
  }

  /*Future<int> obtieneDatosLayout(String ip) async {
    int _layoutSeleccionado;
    String resp;
    //String tipoNuevoLayout;
    Uint8List _respuesta;
    List<int> listadoRespuestas;
    try{
      Socket socket;
      socket = await Socket.connect(ip,
          DatosEstaticos.puertoSocketRaspberry).timeout(Duration(seconds: 5));
      socket.write('TVPOSTGETDATOSREPRODUCCIONACTUAL');
      socket.listen((event) {
        listadoRespuestas.addAll(event.toList());
      }).onDone(() {
        _respuesta = Uint8List.fromList(listadoRespuestas);
        socket.close();
        return;
      });

      await socket.done.whenComplete(() => resp = utf8.decode(_respuesta));
      //Al ya tener los datos, se convierten en diccionario y se pueden utilizar
      Map<String,dynamic> mapaDatos = json.decode(resp);

      if (mapaDatos.isNotEmpty){
        _layoutSeleccionado = int.parse(DatosEstaticos
            .mapaDatosReproduccionEquipoSeleccionado['layout']);
      } else {
        _layoutSeleccionado = 1;
      }

    } catch(e){
      print("Error al obtener layout equipos listados: " + e.toString());
      _layoutSeleccionado = 1;
    }
    return _layoutSeleccionado;
  }
*/
}

bool TodosEquiposDesactivados() {
  bool todosDesactivados;
  int cantidadDesactivados = 0;
  var listado = ObtieneDatos.listadoEquipos;
  listado.forEach((element) {
    if (element['f_equipoActivo'].toString() == '0') {
      cantidadDesactivados += 1;
    }
  });
  if (cantidadDesactivados >= listado.length) {
    todosDesactivados = true;
  } else {
    todosDesactivados = false;
  }
  return todosDesactivados;
}
