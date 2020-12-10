import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CrearLayout2 extends StatefulWidget {
  @override
  _CrearLayout2State createState() => _CrearLayout2State();
}

class _CrearLayout2State extends State<CrearLayout2> {
  //dato que indica que parte del layout se quiere modificar y se envia a la
  // selección de contenido correspondiente
  String divisionLayout;
  //Widget dentro del mapa de datos de ventana anterior
  Widget widget1;
  Widget widget2;
  bool _visible = false;
  BoxDecoration _decorationPorcion1;
  BoxDecoration _decorationPorcion2;
  bool publicar_redes_sociales = false;
  bool publicar_porcion_izquierda = false;
  bool publicar_porcion_derecha = false;
  int porcion_publicar_rrss = 1;

  @override
  void initState() {
    PorcionSeleccionada(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

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

    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if (DatosEstaticos.wiget2 != null) {
      if (DatosEstaticos.wiget2.runtimeType.toString() == 'WebView'){
        WebView widgetWebView = DatosEstaticos.wiget2;
        String url = widgetWebView.initialUrl;
        DatosEstaticos.webViewControllerWidget2?.loadUrl(url);
        widget2 = DatosEstaticos.wiget2;
        /*try{
          DatosEstaticos.webViewControllerWidget1?.loadUrl(url);
          widget1 = DatosEstaticos.wiget1;
          //DatosEstaticos.webViewControllerWidget1 = null;
        } catch (e) {
          widget1 = DatosEstaticos.wiget1;
          print("Error al loadurl: " + e.toString());
        }*/

      }else {
        widget2 = DatosEstaticos.wiget2;
      }
    } else {
      Widget _imageSeleccionLayout = Image.asset('imagenes/layout1a.png');
      widget2 = _imageSeleccionLayout;
    }

    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height/3,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 5)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex:1,
                    child: Container(
                      decoration: _decorationPorcion1,
                      child: InkWell(
                          enableFeedback: true,
                          onTap: () {
                            setState(() {
                              PorcionSeleccionada(1);
                              if (!_visible) {
                                _visible = true;
                              }
                              divisionLayout = '2-1';
                            });
                          },
                          child: ignorarInteraccionesElemento(widget1),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: _decorationPorcion2,
                      child: InkWell(
                          enableFeedback: true,
                          onTap: () {
                            setState(() {
                              PorcionSeleccionada(2);
                              if (!_visible) {
                                _visible = true;
                              }
                              divisionLayout = '2-2';
                            });
                          },
                          child: ignorarInteraccionesElemento(widget2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //Publicacion
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: CheckboxListTile(
                    title: Text('¿Porción izquierda en redes sociales?'),
                    secondary: Icon(Icons.share),
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: publicar_porcion_izquierda,
                    onChanged: (bool value){
                      setState(() {
                        if (publicar_porcion_derecha){
                          publicar_porcion_derecha = false;
                        }
                        if (value){
                          if (DatosEstaticos.wiget1 != null ){
                            if (DatosEstaticos.wiget1.runtimeType.toString() != 'Image'){
                              Column cont = Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Solo se pueden publicar imágenes'),
                                  RaisedButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                    child: Text('Aceptar'),),
                                ],
                              );
                              PopUps.PopUpConWidget(context, cont);
                              publicar_redes_sociales = false;
                              publicar_porcion_izquierda = false;
                            } else {
                              publicar_redes_sociales = true;
                              publicar_porcion_izquierda = true;
                              porcion_publicar_rrss = 1;
                            }
                          } else {
                            Column cont = Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('La imagen no puede estar vacía'),
                                RaisedButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                  child: Text('Aceptar'),),
                              ],
                            );
                            PopUps.PopUpConWidget(context, cont);
                            publicar_redes_sociales = false;
                            publicar_porcion_izquierda = false;
                          }
                        }  else {
                          publicar_redes_sociales = false;
                          publicar_porcion_izquierda = false;
                        }
                      });

                    },
                  ),
                ),
              ],
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: CheckboxListTile(
                    title: Text('¿Porción derecha en redes sociales?'),
                    secondary: Icon(Icons.share),
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: publicar_porcion_derecha,
                    onChanged: (bool value){
                      if (publicar_porcion_izquierda){
                        publicar_porcion_izquierda = false;
                      }
                      setState(() {
                        if (value){
                          if (DatosEstaticos.wiget2 != null ){
                            if (DatosEstaticos.wiget2.runtimeType.toString() != 'Image'){
                              Column cont = Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Solo se pueden publicar imágenes'),
                                  RaisedButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                    child: Text('Aceptar'),),
                                ],
                              );
                              PopUps.PopUpConWidget(context, cont);
                              publicar_redes_sociales = false;
                              publicar_porcion_derecha = false;
                            } else {
                              publicar_redes_sociales = true;
                              publicar_porcion_derecha = true;
                              porcion_publicar_rrss = 2;
                            }
                          } else {
                            Column cont = Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('La imagen no puede estar vacía'),
                                RaisedButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                  child: Text('Aceptar'),),
                              ],
                            );
                            PopUps.PopUpConWidget(context, cont);
                            publicar_redes_sociales = false;
                            publicar_porcion_derecha = false;
                          }
                        }  else {
                          publicar_redes_sociales = false;
                          publicar_porcion_derecha = false;
                        }
                      });

                    },
                  ),
                ),
              ],
            ),

            //Acá va el widget de los botones
            OpcionesSeleccionMedia(
              visible: _visible,
              divisionLayout: divisionLayout,
              //Función que al ser ejecutada desde la ventana siguiente
              //actualiza el state (puede hacer cualquier cosa)
              actualizaEstado: () {
                setState(() {});
              },
            ),
            BotonEnviarAEquipo(visible: _visible,
              publicar_rrss: publicar_redes_sociales,
              publicar_porcion: porcion_publicar_rrss,),
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
        _decorationPorcion2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 1:
        _decorationPorcion1 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        _decorationPorcion2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 2:
        _decorationPorcion1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationPorcion2 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        break;
    }
  }

  //Ignora los controles del webview para que no intervenga con el onTap de
  // seleccionar medio
  Widget ignorarInteraccionesElemento(Widget widget){
    if (widget.runtimeType.toString() == 'WebView' ||
        widget.runtimeType.toString() == 'WebViewPropio'){
      return IgnorePointer(child: widget,);
    }else{
      return widget;
    }
  }
}
