import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/CloudStorage.dart';
import 'package:tvpost_flutter/utilidades/comunicacion_raspberry.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SeleccionarVideo extends StatefulWidget {
  @override
  _SeleccionarVideoState createState() => _SeleccionarVideoState();
}

class _SeleccionarVideoState extends State<SeleccionarVideo> {

  //Datos que se envía completo desde la ventana de selección de media
  Map datosDesdeVentanaAnterior = {};
  String divisionLayout;
  String rutaDeDondeViene;
  Future<List<dynamic>> _listadoNombresVideos;
  List listadoNombresString;
  int itemsVisiblesGrid = 0;
  FilePickerResult videoSeleccionadoGaleria;
  TextEditingController _controladorTexto = TextEditingController();

  bool activarBoton = false;

  //VideoPlayerController widget.controller;
  //Future<void> _initializeVideoPlayerFuture;
  //ChewieController chewieController;

  @override
  void initState() {
    //Acá se hace el llamado al listado de nombres de imágenes
    //_listadoNombresVideos = _getNombresVideos();
    activarBoton = true;
    super.initState();
  }

  @override
  void dispose() {
    _controladorTexto.dispose();
    // TODO: implement dispose
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

    ///GRILLA MENU SELECCIONAR VIDEO
    if (rutaDeDondeViene != null) {
      CambiosSeleccion.rutaPadre = rutaDeDondeViene;
      widgetFutureGrilla = StreamBuilder(
        stream: FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('videos').snapshots(),
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
                String idVideo = snapshot.data.docs[index]['idVideo'].toString();
                String urlVideo = snapshot.data.docs[index]['url'].toString();
                String idThumbnail = snapshot.data.docs[index]['idThumbnail'].toString();
                String urlThumbnail = snapshot.data.docs[index]['thumbnail'].toString();

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!SeleccionaVideo.videosSelecionados.contains(idVideo)) {
                        SeleccionaVideo.videosSelecionados.add(idVideo);
                      } else {
                        SeleccionaVideo.videosSelecionados.remove(idVideo);
                      }
                    });
                  },
                  //Container de cada imagen
                  child: Opacity(
                    opacity: resultado(idVideo),
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
                                child: VideoYThumbnail(
                                  urlThumbnail: urlThumbnail,
                                  urlVideo: urlVideo,
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
                          SeleccionaVideo.videosSelecionados.contains(idVideo)
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
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            //Si la lista tiene algún seleccionado se cambia el botón
            child: SeleccionaVideo.videosSelecionados.length >= 1
                ? CambiosSeleccion.btnEliminarHabilitado
                : CambiosSeleccion.btnEliminarDeshabilitado,
          ),
        ],
      );
    } else {
      ///GRILLA SELECCIONAR VIDEO
      ///ESTA GRID DEBE ENVIAR ADEMÁS EL VIDEO DIRECTO A LA RASPBERRY
      widgetFutureGrilla = StreamBuilder(
        stream: FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('videos').snapshots(),
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
                String idVideo = snapshot.data.docs[index]['idVideo'].toString();
                String urlVideo = snapshot.data.docs[index]['url'].toString();
                String idThumbnail = snapshot.data.docs[index]['idThumbnail'].toString();
                String urlThumbnail = snapshot.data.docs[index]['thumbnail'].toString();

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (SeleccionaVideo.videosSelecionados.length >= 1) {
                        if (SeleccionaVideo.videosSelecionados
                            .contains(idVideo)) {
                          SeleccionaVideo.videosSelecionados
                              .remove(idVideo);
                        } else {
                          SeleccionaVideo.videosSelecionados.clear();
                          SeleccionaVideo.videosSelecionados.add(idVideo);
                        }
                      } else {
                        SeleccionaVideo.videosSelecionados.add(idVideo);
                      }
                    });
                  },
                  child: Opacity(
                    opacity: resultado(idVideo),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            Expanded(
                              flex: 5,
                              child: VideoYThumbnail(
                                urlThumbnail: urlThumbnail,
                                urlVideo: urlVideo,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 30,
                          right: 10,
                          //Se aplica el ícono verde al seleccionar
                          child: SeleccionaVideo.videosSelecionados
                              .contains(idVideo)
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

      rowBotones = SeleccionaVideo.videosSelecionados.length == 1
          ? Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 4,
        //color: Colors.pink,
        child: Column(
          children: [
            SizedBox(height: 38),
            Container(
              height: 40,
              width: 200,
              decoration: new BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
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
                      end: FractionalOffset.bottomRight)),
              child: FlatButton(
                color: Colors.transparent,
                onPressed: () async {
                  ///Acá debo obtener la url desde el video id y pasárselo al controlador
                  /*
                  Widget video = ReproductorVideos(
                    url:
                    'http://${DatosEstaticos.ipSeleccionada}/VideosPostTv/${SeleccionaVideo.videosSelecionados[0]}',
                    divisionLayout: divisionLayout,
                    seleccionado: true,
                  );

                   */
                  var listadoUrl = await CloudStorage.GetUrlVideYThumbnail(SeleccionaVideo.videosSelecionados[0]);
                  if (listadoUrl != null){
                    String nombre = SeleccionaVideo.videosSelecionados[0];

                    //Arreglo que contiene el nombre correcto del video para analizar
                    List<String> _verificarVideo = new List<String>();
                    _verificarVideo.add("/var/www/html/VideosPostTv/${SeleccionaVideo.videosSelecionados[0]}");

                    //Se Descarga video inmediatamente al cargar
                    PopUps.popUpCargando(context, "DESCARGANDO ARCHIVOS");
                    await ComunicacionRaspberry.CompruebaArchivosRaspberry(pLinksAEnviar: _verificarVideo);
                    Navigator.of(context).pop();

                    //Se conecta con video directo de la raspberry
                    String urlVideoRaspberry = "http://${DatosEstaticos.ipSeleccionada}/VideosPostTv/$nombre";
                    Widget video = VideoYThumbnail(urlThumbnail: listadoUrl[1], urlVideo: urlVideoRaspberry,);

                    //Se le pasa el id para enviar el video
                    RedireccionarCrearLayout(
                        video,
                        urlVideoRaspberry,
                        false);
                  }else{
                    Fluttertoast.showToast(
                      msg: "Error al cargar video",
                      toastLength: Toast.LENGTH_SHORT,
                      webBgColor: "#e74c3c",
                      timeInSecForIosWeb: 5,
                    );
                  }


                },
                child: Text(
                  'CARGAR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 4,
      ) ;
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
                            'SELECCIONE VIDEO',
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
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                ),
                                heroTag: null,
                                backgroundColor: HexColor('#FC4C8B'),
                                onPressed: () {
                                  abrirGaleria(context);
                                }),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
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

  Future<List> _getNombresVideos() async {
    List<int> listadoValoresBytes = [];
    List datos;
    Socket socket;
    try {
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada,
              DatosEstaticos.puertoSocketRaspberry)
          .timeout(Duration(seconds: 5));
      socket.write('TVPOSTGETNOMBREVIDEOS');
      socket.listen((event) {
        listadoValoresBytes.addAll(event.toList());
        //socket.flush();
        //print(listadoValoresBytes.length);
      }).onDone(() {
        //DatosEstaticos.listadoNombresString = utf8.decode(listadoValoresBytes).split(",");
        datos = utf8.decode(listadoValoresBytes).split(",");
        DatosEstaticos.listadoNombresVideos = datos;
        socket.close();
      });

      await socket.done.whenComplete(() => datos);
      return datos;
    } catch (e) {
      print("Error " + e.toString());
    }
  }

  double resultado(String nombre) {
    if (SeleccionaVideo.videosSelecionados.length > 0) {
      if (SeleccionaVideo.videosSelecionados.contains(nombre) != true) {
        return 0.1;
      } else {
        return 1.0;
      }
    } else {
      return 1.0;
    }
  }


  ///ABRE GALERÍA PARA SELECCIONAR VIDEOS Y SUBIRLOS A FIREBASE
  abrirGaleria(BuildContext context) async {

    if (rutaDeDondeViene != null) {
      //Se toman multiples archivos desde FilePicker
      videoSeleccionadoGaleria = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.video);
    } else {
      //Se toma el archivo desde FilePicker
      videoSeleccionadoGaleria =
      await FilePicker.platform.pickFiles(type: FileType.video);
    }

    //Cantidad archivos seleccionados
    if (videoSeleccionadoGaleria != null) {

      //Se sube listado de imágenes a FireBase
      List<dynamic> resultado = await SubidaVideos(videoSeleccionadoGaleria);

      if (resultado != null){
        if (rutaDeDondeViene != null) {
          //Navigator.pop(context);
          Navigator.pop(context);
          Navigator.popAndPushNamed(
              context, "/seleccionar_video",
              arguments: {
                'division_layout': '0',
                'ruta_proveniente': rutaDeDondeViene,
              });
        }else {
          //Si no es del menú redirige al layout
          //Si el envío es correcto, se redirecciona
          VideoYThumbnail videoAEnviar = VideoYThumbnail(
            urlThumbnail: resultado[2], urlVideo: resultado[1],
          );
          /*
          ReproductorVideos videoAEnviar = ReproductorVideos(
            url: resultado[0],
            divisionLayout: divisionLayout,
            seleccionado: true,
          );

           */
          RedireccionarCrearLayout(
              videoAEnviar,
              "/var/www/html/VideosPostTv/${resultado[3]}",
              true);
        }
        Fluttertoast.showToast(
          msg: "Videos agregados correctamente",
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

  /*
  abrirGaleriaOld() async {
    GlobalKey<FormState> _keyValidadorvideo = GlobalKey<FormState>();
    String nombreNuevoVideo = "";
    if (rutaDeDondeViene != null) {
      videoSeleccionadoGaleria = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.video);
    } else {
      videoSeleccionadoGaleria =
          await FilePicker.platform.pickFiles(type: FileType.video);
    }
    Widget videoAEnviar;
    if (videoSeleccionadoGaleria != null) {
      if (videoSeleccionadoGaleria.files.length == 1) {
        String extension = p.extension(videoSeleccionadoGaleria.paths[0]);
        //print(extension);
        File videoFinal = File(videoSeleccionadoGaleria.paths[0]);
        await showDialog<String>(
          context: context,
          child: StatefulBuilder(builder: (context, setState) {
            return AnimacionPadding(
              child: new AlertDialog(
                content: SingleChildScrollView(
                  child: Card(
                    child: Form(
                      key: _keyValidadorvideo,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.height / 4,
                            child: videoAEnviar = ReproductorVideos(
                              url: videoFinal,
                              seleccionado: true,
                            ),
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
                                      labelText: 'INGRESE NOMBRE DEL VIDEO',
                                      labelStyle: TextStyle(fontSize: 12)),
                                  controller: _controladorTexto,
                                  validator: (textoEscrito) {
                                    if (textoEscrito.isEmpty) {
                                      return "Error: Nombre de video vacío";
                                    }
                                    if (textoEscrito.trim().length <= 0) {
                                      return "Error: Nombre de video vacío";
                                    } else {
                                      nombreNuevoVideo =
                                          textoEscrito.trim().toString() +
                                              extension;
                                      //Chequear si el valor ya existe
                                      if (DatosEstaticos.listadoNombresVideos
                                          .contains(nombreNuevoVideo)) {
                                        return "Error: Nombre de video ya existe";
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
                              if (_keyValidadorvideo.currentState.validate()) {
                                //Se abre el popup de cargando
                                Navigator.pop(context);
                                PopUps.popUpCargando(
                                    context, 'Añadiendo video'.toUpperCase());
                                //Obtengo el resultado del envio
                                var resultado = await PopUps.enviarVideo(
                                        nombreNuevoVideo, videoFinal)
                                    .then((value) => value);

                                if (resultado) {
                                  if (rutaDeDondeViene != null) {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.popAndPushNamed(
                                        context, "/seleccionar_video",
                                        arguments: {
                                          'division_layout':
                                              DatosEstaticos.divisionLayout,
                                          'ruta_proveniente': rutaDeDondeViene,
                                        });
                                  } else {
                                    //Si no es del menú redirige al layout
                                    //Si el envío es correcto, se redirecciona
                                    videoAEnviar = ReproductorVideos(
                                      url:
                                          'http://${DatosEstaticos.ipSeleccionada}/VideosPostTv/$nombreNuevoVideo',
                                      divisionLayout: divisionLayout,
                                      seleccionado: true,
                                    );
                                    RedireccionarCrearLayout(
                                        videoAEnviar,
                                        "/var/www/html/VideosPostTv/$nombreNuevoVideo",
                                        true);
                                  }
                                } else {
                                  //Cierra popup cargando
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();

                                  PopUps.PopUpConWidget(
                                      context, Text('Error al enviar video'));
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
            );
          }),
        );
      } else {
        String extension;
        File videoFinal;
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
                  '¿Agregar ${videoSeleccionadoGaleria.files.length} videos?'
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
                              context, 'Agregando videos'.toUpperCase());

                          for (int i = 0;
                              i <= videoSeleccionadoGaleria.files.length - 1;
                              i++) {
                            PlatformFile element =
                                videoSeleccionadoGaleria.files[i];
                            extension = p.extension(element.path);
                            videoFinal = File(element.path);
                            //Se le da el nombre de la hora actual + su posición
                            // //en el listado
                            DateTime now = DateTime.now();
                            nombreNuevoVideo =
                                '${now.year}${now.month}${now.day}'
                                '${now.hour}${now.minute}${now.second}'
                                '_$i$extension';

                            //Obtengo el resultado del envio
                            var resultado = await PopUps.enviarVideo(
                                    nombreNuevoVideo, videoFinal)
                                .then((value) => value);
                            if (resultado == false) {
                              showDialog(
                                context: null,
                                child: Text('Error al agregar videos'),
                              );
                              break;
                            }
                          }
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.popAndPushNamed(
                              context, "/seleccionar_video",
                              arguments: {
                                'division_layout': '0',
                                'ruta_proveniente': rutaDeDondeViene,
                              });
                          Fluttertoast.showToast(
                            msg: "Videos agregados",
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
                          size: 35,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(flex: 3, child: SizedBox()),
                  ],
                ),
              ],
            ));
        PopUps.PopUpConWidget(context, contenidoPopUp);
      }
    }
  }

   */

  // ignore: non_constant_identifier_names
  void RedireccionarCrearLayout(
      Widget video, String nombre, bool vieneDePopUp) {
    if (vieneDePopUp) {
      //Cierra popup cargando
      //Navigator.pop(context);

      Navigator.of(context, rootNavigator: true).pop();
    }

    //Se asigna además que porcion del layout se reemplazará
    switch (divisionLayout) {
      case '1-1':
        {
          DatosEstaticos.widget1 = video;
          DatosEstaticos.nombreArchivoWidget1 = nombre;
          DatosEstaticos.reemplazarPorcion1 = true;
          Navigator.pop(context, true);
        }
        break;
      case '2-1':
        {
          DatosEstaticos.widget1 = video;
          DatosEstaticos.nombreArchivoWidget1 = nombre;
          DatosEstaticos.reemplazarPorcion1 = true;
          Navigator.pop(context, true);
        }
        break;
      case '2-2':
        {
          DatosEstaticos.widget2 = video;
          DatosEstaticos.nombreArchivoWidget2 = nombre;
          DatosEstaticos.reemplazarPorcion2 = true;
          Navigator.pop(context, true);
        }
        break;
      case '3-1':
        {
          DatosEstaticos.widget1 = video;
          DatosEstaticos.nombreArchivoWidget1 = nombre;
          DatosEstaticos.reemplazarPorcion1 = true;
          Navigator.pop(context, true);
        }
        break;
      case '3-2':
        {
          DatosEstaticos.widget2 = video;
          DatosEstaticos.nombreArchivoWidget2 = nombre;
          DatosEstaticos.reemplazarPorcion2 = true;
          Navigator.pop(context, true);
        }
        break;
      case '3-3':
        {
          DatosEstaticos.widget3 = video;
          DatosEstaticos.nombreArchivoWidget3 = nombre;
          DatosEstaticos.reemplazarPorcion3 = true;
          Navigator.pop(context, true);
        }
        break;
    }
  }

  ///SUBE UN LISTADO DE VIDEOS SELECCIONADOS Y DEVUELVE EL ARCHIVO LOCAL EN
  ///STORAGE, URL RASPBERRY, URL THUMBNAIL EN FIREBASE E ID VIDEO
  ///{0} = ARCHIVO LOCAL
  ///{1} = URL EN RASPBERRY
  ///{2} = URL THUMBNAIL FIREBASE
  ///{3} = ID VIDEO
  Future<List<dynamic>> SubidaVideos(
      FilePickerResult videoSeleccionadoGaleria) async{

    List<dynamic> listadoResultado = List<dynamic>();

    //Video desde archivo por filepicker
    File videoFinal;

    var listadoArchivos = new List<File>();
    PopUps.popUpCargando(context, 'Agregando videos'.toUpperCase());

    //Por cada archivo se envia a firebase
    for (PlatformFile element in videoSeleccionadoGaleria.files){
      videoFinal = File(element.path);

      //Se añade video a listado a subir
      listadoArchivos.add(videoFinal);
    }

    ///Comienzo de uso de firebase
    var resultadoFirebase = await CloudStorage.SubirVideosFirebase(listadoArchivos);

    //Se sube a la raspberry solo si hay ip asignada. SOLO SE PERMITE SUBIR DE
    // A 1 SI HAY IP SELECCIONADA
    if (DatosEstaticos.ipSeleccionada!=null)
      await ComunicacionRaspberry.EnviarVideoPorHTTP(resultadoFirebase[0], videoFinal);

    //Seteamos datos y devolvemos archivo local con link en raspberry
    //esto solo se utiliza cuando ya hay una ip asignada
    String _ip = DatosEstaticos.ipSeleccionada;

    //Video
    listadoResultado.add(videoFinal);
    //Url Raspberry
    listadoResultado.add("http://$_ip/VideosPostTv/${resultadoFirebase[0]}");
    //Url Thumbnail en firebase
    listadoResultado.add(resultadoFirebase[3]);
    //Id video (nombre video)
    listadoResultado.add(resultadoFirebase[0]);

    return listadoResultado;
  }
}

class ReproductorVideos extends StatefulWidget {
  String divisionLayout;
  var url;
  bool seleccionado;
  VideoPlayerController controller;

  ReproductorVideos(
      {this.url,
      this.divisionLayout = "",
      this.seleccionado = false,
      this.controller});
  @override
  _ReproductorVideosState createState() => _ReproductorVideosState();
}

class _ReproductorVideosState extends State<ReproductorVideos> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Dato para no reinicializar el constructor al reproducir
    //y que cambie el ícono correctamente
    if (!DatosEstaticos.reproducirVideo) {
      //Se inicializa acá para que cambie cada vez que se elige otro video
      if (widget.url.runtimeType != String) {
        widget.controller = VideoPlayerController.file(
          widget.url,
        );
      } else {
        widget.controller = VideoPlayerController.network(
          widget.url,
        );
      }
      //widget.controller.setLooping(true);
      widget.controller.initialize();
    }

    DatosEstaticos.reproducirVideo = false;

    double ancho_video = MediaQuery.of(context).size.width;
    double alto_video = MediaQuery.of(context).size.height;

    //Widget hijo por defecto. Este cambia visualmente en las porciones del
    //layout 3
    Widget hijo;
    try {
      hijo = Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            width: ancho_video,
            height: alto_video,
            child: VideoPlayer(widget.controller),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 7,
            child: RaisedButton(
              shape: CircleBorder(),
              child: Icon(
                widget.controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: MediaQuery.of(context).size.width / 15,
              ),
              onPressed: () {
                accionReproducir();
              },
            ),
          ),
        ],
      );
    } catch (ex) {
      print('Error al resproducir: ${ex.toString()}');
    }

    //Cambio visual de videos según layout 3 y porciones
    if (widget.divisionLayout != "") {
      switch (widget.divisionLayout) {
        case '2-2':
          hijo = Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Container(
                width: ancho_video,
                height: alto_video,
                child: VideoPlayer(widget.controller),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 7,
                child: RaisedButton(
                  shape: CircleBorder(),
                  child: Icon(
                    widget.controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: MediaQuery.of(context).size.width / 15,
                  ),
                  onPressed: () {
                    accionReproducir();
                  },
                ),
              ),
            ],
          );
          break;

        case '3-2':
          alto_video = alto_video / 12;
          hijo = Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 7,
                child: RaisedButton(
                  shape: CircleBorder(),
                  child: Icon(
                    widget.controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: MediaQuery.of(context).size.width / 15,
                  ),
                  onPressed: () {
                    accionReproducir();
                  },
                ),
              ),
              Container(
                width: ancho_video,
                height: alto_video,
                child: VideoPlayer(widget.controller),
              ),
            ],
          );
          break;

        case '3-3':
          ancho_video = ancho_video / 6;
          hijo = Padding(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 3.7),
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 7,
                  child: RaisedButton(
                    shape: CircleBorder(),
                    child: Icon(
                      widget.controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: MediaQuery.of(context).size.width / 15,
                    ),
                    onPressed: () {
                      accionReproducir();
                    },
                  ),
                ),
                Container(
                  width: ancho_video,
                  height: alto_video,
                  child: VideoPlayer(widget.controller),
                ),
              ],
            ),
          );
          break;
      }
    }

    return Center(
      child: Container(
        child: hijo,
      ),
    );
  }

  void accionReproducir() {
    setState(() {
      if (widget.controller.value.isPlaying) {
        widget.controller.pause();
        DatosEstaticos.reproducirVideo = true;
      } else {
        widget.controller.play();
        DatosEstaticos.reproducirVideo = true;
      }
    });
  }
}

