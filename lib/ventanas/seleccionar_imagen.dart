import 'dart:async';
//import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:tvpost_flutter/tvlapiz_icons.dart';
//import 'package:flutter_social_content_share/flutter_social_content_share.dart';
import 'package:tvpost_flutter/utilidades/comunicacion_raspberry.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tvpost_flutter/ventanas/soporte.dart';

class SeleccionarImagen extends StatefulWidget {
  @override
  _SeleccionarImagenState createState() => _SeleccionarImagenState();
}

class _SeleccionarImagenState extends State<SeleccionarImagen> {
  //ACA VAN LOS DATOS DE FIREBASE PARA MOSTRAR FILES
  List<Posts> postList = List();
  final fb = FirebaseDatabase.instance.reference().child("Imagenes");
  //ACA VAN LOS DATOS DE FIREBASE PARA SUBIR IMAGENES
  String rutdeEmpresa = DatosEstaticos.rutEmpresa;
  File sampleImage; // imagen
  String _myValue; // descripcion
  String url; // url de la imagen
  final formKey = GlobalKey<FormState>();
  //Datos que se envía completo desde la ventana de selección de media
  Map datosDesdeVentanaAnterior = {};
  String divisionLayout;
  String rutaDeDondeViene;
  Future<List<dynamic>> _listadoNombresImagenes;
  int itemsVisiblesGrid = 0;
  FilePickerResult imagenSeleccionadaGaleria;
  TextEditingController _controladorTexto = TextEditingController();
  List<String> imagenesSeleccionadas = [];
  bool activarBoton = false;
  //bool _visible = false;
  Container cargaRRSS = Container(
    height: 200,
  );

