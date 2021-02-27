import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:tvpost_flutter/tvlapiz_icons.dart';
import 'package:tvpost_flutter/utilidades/CloudStorage.dart';
import 'package:tvpost_flutter/utilidades/comunicacion_raspberry.dart';
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
  String rutaDeDondeViene;
  FilePickerResult imagenSeleccionadaGaleria;
  TextEditingController _controladorTexto = TextEditingController();
  List<String> imagenesSeleccionadas = [];
  bool activarBoton = false;
  Container cargaRRSS = Container(height: 200,);

  @override
  void initState() {
    super.initState();
    activarBoton = true;
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
    Widget rowBotones;

    ///Acá se carga la grid desde Firebase
    if (rutaDeDondeViene != null) {
      CambiosSeleccion.rutaPadre = rutaDeDondeViene;

      widgetFutureGrilla = StreamBuilder(
        stream: FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('imagenes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return !snapshot.hasData
              ? Center(child: CircularProgressIndicator(),)
              : GridView.builder(
                  //Toma el total de imágenes desde la carpeta del
                  // webserver
                  itemCount: snapshot.data.docs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5),
                  itemBuilder: (context, index) {
                    //Por cada imagen, busca su imagen.
                    // El nombre lo toma del listado estático

                    String nombre = snapshot.data.docs[index]['id'].toString();

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!imagenesSeleccionadas.contains(nombre)) {
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(

                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Image.network(snapshot.data.docs[index]['url']),
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
                  });
        },
      );
      rowBotones = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /*Botón Editar
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
          */
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            //Si la lista tiene algún seleccionado se cambia el botón
            child: imagenesSeleccionadas.length > 0
                ? CambiosSeleccion.btnEliminarHabilitado
                : CambiosSeleccion.btnEliminarDeshabilitado,
          ),
        ],
      );
    } else {
      widgetFutureGrilla = StreamBuilder(
        stream: FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('imagenes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return !snapshot.hasData
              ? CircularProgressIndicator()
              : GridView.builder(
            //Toma el total de imágenes desde la carpeta del
            // webserver
              itemCount: snapshot.data.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5),
              itemBuilder: (context, index) {
                //Por cada imagen, busca su imagen.
                // El nombre lo toma del listado estático

                String nombre = snapshot.data.docs[index]['id'].toString();
                //BoxDecoration borderSelec;

                return GestureDetector(
                  onTap: () {

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

                    cargaRRSS = imagenesSeleccionadas.length == 1
                        ? Container(
                      width: MediaQuery.of(context).size.width,
                      //height:MediaQuery.of(context).size.height / 4,
                      //color: Colors.pink,
                      child: Row(
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height/25),
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
                                    Widget imagen = Image.network(snapshot.data.docs[index]['url']);
                                    String nombre = snapshot.data.docs[index]['id'].toString();
                                    RedireccionarCrearLayout(
                                        imagen,
                                        //"/var/www/html/ImagenesPostTv/$nombre",
                                        "/ImagenesPostTv/$nombre",
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

                                    //Valor que activa la publicación en redes sociales
                                    //Este valor se desactiva luego de proyectar en tv
                                    DatosEstaticos
                                        .PublicarEnRedesSociales =
                                    true;
                                    Widget imagen = Image.network(snapshot.data.docs[index]['url']);
                                    String nombre = snapshot.data.docs[index]['id'].toString();
                                    RedireccionarCrearLayout(
                                        imagen,
                                        "/ImagenesPostTv/$nombre",
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
                        ],
                      ),
                    )
                        : Container(
                      width: MediaQuery.of(context).size.width,
                      height:
                      MediaQuery.of(context).size.height / 4,
                    );
                    setState(() {
                      CambiosSeleccion.listadoSeleccionadas =
                          imagenesSeleccionadas;
                    });
                  },
                  //Container de cada imagen
                  child: Opacity(
                    opacity: resultado(nombre),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Image.network(snapshot.data.docs[index]['url']),
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
              });
        },
      );
      rowBotones = cargaRRSS;
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
                                  abrirGaleria(context);
                                  //getImage();
                                }),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                //Acá hacer un future builder para nombres de imágenes
                child: widgetFutureGrilla,
              ),
              Expanded(
                child: rowBotones,
              )
            ],
          ),
        ),
      ),
    );
  }

  ///CONTROLA LA OPACIDAD AL SELECCIONAR IMAGEN
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

  ///ABRE GALERÍA PARA SELECCIONAR IMÁGENES Y SUBIRLAS A FIREBASE
  abrirGaleria(BuildContext context) async {

    if (rutaDeDondeViene != null) {
      //Se toman multiples archivos desde FilePicker
      imagenSeleccionadaGaleria = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);
    } else {
      //Se toma el archivo desde FilePicker
      imagenSeleccionadaGaleria =
          await FilePicker.platform.pickFiles(type: FileType.image);
    }

    //Cantidad archivos seleccionados
    if (imagenSeleccionadaGaleria != null) {

      //Se sube listado de imágenes a FireBase
      List<dynamic> resultado = await SubidaImagenes(imagenSeleccionadaGaleria);

      if (resultado != null){
        if (rutaDeDondeViene != null) {
          //Navigator.pop(context);
          Navigator.pop(context);
          Navigator.popAndPushNamed(
              context, "/seleccionar_imagen",
              arguments: {
                'division_layout': '0',
                'ruta_proveniente': rutaDeDondeViene,
              });
        }else {
          //Si no es del menú redirige al layout
          //Si el envío es correcto, se redirecciona y se utiliza la imagen
          //local en equipo seleccionado
          Image imagen = Image.file(resultado[0],);

          RedireccionarCrearLayout(
              imagen,
              "/var/www/html/ImagenesPostTv/${resultado[1]}",
              true
          );
        }
        Fluttertoast.showToast(
          msg: "Imagenes agregadas correctamente",
          toastLength: Toast.LENGTH_SHORT,
          webBgColor: "#e74c3c",
          timeInSecForIosWeb: 5,
        );
      }
      else {
        //Cierra popup cargando
        Navigator.of(context, rootNavigator: true).pop();

        PopUps.PopUpConWidget(context, Text('Error al enviar imagen'));
      }
    }
  }

  ///REDIRECCIONA A UNA DE LAS DISTINTAS VENTANAS DE CREACIÓN DE
  ///LAYOUT
  void RedireccionarCrearLayout(
      Widget imagen, String nombre, bool vieneDePopUp) {
    if (vieneDePopUp) {
      //Cierra popup cargando
      //Navigator.of(context, rootNavigator: true).pop();
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

  ///SUBE UN LISTADO DE IMÁGENES SELECCIONADAS DEVOLVIENDO EL ARCHIVO EN STORAGE
  ///ID IMAGEN Y URL EN FIREBASE
  ///{0} = ARCHIVOSTORAGE
  ///{1} = ID IMAGEN
  ///{2} = URL
  Future<List<dynamic>> SubidaImagenes(
      FilePickerResult imagenSeleccionadaGaleria) async{

    List<dynamic> listadoResultado = List<dynamic>();
    File imagenFinal;
    var listadoArchivos = new List<File>();
    PopUps.popUpCargando(context, 'Agregando imagenes'.toUpperCase());

    for (PlatformFile element in imagenSeleccionadaGaleria.files){
      imagenFinal = File(element.path);

      //Se añade imagen a listado a subir
      listadoArchivos.add(imagenFinal);
    }

    ///Comienzo de uso de firebase
    List<String> resultadoFirebase = await CloudStorage.SubirImagenFirebase(listadoArchivos);

    if (DatosEstaticos.ipSeleccionada!=null)
      await ComunicacionRaspberry.EnviarImagenPorHTTP(resultadoFirebase[0], imagenFinal);

    listadoResultado.add(imagenFinal);
    listadoResultado.add(resultadoFirebase[0]);
    listadoResultado.add(resultadoFirebase[1]);
    return listadoResultado;
  }

}

///CAMBIO DE SELECCIÓN PARA BOTONES DE ADMINISTRADOR DE IMAGENES
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
          '¿ELIMINAR IMAGEN SELECCIONADA?',
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

                      var resultadoEliminar = await CloudStorage.EliminarImagenFirebase(listadoSeleccionadas);
                      /*
                      var resultadoEliminar =
                          await ComunicacionRaspberry.EliminarContenido(
                              tipoContenido: 'imagenes',
                              nombresAEliminar: listadoSeleccionadas);

                       */

                      if (resultadoEliminar) {
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
