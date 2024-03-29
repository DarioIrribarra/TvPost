import 'dart:async';
//import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
//import 'package:tvpost_flutter/ventanas/raspberries_conectadas.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:fswitch/fswitch.dart';
import 'package:tvpost_flutter/tvlapiz_icons.dart';

class DetalleEquipo extends StatefulWidget {
  @override
  _DetalleEquipoState createState() => _DetalleEquipoState();
}

class _DetalleEquipoState extends State<DetalleEquipo> {
  Map datosDesdeVentanaAnterior = {};
  int indexEquipoGrid = 0;
  Image _screenshotProcesada = Image.asset(
    'imagenes/logohorizontal.png',
    fit: BoxFit.fill,
  );
  Image _equipoNoActivado = Image.asset(
    'imagenes/linea.png',
    width: 300,
  );
  GlobalKey<FormState> _keyValidador = GlobalKey<FormState>();
  TextEditingController _controladorTexto = TextEditingController(text: "");
  //Guarda el estado del context para usarlo con el snackbar
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool valorSwitch;
  EventosPropios eventosPropios = EventosPropios();

  //Utilizar el memoizer hace que la función de Future (getScreenShot())
  // solo ocurra una vez. De lo contrario se llama con cada acción del build
  //final AsyncMemoizer _memoizer = AsyncMemoizer();