  @override
  void initState() {
    super.initState();
    //Acá se hace el llamado al listado de nombres de imágenes
    _listadoNombresImagenes = PopUps.getNombresImagenes();
    //DatosEstaticos.PublicarEnRedesSociales = false;
    activarBoton = true;
    fb.once().then((DataSnapshot snap) {
      var data = snap.value;
      postList.clear();
      data.forEach((key, value) {
        Posts posts = Posts(image: value['image'], nombre: value['nombre']);
        if (posts.image.contains(rutdeEmpresa)) {
          postList.add(posts);
        }
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controladorTexto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Se le da el context a la ventana para los popups
    CambiosSeleccion.context = context;
    datosDesdeVentanaAnterior = ModalRoute.of(context).settings.arguments;
    if (datosDesdeVentanaAnterior != null) {
      divisionLayout = datosDesdeVentanaAnterior['division_layout'];
      rutaDeDondeViene = datosDesdeVentanaAnterior['ruta_proveniente'];
    }

    Widget widgetFutureGrilla;

    if (rutaDeDondeViene != null) {
      CambiosSeleccion.rutaPadre = rutaDeDondeViene;
      widgetFutureGrilla = FutureBuilder(
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Text(
                        "Presione el ícono para agregar imágenes",
                        textScaleFactor: 1.3,
                      ),
                    ),
                  ],
                );
              }

              //Future Builder para el gridview de imágenes
              return Column(
                children: [
                  Expanded(
                    child: postList.length == 0
                        ? Text("CARGUE IMAGENES PARA VISUALIZARLAS")
                        : GridView.builder(
                            itemCount: postList.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5),
                            itemBuilder: (context, index) {
                              return postsUI(postList[index].image,
                                  postList[index].nombre);
                              /* postList[index].date,
                        postList[index].time);*/
                            },
                          ),

                    /* ListView.builder(
                      itemCount: postList.length,
                      itemBuilder: (_, index) {
                        return postsUI(
                            postList[index].image, postList[index].nombre);
                        /* postList[index].date,
                        postList[index].time);*/
                      },
                    ),*/

                    /*GridView.builder(
                        //Toma el total de imágenes desde la carpeta del
                        // webserver
                        itemCount: DatosEstaticos.listadoNombresImagenes.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5),
                        itemBuilder: (context, index) {
                          //Por cada imagen, busca su imagen.
                          // El nombre lo toma del listado estático
                          String nombre = DatosEstaticos
                              .listadoNombresImagenes[index]
                              .toString();
                          //BoxDecoration borderSelec;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (imagenesSeleccionadas.contains(nombre) ==
                                    false) {
                                  imagenesSeleccionadas.add(nombre);
                                } else {
                                  imagenesSeleccionadas.remove(nombre);
                                }
                                CambiosSeleccion.listadoSeleccionadas =
                                    imagenesSeleccionadas;
                                //print(imagenesSeleccionadas);
                              });
                            },
                            //Container de cada imagen
                            child: Opacity(
                              opacity: resultado(nombre),
                              /* imagenesSeleccionadas.contains(nombre)
                                  ? 1.0
                                  : 0.1,*/
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    //Si se encuentra en el listado de seleccionadas se cambia el borde
                                    /*decoration:
                                        imagenesSeleccionadas.contains(nombre)
                                            ? CambiosSeleccion.bordeSeleccionado
                                            : null,*/
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Image.network(
                                            'http://'
                                            '${DatosEstaticos.ipSeleccionada}'
                                            '/ImagenesPostTv/'
                                            '${DatosEstaticos.listadoNombresImagenes[index]}',
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 3),
                                            child: Text(
                                              nombre.substring(
                                                  0, nombre.lastIndexOf('.')),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'textoMont',
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 30,
                                    right: 10,
                                    //Se aplica el ícono verde al seleccionar
                                    child:
                                        imagenesSeleccionadas.contains(nombre)
                                            ? CambiosSeleccion.iconoSeleccionado
                                            : Container(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),*/
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        //Si la lista tiene algún seleccionado se cambia el botón
                        child: imagenesSeleccionadas.length == 1
                            ? CambiosSeleccion.btnEditarHabilitado
                            : CambiosSeleccion.btnEditarDeshabilitado,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        //Si la lista tiene algún seleccionado se cambia el botón
                        child: imagenesSeleccionadas.length > 0
                            ? CambiosSeleccion.btnEliminarHabilitado
                            : CambiosSeleccion.btnEliminarDeshabilitado,
                      ),
                    ],
                  ),
                ],
              );
            }
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(HexColor("#FC4C8B")),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(HexColor("#FC4C8B")),
              ),
            );
          }
        },
      );
    } else {
      widgetFutureGrilla = FutureBuilder(
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Presione el ícono para agregar imágenes",
                      textScaleFactor: 1.3,
                    ),
                  ],
                );
              }

              //Future Builder para el gridview de imágenes
              return Column(children: [
                Expanded(
                  child:
                      /*ListView.builder(
                    itemCount: postList.length,
                    itemBuilder: (_, index) {
                      return postsUI(
                          postList[index].image, postList[index].nombre);
                      /* postList[index].date,
                        postList[index].time);*/
                    },
                  ),*/

                      postList.length == 0
                          ? Text("CARGUE IMAGENES PARA VISUALIZARLAS")
                          : GridView.builder(
                              itemCount: postList.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5),
                              itemBuilder: (_, index) {
                                return postsUI(postList[index].image,
                                    postList[index].nombre);
                                /* postList[index].date,
                        postList[index].time);*/
                              },
                            ),

                  /*GridView.builder(
                      //Toma el total de imágenes desde la carpeta del
                      // webserver
                      itemCount: DatosEstaticos.listadoNombresImagenes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5),
                      itemBuilder: (context, index) {
                        //Por cada imagen, busca su imagen.
                        // El nombre lo toma del listado estático
                        // El nombre lo toma del listado estático
                        String nombre = DatosEstaticos
                            .listadoNombresImagenes[index]
                            .toString();
                        return GestureDetector(
                          onTap: () {
                            /*Fluttertoast.showToast(
                              msg: "Presione dos veces para seleccionar imagen",
                              toastLength: Toast.LENGTH_LONG,
                              webBgColor: "#e74c3c",
                              timeInSecForIosWeb: 10,
                            );*/

                            //Hice la selección antes de la creación del container
                            //ahora si la lista ya tiene un item se borra entera
                            //y luego se agrega la nueva imagen seleccionada

                            if (imagenesSeleccionadas.length >= 1) {
                              if (imagenesSeleccionadas.contains(nombre)) {
                                imagenesSeleccionadas.remove(nombre);
                              } else {
                                imagenesSeleccionadas.clear();
                                imagenesSeleccionadas.add(nombre);
                              }
                            } else {
                              imagenesSeleccionadas.add(nombre);
                            }
                            /*try {
                              print(imagenesSeleccionadas[0]);
                            } catch(ex){
                              print("lista vacía: último item clicado $nombre");
                            }*/

                            /*cargaRRSS = imagenesSeleccionadas.isEmpty ||
                                    imagenesSeleccionadas.length > 1*/

                            //Cambié este condicional
                            cargaRRSS = imagenesSeleccionadas.length == 1
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 4,
                                    //color: Colors.pink,
                                    child: Column(
                                      children: [
                                        SizedBox(height: 38),
                                        Container(
                                          height: 40,
                                          width: 200,
                                          decoration: new BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                  colors: [
                                                    HexColor("#0683ff"),
                                                    HexColor("#3edb9b")
                                                  ],
                                                  stops: [
                                                    0.1,
                                                    0.6
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: FractionalOffset
                                                      .bottomRight)),
                                          child: FlatButton(
                                            color: Colors.transparent,
                                            onPressed: () async {
                                              //String dir = (await getTemporaryDirectory()).path;
                                              //File temporal = new File('$dir/img_temp_creada.png');
                                              //Se desactiva la publicación en redes sociales
                                              DatosEstaticos
                                                      .PublicarEnRedesSociales =
                                                  false;
                                              Widget imagen = Image.network(
                                                  'http://'
                                                  '${DatosEstaticos.ipSeleccionada}'
                                                  '/ImagenesPostTv/'
                                                  '${DatosEstaticos.listadoNombresImagenes[index]}');
                                              String nombre = DatosEstaticos
                                                      .listadoNombresImagenes[
                                                  index];
                                              RedireccionarCrearLayout(
                                                  imagen,
                                                  "/var/www/html/ImagenesPostTv/$nombre",
                                                  false);
                                              return;
                                            },
                                            child: Text(
                                              'CARGAR',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Container(
                                          height: 40,
                                          width: 200,
                                          decoration: new BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                  colors: [
                                                    HexColor("#3edb9b"),
                                                    HexColor("#0683ff")
                                                  ],
                                                  stops: [
                                                    0.5,
                                                    1
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: FractionalOffset
                                                      .bottomRight)),
                                          child: FlatButton(
                                            color: Colors.transparent,
                                            onPressed: () async {
                                              /*await FlutterSocialContentShare
                                                  .share(
                                                      type: ShareType
                                                          .instagramWithImageUrl,
                                                      imageUrl: 'http://'
                                                          '${DatosEstaticos.ipSeleccionada}'
                                                          '/ImagenesPostTv/'
                                                          '${DatosEstaticos.listadoNombresImagenes[index]}');*/
                                              //Valor que activa la publicación en redes sociales
                                              //Este valor se desactiva luego de proyectar en tv
                                              DatosEstaticos
                                                      .PublicarEnRedesSociales =
                                                  true;
                                              Widget imagen = Image.network(
                                                  'http://'
                                                  '${DatosEstaticos.ipSeleccionada}'
                                                  '/ImagenesPostTv/'
                                                  '${DatosEstaticos.listadoNombresImagenes[index]}');
                                              String nombre = DatosEstaticos
                                                      .listadoNombresImagenes[
                                                  index];
                                              RedireccionarCrearLayout(
                                                  imagen,
                                                  "/var/www/html/ImagenesPostTv/$nombre",
                                                  false);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Column(children: [
                                                Text(
                                                  'CARGAR +',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  ' COMPARTIR RRSS',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 4,
                                  );

                            /*setState(() {
                              if (imagenesSeleccionadas.contains(nombre) ==
                                      false &&
                                  imagenesSeleccionadas.length < 1) {
                                imagenesSeleccionadas.add(nombre);
                              } else {
                                imagenesSeleccionadas.remove(nombre);
                              }

                              CambiosSeleccion.listadoSeleccionadas =
                                  imagenesSeleccionadas;
                            });*/

                            setState(() {
                              CambiosSeleccion.listadoSeleccionadas =
                                  imagenesSeleccionadas;

                              /*if (imagenesSeleccionadas.contains(nombre) ==
                                  false) {
                                imagenesSeleccionadas.add(nombre);
                              } else {
                                imagenesSeleccionadas.remove(nombre);
                              }*/
                            });
                          },
                          //se comenta lo anterior, donde se hacia doble tap para agregar una imagen
                          /*onDoubleTap: () {
                            Widget imagen = Image.network('http://'
                                '${DatosEstaticos.ipSeleccionada}'
                                '/ImagenesPostTv/'
                                '${DatosEstaticos.listadoNombresImagenes[index]}');
                            String nombre =
                                DatosEstaticos.listadoNombresImagenes[index];
                            RedireccionarCrearLayout(imagen,
                                "/var/www/html/ImagenesPostTv/$nombre", false);
                            return;
                          },
                          child: Image.network('http://'
                              '${DatosEstaticos.ipSeleccionada}'
                              '/ImagenesPostTv/'
                              '${DatosEstaticos.listadoNombresImagenes[index]}'),*/
                          //Container de cada imagen
                          child: Opacity(
                            opacity: resultado(nombre),
                            /* imagenesSeleccionadas.contains(nombre)
                                      ? 1.0
                                      : 0.1,*/
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  //Si se encuentra en el listado de seleccionadas se cambia el borde
                                  //aca se encuentra el borde de las imagenes seleccionadas
                                  /*decoration: imagenesSeleccionadas.contains(nombre)
                                      ? CambiosSeleccion.bordeSeleccionado
                                      : null,*/
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Image.network(
                                          'http://'
                                          '${DatosEstaticos.ipSeleccionada}'
                                          '/ImagenesPostTv/'
                                          '${DatosEstaticos.listadoNombresImagenes[index]}',
                                          fit: BoxFit.scaleDown,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 3),
                                          child: Text(
                                            nombre.substring(
                                                0, nombre.lastIndexOf('.')),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'textoMont',
                                                fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 30,
                                  right: 10,
                                  //Se aplica el ícono verde al seleccionar
                                  child: imagenesSeleccionadas.contains(nombre)
                                      ? CambiosSeleccion.iconoSeleccionado
                                      : Container(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),*/
                ),
                cargaRRSS
              ]);
            }
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(HexColor("#FC4C8B")),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(HexColor("#FC4C8B")),
              ),
            );
          }
        },
      );
    }

    return WillPopScope(
      onWillPop: () {
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
        //Por error del future, se debe dejar sin acceso al menmú para que no redireccione
        //a "Mis Pantallas"
        appBar: divisionLayout == '0' ? CustomAppBar() : CustomAppBarSinMenu(),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'SELECCIONE IMAGEN',
                            textScaleFactor: 1.3,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 30,
                            width: 30,
                            transform:
                                Matrix4.translationValues(-22.0, -2.0, 22.0),
                            child: FloatingActionButton(
                                mini: true,
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                                heroTag: null,
                                backgroundColor: HexColor('#FC4C8B'),
                                onPressed: () {
                                  //abrirGaleria(context);
                                  getImage();
                                }),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                //Acá hacer un future builder para nombres de imágenes
                child: widgetFutureGrilla,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double resultado(String nombre) {
    if (imagenesSeleccionadas.length > 0) {
      if (imagenesSeleccionadas.contains(nombre) != true) {
        return 0.1;
      } else {
        return 1.0;
      }
    } else {
      return 1.0;
    }
  }

  refresh() {
    setState(() {});
  }

  abrirGaleria(BuildContext context) async {
    GlobalKey<FormState> _keyValidador = GlobalKey<FormState>();
    if (rutaDeDondeViene != null) {
      //Se toman multiples archivos desde FilePicker
      imagenSeleccionadaGaleria = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);
    } else {
      //Se toma el archivo desde FilePicker
      imagenSeleccionadaGaleria =
          await FilePicker.platform.pickFiles(type: FileType.image);
    }
    if (imagenSeleccionadaGaleria != null) {
      if (imagenSeleccionadaGaleria.files.length == 1) {
        String nombreNuevaImagen = "";
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
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                radius: 10,
                                child: FlatButton(
                                  onPressed: () async {},
                                  child: Container(
                                    transform: Matrix4.translationValues(
                                        -16.0, 0.0, 0.0),
                                    child: Icon(
                                      Tvlapiz.lapiz,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    labelText: 'INGRESE NOMBRE DE LA IMAGEN',
                                    labelStyle: TextStyle(fontSize: 12)),
                                controller: _controladorTexto,
                                validator: (textoEscrito) {
                                  if (textoEscrito.isEmpty) {
                                    return "Error: Nombre de imagen vacío";
                                  }
                                  if (textoEscrito.trim().length <= 0) {
                                    return "Error: Nombre de imagen vacío";
                                  } else {
                                    nombreNuevaImagen =
                                        textoEscrito.trim().toString() +
                                            extension;
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
                          ],
                        ),
                        FlatButton(
                          child: Icon(
                            Icons.check_circle,
                            color: HexColor('#3EDB9B'),
                            size: 35,
                          ),
                          autofocus: true,
                          onPressed: () async {
                            if (_keyValidador.currentState.validate()) {
                              //Se abre el popup de cargando
                              Navigator.pop(context);
                              PopUps.popUpCargando(
                                  context, 'Añadiendo imagen'.toUpperCase());
                              //Obtengo el resultado del envio
                              var resultado = await PopUps.enviarImagen(
                                      nombreNuevaImagen, imagenFinal)
                                  .then((value) => value);

                              if (resultado) {
                                //Replica la imagen para porción 10%
                                await ComunicacionRaspberry.ReplicarImagen(
                                    nombreNuevaImagen);

                                if (rutaDeDondeViene != null) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.popAndPushNamed(
                                      context, "/seleccionar_imagen",
                                      arguments: {
                                        'division_layout': '0',
                                        'ruta_proveniente': rutaDeDondeViene,
                                      });
                                } else {
                                  //Si no es del menú redirige al layout
                                  //Si el envío es correcto, se redirecciona
                                  Image imagen = Image.file(
                                    imagenFinal,
                                  );
                                  RedireccionarCrearLayout(
                                      imagen,
                                      "/var/www/html/ImagenesPostTv/$nombreNuevaImagen",
                                      true);
                                }
                              } else {
                                //Cierra popup cargando
                                Navigator.of(context, rootNavigator: true)
                                    .pop();

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
      } else {
        String nombreNuevaImagen = "";
        String extension;
        File imagenFinal;
        Widget contenidoPopUp = Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: HexColor('#f4f4f4')),
          height: 150,
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '¿Agregar ${imagenSeleccionadaGaleria.files.length} imagenes?'
                    .toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              Row(
                children: [
                  Expanded(flex: 3, child: SizedBox()),
                  Expanded(
                    flex: 4,
                    child: FlatButton(
                      child: Icon(
                        Icons.check_circle,
                        color: HexColor('#3EDB9B'),
                        size: 35,
                      ),
                      onPressed: () async {
                        PopUps.popUpCargando(
                            context, 'Agregando imagenes'.toUpperCase());

                        for (int i = 0;
                            i <= imagenSeleccionadaGaleria.files.length - 1;
                            i++) {
                          PlatformFile element =
                              imagenSeleccionadaGaleria.files[i];
                          extension = p.extension(element.path);
                          imagenFinal = File(element.path);
                          //Se le da el nombre de la hora actual + su posición
                          // //en el listado
                          DateTime now = DateTime.now();
                          nombreNuevaImagen =
                              '${now.year}${now.month}${now.day}'
                              '${now.hour}${now.minute}${now.second}'
                              '_$i$extension';

                          //Obtengo el resultado del envio
                          var resultado = await PopUps.enviarImagen(
                                  nombreNuevaImagen, imagenFinal)
                              .then((value) => value);
                          if (resultado == false) {
                            showDialog(
                              context: null,
                              child: Text('Error al agregar imágenes'),
                            );
                            break;
                          }
                          //Replica imagen para porción 10%
                          await ComunicacionRaspberry.ReplicarImagen(
                              nombreNuevaImagen);
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.popAndPushNamed(
                            context, "/seleccionar_imagen",
                            arguments: {
                              'division_layout': '0',
                              'ruta_proveniente': rutaDeDondeViene,
                            });
                        Fluttertoast.showToast(
                          msg: "Imagenes agregadas",
                          toastLength: Toast.LENGTH_SHORT,
                          webBgColor: "#e74c3c",
                          timeInSecForIosWeb: 5,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: FlatButton(
                      child: Icon(
                        Icons.cancel,
                        color: HexColor('#FC4C8B'),
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(flex: 3, child: SizedBox()),
                ],
              ),
            ],
          ),
        );
        PopUps.PopUpConWidget(context, contenidoPopUp);
      }
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
      case '0':
        Navigator.popAndPushNamed(context, "/seleccionar_imagen", arguments: {
          'division_layout': '0',
          'ruta_proveniente': rutaDeDondeViene,
        });
        Fluttertoast.showToast(
          msg: "Imagenes agregadas",
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
        break;
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

//ACA SE COMENZARA A IMPLEMENTAR LAS FUNCIONES DE FIREBASE

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
    enableUpload(context);
  }

  Future<void> enableUpload(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: SingleChildScrollView(
                  child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Image.file(
                      sampleImage,
                      /* height: 300.0,
                      width: 600.0,*/
                      //width: MediaQuery.of(context).size.width / 2,
                      // height: MediaQuery.of(context).size.height / 4,
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Nombre imagen"),
                      validator: (value) {
                        return value.isEmpty ? "Nombre es requerido" : null;
                      },
                      onSaved: (value) {
                        return _myValue = value;
                      },
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    RaisedButton(
                      elevation: 10.0,
                      child: Text("Agregar nueva imagen"),
                      textColor: Colors.white,
                      color: Colors.blueAccent,
                      onPressed: uploadStatusImage,
                    )
                  ],
                ),
              ),
            ),
          )));
        });
  }

  void uploadStatusImage() async {
    if (validateAndSave()) {
      // Subir imagen a firebase storage
      final StorageReference postIamgeRef =
          FirebaseStorage.instance.ref().child(rutdeEmpresa);
      final StorageUploadTask uploadTask =
          postIamgeRef.child(_myValue + ".jpg").putFile(sampleImage);
      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      url = imageUrl.toString();
      print("Image url: " + url);

      // Guardar el post a firebase database: database realtime
      saveToDatabase(url);

      // Regresar a Home
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Soporte();
      }));
    }
  }

  void saveToDatabase(String url) {
    // Guardar un post (image, descripcion)

    DatabaseReference ref = FirebaseDatabase.instance.reference();
    var data = {
      "image": url,
      "nombre": _myValue,
    };

    ref.child("Imagenes").push().set(data);
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Widget postsUI(
    String image,
    String nombre,
    //String empresa,
    /* String date, String time*/
  ) {
    return /*Card(
      elevation: 10.0,
      margin: EdgeInsets.all(14.0),
      child: Container(
        padding: EdgeInsets.all(14.0),
        child: */
        /* Column(
      children: <Widget>[*/
        /*Row(
          children: <Widget>[
            /*  Text(
                  date,
                  style: Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),*/
          ],
        ),*/
        /*  SizedBox(
              height: 10.0,
            ),*/
        Stack(
      children: [
        Image.network(
          image,
          /*fit: BoxFit.cover*/
          // width: MediaQuery.of(context).size.width / 2,
          //  height: MediaQuery.of(context).size.height / 4,
        ),
        Positioned(
            bottom: 0,
            child: Container(
              color: Colors.lightGreenAccent,
              child: Text(
                nombre,
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
            ))
      ],
    );
    /*SizedBox(
              height: 10.0,
            ),
            Text(
              nombre,
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            )*/
    /*],
    );*/
    /*),
    );*/
  }
}

