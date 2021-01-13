import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:flutter/material.dart';

class Perfil extends StatefulWidget {
  Perfil({Key key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  File archivoImagen;
  Color fondo = Colors.green;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        height: MediaQuery.of(context).size.height / 1.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(),
            Text("MI PERFIL", style: TextStyle(fontSize: 16.5)),
            SizedBox(),
            Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: Colors.greenAccent),
                child: FlatButton(
                  onPressed: () {
                    _cargarImagen(context);
                  },
                  child: Container(
                      width: 105,
                      height: 105,
                      decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: archivoImagen == null
                          ? Image.asset(
                              'imagenes/logohorizontal.png',
                              fit: BoxFit.fill,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.file(
                                archivoImagen,
                              ),
                            )),
                )),
            SizedBox(
              height: 1,
            ),
            Container(
                child: Column(
              children: [
                Text("EMPRESA PRODUCNOVA", style: TextStyle(fontSize: 13)),
                SizedBox(
                  height: 10,
                ),
                Text("98.765.432", style: TextStyle(fontSize: 13)),
              ],
            )),
            Container(
              width: MediaQuery.of(context).size.width / 1.3,
              height: 1.5,
              color: Colors.greenAccent,
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              height: MediaQuery.of(context).size.height / 8,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(children: [
                    Row(
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 4,
                              ),
                              Text('EMAIL', style: TextStyle(fontSize: 13)),
                              SizedBox(
                                height: 10,
                              ),
                              Text('FONO', style: TextStyle(fontSize: 13)),
                              SizedBox(
                                height: 10,
                              ),
                              Text('WEB', style: TextStyle(fontSize: 13)),
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                '  : ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                '  : ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                '  : ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ]),
                      ],
                    )
                  ]),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /*Text(
                              DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                                      ['f_alias']
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'textoMont',
                                fontSize: 12,
                              ),
                            ),*/
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        "contacto@productnova.cl",
                        style: TextStyle(
                          fontFamily: 'textoMont',
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 9,
                      ),
                      /*Text(
                              DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                                      ['f_serial']
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'textoMont',
                                fontSize: 12,
                              ),
                            ),*/
                      Text("(987) 987654321",
                          style: TextStyle(
                            fontFamily: 'textoMont',
                            fontSize: 12,
                          )),
                      SizedBox(
                        height: 8,
                      ),
                      /*Text(
                              DatosEstaticos.listadoDatosEquipoSeleccionado[0]
                                  ['f_ip'],
                              style: TextStyle(
                                fontFamily: 'textoMont',
                                fontSize: 12,
                              ),
                            ),*/
                      Text("www.producnova.cl",
                          style: TextStyle(
                            fontFamily: 'textoMont',
                            fontSize: 12,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _abrirCamara(BuildContext context) async {
    var imagen = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      archivoImagen = imagen;
    });

    Navigator.of(context).pop();
  }

  _abrirGaleria(BuildContext context) async {
    var imagen = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      archivoImagen = imagen;
    });
    Navigator.of(context).pop();
  }

  Future<void> _cargarImagen(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
          backgroundColor: Colors.grey.withOpacity(0.0),
          content: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: HexColor('#f4f4f4')),
            height: 150,
            width: 250,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Text("CARGAR IMÁGENES "),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Icon(Icons.camera_alt,
                          size: 40, color: HexColor('#3EDB9B')),
                      onTap: () {
                        _abrirCamara(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Icon(Icons.photo_album,
                          size: 40, color: HexColor('#FC4C8B')),
                      onTap: () {
                        _abrirGaleria(context);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                      child: Text(
                        "CAMARA",
                        style: TextStyle(fontSize: 10),
                      ),
                      onTap: () {
                        _abrirCamara(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text(
                        "GALERÍA",
                        style: TextStyle(fontSize: 10),
                      ),
                      onTap: () {
                        _abrirGaleria(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}