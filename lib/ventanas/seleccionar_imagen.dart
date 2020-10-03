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
    _listadoNombresImagenes = _getNombresImagenes();

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
                      child: Text('Seleccione una imagen'),
                    )
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (){abrirGaleria(context);},
                ),
              ],
            ),
            Expanded(
              //Acá hacer un future builder para nombres de imágenes
              child: FutureBuilder(
                future: _listadoNombresImagenes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done){
                    if (snapshot.data == null){
                      return Center(
                        child: Text('Error de conexión'),
                      );
                    } else {
                      //Future Builder para el gridview de imágenes
                      return GridView.builder(
                        //Toma el total de imágenes desde la carpeta del
                        // webserver
                          itemCount: DatosEstaticos
                              .listadoNombresImagenes
                              .length,
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                          itemBuilder: (context, index){
                            //Por cada imagen, busca su imagen.
                            // El nombre lo toma del listado estático
                            return GestureDetector(
                              onTap: (){
                                Widget imagen = Image.network('http://'
                                    '${DatosEstaticos.ipSeleccionada}'
                                    '/ImagenesPostTv/'
                                    '${DatosEstaticos.
                                listadoNombresImagenes[index]}'
                                );
                                String nombre = DatosEstaticos.
                                listadoNombresImagenes[index];
                                //DatosEstaticos.wiget1 = imagen;
                                RedireccionarCrearLayout(imagen, nombre, false);
                                return;
                              },
                              child: Image.network('http://'
                                  '${DatosEstaticos.ipSeleccionada}'
                                  '/ImagenesPostTv/'
                                  '${DatosEstaticos.listadoNombresImagenes[index]
                              }'),
                            );
                          });
                    }
                  }
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else{
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

/*  _getImagenesRaspberry() async {
    Socket socket;
    List<int> list = [];
    try{
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada,
          DatosEstaticos.puertoSocketRaspberry).timeout(Duration(seconds: 5));
      socket.add(utf8.encode('TVPOSTGETIMAGEN1'));
      socket.listen((event) {
        list.addAll(event);
        print(list.length);
      }).onDone(() {socket.close();});
      socket.done.whenComplete(() {
        Uint8List bytes = Uint8List.fromList(list);
        controlerStream.add(bytes);
      });
    }catch(e){
      print('Error Stream ${e.toString()}');
    }
  }*/

  Future<List> _getNombresImagenes() async {
    List<int> listadoValoresBytes = [];
    List datos;
    Socket socket;
    try{
      socket= await Socket.connect(DatosEstaticos.ipSeleccionada,
          DatosEstaticos.puertoSocketRaspberry).timeout(Duration(seconds: 5));
      socket.write('TVPOSTGETNOMBREIMAGENES');
      socket.listen((event) {
        listadoValoresBytes.addAll(event.toList());
        //socket.flush();
        //print(listadoValoresBytes.length);
      }).onDone(() {
        //DatosEstaticos.listadoNombresString = utf8.decode(listadoValoresBytes).split(",");
        datos =  utf8.decode(listadoValoresBytes).split(",");
        DatosEstaticos.listadoNombresImagenes = datos;
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
    String nombreNuevaImagen = "";
    imagenSeleccionadaGaleria = await FilePicker.platform.pickFiles(
        type: FileType.image);
    if (imagenSeleccionadaGaleria!=null){
      String extension = p.extension(imagenSeleccionadaGaleria.paths[0]);
      //print(extension);
      File imagenFinal = File(imagenSeleccionadaGaleria.paths[0]);
      Widget widget =
      SingleChildScrollView(
        child: Card(
          child: Form(
            key: _keyValidador,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(imagenFinal,),
                Center(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    controller: _controladorTexto,
                    validator: (textoEscrito){
                      if(textoEscrito.isEmpty){
                        return "Error: Nombre de imagen vacío";
                      }
                      if(textoEscrito.trim().length<= 0){
                        return "Error: Nombre de imagen vacío";
                      }
                      else {
                        nombreNuevaImagen = textoEscrito.trim()
                            .toString() + extension;
                        //Chequear si el valor ya existe
                        if (DatosEstaticos.listadoNombresImagenes.contains(
                            nombreNuevaImagen)){
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
                    if(_keyValidador.currentState.validate()){
                      //Se abre el popup de cargando
                      PopUps.popUpCargando(context, 'Añadiendo imagen...');
                      //Obtengo el resultado del envio
                      var resultado = await enviarImagen(nombreNuevaImagen,
                          imagenFinal).then((value) => value);

                      if(resultado){
                        //Si el envío es correcto, se redirecciona
                        Image imagen = Image.file(imagenFinal,);
                        RedireccionarCrearLayout(imagen, nombreNuevaImagen,true);

                      }else{
                        //Cierra popup cargando
                        Navigator.of(context, rootNavigator: true).pop();

                        PopUps.PopUpConWidget(context, Text('Error al enviar imagen'));
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

  Future<bool> enviarImagen(String nombre, File imagen) async{
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
  }

  // ignore: non_constant_identifier_names
  void RedireccionarCrearLayout(Widget imagen, String nombre,bool vieneDePopUp){
    if (vieneDePopUp){
      //Cierra popup cargando
      Navigator.of(context, rootNavigator: true).pop();
      //Cierra popup imagen
      Navigator.of(context, rootNavigator: true).pop();
    }

    switch(divisionLayout){
      case '1-1': {
        DatosEstaticos.wiget1 = imagen;
        DatosEstaticos.nombreArchivoWidget1 = nombre;
        Navigator.pop(context, true);
      }
      break;
      case '2-1': {
        DatosEstaticos.wiget1 = imagen;
        DatosEstaticos.nombreArchivoWidget1 = nombre;
        Navigator.pop(context, true);
      }
      break;
      case '2-2': {
        DatosEstaticos.wiget2 = imagen;
        DatosEstaticos.nombreArchivoWidget2 = nombre;
        Navigator.pop(context, true);
      }
      break;
      case '3-1': {
        DatosEstaticos.wiget1 = imagen;
        DatosEstaticos.nombreArchivoWidget1 = nombre;
        Navigator.pop(context, true);
      }
      break;
      case '3-2': {
        DatosEstaticos.wiget2 = imagen;
        DatosEstaticos.nombreArchivoWidget2 = nombre;
        Navigator.pop(context, true);
      }
      break;
      case '3-3': {
        DatosEstaticos.wiget3 = imagen;
        DatosEstaticos.nombreArchivoWidget3 = nombre;
        Navigator.pop(context, true);
        /*Navigator.popAndPushNamed(context,
            '/crear_layout3');*/
      }
      break;
    }
  }

/*  Future<List> _getImagenes(int index) async{
    Socket socket;
    List<int> listadoValoresBytes = [];
    List datos = [];
    Uint8List _imagenBytes;
    try{
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada,
          DatosEstaticos.puertoSocketRaspberry).timeout(Duration(seconds: 5));
      socket.add(utf8.encode('TVPOSTGETIMAGEN1'));
      socket.listen((event) {
        if(utf8.decode(event).contains('fin')){
          utf8.decode(event).replaceAll('fin', '');
          listadoValoresBytes.addAll(event.toList());
          //Transformo a imagen
          _imagenBytes = Uint8List.fromList(listadoValoresBytes);
          Image imagen = Image.memory(_imagenBytes);
          controlerStream.add(imagen);
        } else {
          listadoValoresBytes.addAll(event.toList());
        }

        //listadoValoresBytes.addAll(event.toList());
        //Image.memory(Uint8List.fromList(listadoRespuestas));

      }).onDone(() {
        //_imagenBytes = Uint8List.fromList(listadoRespuestas);
        //socket.write('RECIBIDO DESDE APP');
        DatosEstaticos.listadoImagenes = datos;
        print(datos.length);
        print('FIN');
        socket.close();
      });
      return null;
    } catch(e){
      print("Error get imagenes ${e.toString()}");
    }

  }*/

/*  Future<Uint8List> _getImagen(int index) async{
    Socket socket;
    List<int> listadoRespuestas = [];
    Uint8List _imagenBytes;
    try{
      socket = await Socket.connect(DatosEstaticos.ipSeleccionada,
          DatosEstaticos.puertoSocketRaspberry).timeout(Duration(seconds: 5));
      socket.write('TVPOSTGETIMAGEN$index');
      socket.listen((event) {
        listadoRespuestas.addAll(event.toList());
      }).onDone(() {
        _imagenBytes = Uint8List.fromList(listadoRespuestas);
        //socket.write('RECIBIDO DESDE APP');
        socket.close();
      });
      await socket.done.whenComplete(() => _imagenBytes);
      await Future.delayed(Duration(seconds: 3));
      return _imagenBytes;
    }catch(e){
      print("Error getImagen: ${e.toString()}");
    }
  }*/

}


/*
class SeleccionarImagen extends StatefulWidget {
  @override
  _SeleccionarImagenState createState() => _SeleccionarImagenState();
}


class _SeleccionarImagenState extends State<SeleccionarImagen> {
  Future<List<dynamic>> _listadoNombresImagenes;
  List listadoNombresString;
  //Guarda el estado del context para usarlo con el snackbar
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    //Acá se hace el llamado al listado de nombres de imágenes
    //_listadoNombresImagenes = _getNombresImagenes();
    //print(listadoNombresString);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                      child: Center(
                          child: Text('Seleccione una imagen'),
                      )
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: (){},
                  ),
                ],
              ),
              Expanded(
                //Acá hacer un future builder para nombres de imágenes
                child: FutureBuilder(
                  future: _getNombresImagenes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done){
                      if (snapshot.data == null){
                        return Center(
                          child: Text('Error de conexión'),
                        );
                      } else {
                        listadoNombresString = snapshot.data;
                        //Future Builder para el gridview de imágenes
                        
                        return RefreshIndicator(
                          onRefresh: ()=>_recargarGrid(),
                          child: GridView.count(
                            crossAxisCount: 2,
                            children: List.generate(12, (index) {
                              return Text(index.toString());
                            }),
                          ),
                        );
                      }
                    }
                    if (snapshot.connectionState == ConnectionState.waiting){
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    else{
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

  Future<List> _getNombresImagenes() async {
    List<int> listadoValoresBytes = [];
    List datos;
    Socket socket;
    try{
      socket= await Socket.connect(DatosEstaticos.ipSeleccionada,
          DatosEstaticos.puertoSocketRaspberry).timeout(Duration(seconds: 5));
    socket.write('TVPOSTGETNOMBREIMAGENES');
    socket.listen((event) {
      listadoValoresBytes.addAll(event.toList());
      //socket.flush();
      //print(listadoValoresBytes.length);
    }).onDone(() {
      //DatosEstaticos.listadoNombresString = utf8.decode(listadoValoresBytes).split(",");
       datos =  utf8.decode(listadoValoresBytes).split(",");
      socket.close();
    });
    await socket.done.whenComplete(() => datos);
    return datos;

    } catch(e){
      print("Error " + e.toString());
    }
  }

  Future<void> _recargarGrid() async {
    setState(() {

    });
  }
}
*/
