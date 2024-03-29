import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';
import 'package:video_player/video_player.dart';
//import 'package:tvpost_flutter/ventanas/mi_perfil.dart';
//import 'package:tvpost_flutter/ventanas/soporte.dart';
//import 'package:tvpost_flutter/ventanas/crear_layout3.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tvpost_flutter/utilidades/comunicacion_raspberry.dart';
import 'package:flutter_social_content_share/flutter_social_content_share.dart';

class PopUps {
  //Se crea popup de cargando
  static popUpCargando(BuildContext context, String texto) async{

    await Future.delayed(Duration(microseconds: 1));
    Widget alert = AlertDialog(
      contentPadding: EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
      backgroundColor: Colors.grey.withOpacity(0.0),
      content: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: HexColor('#f4f4f4')),
          height: 100,
          width: 250,
          child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Center(child: Text(texto, style: TextStyle(fontSize: 13))),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(HexColor("#FC4C8B")),
            )
          ])),
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

  ///Crear un popup con cualquier widget de contenido
  static PopUpConWidget(BuildContext context, Widget contenidoPopUp){
    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
      backgroundColor: Colors.grey.withOpacity(0.0),
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

  ///Crear un popup con cualquier widget de contenido ASINCRONO PARA ESPERA DE
  ///RESPUESTA
  static PopUpConWidgetAsync(BuildContext context, Widget contenidoPopUp)async{
    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
      backgroundColor: Colors.grey.withOpacity(0.0),
      content: contenidoPopUp,
    );
    await showDialog(
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

  static Future<bool> guardarPerfil(String nombre, File imagen) async {
    String imabenBytes = base64Encode(imagen.readAsBytesSync());
    String rutaSubidaImagenes =
        '${DatosEstaticos.hosting}/imgPerfil/subirPerfil.php';
    //'http://' + DatosEstaticos.ipSeleccionada + '/upload_one_image2.php';
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

}

class MenuAppBar {
  static String administrarImagenes = "Imagenes";
  static String administrarVideos = "Videos";
  static String miPerfil = "Mi Perfil";
  static String soporte = "Soporte";
  static String cerrarSesion = "Salir";
  static String misPantallas = "Mis Pantallas";

  static List<String> itemsMenu = <String>[
    misPantallas,
    administrarImagenes,
    administrarVideos,
    soporte,
    miPerfil,
    cerrarSesion,
  ];

  static Validacion(
      {List<int> listadoEquipos,
      BuildContext context,
      String rutaVentana,
      String rutaProveniente,
      bool necesitaEquipoConectado}) {
    /*
    Navigator.pushNamed(context, rutaVentana, arguments: {
      'division_layout': '0',
      'ruta_proveniente': rutaProveniente,
    });
    */
      Navigator.popAndPushNamed(context, rutaVentana, arguments: {
        'division_layout': '0',
        'ruta_proveniente': rutaProveniente,
      });


    //print(ModalRoute.of(context).settings.name);
    /*
    if (necesitaEquipoConectado) {
      if (listadoEquipos.length > 0) {
        if (DatosEstaticos.ipSeleccionada != null) {
          //Navigator.pop(context);
          Navigator.popAndPushNamed(context, rutaVentana, arguments: {
            'division_layout': '0',
            'ruta_proveniente': rutaProveniente,
          });
          //Muestro listado de equipos a elegir
          //Para que el listado funcione correctamente, por cada equipo se añade
          //altura y si llega al máximo se deja de añadir. Esto hace que el efecto
          //de deslizar funcione correctamente
        } else {
          double altura = 60.0 + (30 * listadoEquipos.length);
          if (altura >= MediaQuery.of(context).size.height) {
            altura = MediaQuery.of(context).size.height;
          }
          //Se crea el arreglo que almacena los equipos habilitados
          List<Widget> listadoHabilitados = [];

          //Cada elemento representa un item dentro del listado de los
          //Equipos conectados que aparecen para elegir
          listadoEquipos.forEach((element) {
            //print(element);
            Container item = Container(
              /*decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: HexColor('#f4f4f4')),*/
              height: MediaQuery.of(context).size.height / 10,
              width: 250,
              child: ListTile(
                contentPadding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 6),
                leading: Icon(
                  Icons.screen_share,
                  color: Colors.blueAccent,
                ),
                title: Text(
                  ObtieneDatos.listadoEquipos[element]['f_alias']
                      .toString()
                      .toUpperCase(),
                  //'DARIO CLON 1',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  DatosEstaticos.ipSeleccionada =
                      ObtieneDatos.listadoEquipos[element]['f_ip'].toString();
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
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: HexColor('#f4f4f4')),
              width: MediaQuery.of(context).size.width,
              height: altura,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    height: 10,
                    child: Text('EQUIPOS CONECTADOS',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13)),
                  ),
                  Container(
                    height: altura - 30,
                    child: ListView(
                      children: listadoHabilitados,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        if (rutaVentana == "/seleccionar_imagen") {
          PopUps.PopUpConWidget(
              context,
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: HexColor('#f4f4f4')),
                height: 100,
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 3, bottom: 1),
                                child: Text(
                                  'USTED NO POSEE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                'EQUIPOS CONECTADOS',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Icon(
                            Icons.do_disturb_on_rounded,
                            color: HexColor('#FC4C8B'),
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
        } else if (rutaVentana == "/seleccionar_video") {
          PopUps.PopUpConWidget(
              context,
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: HexColor('#f4f4f4')),
                height: 100,
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 3, bottom: 1),
                                child: Text(
                                  'USTED NO POSEE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                'EQUIPOS CONECTADOS',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Icon(
                            Icons.do_disturb_on_rounded,
                            color: HexColor('#FC4C8B'),
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
        }
      }
    } else {
      Navigator.popAndPushNamed(context, rutaVentana, arguments: {
        'division_layout': '0',
        'ruta_proveniente': rutaProveniente,
      });
    }

     */
  }

  static void SeleccionMenu(String itemSeleccionado, BuildContext context) {
    //Se toma la ruta base desde donde se clicó el menú
    String rutaProveniente = ModalRoute.of(context).settings.name;

    //Selección Mis Pantallas
    if (itemSeleccionado == MenuAppBar.misPantallas) {
      //Acá hay un problema de cuando se está en el popup para elegir
      //videos o imágenes, se vuelve a cargar la ventana y hace que salte
      //una excepción antes de cargar raspberries_conectadas;

      /*if (RutasRedireccionMenu.divisionLayoutElegido != ""){
        */ /*Navigator.of(context).popUntil(ModalRoute.withName("/"));
        Navigator.pushNamed(context, '/raspberries_conectadas')*/ /*;
        //return;

        CambiarRutaMisPantallas(context);
        //return;
        //Navigator.pop(context);

        //Navigator.pushNamed(context, '/raspberries_conectadas');
      }*/

      Navigator.of(context).popUntil(ModalRoute.withName("/"));
      Navigator.pushNamed(context, '/raspberries_conectadas');
      return;
    }

    //Selección de Imagenes
    if (itemSeleccionado == MenuAppBar.administrarImagenes) {
      //Se limpia listado de videos seleccionados
      SeleccionaVideo.videosSelecionados.clear();

      //Si la ruta seleccionada es la misma ventana, no se cambia
      if (rutaProveniente == "/seleccionar_imagen") {
        return;
      }

      if (rutaProveniente == "/seleccionar_video" ||
          rutaProveniente == "/soporte" ||
          rutaProveniente == "/miPerfil") {
        //se utiliza ruta ya almacenada
        rutaProveniente = RutasRedireccionMenu.RutaDeDondeViene;
      } else {
        //Se reasigna la ruta
        RutasRedireccionMenu.RutaDeDondeViene = rutaProveniente;
      }

      //print(RutasRedireccionMenu.RutaDeDondeViene);
      //List<int> listaTest = [1, 2, 3, 4, 5, 6,7, 8, 9, 10, 11];
      Validacion(
          necesitaEquipoConectado: true,
          //listadoEquipos: listaTest,
          listadoEquipos: DatosEstaticos.listadoIndexEquiposConectados,
          context: context,
          rutaVentana: "/seleccionar_imagen",
          rutaProveniente: rutaProveniente);
    }

    //Selección Videos
    if (itemSeleccionado == MenuAppBar.administrarVideos) {
      //Si la ruta seleccionada es la misma ventana, no se cambia
      if (rutaProveniente == "/seleccionar_video") {
        return;
      }

      if (rutaProveniente == "/seleccionar_imagen" ||
          rutaProveniente == "/soporte" ||
          rutaProveniente == "/miPerfil") {
        //se utiliza ruta ya almacenada
        rutaProveniente = RutasRedireccionMenu.RutaDeDondeViene;
      } else {
        //Se limpia listado de videos seleccionados
        SeleccionaVideo.videosSelecionados.clear();
        //Se reasigna la ruta
        RutasRedireccionMenu.RutaDeDondeViene = rutaProveniente;
      }

      //print(RutasRedireccionMenu.RutaDeDondeViene);
      Validacion(
        necesitaEquipoConectado: true,
        listadoEquipos: DatosEstaticos.listadoIndexEquiposConectados,
        context: context,
        rutaVentana: "/seleccionar_video",
        rutaProveniente: rutaProveniente,
      );
    }

    //Selección Soporte
    if (itemSeleccionado == MenuAppBar.soporte) {
      //Si la ruta seleccionada es la misma ventana, no se cambia
      if (rutaProveniente == "/soporte") {
        return;
      }

      if (rutaProveniente == "/seleccionar_imagen" ||
          rutaProveniente == "/seleccionar_video" ||
          rutaProveniente == "/miPerfil") {
        //se utiliza ruta ya almacenada
        rutaProveniente = RutasRedireccionMenu.RutaDeDondeViene;
      } else {
        //Se limpia listado de videos seleccionados
        SeleccionaVideo.videosSelecionados.clear();
        //Se reasigna la ruta
        RutasRedireccionMenu.RutaDeDondeViene = rutaProveniente;
      }

      Validacion(
        necesitaEquipoConectado: false,
        listadoEquipos: DatosEstaticos.listadoIndexEquiposConectados,
        context: context,
        rutaVentana: "/soporte",
        rutaProveniente: rutaProveniente,
      );
      //return Navigator.popUntil(context,  ModalRoute.of(context).('/soporte'));
    }

    //Selección Mi perfil
    if (itemSeleccionado == MenuAppBar.miPerfil) {
      //Si la ruta seleccionada es la misma ventana, no se cambia
      if (rutaProveniente == "/miPerfil") {
        return;
      }

      if (rutaProveniente == "/seleccionar_imagen" ||
          rutaProveniente == "/seleccionar_video" ||
          rutaProveniente == "/soporte") {
        //se utiliza ruta ya almacenada
        rutaProveniente = RutasRedireccionMenu.RutaDeDondeViene;
      } else {
        //Se limpia listado de videos seleccionados
        SeleccionaVideo.videosSelecionados.clear();
        //Se reasigna la ruta
        RutasRedireccionMenu.RutaDeDondeViene = rutaProveniente;
      }

      Validacion(
        necesitaEquipoConectado: false,
        listadoEquipos: DatosEstaticos.listadoIndexEquiposConectados,
        context: context,
        rutaVentana: "/miPerfil",
        rutaProveniente: rutaProveniente,
      );
    }

    //Selección Cerrar Sesión
    if (itemSeleccionado == MenuAppBar.cerrarSesion) {
      Widget contenidoPopUp = Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: HexColor('#f4f4f4')),
          height: 150,
          width: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text('¿DESEA CERRAR SESIÓN?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(flex: 3, child: SizedBox()),
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        child: Icon(
                          Icons.check_circle,
                          color: HexColor('#3EDB9B'),
                          size: 35,
                        ),
                        onTap: () {
                          if (Platform.isAndroid) {
                            SystemNavigator.pop();
                            return;
                          } else {
                            exit(0);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        child: Icon(
                          Icons.cancel,
                          color: HexColor('#FC4C8B'),
                          size: 35,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(flex: 3, child: SizedBox()),
                  ],
                ),
              ),
            ],
          ));
      PopUps.PopUpConWidget(context, contenidoPopUp);
      return;
    }
  }

  static void CambiarRutaMisPantallas(BuildContext context) async {
    //Navigator.popUntil(context, ModalRoute.withName("/"));
    Navigator.pop(context);
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/ventana_fondo_estatica', ModalRoute.withName("/"));
    Navigator.pushReplacementNamed(context, '/login');
    Navigator.popAndPushNamed(context, '/raspberries_conectadas');
  }

  static PopupMenuButton botonMenu(BuildContext context) {
    Widget fila(String e) {
      return Text(
        e,
        textAlign: TextAlign.left,
      );
    }

    return PopupMenuButton<String>(
      captureInheritedThemes: false,
      icon: Icon(
        Icons.menu,
        color: Colors.white,
      ),
      itemBuilder: (context) {
        return MenuAppBar.itemsMenu.map((e) {
          if (e == MenuAppBar.misPantallas) {
            return PopupMenuItem(
              value: e,
              child: fila(e),
            );
          }
          if (e == MenuAppBar.administrarImagenes) {
            return PopupMenuItem(
              value: e,
              child: fila(e),
            );
          }
          if (e == MenuAppBar.administrarVideos) {
            return PopupMenuItem(
              value: e,
              child: fila(e),
            );
          }
          if (e == MenuAppBar.soporte) {
            return PopupMenuItem(
              value: e,
              child: fila(e),
            );
          }
          if (e == MenuAppBar.miPerfil) {
            return PopupMenuItem(
              value: e,
              child: fila(e),
            );
          }
          if (e == MenuAppBar.cerrarSesion) {
            return PopupMenuItem(
              value: e,
              child: fila(e),
            );
          }
        }).toList();
      },
      onSelected: (selected) {
        MenuAppBar.SeleccionMenu(selected, context);
      },
    );
  }
}

