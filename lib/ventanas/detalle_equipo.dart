import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/ventanas/raspberries_conectadas.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fswitch/fswitch.dart';

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
    'imagenes/layoutdeshabilitado1.png',
  );
  GlobalKey<FormState> _keyValidador = GlobalKey<FormState>();
  TextEditingController _controladorTexto = TextEditingController(text: "");
  //Guarda el estado del context para usarlo con el snackbar
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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

    String equipoActivo = ObtieneDatos.listadoEquipos[indexEquipoGrid]
            ['f_equipoActivo']
        .toString();

    Widget widgetContenido;
    if (equipoActivo == '1') {
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

              //Acá obtengo las dimensiones base exactas de la pantalla
              ObtenerSizePixelesPantalla();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                            margin: EdgeInsets.only(bottom: 5),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 3,
                            child: _screenshotProcesada),
                        /* Row(
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
                        ),*/
                        Container(
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
                                        ['f_alias'],
                                    style: TextStyle(
                                      fontFamily: 'textoMont',
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Text(
                                    DatosEstaticos
                                            .listadoDatosEquipoSeleccionado[0]
                                        ['f_serial'],
                                    style: TextStyle(
                                      fontFamily: 'textoMont',
                                      fontSize: 13.5,
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
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      radius: 8,
                                      child: IconButton(
                                        onPressed: () async {
                                          _widgetPopUpAlias();
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          size: 10,
                                        ),
                                      )),
                                  Text(""),
                                  Text("")
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 3.0,
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
                          String dir = (await getTemporaryDirectory()).path;
                          File temporal = new File('$dir/img_temp_creada.png');
                          Navigator.pushNamed(context, '/seleccionar_layout');
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
                        left: 11,
                        child: Text("ON"),
                      ),
                      Positioned(
                        bottom: 13,
                        left: 168,
                        child: Text("OFF"),
                      )
                    ]),
                  ),
                ],
              );
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    } else {
      widgetContenido = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: 5),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    child: _equipoNoActivado),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.white,
                      heroTag: null,
                      child: Icon(Icons.refresh, color: Colors.red),
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.white,
                      heroTag: null,
                      child: Icon(
                        Icons.screen_search_desktop,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        //_vncRaspberryWeb();
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Alias: '),
                    Text(DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                        ['f_alias']),
                    IconButton(
                      onPressed: () async {
                        _widgetPopUpAlias();
                      },
                      icon: Icon(Icons.edit),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Ip: '),
                    Text(DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                        ['f_ip']),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Serial: '),
                    Text(DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                        ['f_serial']),
                  ],
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => RaspberriesConectadas()),
          ModalRoute.withName('/'),
        );
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
                margin: EdgeInsets.only(top: 30),
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(
                    "CAJA 1",
                    style: TextStyle(fontSize: 16.5),
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
          _screenshotProcesada = Image.memory(_respuesta);
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
          contentPadding: const EdgeInsets.all(16.0),
          content: Form(
            key: _keyValidador,
            child: Container(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
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
                  RaisedButton(
                    child: Text('Cambiar Alias'),
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
    setState(() {});
  }

  void ObtenerSizePixelesPantalla() async {
    String resp;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];
    try {
      Socket socket;
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada,
              DatosEstaticos.puertoSocketRaspberry)
          .timeout(Duration(seconds: 5));
      socket.write('TVPOSTGETSIZEPANTALLA');
      socket.listen((event) {
        listadoRespuestas.addAll(event.toList());
      }).onDone(() {
        _respuesta = Uint8List.fromList(listadoRespuestas);
        socket.close();
        return;
      });

      await socket.done.whenComplete(() => resp = utf8.decode(_respuesta));
      //Se manipula la respuesta de datos
      Map<String, dynamic> datosRecibidos = json.decode(resp);
      DatosEstaticos.ancho_pantalla_seleccionada =
          int.parse(datosRecibidos['anchoPantalla'].toString());
      DatosEstaticos.alto_pantalla_seleccionada =
          int.parse(datosRecibidos['altoPantalla'].toString());
    } catch (e) {}
  }
}
