import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:tvpost_flutter/icon_soporte_icons.dart';
import 'package:tvpost_flutter/icon_r_r_s_s_icons.dart';
import 'package:store_redirect/store_redirect.dart';

class Soporte extends StatefulWidget {
  Soporte({Key key}) : super(key: key);

  @override
  _SoporteState createState() => _SoporteState();
}

class _SoporteState extends State<Soporte> {
  Map datosDesdeVentanaAnterior = {};
  String rutaDeDondeViene;
  String divisionLayout;
  //Tamaño del eje x en matriz de íconos
  double ejex = 0.0;

  @override
  Widget build(BuildContext context) {
    //Tomo los argumentos que vienen de la ruta anterior
    datosDesdeVentanaAnterior = ModalRoute.of(context).settings.arguments;
    if (datosDesdeVentanaAnterior != null) {
      divisionLayout = datosDesdeVentanaAnterior['division_layout'];
      rutaDeDondeViene = datosDesdeVentanaAnterior['ruta_proveniente'];
    }

    ejex = MediaQuery.of(context).size.width/80 - 6;

    return WillPopScope(
      onWillPop: () {
        //Acá si la ruta no viene nula, se toma esa como el destino
        //Y se le pasan argumentos necesarios para ciertas ventanas
        if (rutaDeDondeViene != null) {
          Navigator.popAndPushNamed(context, rutaDeDondeViene, arguments: {
            "indexEquipoGrid": DatosEstaticos.indexSeleccionado,
            "division_layout": DatosEstaticos.divisionLayout,
          });
        } else {
          Navigator.pop(context);
        }
        return;
      },
      child: Scaffold(
        appBar: CustomAppBar(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 15),
              child: Text(
                "SOPORTE TÉCNICO",
                style: TextStyle(fontSize: 16.5),
              ),
            ),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: HexColor('#3EDB9B')),
              child: Image.asset(
                'imagenes/soporte.png',
                scale: 3,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 10,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 25),
                  child: Text("ESCRÍBENOS SOBRE TU PROBLEMA",
                      style: TextStyle(fontSize: 13)),
                ),
              ),
            ),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width/15,
                      //radius: 28,
                      backgroundColor: HexColor('#4fce5d'),
                      child: FlatButton(
                          onPressed: () {
                            wsp(phone: "+56976402129", message: 'Hola Tv Post');
                          },
                          child: Container(
                            transform:
                                Matrix4.translationValues(ejex, 0.0, 0.0),
                            child: Icon(
                              IconRRSS.whatsapp,
                              color: Colors.white,
                              size: 32,
                            ),
                          ))),
                ),
                Expanded(flex: 1, child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width/15,
                    backgroundColor: HexColor('#2e74ff'),
                    child: FlatButton(
                        onPressed: () {
                          llamada("tel:+56976402129");
                        },
                        child: Container(
                          transform: Matrix4.translationValues(ejex+1, 1.0, 0.0),
                          child: Icon(
                            IconRRSS.phone,
                            color: Colors.white,
                            size: 32,
                          ),
                        )),
                  ),
                ),
                Expanded(flex: 1, child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width/15,
                    backgroundColor: HexColor('#ff534a'),
                    child: FlatButton(
                        onPressed: () {
                          correo("mailto:producnova@gmail.com");
                        },
                        child: Container(
                          transform: Matrix4.translationValues(ejex-2, -1.0, 0.0),
                          child: Icon(
                            IconRRSS.mail_1,
                            color: Colors.white,
                            size: 32,
                          ),
                        )),
                  ),
                ),
                Expanded(flex: 3, child: SizedBox()),
              ],
            ),
            /* RaisedButton(
                onPressed: () {
                  StoreRedirect.redirect(
                      androidAppId: "com.whatsapp", iOSAppId: "	310633997");
                },
                child: Text("presione aquí"))*/
            SizedBox(
              height: 85,
            ),
            Container(
                padding: EdgeInsets.only(top: 20),
                height: MediaQuery.of(context).size.height / 5,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: 1.5,
                      color: HexColor("#3EDB9B"),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "Empresa de Diseño y Desarrollo Producnova",
                      style: TextStyle(
                        fontFamily: 'textoMont',
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "Ejercito 435, Concepción. Chile",
                      style: TextStyle(
                        fontFamily: 'textoMont',
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "www.tvpost.cl",
                      style: TextStyle(
                        fontFamily: 'textoMont',
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "contacto@tvpost.cl",
                      style: TextStyle(
                        fontFamily: 'textoMont',
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "(+569) 76402129",
                      style: TextStyle(
                        fontFamily: 'textoMont',
                        fontSize: 12,
                      ),
                    ),
                  ],
                )),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 5),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 2, child: SizedBox()),
                  Expanded(
                    flex: 2,
                    child: CircleAvatar(
                        radius: 16,
                        backgroundColor: HexColor('#3edb9b'),
                        child: FlatButton(
                            onPressed: () {
                            },
                            child: Container(
                              transform:
                                  Matrix4.translationValues(-0.0, 0.0, 0.0),
                              child: Icon(
                                IconRRSS.globe,
                                color: Colors.white,
                                size: 18,
                              ),
                            ))),
                  ),
                  Expanded(
                    flex: 2,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: HexColor('#0077b5'),
                      child: FlatButton(
                          onPressed: () {
                          },
                          child: Container(
                            transform: Matrix4.translationValues(0.5, 0.0, 0.0),
                            child: Icon(
                              IconRRSS.linkedin_in,
                              color: Colors.white,
                              size: 18,
                            ),
                          )),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: HexColor('#dd2a7b'),
                      child: FlatButton(
                          onPressed: () {
                          },
                          child: Container(
                            transform:
                                Matrix4.translationValues(-0.0, 0.0, 0.0),
                            child: Icon(
                              IconRRSS.instagram,
                              color: Colors.white,
                              size: 18,
                            ),
                          )),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: HexColor('#1778f2'),
                      child: FlatButton(
                          onPressed: () {
                          },
                          child: Container(
                            transform:
                                Matrix4.translationValues(-0.0, 0.0, 0.0),
                            child: Icon(
                              IconRRSS.facebook_f,
                              color: Colors.white,
                              size: 20,
                            ),
                          )),
                    ),
                  ),
                  Expanded(flex: 2, child: SizedBox()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void wsp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      StoreRedirect.redirect(
          androidAppId: "com.whatsapp",
          iOSAppId: "	310633997"); //'WSP INVALIDO ${url()}';
    }
  }

  Future<void> llamada(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'NÚMERO INVALIDO $url';
    }
  }

  Future<void> correo(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'CORREO INVALIDO $url';
    }
  }
}