class CustomAppBarSinMenu extends PreferredSize {
  final double height;

  CustomAppBarSinMenu({
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
                    child: Container(),
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
                    child: IconButt
      on(
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
                    activarVideo(),
                  ],
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    activarURL(widget.divisionLayout),
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

  //aca se activa y desactiva el boton url, dependiendo de la porsion seleccionada
  Widget activarURL(String divisionDellayout) {
    if (divisionDellayout == "3-2" || divisionDellayout == "3-3") {
      return FlatButton(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        onPressed: () {},
        child: Text(
          'URL',
          style: TextStyle(color: Colors.white.withOpacity(0.4)),
        ),
      );
    }
    /*
    else if (divisionDellayout == "3-3") {
      return FlatButton(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        onPressed: () {},
        child: Text(
          'URL',
          style: TextStyle(color: Colors.white.withOpacity(0.4)),
        ),
      );

     */
    else {
      return FlatButton(
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
      );
    }
  }

  //aca se activa y desactiva el boton video, dependiendo de la porsion seleccionada
  Widget activarVideo() {
    if (DatosEstaticos.divisionLayout == "3-2") {
      return FlatButton(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        onPressed: () {},
        child: Text(
          'VIDEO',
          style: TextStyle(color: Colors.white.withOpacity(0.4)),
        ),
      );
    } else if (DatosEstaticos.divisionLayout == "3-3") {
      return FlatButton(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        onPressed: () {},
        child: Text(
          'VIDEO',
          style: TextStyle(color: Colors.white.withOpacity(0.4)),
        ),
      );
    } else {
      return FlatButton(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        onPressed: () {
          //Se limpia listado estático de selección de videos
          SeleccionaVideo.videosSelecionados.clear();
          //Va a la otra ventana esperando respuesta
          navegarYEsperarRespuesta('/seleccionar_video');
          /*
          Navigator.popAndPushNamed(context, "/seleccionar_video", arguments: {
            'division_layout': DatosEstaticos.divisionLayout,
            'ruta_proveniente': ModalRoute.of(context).settings.name,
          });

           */
        },
        child: Text(
          'VIDEO',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  contenidoPopUpSeleccionUrl() async {
    GlobalKey<FormState> _keyValidador = GlobalKey<FormState>();
    await showDialog<String>(
      context: context,
      child: StatefulBuilder(builder: (context, setState) {
        return AnimacionPadding(
          child: new AlertDialog(
            contentPadding:
                const EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
            backgroundColor: Colors.grey.withOpacity(0.0),
            content: Form(
              key: _keyValidador,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: HexColor('#f4f4f4')),
                height: MediaQuery.of(context).size.height/4.5,
                width: 250,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Text("INGRESAR URL",
                              style: TextStyle(fontSize: 13)),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                radius: 15,
                                child: FlatButton(
                                  onPressed: () async {
                                    _abrirBuscador();
                                  },
                                  child: Container(
                                    transform: Matrix4.translationValues(
                                        -11.0, 0.0, 0.0),
                                    child: Icon(
                                      Icons.search,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 70,
                              width: 180,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  controller: controladorTextoUrl,
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
                              ),
                            ),

                          ],
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.check_circle,
                            color: HexColor('#3EDB9B'),
                            size: 35,
                          ),
                          onTap: () {
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
                  ],
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
    //String rutaProvenienteAEsperar = ModalRoute.of(context).settings.name;
    RutasRedireccionMenu.divisionLayoutElegido = widget.divisionLayout;
    final result = await Navigator.pushNamed(context, rutaVentana, arguments: {
      'division_layout': widget.divisionLayout,
    });
    if (result != null) {
      //Si se selecciona la imagen, esto le dice a la ventana anterior que se
      //Ejecutó. La ventana anterior, ejecuta un setstate
      widget.actualizaEstado();
    }
    RutasRedireccionMenu.divisionLayoutElegido = "";
    /*else {
      Navigator.pop(context);
      Navigator.pushNamed(context, rutaProvenienteAEsperar);
    }

     */
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
                //Envio instruccion a raspberry.
                PopUps.PopUpConWidget(context, await EsperarRespuestaProyeccion(context));
              } else {
                PopUps.PopUpConWidget(
                    context,
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: HexColor('#f4f4f4')),
                      height: 100,
                      width: 250,
                      child: Center(
                        child: Text('Error: Contenido no seleccionado',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ));
              }
            },
            child: Text(mensaje_boton, style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }



  Future<Widget> EsperarRespuestaProyeccion(BuildContext contexto) async {
    //PREPARA TODA LA INFORMACIÓN Y DEVUELVE LA INSTRUCCIÓN A ENVIAR
    // A LA RASPBERRY
    //String InstruccionEnviar = await ComunicacionRaspberry.PreparaDatosMediaEnvioEquipo();

    return FutureBuilder(
        future: ComunicacionRaspberry.PreparaDatosMediaEnvioEquipo(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done)
            if (snapshot.data != null){
              //Cierra popup de descarga
              Navigator.of(context).pop();
              return FutureBuilder(
                future: ComunicacionRaspberry.ConfigurarLayout(snapshot.data.toString()),
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

                      return Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: HexColor('#f4f4f4')),
                        height: 150,
                        width: 250,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 13),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('PROYECCIÓN FINALIZADA',
                                  style: TextStyle(fontSize: 13)),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: FlatButton(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: HexColor('#3EDB9B'),
                                    size: 35,
                                  ),
                                  onPressed: () async {
                                    //Acá se publica
                                    if (DatosEstaticos.idImagenPUblicarRRSS != "") {
                                      String resultado = await PublicarEnRedesSociales();
                                      VolverADetalleEquipo(context);
                                      DatosEstaticos.idImagenPUblicarRRSS = "";
                                      if (resultado != 'Success') {
                                        Widget contenidoPopUp = Container(
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(40),
                                                color: HexColor('#f4f4f4')),
                                            height: 100,
                                            width: 250,
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  'Error de publicación',
                                                  textAlign: TextAlign.center,
                                                  textScaleFactor: 1.3,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold),
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
                                                FlatButton(
                                                  child: Icon(
                                                    Icons.check_circle,
                                                    color: HexColor('#3EDB9B'),
                                                    size: 30,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    VolverADetalleEquipo(context);
                                                  },
                                                ),
                                              ],
                                            ));
                                        PopUps.PopUpConWidget(context, contenidoPopUp);
                                      }
                                    } else {
                                      VolverADetalleEquipo(context);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: HexColor('#f4f4f4')),
                      height: 100,
                      width: 250,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('PREPARANDO PANTALLAS', style: TextStyle(fontSize: 13)),
                          CircularProgressIndicator(
                              valueColor:
                              AlwaysStoppedAnimation<Color>(HexColor("#FC4C8B"))),
                        ],
                      ),
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: HexColor('#f4f4f4')),
                    height: 100,
                    width: 250,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('PREPARANDO PANTALLAS', style: TextStyle(fontSize: 13)),
                        CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(HexColor("#FC4C8B"))),
                      ],
                    ),
                  );
                },
              );
            }
          //Muestra el popup y un center vacío
          PopUps.popUpCargando(context, "DESCARGANDO ARCHIVOS");
          return CircularProgressIndicator();

        });


  }

  /*
  String PreparaInstruccion(){
    String instruccionPreparada = "";
    ComunicacionRaspberry.PreparaDatosMediaEnvioEquipo()
        .then((value) => {instruccionPreparada = value});
    return instruccionPreparada;
  }

   */

  Future<String> PublicarEnRedesSociales() async {
    //String nombreNuevaImagen;
    String resultado  = "";

    resultado = await FlutterSocialContentShare.share(
        type: ShareType.instagramWithImageUrl,
        imageUrl:DatosEstaticos.idImagenPUblicarRRSS);
    /*
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

     */
    return resultado;
  }

  void VolverADetalleEquipo(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.pushNamedAndRemoveUntil(
        context, '/detalle_equipo', ModalRoute.withName('/'),
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

class RutasRedireccionMenu {
  //String que marca que se está eligiendo el menú desde una selección
  //De layout activa (1-1, 2-1, 2-2...)
  static String divisionLayoutElegido = "";
  static String RutaDeDondeViene = "";
}

class EventosPropios {
  Future ObtenerSizePixelesPantalla() async {
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
      });

      await socket.done.whenComplete(() => resp = utf8.decode(_respuesta));
      //Se manipula la respuesta de datos
      Map<String, dynamic> datosRecibidos = json.decode(resp);
      DatosEstaticos.ancho_pantalla_seleccionada =
          double.parse(datosRecibidos['anchoPantalla'].toString()) * 2;
      DatosEstaticos.alto_pantalla_seleccionada =
          double.parse(datosRecibidos['altoPantalla'].toString()) * 2;
      return true;
    } catch (e) {}
  }
}

