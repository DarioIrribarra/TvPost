import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CrearLayout3 extends StatefulWidget {
  @override
  _CrearLayout3State createState() => _CrearLayout3State();
}

class _CrearLayout3State extends State<CrearLayout3> {
  //dato que indica que parte del layout se quiere modificar y se envia a la
  // selección de contenido correspondiente
  String divisionLayout;
  //Widget dentro del mapa de datos de ventana anterior
  Widget widget1;
  Widget widget2;
  Widget widget3;
  bool _visible = false;
  BoxDecoration _decorationPorcion1;
  BoxDecoration _decorationPorcion2;
  BoxDecoration _decorationPorcion3;
  bool _visible_btn_envio_reloj = false;

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

    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if (DatosEstaticos.wiget3 != null) {
      if (DatosEstaticos.wiget3.runtimeType.toString() == 'WebView'){
        WebView widgetWebView = DatosEstaticos.wiget3;
        String url = widgetWebView.initialUrl;
        DatosEstaticos.webViewControllerWidget3?.loadUrl(url);
        widget3 = DatosEstaticos.wiget3;
        /*try{
          DatosEstaticos.webViewControllerWidget1?.loadUrl(url);
          widget1 = DatosEstaticos.wiget1;
          //DatosEstaticos.webViewControllerWidget1 = null;
        } catch (e) {
          widget1 = DatosEstaticos.wiget1;
          print("Error al loadurl: " + e.toString());
        }*/

      }else {
        widget3 = DatosEstaticos.wiget3;
      }
    } else {
      Widget _imageSeleccionLayout = Image.asset('imagenes/layout1a.png');
      widget3 = _imageSeleccionLayout;
    }


    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 5)),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/3,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.169),
                        height:MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.779),
                        decoration: _decorationPorcion1,
                        child: InkWell(
                            enableFeedback: true,
                            onTap: () {
                              setState(() {
                                PorcionSeleccionada(1);
                                if (!_visible) {
                                  _visible = true;
                                }
                                divisionLayout = '3-1';
                              });
                            },
                            child: ignorarInteraccionesElemento(widget1),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.88),
                        height:MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.779),
                        decoration: _decorationPorcion2,
                        child: InkWell(
                            enableFeedback: true,
                            onTap: () {
                              setState(() {
                                PorcionSeleccionada(2);
                                if (!_visible) {
                                  _visible = true;
                                }
                                divisionLayout = '3-2';
                              });
                            },
                            child: ignorarInteraccionesElemento(widget2),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.91),
                    decoration: _decorationPorcion3,
                    child: InkWell(
                        enableFeedback: true,
                        onTap: () {
                          setState(() {
                            PorcionSeleccionada(3);
                            if (!_visible) {
                              _visible = true;
                            }
                            divisionLayout = '3-3';
                          });
                        },
                        child: ignorarInteraccionesElemento(widget3),
                    ),
                  ),
                ],
              ),
            ),

            //Manejo del reloj
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: CheckboxListTile(
                    title: Text('¿Activar reloj?'),
                    secondary: Icon(Icons.more_time_rounded),
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: DatosEstaticos.relojEnPantalla,
                    onChanged: (bool value){
                      setState(() {
                        if (value){
                          PopUps.PopUpConWidgetYEventos(context, EditarReloj());
                        }
                        _visible_btn_envio_reloj = true;
                        DatosEstaticos.relojEnPantalla = value;
                      });
                    },
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: BotonEnviarAEquipo(
                    visible: _visible_btn_envio_reloj,
                    mensaje_boton: "Enviar Solo reloj",
                  ),
                )
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
            BotonEnviarAEquipo(visible: _visible),
          ],
        ),
      ),
    );
  }

  StatefulBuilder EditarReloj (){

    // Valores para color de fonddo y texto
    Color pickerColorFondo = HexColor(DatosEstaticos.color_fondo_reloj);
    Color pickerColorTexto = HexColor(DatosEstaticos.color_texto_reloj);

    //Funciones que cambian y devuelven color
    void changeColorFondo(Color color) {
      setState(() {
        pickerColorFondo = color;
        //El valor viene en int, así que para pasarlo al reloj en la pantalla
        //se debe transformar a hex.
        var hex = '#${color.value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
        DatosEstaticos.color_fondo_reloj = hex;
      });
    }

    //Funciones que cambian y devuelven color
    void changeColorLetras(Color color) {
      setState(() {
        pickerColorTexto = color;
        //El valor viene en int, así que para pasarlo al reloj en la pantalla
        //se debe transformar a hex.
        var hex = '#${color.value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
        DatosEstaticos.color_texto_reloj = hex;
      });
    }

    return StatefulBuilder(
        builder: (context, setState){
          return SingleChildScrollView(
            child: AlertDialog(
              title: Text("Vista Previa Reloj", textAlign: TextAlign.center,),
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: pickerColorFondo,
                      ),
                      child: Text('12:00:00', textScaleFactor: 2.0,
                        textAlign: TextAlign.center, style: TextStyle(color: pickerColorTexto),),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Fondo", textScaleFactor: 1.5, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                      ColorPicker(
                        pickerColor: pickerColorFondo,
                        showLabel: false,
                        displayThumbColor: true,
                        pickerAreaHeightPercent: 0.25,
                        onColorChanged: (color){
                          changeColorFondo(color);
                          setState((){});
                        },
                      ),
                      Text("Hora", textScaleFactor: 1.5, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                      ColorPicker(
                        pickerColor: pickerColorTexto,
                        showLabel: false,
                        displayThumbColor: true,
                        pickerAreaHeightPercent: 0.25,
                        onColorChanged: (color){
                          changeColorLetras(color);
                          setState((){});
                        },
                      ),
                      RaisedButton(
                        child: Text("Guardar"),
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop()
                      ),
                    ],
                  ),

                ],
              ),
              /*actions: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: ColorPicker(
                    pickerColorFondo: pickerColorFondo,
                    onColorChanged: (color){
                      changeColor(color);
                      setState((){});
                    },
                    pickerAreaHeightPercent: 0.5,
                  ),
                ),
              ],*/
            ),
          );
        }
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
        _decorationPorcion3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 2:
        _decorationPorcion1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationPorcion2 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        _decorationPorcion3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 3:
        _decorationPorcion1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationPorcion2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationPorcion3 = BoxDecoration(
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
