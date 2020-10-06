import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    /*if (webViewController!=null){
      if (widget.divisionLayout.contains('-1')){
        DatosEstaticos.webViewControllerWidget1 = webViewController;
        *//*DatosEstaticos.webViewControllerWidget2 = null;
        DatosEstaticos.webViewControllerWidget3 = null;*//*
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

    }*/
    Widget _webview;
    _webview = WebView(
      initialUrl: url,
      javascriptMode: JavascriptMode.unrestricted,
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

