import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:tvpost_flutter/ventanas/seleccionar_video.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';

class CrearLayout3 extends StatefulWidget {
  @override
  _CrearLayout3State createState() => _CrearLayout3State();
}

class _CrearLayout3State extends State<CrearLayout3> {
  //Widget dentro del mapa de datos de ventana anterior
  Widget widget1;
  Widget widget2;
  Widget widget3;
  bool op = false;
  bool op2 = false;
  bool op3 = false;
  bool _visible = false;
  BoxDecoration _decorationPorcion1;
  BoxDecoration _decorationPorcion2;
  BoxDecoration _decorationPorcion3;
  bool publicar_redes_sociales = false;
  bool videoPorcion2Reemplazado = false;

  @override
  void initState() {
    PorcionSeleccionada(0);
    videoPorcion2Reemplazado = true;
    DatosEstaticos.primeraVezCargaVideo = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      Widget _imageSeleccionLayout =
          Container(); /*Image.asset('imagenes/layout1a.png', fit: BoxFit.fill,);*/
      widget1 = _imageSeleccionLayout;
    }

    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if (DatosEstaticos.widget2 != null) {
      switch (DatosEstaticos.widget2.runtimeType.toString()) {
        //Cambio de tamaño para reproductor en esta porción
        case 'ReproductorVideos':
          if (DatosEstaticos.primeraVezCargaVideo == false) {
            ReproductorVideos antiguo = DatosEstaticos.widget2;
            String dato = antiguo.url;
            VideoPlayerController controladorantiguo = antiguo.controller;
            //Se liberan los recursos del controlador antiguo
            if (controladorantiguo != null) {
              controladorantiguo.dispose();
            }
            ReproductorVideos videoResized = ReproductorVideos(
              divisionLayout: '3-2',
              url: dato,
            );
            widget2 = videoResized;
            DatosEstaticos.widget2 = widget2;
            videoPorcion2Reemplazado = false;
            DatosEstaticos.primeraVezCargaVideo = false;
          }

          break;

        case 'WebView':
          WebView widgetWebView = DatosEstaticos.widget2;
          String url = widgetWebView.initialUrl;
          DatosEstaticos.webViewControllerWidget2?.loadUrl(url);
          widget2 = DatosEstaticos.widget2;
          break;
      }
      widget2 = DatosEstaticos.widget2;

      /*//Cambio de tamaño de video para proporción 5050
      if (DatosEstaticos.widget2.runtimeType.toString() == 'ReproductorVideos') {

      }

      if (DatosEstaticos.widget2.runtimeType.toString() == 'WebView'){

        */ /*try{
          DatosEstaticos.webViewControllerWidget1?.loadUrl(url);
          widget1 = DatosEstaticos.wiget1;
          //DatosEstaticos.webViewControllerWidget1 = null;
        } catch (e) {
          widget1 = DatosEstaticos.wiget1;
          print("Error al loadurl: " + e.toString());
        }*/ /*

      }else {
        widget2 = DatosEstaticos.widget2;
      }*/
    } else {
      Widget _imageSeleccionLayout = Container();
      /*Image.asset(
        'imagenes/layout1a.png',
        fit: BoxFit.fitHeight,
      );*/
      widget2 = _imageSeleccionLayout;
    }

    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if (DatosEstaticos.widget3 != null) {
      if (DatosEstaticos.widget3.runtimeType.toString() == 'WebView') {
        WebView widgetWebView = DatosEstaticos.widget3;
        String url = widgetWebView.initialUrl;
        DatosEstaticos.webViewControllerWidget3?.loadUrl(url);
        widget3 = DatosEstaticos.widget3;
        /*try{
          DatosEstaticos.webViewControllerWidget1?.loadUrl(url);
          widget1 = DatosEstaticos.wiget1;
          //DatosEstaticos.webViewControllerWidget1 = null;
        } catch (e) {
          widget1 = DatosEstaticos.wiget1;
          print("Error al loadurl: " + e.toString());
        }*/

      } else {
        widget3 = DatosEstaticos.widget3;
      }
    } else {
      Widget _imageSeleccionLayout = Container();
      /*Image.asset(
        'imagenes/layout1a.png',
        fit: BoxFit.fitWidth,
      );*/
      widget3 = _imageSeleccionLayout;
    }

    setState(() {
      DatosEstaticos.primeraVezCargaVideo = false;
    });

