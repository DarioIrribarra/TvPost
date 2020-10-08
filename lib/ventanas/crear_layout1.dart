import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CrearLayout1 extends StatefulWidget {
  @override
  _CrearLayout1State createState() => _CrearLayout1State();
}

class _CrearLayout1State extends State<CrearLayout1> {
  //Acá va el cambio desde VSCode - 2
  //Acá va el cambio desde Android

  //dato que indica que parte del layout se quiere modificar y se envia a la
  // selección de contenido correspondiente
  String divisionLayout;

  //Widget dentro del mapa de datos de ventana anterior
  Widget widget1;
  bool _visible = false;
  //Decoración que permite el poner un borde al seleccionar la porción de
  // pantalla
  BoxDecoration _decorationPorcion1;

  @override
  void initState() {
    PorcionSeleccionada(0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final webViewKey = GlobalKey<ScaffoldState>();
    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if (DatosEstaticos.wiget1 != null) {
      if (DatosEstaticos.wiget1.runtimeType.toString() == 'WebView'){
        WebView widgetWebView = DatosEstaticos.wiget1;
        String url = widgetWebView.initialUrl;
        DatosEstaticos.webViewControllerWidget1?.loadUrl(url);
        widget1 = DatosEstaticos.wiget1;
        /*try{
          DatosEstaticos.webViewControllerWidget1?.loadUrl(url);
          widget1 = DatosEstaticos.wiget1;
          //DatosEstaticos.webViewControllerWidget1 = null;
        } catch (e) {
          widget1 = DatosEstaticos.wiget1;
          print("Error al loadurl: " + e.toString());
        }*/

      }else {
        widget1 = DatosEstaticos.wiget1;
      }
    } else {
      Widget _imageSeleccionLayout = Image.asset('imagenes/layout1a.png');
      widget1 = _imageSeleccionLayout;
    }
    return Scaffold(
      //key: webViewKey,
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
          child: Column(
            children: [
              //Ink well para poder tener feedback como botón de cualquier widget
              Container(
                margin: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 5)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height/3,
                  decoration: _decorationPorcion1,
                  child: InkWell(
                    enableFeedback: true,
                    onTap: () {
                      setState(() {
                        PorcionSeleccionada(1);
                        if (!_visible) {
                          _visible = true;
                        }
                        divisionLayout = '1-1';
                      });
                    },
                    child: ignorarInteraccionesElemento(widget1),
                  ),
                ),
              ),
              //Acá va el widget de los botones
              OpcionesSeleccionMedia(
                //keywebview: webViewKey,
                visible: _visible,
                divisionLayout: divisionLayout,
                //Función que al ser ejecutada desde la ventana siguiente
                //actualiza el state (puede hacer cualquier cosa)
                actualizaEstado: () {
                  setState(() {});
                },
              ),
              BotonEnviarAEquipo(visible: _visible),
            ],
          ),
      ),
    );
  }

  void PorcionSeleccionada (int seleccionada){
    switch(seleccionada){
      case 0:
        _decorationPorcion1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 1:
        _decorationPorcion1 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        break;
    }
  }

  //Ignora los controles del webview para que no intervenga con el onTap de
  // seleccionar medio
  Widget ignorarInteraccionesElemento(Widget widget){
    if (widget.runtimeType.toString() == 'WebView'){
      return IgnorePointer(child: widget,);
    }else{
      return widget;
    }
  }
/*navegarYEsperarRespuesta(String rutaVentana) async {
    final result = await Navigator.pushNamed(context, rutaVentana, arguments: {
      'division_layout': divisionLayout,
    });
    if (result != null) {
      setState(() {});
    }
  }*/
}

/*class CrearLayout1 extends StatelessWidget {
  //Datos que se envía completo desde la ventana de selección de media
  Map datosDesdeVentanaAnterior = {};
  //dato que indica que parte del layout se quiere modificar y se envia a la
  // selección de contenido correspondiente
  int divisionLayout;
  //Widget dentro del mapa de datos de ventana anterior
  Widget widget1;

  @override
  Widget build(BuildContext context) {

    //Se le puede pasar cualquier tipo de argumento (incluido widgets completos)
    datosDesdeVentanaAnterior = ModalRoute.of(context).settings.arguments;
    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if(datosDesdeVentanaAnterior != null){
      widget1 = datosDesdeVentanaAnterior['widget1'];
      return Scaffold(
        //Appbar viene de archivo custom_widgets.dart
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
            child: Column(
              children: [
                widget1,
              ],
            )
        ),
        backgroundColor: Colors.green,
      );
    }
    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                    child: Image(
                      image: AssetImage('imagenes/layout1a.png'),
                    )
                ),
                Visibility(

                  child: Container(
                    margin: EdgeInsets.only(left: 120.0),
                    child: Center(

                      child: SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RaisedButton(onPressed: (){},),
                            RaisedButton(onPressed: (){},),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}*/