class CambiosSeleccion {
  static String rutaPadre;
  static BuildContext context;
  static List<String> listadoSeleccionadas;

  static BoxDecoration bordeSeleccionado = BoxDecoration(
    border: Border.all(color: Colors.blueAccent, width: 4.0),
  );

  static Widget iconoSeleccionado = Container(
    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
    child: Icon(
      Icons.check,
      color: Colors.white,
    ),
  );

  static Widget btnEliminarHabilitado = FlatButton(
    color: Colors.red,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    ),
    onPressed: eliminarImagenesSeleccionadas,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.delete_forever,
          color: Colors.white,
        ),
        Text(
          'Eliminar',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );

  static Widget btnEliminarDeshabilitado = FlatButton(
    color: Colors.grey,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    ),
    onPressed: () {},
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.delete_forever,
          color: Colors.white,
        ),
        Text(
          'Eliminar',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );

  static Widget btnEditarHabilitado = FlatButton(
    color: Colors.blueAccent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    ),
    onPressed: editarImagenesSeleccionadas,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.edit,
          color: Colors.white,
        ),
        Text(
          'Editar',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );

  static Widget btnEditarDeshabilitado = FlatButton(
    color: Colors.grey,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
    ),
    onPressed: () {},
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.edit,
          color: Colors.white,
        ),
        Text(
          'Editar',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );

  static eliminarImagenesSeleccionadas() {
    Text textoPopUp;
    Widget contenidoPopUp;
    String nombre;
    if (listadoSeleccionadas.length == 1) {
      nombre = listadoSeleccionadas[0];
      textoPopUp = Text(
          '¿ELIMINAR ${nombre.substring(0, nombre.lastIndexOf('.')).toUpperCase()} IMAGEN?',
          style: TextStyle(fontSize: 13));
    } else {
      textoPopUp = Text(
        '¿ELIMINAR ${listadoSeleccionadas.length} IMAGENES?',
        style: TextStyle(fontSize: 13),
      );
    }
    contenidoPopUp = Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40), color: HexColor('#f4f4f4')),
      height: 150,
      width: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: textoPopUp,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Row(
              children: [
                Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 4,
                  child: FlatButton(
                    child: Icon(
                      Icons.check_circle,
                      color: HexColor('#3EDB9B'),
                      size: 35,
                    ),
                    //Eliminar
                    onPressed: () async {
                      Navigator.pop(context);
                      PopUps.popUpCargando(
                          context, 'Eliminando imagenes'.toUpperCase());
                      var resultadoEliminar =
                          await ComunicacionRaspberry.EliminarContenido(
                              tipoContenido: 'imagenes',
                              nombresAEliminar: listadoSeleccionadas);
                      if (resultadoEliminar != null) {
                        Navigator.pop(context);
                        Navigator.popAndPushNamed(
                            context, "/seleccionar_imagen",
                            arguments: {
                              'division_layout': '0',
                              'ruta_proveniente': rutaPadre,
                            });
                        Fluttertoast.showToast(
                          msg: "Imagenes eliminadas",
                          toastLength: Toast.LENGTH_SHORT,
                          webBgColor: "#e74c3c",
                          timeInSecForIosWeb: 5,
                        );
                      } else {
                        Navigator.pop(context);
                        Fluttertoast.showToast(
                          msg: "Error al eliminar, intente nuevamente",
                          toastLength: Toast.LENGTH_SHORT,
                          webBgColor: "#e74c3c",
                          timeInSecForIosWeb: 5,
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: FlatButton(
                    child: Icon(
                      Icons.cancel,
                      color: HexColor('#FC4C8B'),
                      size: 35,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(flex: 3, child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );

    PopUps.PopUpConWidget(context, contenidoPopUp);
  }

  static editarImagenesSeleccionadas() {
    GlobalKey<FormState> _keyValidador2 = GlobalKey<FormState>();
    String nombreNuevaImagen;
    Text textoPopUp, linea2;
    Widget contenidoPopUp;
    String extension;
    String nombre;
    nombre = listadoSeleccionadas[0];
    extension = nombre.substring(nombre.lastIndexOf('.'));
    List<String> listadoNombres = [];
    textoPopUp = Text(
      'EDITAR NOMBRE',
      style: TextStyle(fontSize: 13),
    );
    linea2 = Text(
      ' ${nombre.substring(0, nombre.lastIndexOf('.')).toUpperCase()}',
      style: TextStyle(fontFamily: 'textoMont', fontSize: 12),
    );
    contenidoPopUp = Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40), color: HexColor('#f4f4f4')),
      height: 175,
      width: 250,
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: textoPopUp,
                ),
                linea2,
              ],
            ),
            SizedBox(
              width: 180,
              child: TextFormField(
                style: TextStyle(fontSize: 13, fontFamily: 'textoMont'),
                textAlign: TextAlign.center,
                validator: (textoEscrito) {
                  if (textoEscrito == null) {
                    return "Error: Nombre de imagen vacío";
                  }
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
            Row(
              children: [
                Expanded(flex: 2, child: SizedBox()),
                Expanded(
                  flex: 4,
                  child: FlatButton(
                    child: Icon(
                      Icons.check_circle,
                      color: HexColor('#3EDB9B'),
                      size: 35,
                    ),
                    autofocus: true,
                    onPressed: () async {
                      if (_keyValidador2.currentState.validate()) {
                        nombre = nombre.replaceAll(RegExp(' +'), '<!-!>');
                        nombreNuevaImagen =
                            nombreNuevaImagen.replaceAll(RegExp(' +'), '<!-!>');
                        listadoNombres.add(nombre);
                        listadoNombres.add(nombreNuevaImagen);
                        print(listadoNombres);
                        //Se abre el popup de cargando
                        Navigator.of(context).pop();
                        PopUps.popUpCargando(context, 'Editando imagen...');
                        //Obtengo el resultado del envio
                        var resultado =
                            await ComunicacionRaspberry.EditarContenido(
                          tipoContenido: 'imagenes',
                          nombresAEliminar: listadoNombres,
                        );
                        if (resultado != null) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.popAndPushNamed(
                              context, "/seleccionar_imagen",
                              arguments: {
                                'division_layout': '0',
                                'ruta_proveniente': rutaPadre,
                              });
                          Fluttertoast.showToast(
                            msg: "Imagen editada",
                            toastLength: Toast.LENGTH_LONG,
                            webBgColor: "#e74c3c",
                            timeInSecForIosWeb: 10,
                          );
                        } else {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg: "Error al eliminar, intente nuevamente",
                            toastLength: Toast.LENGTH_SHORT,
                            webBgColor: "#e74c3c",
                            timeInSecForIosWeb: 5,
                          );
                        }
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: FlatButton(
                    child: Icon(
                      Icons.cancel,
                      color: HexColor('#FC4C8B'),
                      size: 35,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(flex: 2, child: SizedBox())
              ],
            ),
          ],
        ),
        key: _keyValidador2,
      ),
    );

    PopUps.PopUpConWidget(context, contenidoPopUp);
  }
}

class SubiendoFirebase {}