    Widget contenidoLayout10;

    //Si es true, es decir presionaron guardar...
    if (DatosEstaticos.relojEnPantalla) {
      contenidoLayout10 = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 4, child: widget3),
          Expanded(
            flex: 1,
            child: Container(
              color: HexColor(DatosEstaticos.color_fondo_reloj),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "00:00",
                  style: TextStyle(
                      color: HexColor(DatosEstaticos.color_texto_reloj)),
                  textScaleFactor: 1.0,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      contenidoLayout10 = widget3;
    }

    /*
    //Diego. Acá verifica si el valor del reloj en pantalla es true. Si es así,
    //muestras el layout distinto, sino, muestras el antiguo. T odo lo que quieras
    //mostrar, será el widget "contenidoLayout20" porquie al final solo cambia la porcion
    //del 20%

    Widget contenidoLayout20;
    //Si es true, es decir presionaron guardar...
    if (DatosEstaticos.relojEnPantalla) {
      contenidoLayout20 = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: HexColor(DatosEstaticos.color_fondo_reloj),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "00:00",
                  style: TextStyle(
                      color: HexColor(DatosEstaticos.color_texto_reloj)),
                  textScaleFactor: 1.0,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(flex: 4, child: widget2),
        ],
      );
    } else {
      contenidoLayout20 = widget2;
    }
    //Diego, ahora mira la línea 236 de este archivo. Ahí es donde se carga
    //una porción de layout o la otra. Sugiero eliminar la creación del nuevo
    //archivo layout que hiciste porque por cada cambio que hagamos acá, se va a
    //tener que duplicar en ese.

     */

    return WillPopScope(
      onWillPop: () {
        Navigator.popAndPushNamed(
          context,
          '/seleccionar_layout',
        );
        return;
      },
      child: Scaffold(
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
                      .toString()
                      .toUpperCase(),
                  style: TextStyle(fontSize: 16.5),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3,
                margin:
                    EdgeInsets.only(top: 15, bottom: 20, left: 20, right: 20),
                /*decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 5)),*/
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Container(
                              /*width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.169),
                              height:MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.779),*/
                              decoration: _decorationPorcion1,
                              child: InkWell(
                                enableFeedback: true,
                                onTap: () {
                                  setState(() {
                                    PorcionSeleccionada(1);
                                    if (!_visible) {
                                      _visible = true;
                                    }
                                    DatosEstaticos.divisionLayout = '3-1';
                                  });
                                },
                                child: Opacity(
                                    opacity: op ? 1.0 : 0.1,
                                    child:
                                        ignorarInteraccionesElemento(widget1)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              /*width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.88),
                              height:MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.779),*/
                              decoration: _decorationPorcion2,
                              child: InkWell(
                                enableFeedback: true,
                                onTap: () {
                                  setState(() {
                                    PorcionSeleccionada(2);
                                    if (!_visible) {
                                      _visible = true;
                                    }
                                    DatosEstaticos.divisionLayout = '3-2';
                                  });
                                },
                                child: Opacity(
                                    opacity: op2 ? 1.0 : 0.1,
                                    child:
                                        ignorarInteraccionesElemento(widget2)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        /*width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.91),*/
                        decoration: _decorationPorcion3,
                        child: InkWell(
                          enableFeedback: true,
                          onTap: () {
                            setState(() {
                              PorcionSeleccionada(3);
                              if (!_visible) {
                                _visible = true;
                              }
                              DatosEstaticos.divisionLayout = '3-3';
                            });
                          },
                          child: Opacity(
                              opacity: op3 ? 1.0 : 0.1,
                              child: ignorarInteraccionesElemento(
                                  contenidoLayout10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Publicacion
              /* Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 2,
                    child: CheckboxListTile(
                      title: Text('¿Porción izquierda en redes sociales?'),
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
              ),

              //Manejo reloj
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
                      onChanged: (bool value) {
                        setState(() {
                          if (value) {
                            PopUps.PopUpConWidgetYEventos(context, EditarReloj());
                          }
                          DatosEstaticos.relojEnPantalla = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: BotonEnviarAEquipo(
                      publicar_rrss: publicar_redes_sociales,
                      publicar_porcion: 1,
                      visible: true,
                      mensaje_boton: "Enviar Solo reloj",
                    ),
                  )
                ],
              ),*/

              //Acá va el widget de los botones
              OpcionesSeleccionMedia(
                visible: _visible,
                divisionLayout: DatosEstaticos.divisionLayout,
                //Función que al ser ejecutada desde la ventana siguiente
                //actualiza el state (puede hacer cualquier cosa)
                actualizaEstado: () {
                  setState(() {
                    videoPorcion2Reemplazado = true;
                    if (DatosEstaticos.PublicarEnRedesSociales) {
                      Widget contenido = Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: HexColor('#f4f4f4')),
                          height: MediaQuery.of(context).size.height/5,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Publicación Redes Sociales',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Proyecte en la TV para realizar publicacion',
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 10,
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
                      PopUps.PopUpConWidget(context, contenido);
                    }
                  });
                },
              ),
              BotonEnviarAEquipo(
                visible: _visible,
                publicar_rrss: DatosEstaticos.PublicarEnRedesSociales,
                publicar_porcion: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  StatefulBuilder EditarReloj() {
    // Valores para color de fonddo y texto
    Color pickerColorFondo = HexColor(DatosEstaticos.color_fondo_reloj);
    Color pickerColorTexto = HexColor(DatosEstaticos.color_texto_reloj);

    //Funciones que cambian y devuelven color
    void changeColorFondo(Color color) {
      setState(() {
        pickerColorFondo = color;
        //El valor viene en int, así que para pasarlo al reloj en la pantalla
        //se debe transformar a hex.
        var hex =
            '#${color.value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
        DatosEstaticos.color_fondo_reloj = hex;
      });
    }

    //Funciones que cambian y devuelven color
    void changeColorLetras(Color color) {
      setState(() {
        pickerColorTexto = color;
        //El valor viene en int, así que para pasarlo al reloj en la pantalla
        //se debe transformar a hex.
        var hex =
            '#${color.value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
        DatosEstaticos.color_texto_reloj = hex;
      });
    }

    return StatefulBuilder(builder: (context, setState) {
      return Center(
        child: SingleChildScrollView(
          child: AlertDialog(
            title: Text(
              "Vista Previa Reloj",
              textAlign: TextAlign.center,
            ),
            content: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: pickerColorFondo,
                    ),
                    child: Text(
                      '12:00:00',
                      textScaleFactor: 2.0,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: pickerColorTexto),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Fondo",
                      textScaleFactor: 1.5,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    ColorPicker(
                      pickerColor: pickerColorFondo,
                      showLabel: false,
                      enableAlpha: false,
                      displayThumbColor: true,
                      pickerAreaHeightPercent: 0.25,
                      onColorChanged: (color) {
                        changeColorFondo(color);
                        setState(() {});
                      },
                    ),
                    Text(
                      "Hora",
                      textScaleFactor: 1.5,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    ColorPicker(
                      pickerColor: pickerColorTexto,
                      showLabel: false,
                      enableAlpha: false,
                      displayThumbColor: true,
                      pickerAreaHeightPercent: 0.25,
                      onColorChanged: (color) {
                        changeColorLetras(color);
                        setState(() {});
                      },
                    ),
                    RaisedButton(
                        child: Text("Guardar"),
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop()),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void PorcionSeleccionada(int seleccionada) {
    switch (seleccionada) {
      case 0:
        _decorationPorcion1 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#3EDB9B').withOpacity(0.2));
        _decorationPorcion2 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#0683FF').withOpacity(0.2));
        _decorationPorcion3 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#FC4C8B').withOpacity(0.2));
        break;
      case 1:
        op = true;
        op2 = false;
        op3 = false;

        _decorationPorcion1 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#3EDB9B'));
        _decorationPorcion2 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#0683FF').withOpacity(0.2));
        _decorationPorcion3 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#FC4C8B').withOpacity(0.2));
        break;
      case 2:
        op = false;
        op2 = true;
        op3 = false;
        _decorationPorcion1 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#3EDB9B').withOpacity(0.2));
        _decorationPorcion2 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#0683FF'));
        _decorationPorcion3 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#FC4C8B').withOpacity(0.2));
        break;
      case 3:
        op = false;
        op2 = false;
        op3 = true;
        _decorationPorcion1 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#3EDB9B').withOpacity(0.2));
        _decorationPorcion2 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#0683FF').withOpacity(0.2));
        _decorationPorcion3 = BoxDecoration(
            //borderRadius: BorderRadius.circular(50),
            color: HexColor('#FC4C8B'));
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
