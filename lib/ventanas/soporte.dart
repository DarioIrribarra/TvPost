import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class Soporte extends StatefulWidget {
  Soporte({Key key}) : super(key: key);

  @override
  _SoporteState createState() => _SoporteState();
}

class _SoporteState extends State<Soporte> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "SOPORTE TÉCNICO",
            style: TextStyle(fontSize: 16.5),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
            ),
            child: Image.asset('imagenes/soporte.png'),
            //color: Colors.greenAccent,
            //decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200]),
                width: MediaQuery.of(context).size.width / 1.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(),
                    Icon(
                      Icons.sentiment_very_satisfied,
                      color: Colors.grey,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: HexColor("#3EDB9B"),
                    ),
                    Text(
                      "Escríbe un mensaje...",
                      style: TextStyle(
                        fontFamily: 'textoMont',
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.attach_file_outlined,
                      color: Colors.grey,
                    ),
                    Icon(
                      Icons.add_a_photo_sharp,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                        color: Colors.greenAccent,
                      ),
                      child: FlatButton(
                          padding: EdgeInsets.only(right: 3),
                          onPressed: () {},
                          child: Icon(
                            Icons.attach_money,
                            color: Colors.white,
                          )),
                    )
                  ],
                )),
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
                        wsp(
                            phone: "+56933710386",
                            message: 'Hola, solicito ayuda!!!');
                      },
                      child: Icon(Icons.phone))),
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
          SizedBox(
            height: 20,
          ),
          Container(
              padding: EdgeInsets.only(top: 20),
              height: MediaQuery.of(context).size.height / 7,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
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
      throw 'WSP INVALIDO ${url()}';
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
