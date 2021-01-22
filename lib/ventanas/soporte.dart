import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:tvpost_flutter/icon_soporte_icons.dart';
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

  @override
  Widget build(BuildContext context) {
    //Tomo los argumentos que vienen de la ruta anterior
    datosDesdeVentanaAnterior = ModalRoute.of(context).settings.arguments;
    if (datosDesdeVentanaAnterior != null) {
      divisionLayout = datosDesdeVentanaAnterior['division_layout'];
      rutaDeDondeViene = datosDesdeVentanaAnterior['ruta_proveniente'];
    }
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
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
              //color: Colors.greenAccent,
              //decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),),
            ),
            SizedBox(
              height: 10,
            ),
            Text("CONTÁCTANOS", style: TextStyle(fontSize: 13)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    width: 70,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.greenAccent,
                    ),
                    //color: Colors.greenAccent,
                    child: FlatButton(
                        onPressed: () {
                          wsp(phone: "+56933710386", message: 'Hola Tv Post');
                        },
                        child: Container(
                          color: Colors.amber,
                          child: Icon(
                            IconSoporte.whatsapp,
                            color: Colors.black,
                          ),
                        ))),
                Container(
                  width: 70,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.greenAccent,
                  ),
                  //color: Colors.greenAccent,
                  child: FlatButton(
                      onPressed: () {
                        llamada("tel:+56933710386");
                      },
                      child: Icon(Icons.phone_android)),
                ),
                Container(
                  width: 70,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.greenAccent,
                  ),
                  //color: Colors.greenAccent,
                  child: FlatButton(
                      onPressed: () {
                        correo("mailto:d.saezzcc@gmail.com");
                      },
                      child: Icon(Icons.mail_outline)),
                ),
              ],
            ),
            /* RaisedButton(
                onPressed: () {
                  StoreRedirect.redirect(
                      androidAppId: "com.whatsapp", iOSAppId: "	310633997");
                },
                child: Text("presione aquí"))*/
            SizedBox(
              height: 110,
            ),
            Container(
                padding: EdgeInsets.only(top: 25),
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
                      "(+569) 87654321",
                      style: TextStyle(
                        fontFamily: 'textoMont',
                        fontSize: 12,
                      ),
                    ),
                  ],
                )),
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
          iOSAppId: "	310633997"
      ); //'WSP INVALIDO ${url()}';
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