class CambiosSeleccion {
  static String rutaPadre;
  static BuildContext context;
  //static List<String> listadoSeleccionados = SeleccionaVideo.videosSelecionados;

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
    onPressed: eliminarVideosSeleccionados,
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
    onPressed: editarVideosSeleccionadas,
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

  static eliminarVideosSeleccionados() {
    Text textoPopUp;
    Widget contenidoPopUp;
    if (SeleccionaVideo.videosSelecionados.length == 1) {
      textoPopUp = Text(
          '¿ELIMINAR VIDEO SELECCIONADO?',
          style: TextStyle(fontSize: 13));
    } else {
      textoPopUp = Text(
        '¿ELIMINAR ${SeleccionaVideo.videosSelecionados.length} VIDEOS?',
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
          textoPopUp,
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
                  //Eliminar
                  onPressed: () async {
                    Navigator.pop(context);
                    PopUps.popUpCargando(
                        context, 'Eliminando videos'.toUpperCase());
                    var resultadoEliminar = await CloudStorage.EliminarVideoFirebase(SeleccionaVideo.videosSelecionados);
                    /*
                    var resultadoEliminarRaspberry = await ComunicacionRaspberry.EliminarContenido(tipoContenido: "video", nombresAEliminar: SeleccionaVideo.videosSelecionados);

                     */

                    if (resultadoEliminar != null /*&& resultadoEliminarRaspberry !=null*/) {
                      //Se limpia la lista estática de videos seleccionados
                      SeleccionaVideo.videosSelecionados.clear();
                      Navigator.pop(context);
                      Navigator.popAndPushNamed(context, "/seleccionar_video",
                          arguments: {
                            'division_layout': '0',
                            'ruta_proveniente': rutaPadre,
                          });
                      Fluttertoast.showToast(
                        msg: "Videos eliminados",
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
        ],
      ),
    );

    PopUps.PopUpConWidget(context, contenidoPopUp);
  }

  static editarVideosSeleccionadas() {
    GlobalKey<FormState> _keyValidadorvideo2 = GlobalKey<FormState>();
    String nombreNuevaImagen;
    Text textoPopUp, linea2;
    Widget contenidoPopUp;
    String extension;
    String nombre;
    nombre = SeleccionaVideo.videosSelecionados[0];
    extension = nombre.substring(nombre.lastIndexOf('.'));
    List<String> listadoNombres = [];
    textoPopUp = Text(
      'EDITAR NOMBRE',
      style: TextStyle(fontSize: 13),
    );
    linea2 = Text(
      '${nombre.substring(0, nombre.lastIndexOf('.'))}',
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
                  padding: const EdgeInsets.only(top: 15),
                  child: textoPopUp,
                ),
                linea2
              ],
            ),
            SizedBox(
              width: 180,
              child: TextFormField(
                style: TextStyle(fontSize: 13, fontFamily: 'textoMont'),
                textAlign: TextAlign.center,
                validator: (textoEscrito) {
                  if (textoEscrito == null) {
                    return "Error: Nombre de video vacío";
                  }
                  if (textoEscrito.isEmpty) {
                    return "Error: Nombre de video vacío";
                  }
                  if (textoEscrito.trim().length <= 0) {
                    return "Error: Nombre de video vacío";
                  } else {
                    nombreNuevaImagen =
                        textoEscrito.trim().toString() + extension;
                    //Chequear si el valor ya existe
                    if (DatosEstaticos.listadoNombresVideos
                        .contains(nombreNuevaImagen)) {
                      return "Error: Nombre de video ya existe";
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
                      if (_keyValidadorvideo2.currentState.validate()) {
                        nombre = nombre.replaceAll(RegExp(' +'), '<!-!>');
                        nombreNuevaImagen =
                            nombreNuevaImagen.replaceAll(RegExp(' +'), '<!-!>');
                        listadoNombres.add(nombre);
                        listadoNombres.add(nombreNuevaImagen);
                        print(listadoNombres);
                        //Se abre el popup de cargando
                        PopUps.popUpCargando(context, 'Editando video...');
                        //Obtengo el resultado del envio
                        var resultado =
                            await ComunicacionRaspberry.EditarContenido(
                          tipoContenido: 'videos',
                          nombresAEliminar: listadoNombres,
                        );
                        if (resultado != null) {
                          //Se limpia la lista estática de videos seleccionados
                          SeleccionaVideo.videosSelecionados.clear();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.popAndPushNamed(
                              context, "/seleccionar_video",
                              arguments: {
                                'division_layout': '0',
                                'ruta_proveniente': rutaPadre,
                              });
                          Fluttertoast.showToast(
                            msg: "Video editado",
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
                Expanded(flex: 2, child: SizedBox()),
              ],
            ),
          ],
        ),
        key: _keyValidadorvideo2,
      ),
    );

    PopUps.PopUpConWidget(context, contenidoPopUp);
  }
}
