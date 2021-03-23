import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/rendering.dart';
import 'package:tvpost_flutter/utilidades/CloudStorage.dart';
import 'package:tvpost_flutter/utilidades/comunicacion_raspberry.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';
import 'package:tvpost_flutter/utilidades_crear_contenido/editableitem.dart';
import 'package:tvpost_flutter/utilidades_crear_contenido/emoticones.dart';
import 'package:tvpost_flutter/utilidades_crear_contenido/utilidad_widgetimagen.dart';
import 'package:tvpost_flutter/utilidades_crear_contenido/widgetimagen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tvpost_flutter/custom_icons_icons.dart';

class CrearContenido extends StatefulWidget {
  CrearContenido({Key key}) : super(key: key);

  @override
  _CrearContenidoState createState() => _CrearContenidoState();
}

class _CrearContenidoState extends State<CrearContenido> {
  EditableItem _activeItem;
  Offset _initPos, _currentPos;
  double _currentScale, _currentRotation;
  File archivoImagen, imagenFondo;
  bool _inAction = false;
  List<EditableItem> mockData = [];
  Color colorFondo;
  Text txt;
  String temoji, emoji, textoo, divisionLayout;
  final messages = <String>[];
  final controller = TextEditingController();
  TextEditingController controladorOferta;
  bool isEmojiVisible = false, isKeyboardVisible = false;
  GlobalKey key1, key2;
  Uint8List bytes2;
  Map datosDesdeVentanaAnterior = {};
  double altoCanvas = 350, anchoCanvas = 250;
  int espacioEnNube = -1;
  FocusNode nodoTexto;

