import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SeleccionarImagen extends StatefulWidget {
  @override
  _SeleccionarImagenState createState() => _SeleccionarImagenState();
}

class _SeleccionarImagenState extends State<SeleccionarImagen> {
  //Datos que se envía completo desde la ventana de selección de media
  Map datosDesdeVentanaAnterior = {};
  String divisionLayout;
  Future<List<dynamic>> _listadoNombresImagenes;
  int itemsVisiblesGrid = 0;
  FilePickerResult imagenSeleccionadaGaleria;
  TextEditingController _controladorTexto = TextEditingController();

  @override
  void initState() {
    super.initState();
    //Acá se hace el llamado al listado de nombres de imágenes
    _listadoNombresImagenes = PopUps.getNombresImagenes();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controladorTexto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    datosDesdeVentanaAnterior = ModalRoute.of(context).settings.arguments;
    if (datosDesdeVentanaAnterior != null) {
      divisionLayout = datosDesdeVentanaAnterior['division_layout'];
    }

    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(width: 5, color: Colors.green),
              )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Seleccione una imagen',
                          textScaleFactor: 1.3,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton(
                            child: Icon(Icons.add),
                            heroTag: null,
                            onPressed: () {
                              abrirGaleria(context);
                            }),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              //Acá hacer un future builder para nombres de imágenes
              child: FutureBuilder(
                future: _listadoNombresImagenes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == null) {
                      return Center(
                        child: Text(
                          'Error de conexión',
                          textScaleFactor: 1.3,
                        ),
                      );
                    } else {
                      if (snapshot.data[0] == "") {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'imagenes/arrow.png',
                              width: MediaQuery.of(context).size.width / 1.5,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Text(
                                "Presione el ícono para agregar imágenes",
                                textScaleFactor: 1.3,
                              ),
                            ),
                          ],
                        );
                      }

                      //Future Builder para el gridview de imágenes
                      return GridView.builder(
                          //Toma el total de imágenes desde la carpeta del
                          // webserver
                          itemCount:
                              DatosEstaticos.listadoNombresImagenes.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
                          itemBuilder: (context, index) {
                            //Por cada imagen, busca su imagen.
                            // El nombre lo toma del listado estático
                            return GestureDetector(
                              onTap: () {
                                Fluttertoast.showToast(
                                  msg:
                                      "Presione dos veces para seleccionar imagen",
                                  toastLength: Toast.LENGTH_LONG,
                                  webBgColor: "#e74c3c",
                                  timeInSecForIosWeb: 10,
                                );
                              },
                              onDoubleTap: () {
                                Widget imagen = Image.network('http://'
                                    '${DatosEstaticos.ipSeleccionada}'
                                    '/ImagenesPostTv/'
                                    '${DatosEstaticos.listadoNombresImagenes[index]}');
                                String nombre = DatosEstaticos
                                    .listadoNombresImagenes[index];
                                RedireccionarCrearLayout(
                                    imagen,
                                    "/var/www/html/ImagenesPostTv/$nombre",
                                    false);
                                return;
                              },
                              child: Image.network('http://'
                                  '${DatosEstaticos.ipSeleccionada}'
                                  '/ImagenesPostTv/'
                                  '${DatosEstaticos.listadoNombresImagenes[index]}'),
                            );
                          });
                    }
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  abrirGaleria(BuildContext context) async {
    GlobalKey<FormState> _keyValidador = GlobalKey<FormState>();
    String nombreNuevaImagen = "";
    //Se toma el archivo desde FilePicker
    imagenSeleccionadaGaleria =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (imagenSeleccionadaGaleria != null) {
      //Acá tomo la extensión para saber si es png o jpg
      String extension = p.extension(imagenSeleccionadaGaleria.paths[0]);
      //Acá obtengo el archivo desde la  ruta
      File imagenFinal = File(imagenSeleccionadaGaleria.paths[0]);
      await showDialog<String>(
        context: context,
        child: AnimacionPadding(
          child: new AlertDialog(
            content: SingleChildScrollView(
              child: Card(
                child: Form(
                  key: _keyValidador,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.file(
                        imagenFinal,
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 4,
                      ),
                      Center(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: _controladorTexto,
                          validator: (textoEscrito) {
                            if (textoEscrito.isEmpty) {
                              return "Error: Nombre de imagen vacío";
                            }
                            if (textoEscrito.trim().length <= 0) {
                              return "Error: Nombre de imagen vacío";
                            } else {
                              nombreNuevaImagen =
                                  textoEscrito.trim().toString() + extension;
                              //Chequear si el valor ya existe
                              if (DatosEstaticos.listadoNombresImagenes
                                  .contains(nombreNuevaImagen)) {
                                return "Error: Nombre de imagen ya existe";
                              } else {
                                return null;
                              }
                            }
                          },
                        ),
                      ),
                      RaisedButton(
                        child: Text('Añadir'),
                        autofocus: true,
                        onPressed: () async {
                          if (_keyValidador.currentState.validate()) {
                            //Se abre el popup de cargando
                            PopUps.popUpCargando(
                                context, 'Añadiendo imagen...');
                            //Obtengo el resultado del envio
                            var resultado = await PopUps.enviarImagen(
                                    nombreNuevaImagen, imagenFinal)
                                .then((value) => value);

                            if (resultado) {
                              //Si el envío es correcto, se redirecciona
                              Image imagen = Image.file(
                                imagenFinal,
                              );
                              RedireccionarCrearLayout(
                                  imagen,
                                  "/var/www/html/ImagenesPostTv/$nombreNuevaImagen",
                                  true);
                            } else {
                              //Cierra popup cargando
                              Navigator.of(context, rootNavigator: true).pop();

                              PopUps.PopUpConWidget(
                                  context, Text('Error al enviar imagen'));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

/*  static Future<bool> enviarImagen(String nombre, File imagen) async{
    String imabenBytes = base64Encode(imagen.readAsBytesSync());
    bool resultado = await http.post(DatosEstaticos.rutaSubidaImagenes, body: {
      "image": imabenBytes,
      "name": nombre,
    }).then((result) {
      //print("Resultado: " + result.statusCode.toString());
      if (result.statusCode == 200) {return true;}
    }).catchError((error) {
      return false;
    });
    return resultado;
  }*/

  // ignore: non_constant_identifier_names
  void RedireccionarCrearLayout(
      Widget imagen, String nombre, bool vieneDePopUp) {
    if (vieneDePopUp) {
      //Cierra popup cargando
      Navigator.of(context, rootNavigator: true).pop();
      //Cierra popup imagen
      Navigator.of(context, rootNavigator: true).pop();
    }

    DatosEstaticos.webViewControllerWidget1 = null;
    DatosEstaticos.webViewControllerWidget2 = null;
    DatosEstaticos.webViewControllerWidget3 = null;

    //Se asigna además que porcion del layout se reemplazará
    switch (divisionLayout) {
      case '1-1':
        {
          DatosEstaticos.widget1 = imagen;
          DatosEstaticos.nombreArchivoWidget1 = nombre;
          DatosEstaticos.reemplazarPorcion1 = true;
          Navigator.pop(context, true);
        }
        break;
      case '2-1':
        {
          DatosEstaticos.widget1 = imagen;
          DatosEstaticos.nombreArchivoWidget1 = nombre;
          DatosEstaticos.reemplazarPorcion1 = true;
          Navigator.pop(context, true);
        }
        break;
      case '2-2':
        {
          DatosEstaticos.widget2 = imagen;
          DatosEstaticos.nombreArchivoWidget2 = nombre;
          DatosEstaticos.reemplazarPorcion2 = true;
          Navigator.pop(context, true);
        }
        break;
      case '3-1':
        {
          DatosEstaticos.widget1 = imagen;
          DatosEstaticos.nombreArchivoWidget1 = nombre;
          DatosEstaticos.reemplazarPorcion1 = true;
          Navigator.pop(context, true);
        }
        break;
      case '3-2':
        {
          DatosEstaticos.widget2 = imagen;
          DatosEstaticos.nombreArchivoWidget2 = nombre;
          DatosEstaticos.reemplazarPorcion2 = true;
          Navigator.pop(context, true);
        }
        break;
      case '3-3':
        {
          DatosEstaticos.widget3 = imagen;
          DatosEstaticos.nombreArchivoWidget3 = nombre;
          DatosEstaticos.reemplazarPorcion3 = true;
          Navigator.pop(context, true);
          /*Navigator.popAndPushNamed(context,
            '/crear_layout3');*/
        }
        break;
    }
  }
}