class VideoYThumbnail extends StatefulWidget {
  String urlThumbnail;
  var urlVideo;
  //BuildContext context;

  //Constructor
  VideoYThumbnail({
    @required
    this.urlThumbnail,
    this.urlVideo,
    //this.context,
  });

  @override
  _VideoYThumbnailState createState() => _VideoYThumbnailState();
}

class _VideoYThumbnailState extends State<VideoYThumbnail> {
  IconData _iconoPlayStop = Icons.play_arrow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: Image.network(widget.urlThumbnail),),
        _botonPlayPause(),
      ],
    );
  }

  //Manejo del widget del botón con clase de video de popup dentro
  Widget _botonPlayPause (){
    return Container(
      width: MediaQuery.of(context).size.width / 7,
      child: RaisedButton(
        shape: CircleBorder(),
        child: Icon(
          _iconoPlayStop,
          size: MediaQuery.of(context).size.width / 15,
        ),
        onPressed: () {
          //Acá debe salir el popup del video
          setState(() {
            _iconoPlayStop = Icons.stop;
          });
          //PopUps.popUpCargando(context, "Cargando video");
          _popUpConVideo();
        },
      ),
    );
  }


  ///Popup con el video
  void _popUpConVideo() async{

    AlertDialog alert = AlertDialog(
      content: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
        child: VideoFirebase(urlVideo: widget.urlVideo,),
      ),
    );

    //Dialog que espera a que se desaparezca el popup para cambiar flecha y
    //Popup de cargando
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    ).then((value) {
      //Al terminar el popup, cambia el ícono a "play" y cierra el popup de
      //cargando
      setState(() {
        _iconoPlayStop = Icons.play_arrow;
      });
    });
    return;
  }


}
///Clase que maneja el video desde firebase. Devuelve el popup
class VideoFirebase extends StatefulWidget {
  VideoPlayerController controladorVideo;
  String urlVideo;