  @override
  void initState() {
    super.initState();
    //Acá se hace el llamado al listado de nombres de imágenes
    //ComunicacionRaspberry.getNombresImagenes();
    _requestPermission();
    controladorOferta = TextEditingController();
    nodoTexto = FocusNode();
    _COnsultaEspacioEnNube();
    /*KeyboardVisibility.onChange.listen((bool isKeyboardVisible) {
      setState(() {
        this.isKeyboardVisible = isKeyboardVisible;
      });

      if (isKeyboardVisible && isEmojiVisible) {
        setState(() {
          isEmojiVisible = false;
        });
      }
    });*/
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (this.mounted) {
      controladorOferta.dispose();
      controller.dispose();
      nodoTexto.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    //Tomo los datos que vienen de la ventana anterior
    datosDesdeVentanaAnterior = ModalRoute.of(context).settings.arguments;
    if (datosDesdeVentanaAnterior != null) {
      divisionLayout = datosDesdeVentanaAnterior['division_layout'];
      if (divisionLayout.contains('-1')) {
        anchoCanvas = MediaQuery.of(context).size.width;
        altoCanvas = MediaQuery.of(context).size.height / 2.6;
      }
      if (divisionLayout.contains('2-')) {
        anchoCanvas = MediaQuery.of(context).size.width / 1.8;
        altoCanvas = MediaQuery.of(context).size.height / 2.6;
        //anchoCanvas = altoCanvas;
      }
      if (divisionLayout.contains('3-2')) {
        anchoCanvas = MediaQuery.of(context).size.width / 3;
        altoCanvas = MediaQuery.of(context).size.height / 2.6;
      }
      if (divisionLayout.contains('-3')) {
        anchoCanvas = MediaQuery.of(context).size.width;
        altoCanvas = MediaQuery.of(context).size.height / 8;
      }
    }

    final screen = MediaQuery.of(context).size;

    int _gbPermitidosCloud = int.parse(
        ObtieneDatos.listadoEmpresa[0]["f_GigasEnFirebase"]
    );

    _gbPermitidosCloud = _gbPermitidosCloud * 1024;

    //RETORNA EL WIDGET SOLO CUANDO YA SE CALCULÓ EL ESPACIO
    if (espacioEnNube >= 0){
      if (espacioEnNube >= _gbPermitidosCloud){
        //NO PERMITIDO
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('INSUFICIENTE ESPACIO EN LA NUBE\nCONTACTE CON PRODUCNOVA'),
              SizedBox(height: 10,),
              Center(
                child: FlatButton(
                  color: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side:
                      BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
                  child: Text(
                    'REGRESAR',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      }
      else {
        //PERMITIDO
        return Scaffold(
          appBar: divisionLayout == '0' ? CustomAppBar() : CustomAppBarSinMenu(),
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 30, bottom: 30),
                child: Text(
                  "DISEÑAR LAYOUT",
                  style: TextStyle(fontSize: 16.5),
                ),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Center(
                    child: WidgetToImage(builder: (key) {
                      this.key1 = key;
                      return Padding(
                        child: Container(
                          height: altoCanvas,
                          width: anchoCanvas,
                          color: colorFondo,
                          child: GestureDetector(
                            onScaleStart: (details) {
                              if (_activeItem == null) return;

                              _initPos = details.focalPoint;
                              _currentPos = _activeItem.position;
                              _currentScale = _activeItem.scale;
                              _currentRotation = _activeItem.rotation;
                            },
                            onScaleUpdate: (details) {
                              if (_activeItem == null) return;
                              final delta = details.focalPoint - _initPos;
                              final left = (delta.dx / screen.width) + _currentPos.dx;
                              final top = (delta.dy / screen.height) + _currentPos.dy;

                              setState(() {
                                _activeItem.position = Offset(left, top);
                                _activeItem.rotation =
                                    details.rotation + _currentRotation;
                                _activeItem.scale = details.scale * _currentScale;
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                  color: Colors.black12,
                                ),
                                imagenDeFondo(),
                                ...mockData.map(_buildItemWidget).toList(),
                              ],
                            ),
                          ),
                        ),
                        padding: _PaddingPorcion3(),
                      );
                    }),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: 30, bottom: 10),
                    height: MediaQuery.of(context).size.height / 4,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 1,
                            ),
                            botonColorFondo(),
                            botonJPG(),
                            botonPNG(),
                            botonTexto(),
                            botonEmoji(),
                            botonOferta(),
                            SizedBox(
                              width: 20,
                            )
                          ],
                        ),
                        //SizedBox(height: 20,),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          //height:MediaQuery.of(context).size.height / 4,
                          //color: Colors.pink,
                          child: Row(
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height/30),
                                  Container(
                                    //margin: EdgeInsets.symmetric(horizontal: 90),
                                    width: 200.0,
                                    height: 40.0,
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
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side:
                                          BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
                                      child: Text(
                                        'CARGAR',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        //FUNCIÓN QUE PROCESA EL GUARDADO
                                        List<dynamic> resultado = await _ProcesarImagen();

                                        if (resultado != null) {
                                          //Si el envío es correcto, se redirecciona
                                          Image imagen = Image.network(
                                            "http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/${resultado[1]}",
                                            fit: BoxFit.cover,
                                          );

                                          RedireccionarCrearLayout(
                                              imagen,
                                              "/var/www/html/ImagenesPostTv/${resultado[1]}",
                                              true);
                                        } else {
                                          //Cierra popup cargando
                                          Navigator.of(context, rootNavigator: true).pop();

                                          PopUps.PopUpConWidget(context,
                                              Text('Error al enviar imagen'.toUpperCase()));
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  //BTN ESPECÍFICO PARA RRSS EN PORCIONES
                                  btnCompartirRRSS(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        /*
                    Container(
                      //margin: EdgeInsets.symmetric(horizontal: 90),
                      width: 200.0,
                      height: 40.0,
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side:
                                BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
                        child: Text(
                          'CARGAR',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          PopUps.popUpCargando(
                              context, 'Guardando Imagen'.toUpperCase());
                          final bytes1 = await Utils.capture(key1);
                          //Cierra popup cargando
                          Navigator.of(context, rootNavigator: true).pop();

                          await _finalizarGuardado(bytes1);
                        },
                      ),
                    ),

                     */
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else{
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('COMPROBANDO ESPACIO EN LA NUBE'),
            SizedBox(height: 10,),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }
  }

  Future _COnsultaEspacioEnNube()async{
    int espacio = await CloudStorage.GetUsedSpace();
    setState(() {
      espacioEnNube = espacio;
    });

  }

  ///BOTON QUE CARGA UN BOTON GRIS ANTES DE PERMITIR O DENEGAR EL SUBRI ARCHIVOS
  ///A LA NUBE
  ///
  /*
  Widget _btnAddContenido(){
    int _gbPermitidosCloud = int.parse(
        ObtieneDatos.listadoEmpresa[0]["f_GigasEnFirebase"]
    );

    _gbPermitidosCloud = _gbPermitidosCloud * 1024;

    if (espacioEnNube <= _gbPermitidosCloud){
      //NO PERMITIDO
      return FlatButton(
        color: Colors.grey,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side:
            BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
        child: Text(
          'CARGAR',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          Widget contenidoPopUp = Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: HexColor('#f4f4f4')),
              height: 110,
              width: 250,
              child: Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //Título
                    Column(
                      children: [
                        Text(
                          'MÁXIMO ESPACIO UTILIZADO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    Text('Contacte con ProducNova',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontFamily: 'textoMont')),
                  ],
                ),
              ));
          PopUps.PopUpConWidget(context,contenidoPopUp);
        },
      );
    }

    //PERMITIDO
    return FlatButton(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side:
          BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
      child: Text(
        'CARGAR',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        //FUNCIÓN QUE PROCESA EL GUARDADO
        List<dynamic> resultado = await _ProcesarImagen();

        if (resultado != null) {
          //Si el envío es correcto, se redirecciona
          Image imagen = Image.network(
            "http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/${resultado[1]}",
            fit: BoxFit.cover,
          );

          RedireccionarCrearLayout(
              imagen,
              "/var/www/html/ImagenesPostTv/${resultado[1]}",
              true);
        } else {
          //Cierra popup cargando
          Navigator.of(context, rootNavigator: true).pop();

          PopUps.PopUpConWidget(context,
              Text('Error al enviar imagen'.toUpperCase()));
        }
      },
    );
    /*
    FutureBuilder containerBtn = FutureBuilder(
        future: CloudStorage.GetUsedSpace(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.data as int >= _gbPermitidosCloud)
              //NO PERMITIDO
              return FlatButton(
                color: Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side:
                    BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
                child: Text(
                  'CARGAR',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  Widget contenidoPopUp = Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: HexColor('#f4f4f4')),
                      height: 110,
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25, bottom: 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //Título
                            Column(
                              children: [
                                Text(
                                  'MÁXIMO ESPACIO UTILIZADO',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            Text('Contacte con ProducNova',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 13, fontFamily: 'textoMont')),
                          ],
                        ),
                      ));
                  PopUps.PopUpConWidget(context,contenidoPopUp);
                },
              );
            else
              //PERMITIDO
              return FlatButton(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side:
                    BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
                child: Text(
                  'CARGAR',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  //FUNCIÓN QUE PROCESA EL GUARDADO
                  List<dynamic> resultado = await _ProcesarImagen();

                  if (resultado != null) {
                    //Si el envío es correcto, se redirecciona
                    Image imagen = Image.network(
                      "http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/${resultado[1]}",
                      fit: BoxFit.cover,
                    );

                    RedireccionarCrearLayout(
                        imagen,
                        "/var/www/html/ImagenesPostTv/${resultado[1]}",
                        true);
                  } else {
                    //Cierra popup cargando
                    Navigator.of(context, rootNavigator: true).pop();

                    PopUps.PopUpConWidget(context,
                        Text('Error al enviar imagen'.toUpperCase()));
                  }
                },
              );
          }
          return FlatButton(
            color: Colors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side:
                BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
            child: Text(
              'CARGAR',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Widget contenidoPopUp = Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: HexColor('#f4f4f4')),
                  height: 110,
                  width: 250,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //Título
                        Column(
                          children: [
                            Text(
                              'CALCULANDO ESPACIO DISPONIBLE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
              PopUps.PopUpConWidget(context,contenidoPopUp);
            },
          );
        }

    );


    return containerBtn;

     */

  }

   */


  ///WIDGET QUE CONTROLA EL BOTÓN COMPARTIR RRSS
  Widget btnCompartirRRSS(){
    /*
    int _gbPermitidosCloud = int.parse(
        ObtieneDatos.listadoEmpresa[0]["f_GigasEnFirebase"]
    );

    _gbPermitidosCloud = _gbPermitidosCloud * 1024;

     */
    String _porcion = DatosEstaticos.divisionLayout;
    Widget btn;

    if (_porcion == "3-2" || _porcion == "3-3"){
      btn = Container(
        child: Text(
          "PUBLICACIÓN REDES SOCIALES\n NO HABILITADA EN ESTA PORCIÓN",
          textAlign: TextAlign.center,
        ),
      );
    } else {
      btn = Container(
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

            //SI HAY UN LINK YA LISTO PARA PUBLICAR
            //PREGUNTAR SI DESEA REEMPLAZARLO
            String pNombre = await Publicar();

            if (pNombre != null){
              //Se Descarga video inmediatamente al cargar
              List<String> _verificarImagen = new List<String>();
              _verificarImagen.add("/var/www/html/ImagenesPostTv/$pNombre");
              PopUps.popUpCargando(context, "DESCARGANDO ARCHIVOS");

              await ComunicacionRaspberry.CompruebaArchivosRaspberry(
                  pLinksAEnviar: _verificarImagen
              );

              Navigator.of(context).pop();

              String img = "http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/"
                  "$pNombre";

              Widget imagen = Image.network(img);

              RedireccionarCrearLayout(
                  imagen,
                  "/ImagenesPostTv/$pNombre",
                  true);
            }
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
      );
    }
    return btn;

    /*
    //CONTROLA EL PERMISO A SUBIR IMAGEN
    FutureBuilder containerBtn = FutureBuilder(
        future: CloudStorage.GetUsedSpace(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            if (snapshot.data as int >= _gbPermitidosCloud)
              //NO PERMITIDO
              return Container(
                height: 40,
                width: 200,
                child: FlatButton(
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side:
                      BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
                  onPressed: () async {
                    Widget contenidoPopUp = Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                            color: HexColor('#f4f4f4')),
                        height: 110,
                        width: 250,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25, bottom: 25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //Título
                              Column(
                                children: [
                                  Text(
                                    'MÁXIMO ESPACIO UTILIZADO',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),

                              Text('Contacte con ProducNova',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, fontFamily: 'textoMont')),
                            ],
                          ),
                        ));
                    PopUps.PopUpConWidget(context,contenidoPopUp);
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
              );
            else
              //PERMITIDO
            if (_porcion == "3-2" || _porcion == "3-3"){
              btn = Container(
                child: Text(
                  "PUBLICACIÓN REDES SOCIALES\n NO HABILITADA EN ESTA PORCIÓN",
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              btn = Container(
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

                    //SI HAY UN LINK YA LISTO PARA PUBLICAR
                    //PREGUNTAR SI DESEA REEMPLAZARLO
                    String pNombre = await Publicar();

                    if (pNombre != null){
                      //Se Descarga video inmediatamente al cargar
                      List<String> _verificarImagen = new List<String>();
                      _verificarImagen.add("/var/www/html/ImagenesPostTv/$pNombre");
                      PopUps.popUpCargando(context, "DESCARGANDO ARCHIVOS");

                      await ComunicacionRaspberry.CompruebaArchivosRaspberry(
                          pLinksAEnviar: _verificarImagen
                      );

                      Navigator.of(context).pop();

                      String img = "http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/"
                          "$pNombre";

                      Widget imagen = Image.network(img);

                      RedireccionarCrearLayout(
                          imagen,
                          "/ImagenesPostTv/$pNombre",
                          true);
                    }
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
              );
            }
            return btn;
          }
          return Container(
            height: 40,
            width: 200,
            child: FlatButton(
              color: Colors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side:
                  BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
              onPressed: () async {
                Widget contenidoPopUp = Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: HexColor('#f4f4f4')),
                    height: 110,
                    width: 250,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25, bottom: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //Título
                          Column(
                            children: [
                              Text(
                                'CALCULANDO ESPACIO DISPONIBLE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ));
                PopUps.PopUpConWidget(context,contenidoPopUp);
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
          );
        }

    );

    return containerBtn;

     */
  }

  Widget _buildItemWidget(EditableItem e) {
    final screen = MediaQuery.of(context).size;

    var widget;
    switch (e.type) {
      case ItemType.Text:
        widget = e.value;
        break;
      case ItemType.Image:
        widget = Image.file(
          e.valor,
          width: 350,
          height: 350,
        );
        break;
      case ItemType.Image2:
        widget = Image.memory(
          e.byte,
          height: 200,
          width: 200,
        );
    }

    return Positioned(
      top: e.position.dy * screen.height,
      left: e.position.dx * screen.width,
      child: Transform.scale(
        scale: e.scale,
        child: Transform.rotate(
          angle: e.rotation,
          child: Listener(
            onPointerDown: (details) {
              if (_inAction) return;
              _inAction = true;
              _activeItem = e;
              _initPos = details.position;
              _currentPos = e.position;
              _currentScale = e.scale;
              _currentRotation = e.rotation;
            },
            onPointerUp: (details) {
              _inAction = false;
            },
            child: widget,
          ),
        ),
      ),
    );
  }

  Future<void> _showChoiceDialog(BuildContext context) {
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
                Text("CARGAR IMÁGENES ", style: TextStyle(fontSize: 13)),
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

  Future<void> _showChoiceDialog2(BuildContext context) {
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
                Text("CARGAR IMÁGENES ", style: TextStyle(fontSize: 13)),
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
                        _abrirCamara2(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Icon(Icons.photo_album,
                          size: 40, color: HexColor('#FC4C8B')),
                      onTap: () {
                        _abrirGaleria2(context);
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
                        _abrirCamara2(context);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text(
                        "GALERÍA",
                        style: TextStyle(fontSize: 10),
                      ),
                      onTap: () {
                        _abrirGaleria2(context);
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

  _abrirGaleria(BuildContext context) async {
    var imagen = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      archivoImagen = imagen;
    });
    if (imagen != null) {
      mockData.add(
        EditableItem()
          ..type = ItemType.Image
          ..valor = archivoImagen,
      );
    }
    Navigator.of(context).pop();
  }

  _abrirGaleria2(BuildContext context) async {
    var imagen = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imagenFondo = imagen;
    });
    Navigator.of(context).pop();
  }

  _abrirCamara(BuildContext context) async {
    var imagen = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      archivoImagen = imagen;
    });
    if (imagen != null) {
      mockData.add(
        EditableItem()
          ..type = ItemType.Image
          ..valor = archivoImagen,
      );
    }

    Navigator.of(context).pop();
  }

  _abrirCamara2(BuildContext context) async {
    var imagen = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState(() {
      imagenFondo = imagen;
    });
    Navigator.of(context).pop();
  }

  _ponerOferta(BuildContext context) async {
    final bytes2 = await Utils.capture(key2);
    setState(() {
      this.bytes2 = bytes2;
    });
    mockData.add(
      EditableItem()
        ..type = ItemType.Image2
        ..byte = bytes2,
    );
    Navigator.of(context).pop();
  }

  Widget buildImage(Uint8List bytes) =>
      bytes != null ? Image.memory(bytes) : Container();

  Widget botonJPG() {
    return SizedBox(
      width: 50,
      child: FlatButton(
        onPressed: () {
          _showChoiceDialog2(context);
        },
        child: Icon(
          CustomIcons.jpg,
          size: 35,
          color: HexColor('#0683FF'),
        ),
      ),
    );
  }

  Widget botonColorFondo() {
    return SizedBox(
      width: 50,
      child: FlatButton(
        onPressed: () {
          _colorFondo(context);
        },
        child: Icon(
          CustomIcons.color,
          size: 35,
          color: HexColor('#0683FF'),
        ),
      ),
    );
  }

  Future<void> _colorFondo(BuildContext context) {
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
            height: 240,
            width: 250,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: Text("COLOR", style: TextStyle(fontSize: 13)),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    child: new ColorPicker(
                      colorPickerWidth: 250,
                      enableAlpha: false,
                      showLabel: false,
                      pickerColor: Colors.black,
                      onColorChanged: (value) {
                        setState(() {
                          imagenFondo = null;
                          colorFondo = value;
                        });
                      },
                      pickerAreaHeightPercent: 0.25,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.check_circle,
                      color: HexColor('#3EDB9B'),
                      size: 30,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ///RETORNA EL ESPACIO TOP PARA HACER QUE EL CREAR EN PORCIÓN 3 QUEDE EN LA
  ///MITAD DEL DISPOSITIVO
  EdgeInsets _PaddingPorcion3(){
    if (DatosEstaticos.divisionLayout == "3-3"){
      return EdgeInsets.only(top: MediaQuery.of(context).size.height/8);
    }
    return EdgeInsets.zero;
  }

  ///REALIZA EL PROCESO DE GUARDADO DE IMAGEN
  Future<List<dynamic>> _ProcesarImagen() async {
    PopUps.popUpCargando(
        context, 'Guardando Imagen'.toUpperCase());
    final bytes1 = await Utils.capture(key1);
    //Cierra popup cargando
    Navigator.of(context, rootNavigator: true).pop();

    List<dynamic> resultado = await _finalizarGuardado(bytes1);

    return resultado;
  }

  ///MUESTRA POPUP PARA CONFIRMAR REEMPLAZO DE LINK A PUBLICAR SI ES QUE YA
  ///EXISTE ALGUNO SELECCIONADO
  Future<String> Publicar() async {
    List<dynamic> resultado = new List<dynamic>();

    if (DatosEstaticos.idImagenPUblicarRRSS != ""){
      bool reemplazo = await _popUpReemplazoLinkRRSS();
      if (reemplazo){
        resultado = await _ProcesarImagen();
      } else {
        return null;
      }
    }
    else{
      resultado = await _ProcesarImagen();
    }

    //SE AÑADE EL ID DE LA IMAGEN A COMPARTIR
    DatosEstaticos.idImagenPUblicarRRSS = "http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/${resultado[1]}";

    return resultado[1];
  }

  ///Popup que pregunta si desea reemplazar publicación o no
   Future<bool> _popUpReemplazoLinkRRSS() async{
    bool valorARetornar;
    Widget contenidoPopUp = Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: HexColor('#f4f4f4')),
        height: 150,
        width: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text('YA EXISTE UNA IMAGEN PARA PUBLICAR\n'
                  '¿DESEA REEMPLAZARLA POR ESTA?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 3, child: SizedBox()),
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      child: Icon(
                        Icons.check_circle,
                        color: HexColor('#3EDB9B'),
                        size: 35,
                      ),
                      onTap: (){
                        //Link para publicar en RRSS
                        valorARetornar = true;
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      child: Icon(
                        Icons.cancel,
                        color: HexColor('#FC4C8B'),
                        size: 35,
                      ),
                      onTap: () {
                        valorARetornar = false;
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ),
                  Expanded(flex: 3, child: SizedBox()),
                ],
              ),
            ),
          ],
        ));
    var valor = await PopUps.PopUpConWidgetAsync(context, contenidoPopUp);
    valor = valorARetornar;
    return valor;
  }



  Widget botonPNG() {
    return SizedBox(
      width: 50,
      child: FlatButton(
        onPressed: () {
          _showChoiceDialog(context);
        },
        child: Icon(
          CustomIcons.png,
          size: 35,
          color: HexColor('#0683FF'),
        ),
      ),
    );
  }

  Widget botonTexto() {
    return SizedBox(
      width: 50,
      child: FlatButton(
        onPressed: () {
          _eltexto(context);
        },
        child: Icon(
          CustomIcons.txt,
          size: 35,
          color: HexColor('#0683FF'),
        ),
      ),
    );
  }

  Future<void> _eltexto(BuildContext context) {
    Color colorTexto = Colors.black;

    void _colorTexto(Color color) {
      setState(() {
        colorTexto = color;
      });
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.only(bottom: 17, top: 17, left: 5, right: 5),
          backgroundColor: Colors.grey.withOpacity(0.0),
          content: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: HexColor('#f4f4f4')),
              height: MediaQuery.of(context).size.height / 1.7,
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text("TEXTO", style: TextStyle(fontSize: 13)),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 220,
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Ingrese texto aquí',
                        ),
                        onChanged: (String str) {
                          this.setState(() {
                            textoo = str;
                          });
                        },
                      ),
                    ),
                    new ColorPicker(
                      enableAlpha: false,
                      showLabel: false,
                      displayThumbColor: true,
                      pickerColor: colorTexto,
                      onColorChanged: (value) {
                        _colorTexto(value);
                        setState(() {});
                      },
                      pickerAreaHeightPercent: 0.7,
                      colorPickerWidth: 220,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (textoo != null) {
                              if (textoo.isNotEmpty &&
                                  textoo.trim().length > 0) {
                                setState(() {
                                  txt = Text(
                                    textoo,
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .apply(
                                            fontSizeFactor: 0.5,
                                            decoration: TextDecoration.none,
                                            color: colorTexto),
                                  );
                                  mockData.add(
                                    EditableItem()
                                      ..type = ItemType.Text
                                      ..value = txt,
                                  );
                                });
                              }
                            }
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.check_circle,
                            color: HexColor('#3EDB9B'),
                            size: 30,
                          ),
                        ),
                        GestureDetector(
                            child: Icon(
                              Icons.cancel,
                              color: HexColor('#FC4C8B'),
                              size: 30,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            }),
                      ],
                    )
                  ],
                ),
              )),
        );
      },
    );
  }

  Widget botonEmoji() {
    return SizedBox(
      width: 50,
      child: FlatButton(
        onPressed: () {
          showAlertDialog(context);
        },
        child: Icon(
          CustomIcons.emoji,
          size: 35,
          color: HexColor('#0683FF'),
        ),
      ),
    );
  }

  Widget botonOferta() {
    return SizedBox(
      width: 50,
      child: FlatButton(
        onPressed: () {
          return PopUpOferta();
        },
        child: Icon(
          CustomIcons.oferta,
          size: 35,
          color: HexColor('#0683FF'),
        ),
      ),
    );
  }

  PopUpOferta() {
    if (controladorOferta.text.length > 0) {
      controladorOferta.text = "";
    }

    // Valores para color de fonddo y texto
    Color pickerColorFondo = Color(0xFFFF0000);
    Color pickerColorTexto = Color(0xffffffff);
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        //Funciones que cambian y devuelven color
        void changeColorFondo(Color color) {
          setState(() {
            pickerColorFondo = color;
          });
        }

        //Funciones que cambian y devuelven color
        void changeColorLetras(Color color) {
          setState(() {
            pickerColorTexto = color;
          });
        }

        void Limite(valor) {
          if (valor > 3) {
            AlertDialog alert = AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Solo 3 caracteres para oferta"),
                ],
              ),
            );
            showDialog(
              barrierDismissible: true,
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );
            controladorOferta.text = controladorOferta.text.substring(0, 3);
          } else {
            //Oculta teclado
            FocusScope.of(context).unfocus();
          }
        }

        return StatefulBuilder(builder: (context, setState) {
          return Center(
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Limite(controladorOferta.text.length);
                },
                child: AlertDialog(
                  contentPadding:
                      EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
                  backgroundColor: Colors.grey.withOpacity(0.0),
                  content: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: HexColor('#f4f4f4')),
                      height: 500,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("OFERTA",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13)),
                          WidgetToImage(builder: (key) {
                            this.key2 = key;
                            return GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(nodoTexto);
                                //print(foc);
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    height:
                                        MediaQuery.of(context).size.height / 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: pickerColorFondo,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          'OFERTA',
                                          style: TextStyle(
                                              color: pickerColorTexto),
                                        ),
                                        Container(
                                          width: 110,
                                          //margin: EdgeInsets.only(left: 5.0),
                                          alignment: Alignment.center,
                                          child: TextFormField(
                                            focusNode: nodoTexto,
                                            autofocus: true,
                                            controller: controladorOferta,
                                            maxLengthEnforced: true,
                                            textAlign: TextAlign.center,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            maxLength: 3,
                                            maxLines: 1,
                                            onEditingComplete: () {
                                              Limite(controladorOferta
                                                  .text.length);
                                            },
                                            //Decoración caja
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                              counterText: "",
                                            ),
                                            //Decoración Texto
                                            style: TextStyle(
                                              color: pickerColorTexto,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  17,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        10,
                                    height:
                                        (MediaQuery.of(context).size.height /
                                                6) -
                                            10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: pickerColorTexto,
                                          width: 2.0,
                                          style: BorderStyle.solid),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text("COLOR DE FONDO",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13)),
                              ),
                              ColorPicker(
                                //Sin barra deslizadora de degradación
                                enableAlpha: false,
                                pickerColor: pickerColorFondo,
                                showLabel: false,
                                displayThumbColor: true,
                                pickerAreaHeightPercent: 0.15,
                                onColorChanged: (color) {
                                  changeColorFondo(color);
                                  setState(() {});
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text("COLOR DE TEXTO",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13)),
                              ),
                              ColorPicker(
                                //Sin barra deslizadora de degradación
                                enableAlpha: false,
                                pickerColor: pickerColorTexto,
                                showLabel: false,
                                displayThumbColor: true,
                                pickerAreaHeightPercent: 0.15,
                                onColorChanged: (color) {
                                  changeColorLetras(color);
                                  setState(() {});
                                },
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      //Acá se debe sacar el screenshot de la oferta
                                      // o moverlo
                                      //**//
                                      _ponerOferta(context);
                                    },
                                    child: Icon(
                                      Icons.check_circle,
                                      color: HexColor('#3EDB9B'),
                                      size: 30,
                                    ),
                                  ),
                                  GestureDetector(
                                      child: Icon(
                                        Icons.cancel,
                                        color: HexColor('#FC4C8B'),
                                        size: 30,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                      }),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert;
    // Configura el popup
    alert = AlertDialog(
        contentPadding:
            const EdgeInsets.only(bottom: 20, top: 0, left: 20, right: 20),
        backgroundColor: Colors.grey.withOpacity(0.0),
        content: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: HexColor('#f4f4f4')),
          height: 420,
          width: 400,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("EMOJI", style: TextStyle(fontSize: 13)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      EmojiPickerWidget(
                        onEmojiSelected: onEmojiSelected,
                      )
                    ],
                  ),
                ),
              ]),
        ));

    // Muestro el popup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void onEmojiSelected(String emojiEscogido) {
    setState(
      () {
        this.emoji = emojiEscogido;
        Navigator.of(context).pop();
        temoji = this.emoji;
        mockData.add(
          EditableItem()
            ..type = ItemType.Text
            ..value = Text(
              temoji,
              style: DefaultTextStyle.of(context)
                  .style
                  .apply(fontSizeFactor: 1.5, decoration: TextDecoration.none),
            ),
        );
      },
    );
  }

  Widget imagenDeFondo() {
    if (imagenFondo == null) {
      return Text("");
    } else {
      return Image.file(
        imagenFondo,
        width: anchoCanvas,
        height: altoCanvas,
        fit: BoxFit.fill,
      );
    }
  }

  _requestPermission() async {
    await [
      Permission.storage,
    ].request();

    //final info = statuses[Permission.storage].toString();
    //print();
    //_toastInfo('Permisos');
  }

  /*_toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }*/

  Future<List<dynamic>> _finalizarGuardado(Uint8List imagenEnBytes) async {
    //GlobalKey<FormState> _keyValidadorTxtImagen = GlobalKey<FormState>();
    PopUps.popUpCargando(context, 'Cambiando tamaño'.toUpperCase());

    //Redimensiono imagen en memoria
    imagenEnBytes = await Utils.redimensionarImg(imagenEnBytes, divisionLayout);

    //Cierra popup cargando
    Navigator.of(context, rootNavigator: true).pop();

    PopUps.popUpCargando(context, 'Añadiendo imagen'.toUpperCase());

    //Se crea el archivo final del tamaño modificado
    File temporal =  await Utils.crearArchivoTemporalRedimensionado(
        imagenEnBytes);

    //Se sube listado de imágenes a FireBase
    List<dynamic> resultado = await SubidaImagenes(temporal);

    //Cierra popup añadiendo
    Navigator.of(context, rootNavigator: true).pop();

    return resultado;
  }

  // ignore: non_constant_identifier_names
  Future<void> RedireccionarCrearLayout(
      Widget imagen, String nombre, bool vieneDePopUp) async {
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
      case '1-1':
        {
          DatosEstaticos.widget1 = imagen;
          DatosEstaticos.nombreArchivoWidget1 = nombre;
          DatosEstaticos.reemplazarPorcion1 = true;
        }
        break;
      case '2-1':
        {
          DatosEstaticos.widget1 = imagen;
          DatosEstaticos.nombreArchivoWidget1 = nombre;
          DatosEstaticos.reemplazarPorcion1 = true;
        }
        break;
      case '2-2':
        {
          DatosEstaticos.widget2 = imagen;
          DatosEstaticos.nombreArchivoWidget2 = nombre;
          DatosEstaticos.reemplazarPorcion2 = true;
        }
        break;
      case '3-1':
        {
          DatosEstaticos.widget1 = imagen;
          DatosEstaticos.nombreArchivoWidget1 = nombre;
          DatosEstaticos.reemplazarPorcion1 = true;
        }
        break;
      case '3-2':
        {
          DatosEstaticos.widget2 = imagen;
          DatosEstaticos.nombreArchivoWidget2 = nombre;
          DatosEstaticos.reemplazarPorcion2 = true;
        }
        break;
      case '3-3':
        {
          DatosEstaticos.widget3 = imagen;
          DatosEstaticos.nombreArchivoWidget3 = nombre;
          DatosEstaticos.reemplazarPorcion3 = true;
        }
        break;
    }
    //Eliminar archivos temporales
    Directory dir = await getTemporaryDirectory();
    dir.deleteSync(recursive: true);
    Navigator.pop(context, true);
  }

  ///SUBE UN LISTADO DE IMÁGENES SELECCIONADAS DEVOLVIENDO EL ARCHIVO EN STORAGE
  ///ID IMAGEN Y URL EN FIREBASE
  ///{0} = ARCHIVOSTORAGE
  ///{1} = ID IMAGEN
  ///{2} = URL
  Future<List<dynamic>> SubidaImagenes(File imagenSeleccionadaGaleria) async{

    //Listado de resultado e imagen
    List<dynamic> listadoResultado = List<dynamic>();
    List<File> listadoArchivos = new List<File>();

    listadoArchivos.add(imagenSeleccionadaGaleria);
    PopUps.popUpCargando(context, 'Agregando imagenes'.toUpperCase());

    ///Comienzo de uso de firebase
    List<String> resultadoFirebase = await CloudStorage.SubirImagenFirebase(listadoArchivos);

    if (DatosEstaticos.ipSeleccionada!=null){
      await ComunicacionRaspberry.EnviarImagenPorHTTP(resultadoFirebase[0], imagenSeleccionadaGaleria);
      await ComunicacionRaspberry.ReplicarImagen(resultadoFirebase[0]);
    }


    listadoResultado.add(imagenSeleccionadaGaleria);
    listadoResultado.add(resultadoFirebase[0]);
    listadoResultado.add(resultadoFirebase[1]);
    return listadoResultado;
  }
}
