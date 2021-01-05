import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';
//import 'package:tvpost_flutter/ventanas/crear_layout3.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tvpost_flutter/utilidades/comunicacion_raspberry.dart';
import 'package:flutter_social_content_share/flutter_social_content_share.dart';

class PopUps {
  //Se crea popup de cargando
  static popUpCargando(BuildContext context, String texto) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 20), child: Text(texto)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
/*
  static _reloj_estado(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("¿DESEA ACTIVAR RELOJ?"),
          content: Row(
            children: <Widget>[
              GestureDetector(
                child: Icon(Icons.check_circle),
                onTap: () {
                  // _layout3_reloj(context);
                },
              ),
              GestureDetector(
                child: Icon(
                  Icons.cancel,
                ),
                onTap: () {
                  //_layout3_solito(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

 */

  //Crear un popup con cualquier widget de contenido
  static SeleccionarReloj(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("¿DESEA ACTIVAR RELOJ?"),
          content: Row(
            children: <Widget>[
              GestureDetector(
                child: Icon(Icons.check_box_outline_blank_rounded),
                onTap: () {
                  // _layout3_reloj(context);
                },
              ),
              GestureDetector(
                child: Icon(
                  Icons.cancel,
                ),
                onTap: () {
                  //_layout3_solito(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Crear un popup con cualquier widget de contenido
  static PopUpConWidget(BuildContext context, Widget contenidoPopUp) {
    AlertDialog alert = AlertDialog(
      content: contenidoPopUp,
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //Crear un popup con cualquier widget de contenido
  static PopUpConWidgetYEventos(
      BuildContext context, StatefulBuilder contenidoPopUp) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return contenidoPopUp;
      },
    );
  }

  static Future<bool> enviarImagen(String nombre, File imagen) async {
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
}

class MenuAppBar {
  static String administrarImagenes = "Imagenes";
  static String administrarVideos = "Videos";

  static List<String> itemsMenu = <String>[
    administrarImagenes,
    administrarVideos,
  ];

  static Validacion({
    List<int> listadoEquipos,
    BuildContext context,
    String rutaVentana,
    String rutaProveniente}){
    //print(ModalRoute.of(context).settings.name);
    if (listadoEquipos.length>0){
      if(DatosEstaticos.ipSeleccionada != null){
        //Navigator.pop(context);
        Navigator.popAndPushNamed(context, rutaVentana, arguments: {
          'division_layout': DatosEstaticos.divisionLayout,
          'ruta_proveniente': rutaProveniente,
        });
        //Muestro listado de equipos a elegir
      } else {
        double altura = 30.0  + (30 * listadoEquipos.length);
        if (altura >= MediaQuery.of(context).size.height){
          altura = MediaQuery.of(context).size.height;

        }
        List<Widget> listadoHabilitados = [];
        listadoEquipos.forEach((element) {
          //print(element);
          Container item = Container(
            margin: EdgeInsets.only(left: 10),
              child:ListTile(
                contentPadding: EdgeInsets.all(0),
                leading: Icon(Icons.screen_share),
                title: Text(ObtieneDatos.listadoEquipos
                [element]['f_alias'].toString().toUpperCase()
                ),
                onTap: () {
                  DatosEstaticos.ipSeleccionada = ObtieneDatos.listadoEquipos
                  [element]['f_ip'].toString();
                  Navigator.pop(context);
                  //Navigator.pop(context);
                  Navigator.popAndPushNamed(context, rutaVentana, arguments: {
                    'division_layout': '0',
                    'ruta_proveniente': rutaProveniente,
                  });
                },
              ),
          );
          listadoHabilitados.add(item);
        });
        PopUps.PopUpConWidget(
          context,
          Container(
            width: MediaQuery.of(context).size.width/2,
            height: altura,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 20,
                  child: Text(
                    'Equipos conectados', textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: altura - 20,
                  child: ListView(
                    children: listadoHabilitados,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }else {
      PopUps.PopUpConWidget(
          context,
          Text('Usted no posee equipos conectados')
      );
    }

  }

  static void SeleccionMenu(String itemSeleccionado, BuildContext context) {
    //Listado de equipos que tienen conexión
    if(itemSeleccionado == MenuAppBar.administrarImagenes){

      String rutaProveniente= ModalRoute.of(context).settings.name;
      if (rutaProveniente == "/seleccionar_imagen"){
        return;
      }

      Validacion(
          listadoEquipos: DatosEstaticos.listadoIndexEquiposConectados,
          context: context,
          rutaVentana: "/seleccionar_imagen",
          rutaProveniente: ModalRoute.of(context).settings.name);

    }
    if(itemSeleccionado == MenuAppBar.administrarVideos){
      PopUps.PopUpConWidget(context, Text('En construcción...'));
    }
  }

  static PopupMenuButton botonMenu(BuildContext context){
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.menu,
        color: Colors.white,
      ),
      itemBuilder: (context){
        return MenuAppBar.itemsMenu.map((e){
          if (e == MenuAppBar.administrarImagenes){
            return PopupMenuItem(
              value: e,
              child: Row(
                children: [
                  Icon(Icons.image),
                  Text(e),
                ],
              ),
            );
          }
          if (e == MenuAppBar.administrarVideos){
            return PopupMenuItem(
              value: e,
              child: Row(
                children: [
                  Icon(Icons.video_library_outlined),
                  Text(e),
                ],
              ),
            );
          }

        }).toList();
      },
      onSelected: (selected){
        MenuAppBar.SeleccionMenu(selected, context);
      },
    );
  }
}



class CustomAppBarSinFlechaBack extends PreferredSize {
  final double height;

  CustomAppBarSinFlechaBack({
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppBar(

        leading: Container(
          color: Colors.transparent,
        ),
        flexibleSpace: Container(
          decoration: new BoxDecoration(
              gradient: LinearGradient(
                  colors: [HexColor("#0683ff"), HexColor("#3edb9b")],
                  stops: [0.1, 0.6],
                  begin: Alignment.centerLeft,
                  end: FractionalOffset.centerRight)),
          child: Padding(
            padding:
            EdgeInsets.only(left: MediaQuery.of(context).size.width / 5.5),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      child: Image.asset(
                        'imagenes/logohorizontal.png',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: MenuAppBar.botonMenu(context),
                    /*
                    child: IconButton(
                      iconSize: 40,
                      padding: const EdgeInsets.only(right: 20),
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        PopUps.PopUpConWidget(
                            context,
                            Text(
                              'Menú en creación',
                              textAlign: TextAlign.center,
                            ));
                      },
                    ),

                     */
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends PreferredSize {
  final double height;

  CustomAppBar({
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
              gradient: LinearGradient(
                  colors: [HexColor("#0683ff"), HexColor("#3edb9b")],
                  stops: [0.1, 0.6],
                  begin: Alignment.centerLeft,
                  end: FractionalOffset.centerRight)),
          child: Padding(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 5.5),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.all(12.0),
                      child: Image.asset(
                        'imagenes/logohorizontal.png',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: MenuAppBar.botonMenu(context),
                    /*
                    child: IconButton(
                      iconSize: 40,
                      padding: const EdgeInsets.only(right: 20),
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        PopUps.PopUpConWidget(
                            context,
                            Text(
                              'Menú en creación',
                              textAlign: TextAlign.center,
                            ));
                      },
                    ),

                     */
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class OpcionesSeleccionMedia extends StatefulWidget {
  OpcionesSeleccionMedia({
    //@required this.keywebview,
    @required this.visible,
    @required this.divisionLayout,
    //Se requiere la función que hará que algo pase en la ventan anterior
    @required this.actualizaEstado,
  });
  //Key keywebview;
  final bool visible;
  final String divisionLayout;
  //Función que devuelve algo a la ventana anterior
  final VoidCallback actualizaEstado;

  @override
  _OpcionesSeleccionMediaState createState() => _OpcionesSeleccionMediaState();
}

class _OpcionesSeleccionMediaState extends State<OpcionesSeleccionMedia> {
  TextEditingController controladorTextoUrl = TextEditingController();
  WebViewController webViewController;

  @override
  void dispose() {
    controladorTextoUrl.dispose();
    webViewController = null;
    DatosEstaticos.webViewControllerWidget1 = null;
    DatosEstaticos.webViewControllerWidget2 = null;
    DatosEstaticos.webViewControllerWidget3 = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Text("¿QUÉ QUIERES PUBLICAR?"),
          SizedBox(
            height: 15,
          ),
          Container(
            width: 176.1,
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                    colors: [HexColor("#3edb9b"), HexColor("#0683ff")],
                    stops: [0.4, 1],
                    begin: Alignment.centerLeft,
                    end: FractionalOffset.centerRight)),
            margin: EdgeInsets.symmetric(
              horizontal: 92,
            ),
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlatButton(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () {
                        //Va a la otra ventana esperando respuesta
                        navegarYEsperarRespuesta('/seleccionar_imagen');
                      },
                      child: Text(
                        'IMAGEN',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    FlatButton(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () {
                        //Va a la otra ventana esperando respuesta
                        navegarYEsperarRespuesta('/seleccionar_video');
                      },
                      child:
                          Text('VIDEO', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlatButton(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () {
                        //Aparece popup de ingresar link
                        contenidoPopUpSeleccionUrl();
                        /*PopUps.PopUpConWidget(w
                          context, contenidoPopUpSeleccionUrl());*/
                      },
                      child: Text('URL', style: TextStyle(color: Colors.white)),
                    ),
                    FlatButton(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      onPressed: () {
                        //Va a la otra ventana esperando respuesta
                        navegarYEsperarRespuesta('/crear_contenido');
                      },
                      child:
                          Text('CREAR', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  contenidoPopUpSeleccionUrl() async {
    GlobalKey<FormState> _keyValidador = GlobalKey<FormState>();
    await showDialog<String>(
      context: context,
      child: StatefulBuilder(builder: (context, setState) {
        return AnimacionPadding(
          child: new AlertDialog(
            content: SingleChildScrollView(
              child: Card(
                child: Form(
                  key: _keyValidador,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: controladorTextoUrl,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              _abrirBuscador();
                            },
                          ),
                        ),
                        validator: (urlEscrita) {
                          if (urlEscrita.isEmpty) {
                            return 'Ingrese un enlace web';
                          }
                          if (urlEscrita.trim().length <= 0) {
                            return 'Ingrese un enlace web';
                          }
                          return null;
                        },
                      ),
                      RaisedButton(
                        child: Text('Ingresar enlace'),
                        onPressed: () {
                          if (_keyValidador.currentState.validate()) {
                            //Crea webvbiew
                            crearWebView(
                                controladorTextoUrl.text.toString().trim());
                            //Cierra popup cargando
                            Navigator.of(context, rootNavigator: true).pop();

                            widget.actualizaEstado();
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
      }),
    );
  }

  Widget crearWebView(String url) {
    if (!url.contains('https://') && !url.contains('http://')) {
      url = 'https://$url';
    }
    Widget _webview;
    _webview = WebView(
      initialUrl: url,
      //Para que no carguen los videos automáticamente
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController controlador) {
        webViewController = controlador;
        if (widget.divisionLayout.contains('-1')) {
          DatosEstaticos.webViewControllerWidget1 = webViewController;
          //DatosEstaticos.webViewControllerWidget2 = null;
          //DatosEstaticos.webViewControllerWidget3 = null;
        }
        if (widget.divisionLayout.contains('-2')) {
          //DatosEstaticos.webViewControllerWidget1 = null;
          DatosEstaticos.webViewControllerWidget2 = webViewController;
          //DatosEstaticos.webViewControllerWidget3 = null;
        }
        if (widget.divisionLayout.contains('-3')) {
          //DatosEstaticos.webViewControllerWidget1 = null;
          //DatosEstaticos.webViewControllerWidget2 = null;
          DatosEstaticos.webViewControllerWidget3 = webViewController;
        }
      },
    );

    switch (widget.divisionLayout) {
      case '1-1':
        DatosEstaticos.widget1 = _webview;
        DatosEstaticos.nombreArchivoWidget1 = url;
        DatosEstaticos.reemplazarPorcion1 = true;
        break;
      case '2-1':
        DatosEstaticos.widget1 = _webview;
        DatosEstaticos.nombreArchivoWidget1 = url;
        DatosEstaticos.reemplazarPorcion1 = true;
        break;
      case '2-2':
        DatosEstaticos.widget2 = _webview;
        DatosEstaticos.nombreArchivoWidget2 = url;
        DatosEstaticos.reemplazarPorcion2 = true;
        break;
      case '3-1':
        DatosEstaticos.widget1 = _webview;
        DatosEstaticos.nombreArchivoWidget1 = url;
        DatosEstaticos.reemplazarPorcion1 = true;
        break;
      case '3-2':
        DatosEstaticos.widget2 = _webview;
        DatosEstaticos.nombreArchivoWidget2 = url;
        DatosEstaticos.reemplazarPorcion2 = true;
        break;
      case '3-3':
        DatosEstaticos.widget3 = _webview;
        DatosEstaticos.nombreArchivoWidget3 = url;
        DatosEstaticos.reemplazarPorcion3 = true;
        break;
    }

    return _webview;
  }

  _abrirBuscador() async {
    const url = 'https://www.google.cl';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se puede abrir el enlace: $url';
    }
  }

  navegarYEsperarRespuesta(String rutaVentana) async {
    final result = await Navigator.pushNamed(context, rutaVentana, arguments: {
      'division_layout': widget.divisionLayout,
    });
    if (result != null) {
      //Si se selecciona la imagen, esto le dice a la ventana anterior que se
      //Ejecutó. La ventana anterior, ejecuta un setstate
      widget.actualizaEstado();
    }
  }
}

class BotonEnviarAEquipo extends StatelessWidget {
  BotonEnviarAEquipo({
    @required this.visible,
    this.mensaje_boton,
    this.publicar_porcion,
    this.publicar_rrss,
  });
  bool visible = false;
  int publicar_porcion = 0;
  bool publicar_rrss = false;
  String mensaje_boton;

  @override
  Widget build(BuildContext context) {
    if (this.mensaje_boton == null) {
      mensaje_boton = "PROYECTAR EN TV";
    }

    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 2.8,
      child: Visibility(
        visible: this.visible,
        child: Container(
          height: 40,
          width: 200,
          decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                  colors: [HexColor("#3edb9b"), HexColor("#0683ff")],
                  stops: [0.4, 1],
                  begin: Alignment.topLeft,
                  end: FractionalOffset.bottomRight)),
          child: FlatButton(
            color: Colors.transparent,
            onPressed: () async {
              if (DatosEstaticos.nombreArchivoWidget1 != "" ||
                  DatosEstaticos.nombreArchivoWidget2 != "" ||
                  DatosEstaticos.nombreArchivoWidget3 != "") {
                //Envio instruccion a raspberry. Esto debería tener un await para la respuesta
                PopUps.PopUpConWidget(context, EsperarRespuestaProyeccion());
              } else {
                PopUps.PopUpConWidget(
                    context, Text('Error: Contenido no seleccionado'));
              }
            },
            child: Text(mensaje_boton, style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  //Prepara datos para enviar a raspberry.
  //Comprueba datos con base de datos para archivos de media
  String PreparaDatosMediaEnvioEquipo() {
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

    String _porcionACambiar = _definirPorcionACambiar();

    _Instruccion =
        "TVPOSTMODLAYOUT $tipoLayoutAEnviar $_porcionACambiar $_Instruccion";
    return _Instruccion;
  }

  Widget EsperarRespuestaProyeccion() {
    String InstruccionEnviar = PreparaDatosMediaEnvioEquipo();

    return FutureBuilder(
      future: ComunicacionRaspberry.ConfigurarLayout(InstruccionEnviar),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null) {
            //Actualiza datos en bd
            ObtieneDatos obtencionDatos = ObtieneDatos();
            obtencionDatos.updateDatosMediaEquipo(
              serial: DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                  ['f_serial'],
              f_layoutActual: DatosEstaticos.layoutSeleccionado.toString(),
              F_TipoArchivoPorcion1:
                  DatosEstaticos.widget1.runtimeType.toString(),
              F_TipoArchivoPorcion2:
                  DatosEstaticos.widget2.runtimeType.toString(),
              F_TipoArchivoPorcion3:
                  DatosEstaticos.widget3.runtimeType.toString(),
              F_ArchivoPorcion1: DatosEstaticos.nombreArchivoWidget1,
              F_ArchivoPorcion2: DatosEstaticos.nombreArchivoWidget2,
              F_ArchivoPorcion3: DatosEstaticos.nombreArchivoWidget3,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ok, vea sus pantallas'),
                RaisedButton(
                  child: Text('Aceptar'),
                  onPressed: () async {
                    //Acá se publica
                    if (this.publicar_rrss) {
                      String resultado = await PublicarEnRedesSociales();
                      if (resultado != 'Success') {
                        Widget contenidoPopUp = Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Error de publicación',
                              textAlign: TextAlign.center,
                              textScaleFactor: 1.3,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Instale, otorgue permisos y configure '
                              'Instagram para realizar una publicación',
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
                                VolverADetalleEquipo(context);
                              },
                            ),
                          ],
                        );
                        PopUps.PopUpConWidget(context, contenidoPopUp);
                      } else {
                        VolverADetalleEquipo(context);
                      }
                    } else {
                      VolverADetalleEquipo(context);
                    }
                  },
                ),
              ],
            );
          }
          return Row(
            children: [
              CircularProgressIndicator(),
              Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Text('Preparando pantallas...')),
            ],
          );
        }
        return Row(
          children: [
            CircularProgressIndicator(),
            Container(
                margin: EdgeInsets.only(left: 20),
                child: Text('Preparando pantallas...')),
          ],
        );
      },
    );
  }

  String _definirPorcionACambiar() {
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

  Future<String> PublicarEnRedesSociales() async {
    String nombreNuevaImagen;
    String resultado = "";
    switch (this.publicar_porcion) {
      case 1:
        RegExp expresion = new RegExp('ImagenesPostTv\/(.+)');
        var match = expresion.firstMatch(DatosEstaticos.nombreArchivoWidget1);
        nombreNuevaImagen = match.group(1);
        /*Uint8List byteImage = await networkImageToByte(
            "http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/$nombreNuevaImagen");
        Share.file("Publicación TvPost Izquierda", "TvPost_Izquierda.png",
            byteImage, "image/png");*/
        resultado = await FlutterSocialContentShare.share(
            type: ShareType.instagramWithImageUrl,
            imageUrl:
                "http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/$nombreNuevaImagen");
        break;
      case 2:
        RegExp expresion = new RegExp('ImagenesPostTv\/(.+)');
        var match = expresion.firstMatch(DatosEstaticos.nombreArchivoWidget2);
        nombreNuevaImagen = match.group(1);
        /*Uint8List byteImage = await networkImageToByte(
            "http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/$nombreNuevaImagen");
        Share.file("Publicación TvPost Derecha", "TvPost_Derecha.png",
            byteImage, "image/png");*/
        resultado = await FlutterSocialContentShare.share(
            type: ShareType.instagramWithImageUrl,
            imageUrl:
                "http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/$nombreNuevaImagen");
        break;
    }
    return resultado;
  }

  void VolverADetalleEquipo(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushNamedAndRemoveUntil(
        context, '/detalle_equipo', ModalRoute.withName('/seleccionar_layout'),
        arguments: {
          "indexEquipoGrid": DatosEstaticos.indexSeleccionado,
        });
  }
}

class WebViewPropio extends StatefulWidget {
  var urlPropia;
  WebViewPropio({this.urlPropia});
  @override
  _WebViewPropioState createState() => _WebViewPropioState();
}

class _WebViewPropioState extends State<WebViewPropio> {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: widget.urlPropia,
      javascriptMode: JavascriptMode.disabled,
    );
  }
}

//Transforma color hex a int
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class AnimacionPadding extends StatelessWidget {
  final Widget child;

  AnimacionPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.padding,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