  @override
  void dispose() {
    _controladorTexto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Se obtiene la info de la ventana anterior

    datosDesdeVentanaAnterior = ModalRoute.of(context).settings.arguments;
    indexEquipoGrid = datosDesdeVentanaAnterior['indexEquipoGrid'];

    //Se obtiene serial para manejar todos los datos en un listado de
    // datos propio de esa serial
    String serialSeleccionada =
        ObtieneDatos.listadoEquipos[indexEquipoGrid]['f_serial'].toString();

    //Se pasan todos los datos del equipo seleccionado a su propio listado
    DatosEstaticos.listadoDatosEquipoSeleccionado = ObtieneDatos.listadoEquipos
        .where((equipo) => equipo['f_serial'] == serialSeleccionada)
        .toList();

    DatosEstaticos.ipSeleccionada =
        DatosEstaticos.listadoDatosEquipoSeleccionado[0]['f_ip'];

    Widget widgetContenido;

    String equipoActivo = ObtieneDatos.listadoEquipos[indexEquipoGrid]
            ['f_equipoActivo']
        .toString();

    //Cuando el equipo está habilitado muestra imagen de pantallazo
    if (equipoActivo == '1') {
      valorSwitch = false;
      widgetContenido = FutureBuilder(
        future: _getScreenShot(),
        builder: (context, snapshot) {
          Widget widgetError = Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3,
                child: _screenshotProcesada,
                color: Colors.green,
                margin: EdgeInsets.only(bottom: 10),
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "¡Ups, algo ha salido mal!",
                  textScaleFactor: 1.2,
                ),
              )),
              Text(
                "Deslice hacia abajo para recargar imagen",
                textScaleFactor: 1.2,
              ),
            ],
          );
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null) {
              return widgetError;
            } else {
              //Retorna el widget con la imagen de screenshot
              var tipoimage = _screenshotProcesada.image.runtimeType.toString();
              if (tipoimage == "AssetImage") {
                return widgetError;
              }

              return Column(
                children: [
                  Column(
                    children: [
                      Column(
                        children: [
                          Container(
                            color: HexColor("#3EDB9B"),
                            margin: EdgeInsets.only(bottom: 5),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _screenshotProcesada,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FlatButton(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.screen_share_outlined,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            'CONTROL REMOTO',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      color: Colors.transparent,
                                      onPressed: () {
                                        _vncRaspberryWeb();
                                      }),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Deslizar hacia abajo para actualizar imagen',
                            style: TextStyle(
                              color: HexColor('#757575'),
                              letterSpacing: 1.5,
                              fontFamily: 'textoMont',
                              fontSize: 12,
                            ),
                            textScaleFactor: 1.1,
                          ),
                        ],
                      ),
                      /*
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FloatingActionButton(
                                heroTag: null,
                                child: Icon(Icons.refresh),
                                onPressed: () {
                                  setState(() {});
                                },
                              ),
                              FloatingActionButton(
                                heroTag: null,
                                child: Icon(Icons.screen_search_desktop),
                                onPressed: () {
                                  _vncRaspberryWeb();
                                },
                              )
                            ],
                          ),

                           */
                      Container(
                        margin: EdgeInsets.only(top: 40),
                        height: MediaQuery.of(context).size.height / 10,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(children: [
                              Row(
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text('NOMBRE'),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('SERIAL'),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('IP'),
                                      ]),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text('  : '),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('  : '),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('  : ')
                                      ]),
                                ],
                              )
                            ]),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  DatosEstaticos
                                      .listadoDatosEquipoSeleccionado[0]
                                          ['f_alias']
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'textoMont',
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  DatosEstaticos
                                      .listadoDatosEquipoSeleccionado[0]
                                          ['f_serial']
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'textoMont',
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Text(
                                  DatosEstaticos
                                          .listadoDatosEquipoSeleccionado[0]
                                      ['f_ip'],
                                  style: TextStyle(
                                    fontFamily: 'textoMont',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  radius: 10,
                                  child: FlatButton(
                                    onPressed: () async {
                                      _widgetPopUpAlias();
                                    },
                                    child: Container(
                                      transform: Matrix4.translationValues(
                                          -16.0, 0.0, 0.0),
                                      child: Icon(
                                        Tvlapiz.lapiz,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                /*Text(""),
                                  Text("")*/
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 2.5,
                    child: Container(
                      height: 40,
                      width: 200,
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                              colors: [
                                HexColor("#0683ff"),
                                HexColor("#3edb9b")
                              ],
                              stops: [
                                0.1,
                                0.6
                              ],
                              begin: Alignment.topLeft,
                              end: FractionalOffset.bottomRight)),
                      child: FlatButton(
                        color: Colors.transparent,
                        onPressed: () async {
                          //String dir = (await getTemporaryDirectory()).path;
                          //File temporal = new File('$dir/img_temp_creada.png');
                          Navigator.popAndPushNamed(
                              context, '/seleccionar_layout');
                        },
                        child: Text(
                          'EDITAR CONTENIDO',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
//aca
                  Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 1.5,
                    child: GestureDetector(
                      onTap: () {
                        AlertaDeshabilitar(index: indexEquipoGrid);
                      },
                      child: Stack(children: [
                        Positioned(
                          child: Container(
                            decoration: new BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                    colors: [
                                      HexColor("#3edb9b"),
                                      HexColor("#0683ff")
                                    ],
                                    stops: [
                                      0.5,
                                      1
                                    ],
                                    begin: Alignment.topLeft,
                                    end: FractionalOffset.bottomRight)),
                            child: IgnorePointer(
                              child: FSwitch(
                                offset: 10,
                                open: valorSwitch,
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
                          child: Text("ON"),
                        ),
                        Positioned(
                          bottom: 13,
                          left: 160,
                          child: Text(
                            "OFF",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ]),
                    ),
                  ),
                ],
              );
            }
          } else {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(HexColor("#FC4C8B")),
            );
          }
        },
      );
    }
    //Si el equipo esta deshabilitado muestra imagen local
    else {
      valorSwitch = true;
      widgetContenido = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Column(
              children: [
                /*Container(
                    margin: EdgeInsets.only(bottom: 5),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    child: _equipoNoActivado),*/

                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        right: 5,
                        left: 5,
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
                              child: _equipoNoActivado,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          right: 7,
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor: HexColor('#FC4C8B'),
                          )),
                      Positioned(
                          top: -10,
                          right: -4,
                          child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              })),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 40),
                  height: MediaQuery.of(context).size.height / 10,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(children: [
                        Row(
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text('NOMBRE'),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('SERIAL'),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('IP'),
                                ]),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text('  : '),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('  : '),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('  : ')
                                ]),
                          ],
                        )
                      ]),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                                    ['f_alias']
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'textoMont',
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                                    ['f_serial']
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'textoMont',
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                                ['f_ip'],
                            style: TextStyle(
                              fontFamily: 'textoMont',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            radius: 10,
                            child: FlatButton(
                              onPressed: () async {
                                _widgetPopUpAlias();
                              },
                              child: Container(
                                transform:
                                    Matrix4.translationValues(-16.0, 0.0, 0.0),
                                child: Icon(
                                  Tvlapiz.lapiz,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Text(""),
                          Text("")
                        ],
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 2.8,
                  child: Visibility(
                    visible: false,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Container(
                      height: 40,
                      width: 200,
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                              colors: [
                                HexColor("#0683ff"),
                                HexColor("#3edb9b")
                              ],
                              stops: [
                                0.1,
                                0.6
                              ],
                              begin: Alignment.topLeft,
                              end: FractionalOffset.bottomRight)),
                      child: FlatButton(
                        color: Colors.transparent,
                        onPressed: () async {
                          //String dir = (await getTemporaryDirectory()).path;
                          //File temporal = new File('$dir/img_temp_creada.png');
                          Navigator.popAndPushNamed(
                              context, '/seleccionar_layout');
                        },
                        child: Text(
                          'EDITAR CONTENIDO',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
//aca
                Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 1.5,
                  child: GestureDetector(
                    onTap: () {
                      AlertaHabilitar(index: indexEquipoGrid);
                    },
                    child: Stack(children: [
                      Positioned(
                        child: Container(
                          decoration: new BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                  colors: [
                                    HexColor("#3edb9b"),
                                    HexColor("#0683ff")
                                  ],
                                  stops: [
                                    0.5,
                                    1
                                  ],
                                  begin: Alignment.topLeft,
                                  end: FractionalOffset.bottomRight)),
                          child: IgnorePointer(
                            child: FSwitch(
                              offset: 10,
                              open: valorSwitch,
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
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 13,
                        left: 160,
                        child: Text("OFF"),
                      )
                    ]),
                  ),
                ),
              ],
            ),
          ),
          /*Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 4.0,
            child: RaisedButton(
              onPressed: () async {
                String dir =
                    (await getTemporaryDirectory()).path;
                File temporal =
                new File('$dir/img_temp_creada.png');
                Navigator.pushNamed(
                    context, '/seleccionar_layout');
              },
              child: Text('Modificar Layout'),
            ),
          ),*/
        ],
      );
    }

    return WillPopScope(
      //Cierra todas las ventanas anteriores existentes y llega a
      // la ruta entregada
      onWillPop: () {
        //Navigator.popUntil(context, ModalRoute.withName('/raspberries_conectadas'));
        Navigator.of(context).popAndPushNamed("/raspberries_conectadas");
        return;
      },
      child: Scaffold(
        key: _scaffoldKey,
        //Appbar viene de archivo custom_widgets.dart
        appBar: CustomAppBar(),
        body: LiquidPullToRefresh(
          springAnimationDurationInMilliseconds: 450,
          onRefresh: () => _recargarGrid(),
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(
                    ObtieneDatos.listadoEquipos[indexEquipoGrid]['f_alias']
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 16.5,
                    ),
                  ),
                ),
              ),
              Container(
                margin:
                    EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
                child: Center(
                  child: widgetContenido,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _vncRaspberryWeb() async {
    String url = 'http://${DatosEstaticos.ipSeleccionada}:6080/vnc.html';
    if (await canLaunch(url)) {
      await launch(
        url,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future _getScreenShot() async {
    //Utilizar el memoizer hace que la función de Future solo ocurra una vez
    String host = DatosEstaticos.listadoDatosEquipoSeleccionado[0]['f_ip'];
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
          _screenshotProcesada = Image.memory(
            _respuesta,
            fit: BoxFit.fill,
          );
        }
        //print(listadoRespuestas.length);
      });
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  _widgetPopUpAlias() async {
    await showDialog<String>(
      context: context,
      child: AnimacionPadding(
        child: new AlertDialog(
          contentPadding:
              const EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
          backgroundColor: Colors.grey.withOpacity(0.0),
          content: Form(
            key: _keyValidador,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: HexColor('#f4f4f4')),
              height: 140,
              width: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 38.0),
                        child: Text("CAMBIAR NOMBRE",
                            style: TextStyle(fontSize: 13)),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 10,
                              child: FlatButton(
                                onPressed: () async {
                                  if (_keyValidador.currentState.validate()) {
                                    PopUps.popUpCargando(
                                        context, 'ACTUALIZANDO ALIAS');
                                    ObtieneDatos datos = ObtieneDatos();
                                    String serial = DatosEstaticos
                                            .listadoDatosEquipoSeleccionado[0]
                                        ['f_serial'];
                                    await datos.updateAliasEquipo(serial,
                                        _controladorTexto.text.toString());
                                    //print(resultado);
                                    await datos.getDatosEquipos();
                                    //Cierra popup cargando
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();

                                    //Cierra popup de cambiar Alias
                                    //Realiza el cambio en la ventana raiz
                                    setState(() {});
                                    await Future.delayed(
                                        Duration(milliseconds: 400));
                                    SnackBar snackbar = SnackBar(
                                        content: Text(
                                          'ALIAS CAMBIADO EXITOSAMENTE',
                                          textAlign: TextAlign.center,
                                        ),
                                        duration: Duration(seconds: 1));
                                    _scaffoldKey.currentState
                                        .showSnackBar(snackbar);
                                  }
                                },
                                child: Container(
                                  transform: Matrix4.translationValues(
                                      -16.0, 0.0, 0.0),
                                  child: Icon(
                                    Tvlapiz.lapiz,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextFormField(
                                controller: _controladorTexto,
                                validator: (textoEscrito) {
                                  if (textoEscrito.isEmpty) {
                                    return "Error: Alias vacío";
                                  }
                                  if (textoEscrito.trim().length <= 0) {
                                    return "Error: Alias vacío";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      /* RaisedButton(
                      child: Text('Cambiar Nombre'),
                      onPressed: () async {
                        if (_keyValidador.currentState.validate()) {
                          PopUps.popUpCargando(context, 'Actualizando alias...');
                          ObtieneDatos datos = ObtieneDatos();
                          String serial = DatosEstaticos
                              .listadoDatosEquipoSeleccionado[0]['f_serial'];
                          await datos.updateAliasEquipo(
                              serial, _controladorTexto.text.toString());
                          //print(resultado);
                          await datos.getDatosEquipos();
                          //Cierra popup cargando
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();

                          //Cierra popup de cambiar Alias
                          //Realiza el cambio en la ventana raiz
                          setState(() {});
                          await Future.delayed(Duration(milliseconds: 400));
                          SnackBar snackbar = SnackBar(
                              content: Text(
                                'Alias cambiado exitosamente',
                                textAlign: TextAlign.center,
                              ),
                              duration: Duration(seconds: 1));
                          _scaffoldKey.currentState.showSnackBar(snackbar);
                        }
                      },
                    ),*/
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
/*

  void _widgetPopUpAlias2(BuildContext context) async{
    GlobalKey<FormState> _keyValidador = GlobalKey<FormState>();
    Widget _widgetCompleto = 
    SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _keyValidador,
            child: Container(
              child: new Column(
                children: [
                  TextFormField(
                    controller: _controladorTexto,
                    validator: (textoEscrito){
                      if(textoEscrito.isEmpty){
                        return "Error: Alias vacío";
                      }
                      if(textoEscrito.trim().length<= 0){
                        return "Error: Alias vacío";
                      }
                      else {return null;}
                    },
                  ),
                  RaisedButton(
                    child: Text('Cambiar Alias'),
                    onPressed: () async{
                      if (_keyValidador.currentState.validate()){
                        PopUps.popUpCargando(context, 'Actualizando alias...');
                        ObtieneDatos datos = ObtieneDatos();
                        String serial = DatosEstaticos.
                        listadoDatosEquipoSeleccionado[0]['f_serial'];
                        await datos.updateAliasEquipo(serial,
                            _controladorTexto.text.toString());
                        //print(resultado);
                        await datos.getDatosEquipos();
                        //Cierra popup cargando
                        Navigator.of(context, rootNavigator: true).pop();
                        //Cierra popup de cambiar Alias
                        Navigator.of(context, rootNavigator: true).pop();
                        //Realiza el cambio en la ventana raiz
                        setState(() {});
                        await Future.delayed(Duration(milliseconds: 500));
                        SnackBar snackbar = SnackBar(content: Text('Alias '
                            'cambiado exitosamente'),);
                        _scaffoldKey.currentState.showSnackBar(snackbar);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    PopUps.PopUpConWidget(context, _widgetCompleto);
  }
*/

  Future<void> _recargarGrid() async {
    //await eventosPropios.ObtenerSizePixelesPantalla();
    setState(() {});
  }

  void AlertaDeshabilitar({
    int index = 0,
  }) async {
    String ip = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
    String serial = ObtieneDatos.listadoEquipos[index]['f_serial'].toString();
    String alias = ObtieneDatos.listadoEquipos[index]['f_alias'].toString();
    ObtieneDatos actualizarEstado = ObtieneDatos();

    Widget contenido;

    contenido = new AlertDialog(
      contentPadding: EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
      backgroundColor: Colors.grey.withOpacity(0.0),
      content: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: HexColor('#f4f4f4')),
        height: 150,
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Column(
                children: [
                  Text(
                    'DESHABILITAR EQUIPO',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    '${alias}'.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            /*
            Text(
              'Serial: ${serial}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Ip: ${ip}',
              textAlign: TextAlign.center,
            ),*/
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 3, child: SizedBox()),
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      child: Icon(
                        Icons.check_circle,
                        color: HexColor('#3EDB9B'),
                        size: 35,
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        PopUps.popUpCargando(context, 'DESHABILITANDO EQUIPO');
                        var resultado = await actualizarEstado
                            .updateEstadoEquipo(serial: serial, estado: "0");
                        await actualizarEstado.getDatosEquipos();
                        if (resultado == 1) {
                          setState(() {
                            Navigator.pop(context);
                            //valorSwitchUno = true;
                            Widget contenidoPopUp = Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: HexColor('#f4f4f4')),
                              height: 150,
                              width: 250,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text('EQUIPO DESHABILITADO ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 13)),
                                      Text('$alias'.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  GestureDetector(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: HexColor('#3EDB9B'),
                                      size: 35,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                            PopUps.PopUpConWidget(context, contenidoPopUp);
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      child: Icon(
                        Icons.cancel,
                        color: HexColor('#FC4C8B'),
                        size: 35,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        /*setState(() {
                          Navigator.pop(context);
                          valorSwitchUno = valorSwitch;
                        });*/
                      },
                    ),
                  ),
                  Expanded(flex: 3, child: SizedBox()),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      child: contenido,
    );
  }

  void AlertaHabilitar({
    int index = 0,
  }) async {
    String ip = ObtieneDatos.listadoEquipos[index]['f_ip'].toString();
    String serial = ObtieneDatos.listadoEquipos[index]['f_serial'].toString();
    String alias = ObtieneDatos.listadoEquipos[index]['f_alias'].toString();
    ObtieneDatos actualizarEstado = ObtieneDatos();

    Widget contenido;

    contenido = new AlertDialog(
      contentPadding: EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
      backgroundColor: Colors.grey.withOpacity(0.0),
      content: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: HexColor('#f4f4f4')),
        height: 150,
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'Habilitar Equipo'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  '${alias}'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            /* Text(
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
            ),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    child: Icon(
                      Icons.check_circle,
                      color: HexColor('#3EDB9B'),
                      size: 35,
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      PopUps.popUpCargando(
                          context, 'Habilitando equipo'.toUpperCase());
                      var resultado = await actualizarEstado.updateEstadoEquipo(
                          serial: serial, estado: "1");
                      await actualizarEstado.getDatosEquipos();
                      if (resultado == 1) {
                        setState(() {
                          Navigator.pop(context);
                          //valorSwitchUno = false;
                          Widget contenidoPopUp = Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: HexColor('#f4f4f4')),
                              height: 150,
                              width: 250,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text('EQUIPO HABILITADO ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 13)),
                                      Text('$alias'.toUpperCase(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  GestureDetector(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: HexColor('#3EDB9B'),
                                      size: 35,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ));
                          PopUps.PopUpConWidget(context, contenidoPopUp);
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    child: Icon(
                      Icons.cancel,
                      color: HexColor('#FC4C8B'),
                      size: 35,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      /*setState(() {
                        Navigator.pop(context);
                        valorSwitchUno = valorSwitch;
                      });*/
                    },
                  ),
                ),
                Expanded(flex: 3, child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );

    await showDialog<String>(
      context: context,
      barrierDismissible: true,
      child: contenido,
    );
  }
}
