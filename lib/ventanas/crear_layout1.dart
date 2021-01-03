import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';

class CrearLayout1 extends StatefulWidget {
  @override
  _CrearLayout1State createState() => _CrearLayout1State();
}

class _CrearLayout1State extends State<CrearLayout1> {
  //dato que indica que parte del layout se quiere modificar y se envia a la
  // selección de contenido correspondiente
  String divisionLayout;

  //Widget dentro del mapa de datos de ventana anterior
  Widget widget1;
  bool _visible = false;
  bool publicar_redes_sociales = false;
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
    if (DatosEstaticos.widget1 != null) {
      if (DatosEstaticos.widget1.runtimeType.toString() == 'WebView') {
        WebView widgetWebView = DatosEstaticos.widget1;
        String url = widgetWebView.initialUrl;
        DatosEstaticos.webViewControllerWidget1?.loadUrl(url);
        widget1 = DatosEstaticos.widget1;
      } else {
        widget1 = DatosEstaticos.widget1;
      }
    } else {
      Widget _imageSeleccionLayout = Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60),
            color: HexColor('#3EDB9B').withOpacity(0.2)),
      );
      //Image.asset('imagenes/layout1a.png', fit: BoxFit.fill);

      widget1 = _imageSeleccionLayout;
    }
    return Scaffold(
      //key: webViewKey,
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                ObtieneDatos.listadoEquipos[DatosEstaticos.indexSeleccionado]
                        ['f_alias']
                    .toString(),
                style: TextStyle(fontSize: 16.5),
                textAlign: TextAlign.center,
              ),
            ),
            //Ink well para poder tener feedback como botón de cualquier widget
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              margin: EdgeInsets.all(5),
              /*decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 5)),*/
              child: Container(
                margin:
                    EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
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

            //Publicacion
            /*Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: CheckboxListTile(
                    title: Text('¿Porción central en redes sociales?'),
                    secondary: Icon(Icons.share),
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: publicar_redes_sociales,
                    onChanged: (bool value) {
                      setState(() {
                        if (value) {
                          if (DatosEstaticos.widget1 != null) {
                            if (DatosEstaticos.widget1.runtimeType.toString() !=
                                'Image') {
                              Column cont = Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Solo se pueden publicar imágenes'),
                                  RaisedButton(
                                    onPressed: () => Navigator.of(context,
                                            rootNavigator: true)
                                        .pop(),
                                    child: Text('Aceptar'),
                                  ),
                                ],
                              );
                              PopUps.PopUpConWidget(context, cont);
                              publicar_redes_sociales = false;
                            } else {
                              publicar_redes_sociales = true;
                            }
                          } else {
                            Column cont = Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('La imagen no puede estar vacía'),
                                RaisedButton(
                                  onPressed: () =>
                                      Navigator.of(context, rootNavigator: true)
                                          .pop(),
                                  child: Text('Aceptar'),
                                ),
                              ],
                            );
                            PopUps.PopUpConWidget(context, cont);
                            publicar_redes_sociales = false;
                          }
                        } else {
                          publicar_redes_sociales = false;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),*/

            //Acá va el widget de los botones
            OpcionesSeleccionMedia(
              //keywebview: webViewKey,
              visible: _visible,
              divisionLayout: divisionLayout,
              //Función que al ser ejecutada desde la ventana siguiente
              //actualiza el state (puede hacer cualquier cosa)
              actualizaEstado: () {
                setState(() {
                  widget1 = DatosEstaticos.widget1;
                });
              },
            ),
            BotonEnviarAEquipo(
              visible: _visible,
              publicar_rrss: publicar_redes_sociales,
              publicar_porcion: 1,
            ),
          ],
        ),
      ),
    );
  }

  void PorcionSeleccionada(int seleccionada) {
    switch (seleccionada) {
      case 0:
        _decorationPorcion1 = BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: HexColor('#3EDB9B').withOpacity(0.2));
        break;
      case 1:
        _decorationPorcion1 = BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: HexColor('#3EDB9B'));
        break;
    }
  }

  //Ignora los controles del webview para que no intervenga con el onTap de
  // seleccionar medio
  Widget ignorarInteraccionesElemento(Widget widget) {
    if (widget.runtimeType.toString() == 'WebView' ||
        widget.runtimeType.toString() == 'WebViewPropio') {
      return IgnorePointer(
        child: widget,
      );
    } else {
      return widget;
    }
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
