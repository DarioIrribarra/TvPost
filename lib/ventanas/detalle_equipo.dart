import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleEquipo extends StatefulWidget {
  @override
  _DetalleEquipoState createState() => _DetalleEquipoState();
}


class _DetalleEquipoState extends State<DetalleEquipo> {

  Map datosDesdeVentanaAnterior = {};
  int indexEquipoGrid = 0;
  Image _screenshotProcesada = Image.asset('imagenes/logohorizontal.png');
  GlobalKey<FormState> _keyValidador = GlobalKey<FormState>();
  TextEditingController _controladorTexto = TextEditingController(text: "");
  //Guarda el estado del context para usarlo con el snackbar
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //Utilizar el memoizer hace que la función de Future (getScreenShot())
  // solo ocurra una vez. De lo contrario se llama con cada acción del build
  //final AsyncMemoizer _memoizer = AsyncMemoizer();

  @override
  void dispose() {
    // TODO: implement dispose
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
    String serialSeleccionada = ObtieneDatos.listadoEquipos
    [indexEquipoGrid]['f_serial'].toString();

    //Se pasan todos los datos del equipo seleccionado a su propio listado
    DatosEstaticos.listadoDatosEquipoSeleccionado =
        ObtieneDatos.listadoEquipos.where((equipo) =>
        equipo['f_serial'] == serialSeleccionada).toList();

    DatosEstaticos.ipSeleccionada = DatosEstaticos.
    listadoDatosEquipoSeleccionado[0]['f_ip'];

    return WillPopScope(
      //Cierra todas las ventanas anteriores existentes y llega a
      // la ruta entregada
      onWillPop: (){
        Navigator.popUntil(context, ModalRoute.withName('/raspberries_conectadas'));
        return;
      },
      child: Scaffold(
        key: _scaffoldKey,
        //Appbar viene de archivo custom_widgets.dart
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20.0),
            child:
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      FutureBuilder(
                        future: _getScreenShot(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.data == null) {
                              return Image.asset('imagenes/logohorizontal.png');
                            } else {
                              //Retorna el widget con la imagen de screenshot

                              //Acá obtengo las dimensiones base exactas de la pantalla
                              ObtenerSizePixelesPantalla();

                              return Column(
                                children: [
                                  _getScreenShotProcesada(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FloatingActionButton(
                                        heroTag: null,
                                        child: Icon(Icons.refresh),
                                        onPressed: (){
                                          setState(() {

                                          });
                                        },
                                      ),
                                      FloatingActionButton(
                                        heroTag: null,
                                        child: Icon(Icons.screen_search_desktop),
                                        onPressed: (){
                                          _vncRaspberryWeb();
                                        },
                                      )

                                    ],
                                  ),
                                ],
                              );
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Alias: '),
                          Text(DatosEstaticos.
                          listadoDatosEquipoSeleccionado[0]['f_alias']),
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
                          Text(DatosEstaticos.
                          listadoDatosEquipoSeleccionado[0]['f_ip']),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Serial: '),
                          Text(DatosEstaticos.
                          listadoDatosEquipoSeleccionado[0]['f_serial']),
                        ],
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 4.0,
                    child: RaisedButton(
                      onPressed: () async {
                        Navigator.pushNamed(context, '/seleccionar_layout');
                      },
                      child: Text('Modificar Layout'),
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }

  _vncRaspberryWeb() async{
    String url = 'http://${DatosEstaticos.ipSeleccionada}:6080/vnc.html';
    if (await canLaunch(url)) {
    await launch(url, enableJavaScript: true,);
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
        //_largoEvent = _largoEvent + event.length;
        //print("Largo del event: ${_largoEvent.toString()}");
        //print(listadoRespuestas.length);
      }).onDone(() {
        socket.close();
        return;
      });

      //El retornar esto, hace que el FutureBuilder espere al "done"
      //Si no se retorna el whencomplete, se salta al final
      return socket.done.whenComplete(() {
        _respuesta = Uint8List.fromList(listadoRespuestas);
        _screenshotProcesada = Image.memory(_respuesta);
        //print(listadoRespuestas.length);
      });
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  Widget _getScreenShotProcesada(){
    return _screenshotProcesada;
  }

  _widgetPopUpAlias() async {
    await showDialog<String>(
      context: context,
      child: _SystemPadding(child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Form(
          key: _keyValidador,
          child: Container(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
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
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();

                      //Cierra popup de cambiar Alias
                      //Navigator.of(context, rootNavigator: true).pop();
                      //Realiza el cambio en la ventana raiz
                      setState(() {});
                      await Future.delayed(Duration(milliseconds: 500));
                      SnackBar snackbar = SnackBar(content: Text('Alias '
                          'cambiado exitosamente'), );
                      _scaffoldKey.currentState.showSnackBar(snackbar);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        /*actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('OPEN'),
              onPressed: () {
                Navigator.pop(context);
              })
        ],*/
      ),),
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

  void ObtenerSizePixelesPantalla() async {
    String resp;
    Uint8List _respuesta;
    List<int> listadoRespuestas = [];
    try{
      Socket socket;
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada,
          DatosEstaticos.puertoSocketRaspberry).timeout(Duration(seconds: 5));
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
      Map<String,dynamic> datosRecibidos = json.decode(resp);
      DatosEstaticos.ancho_pantalla_seleccionada = int.parse(datosRecibidos['anchoPantalla'].toString());
      DatosEstaticos.alto_pantalla_seleccionada = int.parse(datosRecibidos['altoPantalla'].toString());

    }catch (e){

    }
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.padding,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
