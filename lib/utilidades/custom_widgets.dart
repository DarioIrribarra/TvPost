import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tvpost_flutter/utilidades/comunicacion_raspberry.dart';

class PopUps{

  //Se crea popup de cargando
  static popUpCargando(BuildContext context, String texto){

    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 20),child:Text(texto)),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  //Crear un popup con cualquier widget de contenido
  static PopUpConWidget(BuildContext context, Widget contenidoPopUp){
    AlertDialog alert=AlertDialog(
      content: contenidoPopUp,
    );
    showDialog(barrierDismissible: true,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }
}

class CustomAppBar extends PreferredSize{
  final double height;

  CustomAppBar({
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(5.0),
              margin: EdgeInsets.only(right: 30.0),
              child: Image.asset('imagenes/logohorizontal.png'),
            ),
            IconButton(
              icon: Icon(
                Icons.menu,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ],
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
      child: Container(
        margin: EdgeInsets.only(left: 115.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed: () {
                    //Va a la otra ventana esperando respuesta
                    navegarYEsperarRespuesta('/seleccionar_imagen');
                  },
                  child: Text('Imagen'),
                ),
                RaisedButton(
                  onPressed: () {
                    //Va a la otra ventana esperando respuesta
                    navegarYEsperarRespuesta('/seleccionar_video');
                  },
                  child: Text('Video'),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed: () {
                    //Aparece popup de ingresar link
                    PopUps.PopUpConWidget(context, contenidoPopUpSeleccionUrl());
                  },
                  child: Text('Url'),
                ),
                RaisedButton(
                  onPressed: () {},
                  child: Text('Crear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget contenidoPopUpSeleccionUrl(){
    GlobalKey<FormState> _keyValidador = GlobalKey<FormState>();
    return Form(
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
                onPressed: (){_abrirBuscador();},
              ),
            ),
            validator: (urlEscrita) {
              if (urlEscrita.isEmpty){
                return 'Ingrese un enlace web';
              }
              if(urlEscrita.trim().length<= 0){
                return 'Ingrese un enlace web';
              }
              return null;
            },
          ),
          RaisedButton(
            child: Text(
                'Ingresar enlace'
            ),
            onPressed: (){
              if (_keyValidador.currentState.validate()){
                //Crea webvbiew
                crearWebView(controladorTextoUrl.text.toString().trim());
                //this._webViewController.reload();
                /*_keyValidador.currentState?.setState(() {

                });*/
                //Cierra popup cargando
                Navigator.of(context, rootNavigator: true).pop();

                widget.actualizaEstado();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget crearWebView(String url){
    if (!url.contains('https://') && !url.contains('http://')){
      url = 'https://$url';
    }
    Widget _webview;
    _webview = WebView(
      initialUrl: url,
      //Para que no carguen los videos automáticamente
      javascriptMode: JavascriptMode.disabled,
      onWebViewCreated: (WebViewController controlador){
        webViewController = controlador;
        if (widget.divisionLayout.contains('-1')){
          DatosEstaticos.webViewControllerWidget1 = webViewController;
          //DatosEstaticos.webViewControllerWidget2 = null;
          //DatosEstaticos.webViewControllerWidget3 = null;
        }
        if (widget.divisionLayout.contains('-2')){
          //DatosEstaticos.webViewControllerWidget1 = null;
          DatosEstaticos.webViewControllerWidget2 = webViewController;
          //DatosEstaticos.webViewControllerWidget3 = null;
        }
        if (widget.divisionLayout.contains('-3')){
          //DatosEstaticos.webViewControllerWidget1 = null;
          //DatosEstaticos.webViewControllerWidget2 = null;
          DatosEstaticos.webViewControllerWidget3 = webViewController;
        }
      },
    );

    switch (widget.divisionLayout){
      case '1-1':
        DatosEstaticos.wiget1 = _webview;
        DatosEstaticos.nombreArchivoWidget1 = url;
        break;
      case '2-1':
        DatosEstaticos.wiget1 = _webview;
        DatosEstaticos.nombreArchivoWidget1 = url;
        break;
      case '2-2':
        DatosEstaticos.wiget2 = _webview;
        DatosEstaticos.nombreArchivoWidget2 = url;
        break;
      case '3-1':
        DatosEstaticos.wiget1 = _webview;
        DatosEstaticos.nombreArchivoWidget1 = url;
        break;
      case '3-2':
        DatosEstaticos.wiget2 = _webview;
        DatosEstaticos.nombreArchivoWidget2 = url;
        break;
      case '3-3':
        DatosEstaticos.wiget3 = _webview;
        DatosEstaticos.nombreArchivoWidget3 = url;
        break;
    }


    return _webview;

  }


  _abrirBuscador() async{
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
  });
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: this.visible,
      child: RaisedButton(
        onPressed: () async{
          if (DatosEstaticos.nombreArchivoWidget1 != ""
              || DatosEstaticos.nombreArchivoWidget2 != ""
              || DatosEstaticos.nombreArchivoWidget3 != ""){

            //Envio instruccion a raspberry. Esto debería tener un await para la respuesta
            PopUps.PopUpConWidget(context, EsperarRespuestaProyeccion());
            //Future.delayed(Duration(seconds: 3));
            //Cierra popup cargando
            //Navigator.of(context, rootNavigator: true).pop();
          } else {
            PopUps.PopUpConWidget(context, Text('Error: Contenido no seleccionado'));
          }
        },
        child: Text('Enviar a pantalla'),
      ),
    );
  }

  //Prepara datos para enviar a raspberry.
  //Comprueba datos con base de datos para archivos de media
  List<String> PreparaDatosMediaEnvioEquipo(bool nuevoLayout){
    String _Instruccion;
    //Comparar datos que están almacenados con nuevos
    List<String> respuesta = [];

    String tipoLayoutAEnviar = "";
    String layoutEnEquipo = DatosEstaticos.layoutSeleccionado.toString();

    //Nombres de widgets hasta el momento
    String tipoWidget1AEnviar = DatosEstaticos.wiget1.runtimeType.toString();
    String tipoWidget2AEnviar = DatosEstaticos.wiget2.runtimeType.toString();
    String tipoWidget3AEnviar = DatosEstaticos.wiget3.runtimeType.toString();
    if (tipoWidget1AEnviar == 'Null'){tipoWidget1AEnviar = "0";}
    if (tipoWidget2AEnviar == 'Null'){tipoWidget2AEnviar = "0";}
    if (tipoWidget3AEnviar == 'Null'){tipoWidget3AEnviar = "0";}

    //nombres de archivos a enviar
    String link1AEnviar = DatosEstaticos.nombreArchivoWidget1;
    String link2AEnviar = DatosEstaticos.nombreArchivoWidget2;
    String link3AEnviar = DatosEstaticos.nombreArchivoWidget3;
    if (link1AEnviar.isEmpty){link1AEnviar = "0";}
    if (link2AEnviar.isEmpty){link2AEnviar = "0";}
    if (link3AEnviar.isEmpty){link3AEnviar = "0";}

    //Si los datos del archivo del equipo no están vacíos se suplantan
    // para hacer comparación

/*

    if (DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado.isNotEmpty && !nuevoLayout){
      layoutEnEquipo = DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['layout'];
      tipoWidget1EnEquipo = DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['tipoArchivo1'];
      tipoWidget2EnEquipo = DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['tipoArchivo2'];
      tipoWidget3EnEquipo = DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['tipoArchivo3'];
      link1EnEquipo = DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['archivo1'];
      link2EnEquipo = DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['archivo2'];
      link3EnEquipo = DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado['archivo3'];

      //Se envia solo el archivo que es distinto para hacer el cambio
      if (DatosEstaticos.nombreArchivoWidget1==link1EnEquipo){
        link1AEnviar = "0";
      }else {
        link1AEnviar = DatosEstaticos.nombreArchivoWidget1??'0';
      }
      if (DatosEstaticos.nombreArchivoWidget2==link2EnEquipo){
        link2AEnviar = "0";
      }else {
        link2AEnviar = DatosEstaticos.nombreArchivoWidget2??'0';
      }
      if (DatosEstaticos.nombreArchivoWidget3==link3EnEquipo){
        link3AEnviar = "0";
      }else {
        link3AEnviar = DatosEstaticos.nombreArchivoWidget3??'0';
      }
    }
*/

    //Tipo de layout
    /*if (DatosEstaticos.layoutSeleccionado.toString() != layoutEnEquipo){
      layoutEnEquipo = DatosEstaticos.layoutSeleccionado.toString();
    }*/

    if (layoutEnEquipo == "1"){
      tipoLayoutAEnviar = "100";
      if (link1AEnviar!="0" && !link1AEnviar.contains('/var/www/html') && !link1AEnviar.contains('http')){
        link1AEnviar = '/var/www/html$link1AEnviar';
      }
      _Instruccion = "$tipoWidget1AEnviar 0 0 $link1AEnviar 0 0";
    }
    if (layoutEnEquipo == "2"){
      tipoLayoutAEnviar = "5050";
      if (link1AEnviar!="0" && !link1AEnviar.contains('/var/www/html') && !link1AEnviar.contains('http')){
        link1AEnviar = '/var/www/html$link1AEnviar';
      }
      if (link2AEnviar!="0" && !link2AEnviar.contains('/var/www/html') && !link2AEnviar.contains('http')){
        link2AEnviar = '/var/www/html$link2AEnviar';
      }
      _Instruccion = "$tipoWidget1AEnviar $tipoWidget2AEnviar "
          "0 $link1AEnviar $link2AEnviar 0";
    }
    if (layoutEnEquipo == "3"){
      tipoLayoutAEnviar = "802010";
      if (link1AEnviar!="0" && !link1AEnviar.contains('/var/www/html') && !link1AEnviar.contains('http')){
        link1AEnviar = '/var/www/html$link1AEnviar';
      }
      if (link2AEnviar!="0" && !link2AEnviar.contains('/var/www/html') && !link2AEnviar.contains('http')){
        link2AEnviar = '/var/www/html$link2AEnviar';
      }
      if (link3AEnviar!="0" && !link3AEnviar.contains('/var/www/html') && !link3AEnviar.contains('http')){
        link3AEnviar = '/var/www/html$link3AEnviar';
      }
      _Instruccion = "$tipoWidget1AEnviar $tipoWidget2AEnviar "
          "$tipoWidget3AEnviar $link1AEnviar $link2AEnviar $link3AEnviar";
    }

    //Si es nuevo se envia el nuevo layout
    if (nuevoLayout){
      _Instruccion = "TVPOSTNEWLAYOUT $tipoLayoutAEnviar $_Instruccion";
    }else{
      String _porcionACambiar = _definirPorcionACambiar();
      _Instruccion = "TVPOSTMODLAYOUT $tipoLayoutAEnviar $_porcionACambiar $_Instruccion";
    }

    respuesta.add(_Instruccion);
    respuesta.add(link1AEnviar);
    respuesta.add(link2AEnviar);
    respuesta.add(link3AEnviar);

    return respuesta;
  }

  Widget EsperarRespuestaProyeccion(){
    int layoutActualEnEquipo = 0;
    if (DatosEstaticos.mapaDatosReproduccionEquipoSeleccionado.isNotEmpty){
      layoutActualEnEquipo = int.parse(DatosEstaticos
          .mapaDatosReproduccionEquipoSeleccionado['layout']);
    }

    String InstruccionEnviar;
    List<String> listaDatosEnvio = [];
    //Si es distinto se llama al CrearLayout, sino, se llama al Modificar Layout
    //Eso se maneja con el valor bool en PrepararDatosMEdiaEnvioEquipo
    if (DatosEstaticos.layoutSeleccionado!=layoutActualEnEquipo){
      listaDatosEnvio = PreparaDatosMediaEnvioEquipo(true);
      InstruccionEnviar = listaDatosEnvio[0];
    }
    else {
      listaDatosEnvio = PreparaDatosMediaEnvioEquipo(false);
      InstruccionEnviar = listaDatosEnvio[0];
    }
    /*listaDatosEnvio = PreparaDatosMediaEnvioEquipo(false);
    InstruccionEnviar = listaDatosEnvio[0];*/

    return FutureBuilder(
      future: ComunicacionRaspberry.ConfigurarLayout(InstruccionEnviar),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.done){
          if (snapshot.data != null){
            //Actualiza datos de bd del equipo si los datos de respuesta
            // no son nulos
            /*actualizarDatosMediaEquipoBD("${DatosEstaticos.layoutSeleccionado}",
                listaDatosEnvio[1], listaDatosEnvio[2], listaDatosEnvio[3]);*/
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(snapshot.data.toString()),
                RaisedButton(
                  child: Text('Aceptar'),
                  onPressed: (){
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.pushNamedAndRemoveUntil(context,
                        '/detalle_equipo',
                        ModalRoute.withName('/seleccionar_layout'),
                        arguments: {"indexEquipoGrid" : DatosEstaticos.indexSeleccionado,});
                  },
                ),
              ],
            );
          }
          return Row(
            children: [
              CircularProgressIndicator(),
              Container(margin: EdgeInsets.only(left: 20),child:Text('Preparando pantallas...')),
            ],);
        }
        return Row(
          children: [
            CircularProgressIndicator(),
            Container(margin: EdgeInsets.only(left: 20),child:Text('Preparando pantallas...')),
          ],);
      },
    );

  }

  String _definirPorcionACambiar(){
    int ls = DatosEstaticos.layoutSeleccionado;

    switch(ls){
      case 1:
        if (DatosEstaticos.reemplazarPorcion1){
          return "1-1";
        }
        break;
      case 2:
        if (DatosEstaticos.reemplazarPorcion1 && DatosEstaticos.reemplazarPorcion2){
          return "2-3";
        }
        if (DatosEstaticos.reemplazarPorcion1){
          return "2-1";
        }
        if (DatosEstaticos.reemplazarPorcion2){
          return "2-2";
        }
        break;
      case 3:
        if (DatosEstaticos.reemplazarPorcion1 && DatosEstaticos.reemplazarPorcion2 && DatosEstaticos.reemplazarPorcion3){
          return "3-4";
        }
        if (DatosEstaticos.reemplazarPorcion1 && DatosEstaticos.reemplazarPorcion2){
          return "3-5";
        }
        if (DatosEstaticos.reemplazarPorcion1 && DatosEstaticos.reemplazarPorcion3){
          return "3-7";
        }
        if (DatosEstaticos.reemplazarPorcion2 && DatosEstaticos.reemplazarPorcion3){
          return "3-6";
        }
        if (DatosEstaticos.reemplazarPorcion1){
          return "3-1";
        }
        if (DatosEstaticos.reemplazarPorcion2){
          return "3-2";
        }
        if (DatosEstaticos.reemplazarPorcion3){
          return "3-3";
        }
        break;
    }
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

/*  actualizarDatosMediaEquipoBD(String layoutSeleccionado,
      String archivoPorcion1, String archivoPorcion2,
      String archivoPorcion3)async{
    String serial = DatosEstaticos.listadoDatosEquipoSeleccionado[0]['f_serial'];
    String F_TipoArchivoPorcion1 = DatosEstaticos.wiget1.runtimeType.toString();
    String F_TipoArchivoPorcion2 = DatosEstaticos.wiget2.runtimeType.toString();
    String F_TipoArchivoPorcion3 = DatosEstaticos.wiget3.runtimeType.toString();
    if (F_TipoArchivoPorcion1 == 'Null') {F_TipoArchivoPorcion1 = '';}
    if (F_TipoArchivoPorcion2 == 'Null') {F_TipoArchivoPorcion2 = '';}
    if (F_TipoArchivoPorcion3 == 'Null') {F_TipoArchivoPorcion3 = '';}



    ObtieneDatos datos = ObtieneDatos();
    await datos.updateDatosMediaEquipo(serial, layoutSeleccionado,
        F_TipoArchivoPorcion1, F_TipoArchivoPorcion2,
        F_TipoArchivoPorcion3, archivoPorcion1, archivoPorcion2,
        archivoPorcion3
    );
    return true;

  }*/