  VideoFirebase({
    @required
    this.urlVideo,
  });

  @override
  _VideoFirebaseState createState() => _VideoFirebaseState();
}

class _VideoFirebaseState extends State<VideoFirebase> {
  Timer timer;
  //Futuro para saber si ya se incializó correctamente el video
  Future<void> _videoInicializado;

  @override
  void initState() {
    super.initState();
    //Controlador que se le pasa el VideoPlayer
    widget.controladorVideo = VideoPlayerController.network(widget.urlVideo);
    //Se inicializa el controlador
    _videoInicializado = widget.controladorVideo.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    widget.controladorVideo.dispose();
    timer?.cancel();
    timer = null;
  }

  @override
  Widget build(BuildContext context) {
    //Si el video está inicializado lo reproduce
    return FutureBuilder(
        future: _videoInicializado,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done)
            return _videoSiendoReproducido();
          return Center(child: CircularProgressIndicator(),);
        }
    );
  }

  //Retorna el video si ya está inicializado on popup de carga sino
  Widget _videoSiendoReproducido(){
    widget.controladorVideo.setLooping(false);
    widget.controladorVideo.play();
    //Timer para cerrar el popup automáticamente a los 5 segundos
    timer = Timer(Duration(milliseconds: 5000), (){
      Navigator.of(context, rootNavigator: true).pop();
    });
    return VideoPlayer(widget.controladorVideo);
  }



}


