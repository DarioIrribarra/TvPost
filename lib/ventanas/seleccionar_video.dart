import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class SeleccionarVideo extends StatefulWidget {
  @override
  _SeleccionarVideoState createState() => _SeleccionarVideoState();
}

class _SeleccionarVideoState extends State<SeleccionarVideo> {
  //Datos que se envía completo desde la ventana de selección de media
  Map datosDesdeVentanaAnterior = {};
  String divisionLayout;
  Future<List<dynamic>> _listadoNombresVideos;
  List listadoNombresString;
  int itemsVisiblesGrid = 0;
  FilePickerResult videoSeleccionadoGaleria;
  TextEditingController _controladorTexto = TextEditingController();
  //VideoPlayerController _controller;
  //Future<void> _initializeVideoPlayerFuture;
  ChewieController chewieController;

  @override
  void initState() {
    // TODO: implement initState
    //Acá se hace el llamado al listado de nombres de imágenes
    _listadoNombresVideos = _getNombresVideos();

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
    datosDesdeVentanaAnterior = ModalRoute.of(context).settings.arguments;
    if (datosDesdeVentanaAnterior != null){
      divisionLayout = datosDesdeVentanaAnterior['division_layout'];
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                    child: Center(
                      child: Text('Seleccione un video'),
                    )
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (){abrirGaleria(context);},
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                future: _listadoNombresVideos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done){
                    //Future Builder para el gridview de videos
                    return GridView.count(
                      crossAxisSpacing: 5,
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      children: List.generate(
                          DatosEstaticos.listadoNombresVideos.length, (index) {
                        return GestureDetector(
                          onDoubleTap: (){
                            Widget video = ReproductorVideos(url: 'http://${DatosEstaticos.ipSeleccionada}/VideosPostTv/${DatosEstaticos.listadoNombresVideos[index]}',);
                            String nombre = DatosEstaticos.listadoNombresVideos[index];
                            RedireccionarCrearLayout(video, "/var/www/html/VideosPostTv/$nombre", false);
                          },
                          child: ReproductorVideos(url: 'http://${DatosEstaticos.ipSeleccionada}/VideosPostTv/${DatosEstaticos.listadoNombresVideos[index]}',)
                        );
                      }),
                    );
                  } else {
                    return Center();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List> _getNombresVideos() async {
    List<int> listadoValoresBytes = [];
    List datos;
    Socket socket;
    try{
      socket= await Socket.connect(DatosEstaticos.ipSeleccionada,
          DatosEstaticos.puertoSocketRaspberry).timeout(Duration(seconds: 5));
      socket.write('TVPOSTGETNOMBREVIDEOS');
      socket.listen((event) {
        listadoValoresBytes.addAll(event.toList());
        //socket.flush();
        //print(listadoValoresBytes.length);
      }).onDone(() {
        //DatosEstaticos.listadoNombresString = utf8.decode(listadoValoresBytes).split(",");
        datos =  utf8.decode(listadoValoresBytes).split(",");
        DatosEstaticos.listadoNombresVideos = datos;
        socket.close();
      });

      await socket.done.whenComplete(() => datos);
      return datos;

    } catch(e){
      print("Error " + e.toString());
    }
  }

  abrirGaleria(BuildContext context) async {
    GlobalKey<FormState> _keyValidador = GlobalKey<FormState>();
    String nombreNuevoVideo = "";
    videoSeleccionadoGaleria = await FilePicker.platform.pickFiles(
        type: FileType.video);
    Widget videoAEnviar;
    if (videoSeleccionadoGaleria!=null){
      String extension = p.extension(videoSeleccionadoGaleria.paths[0]);
      //print(extension);
      File videoFinal = File(videoSeleccionadoGaleria.paths[0]);
      Widget widget =
      SingleChildScrollView(
        child: Card(
          child: Form(
            key: _keyValidador,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                videoAEnviar = ReproductorVideos(url:videoFinal),
                Center(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: _controladorTexto,
                    validator: (textoEscrito){
                      if(textoEscrito.isEmpty){
                        return "Error: Nombre de video vacío";
                      }
                      if(textoEscrito.trim().length<= 0){
                        return "Error: Nombre de video vacío";
                      }
                      else {
                        nombreNuevoVideo = textoEscrito.trim()
                            .toString() + extension;
                        //Chequear si el valor ya existe
                        if (DatosEstaticos.listadoNombresVideos.contains(
                            nombreNuevoVideo)){
                          return "Error: Nombre de video ya existe";
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
                    if(_keyValidador.currentState.validate()){
                      //Se abre el popup de cargando
                      PopUps.popUpCargando(context, 'Añadiendo video...');
                      //Obtengo el resultado del envio
                      var resultado = await enviarVideo(nombreNuevoVideo,
                          videoFinal).then((value) => value);

                      if(resultado){
                        //Si el envío es correcto, se redirecciona
                        //VideoElement video = Video
                        RedireccionarCrearLayout(videoAEnviar, "/var/www/html/VideosPostTv/$nombreNuevoVideo",true);

                      }else{
                        //Cierra popup cargando
                        Navigator.of(context, rootNavigator: true).pop();

                        PopUps.PopUpConWidget(context, Text('Error al enviar video'));
                      }

                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
      PopUps.PopUpConWidget(context, widget);
    }

  }

  Future<bool> enviarVideo(String nombre, File video) async{
    String videoBytes = base64Encode(video.readAsBytesSync());
    bool resultado = await http.post(DatosEstaticos.rutaSubidaVideos, body: {
      "video": videoBytes,
      "name": nombre,
    }).then((result) {
      if (result.statusCode == 200) {return true;}
    }).catchError((error) {
      return false;
    });
    return resultado;
  }

  // ignore: non_constant_identifier_names
  void RedireccionarCrearLayout(Widget video, String nombre,bool vieneDePopUp){
    if (vieneDePopUp){
      //Cierra popup cargando
      Navigator.of(context, rootNavigator: true).pop();
      //Cierra popup imagen
      Navigator.of(context, rootNavigator: true).pop();
    }

    //Se asigna además que porcion del layout se reemplazará
    switch(divisionLayout){
      case '1-1': {
        DatosEstaticos.wiget1 = video;
        DatosEstaticos.nombreArchivoWidget1 = nombre;
        DatosEstaticos.reemplazarPorcion1 = true;
        Navigator.pop(context, true);
      }
      break;
      case '2-1': {
        DatosEstaticos.wiget1 = video;
        DatosEstaticos.nombreArchivoWidget1 = nombre;
        DatosEstaticos.reemplazarPorcion1 = true;
        Navigator.pop(context, true);
      }
      break;
      case '2-2': {
        DatosEstaticos.wiget2 = video;
        DatosEstaticos.nombreArchivoWidget2 = nombre;
        DatosEstaticos.reemplazarPorcion2 = true;
        Navigator.pop(context, true);
      }
      break;
      case '3-1': {
        DatosEstaticos.wiget1 = video;
        DatosEstaticos.nombreArchivoWidget1 = nombre;
        DatosEstaticos.reemplazarPorcion1 = true;
        Navigator.pop(context, true);
      }
      break;
      case '3-2': {
        DatosEstaticos.wiget2 = video;
        DatosEstaticos.nombreArchivoWidget2 = nombre;
        DatosEstaticos.reemplazarPorcion2 = true;
        Navigator.pop(context, true);
      }
      break;
      case '3-3': {
        DatosEstaticos.wiget3 = video;
        DatosEstaticos.nombreArchivoWidget3 = nombre;
        DatosEstaticos.reemplazarPorcion3 = true;
        Navigator.pop(context, true);
      }
      break;
    }


  }
}




class ReproductorVideos extends StatefulWidget {
  var url;  //here declared
  ReproductorVideos({this.url});
  @override
  _ReproductorVideosState createState() => _ReproductorVideosState();
}

class _ReproductorVideosState extends State<ReproductorVideos> {

  VideoPlayerController _controller;

  @override
  void initState() {
    if(widget.url.runtimeType != String){
      _controller = VideoPlayerController.file(widget.url,);
    }else{
      _controller = VideoPlayerController.network(widget.url,);
    }
    // TODO: implement initState

    _controller.initialize();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: VideoPlayer(_controller)
          ),
          FlatButton(
            child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: (){
              setState(() {
                if(_controller.value.isPlaying){
                    _controller.pause();
                }else{
                  _controller.play();
                }
              });
            },
          ),
        ],
      ),
    );
  }
}