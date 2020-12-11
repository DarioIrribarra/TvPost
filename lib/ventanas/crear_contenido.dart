import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/rendering.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades_crear_contenido/editableitem.dart';
import 'package:tvpost_flutter/utilidades_crear_contenido/emoticones.dart';
import 'package:tvpost_flutter/utilidades_crear_contenido/utilidad_widgetimagen.dart';
import 'package:tvpost_flutter/utilidades_crear_contenido/widgetimagen.dart';
import 'package:path_provider/path_provider.dart';

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

  @override
  void initState() {
    super.initState();
    //Acá se hace el llamado al listado de nombres de imágenes
    PopUps.getNombresImagenes();
    _requestPermission();
    controladorOferta = TextEditingController();
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
    if(this.mounted){
      controladorOferta.dispose();
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    //Tomo los datos que vienen de la ventana anterior
    datosDesdeVentanaAnterior = ModalRoute.of(context).settings.arguments;
    if (datosDesdeVentanaAnterior != null){
      divisionLayout = datosDesdeVentanaAnterior['division_layout'];
      if (divisionLayout.contains('-1')){
        anchoCanvas = MediaQuery.of(context).size.width;
        altoCanvas = MediaQuery.of(context).size.height/4;
      }
      if (divisionLayout.contains('2-')){
        anchoCanvas = MediaQuery.of(context).size.width;
        altoCanvas = MediaQuery.of(context).size.height/2;
      }
      if (divisionLayout.contains('3-2')){
        anchoCanvas = MediaQuery.of(context).size.width/3;
        altoCanvas = MediaQuery.of(context).size.height/2;
      }
      if (divisionLayout.contains('-3')){
        anchoCanvas = MediaQuery.of(context).size.width;
        altoCanvas = MediaQuery.of(context).size.height/8;
      }
    }

    final screen = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Center(
                child: Container(
                  child: Text("DISEÑAR LAYOUT"),
                  margin: EdgeInsets.only(top: 30),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              WidgetToImage(builder: (key) {
                this.key1 = key;
                return Container(
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
                );
              }),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  height: 60,
                  child: Row(
                    children: [
                      botonJPG(),
                      botonColorFondo(),
                      botonPNG(),
                      botonTexto(),
                      botonEmoji(),
                      botonOferta(),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 100),
                width: 150.0,
                height: 30.0,
                child: RaisedButton(
                  color: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Color.fromARGB(30, 0, 0, 0))),
                  child: Text(
                    'Guardar Imagen',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    PopUps.popUpCargando(context, 'Guardando Imagen');
                    final bytes1 = await Utils.capture(key1);
                    //Cierra popup cargando
                    Navigator.of(context, rootNavigator: true).pop();
                    /*setState(() {
                      this.bytes1 = bytes1;
                    });*/
                    //Acá tiene que aparecer el popup para guardar imagen con nombre,
                    //al igual que en el seleccionar imagen
                    await _finalizarGuardado(bytes1);
                  },
                ),
              ),
              /*Container(
                height: 500,
                child: buildImage(bytes1),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  /*Future<bool> onBackPress() {
    if (archivoImagen == null) {
      Navigator.pop(context);
    }
    return Future.value(false);
  }*/

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
          title: Text("Elegir opción: "),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("Galeria"),
                  onTap: () {
                    _abrirGaleria(context);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text("Camara"),
                  onTap: () {
                    _abrirCamara(context);
                  },
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
          title: Text("Elegir opción: "),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("Galeria"),
                  onTap: () {
                    _abrirGaleria2(context);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text("Camara"),
                  onTap: () {
                    _abrirCamara2(context);
                  },
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
    return Container(
      margin: EdgeInsets.only(left: 10),
      width: 55,
      child: RaisedButton(
        onPressed: () {
          _showChoiceDialog2(context);
        },
        child: Icon(
          Icons.photo_size_select_actual,
          color: Colors.white,
        ),
        color: Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(
            color: Color.fromARGB(30, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  Widget botonColorFondo() {
    return Container(
      margin: EdgeInsets.only(left: 5),
      width: 55,
      child: RaisedButton(
        onPressed: () {
          _colorFondo(context);
        },
        child: Icon(
          Icons.colorize,
          color: Colors.white,
        ),
        color: Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color.fromARGB(30, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  Future<void> _colorFondo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Elegir color: "),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: new ColorPicker(
                    enableAlpha: false,
                    showLabel: false,
                    pickerColor: Colors.black,
                    onColorChanged: (value) {
                      setState(() {
                        imagenFondo = null;
                        colorFondo = value;
                      });
                    },
                    pickerAreaHeightPercent: 0.7,
                  ),
                ),
                GestureDetector(
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.lightBlue,
                      ),
                      color: Colors.white,
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget botonPNG() {
    return Container(
      margin: EdgeInsets.only(left: 5),
      width: 55,
      child: RaisedButton(
        onPressed: () {
          _showChoiceDialog(context);
        },
        child: Icon(
          Icons.add_photo_alternate,
          color: Colors.white,
        ),
        color: Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(
            color: Color.fromARGB(30, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  Widget botonTexto() {
    return Container(
      margin: EdgeInsets.only(left: 5),
      width: 55,
      child: RaisedButton(
        onPressed: () {
          return _eltexto(context);
        },
        child: Icon(
          Icons.text_fields,
          color: Colors.white,
        ),
        color: Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color.fromARGB(30, 0, 0, 0),
          ),
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
          title: Text("Ingrese el texto: "),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ingrese texto',
                  ),
                  onChanged: (String str) {
                    this.setState(() {
                      textoo = str;
                    });
                  },
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
                ),
                RaisedButton(
                  onPressed: () {

                    if (textoo!=null){
                      if (textoo.isNotEmpty && textoo.trim().length > 0){
                        setState(() {
                          txt = Text(
                            textoo,
                            style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.5, decoration: TextDecoration.none, color: colorTexto),
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
                    color: Colors.lightBlue,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget botonEmoji() {
    return Container(
      margin: EdgeInsets.only(left: 5),
      width: 55,
      child: RaisedButton(
        onPressed: () {
          return showAlertDialog(context);
        },
        child: Icon(
          Icons.tag_faces,
          color: Colors.white,
        ),
        color: Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color.fromARGB(30, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  Widget botonOferta() {
    return Container(
      margin: EdgeInsets.only(left: 5),
      width: 55,
      child: RaisedButton(
        onPressed: () {
          return PopUpOferta();
        },
        child: Icon(
          Icons.local_offer,
          color: Colors.white,
        ),
        color: Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Color.fromARGB(30, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  PopUpOferta() {
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
                  title: Text(
                    "Vista Previa Oferta",
                    textAlign: TextAlign.center,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WidgetToImage(builder: (key) {
                        this.key2 = key;
                        return Container(
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height / 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pickerColorFondo,
                          ),
                          child: Container(
                            margin: EdgeInsets.only(left: 5.0),
                            alignment: Alignment.center,
                            child: TextFormField(
                              autofocus: true,
                              controller: controladorOferta,
                              maxLengthEnforced: true,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              maxLength: 3,
                              maxLines: 1,
                              onEditingComplete: () {
                                Limite(controladorOferta.text.length);
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
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.height / 25,
                              ),
                            ),
                          ),
                        );
                      }),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Fondo",
                            textScaleFactor: 1.5,
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
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
                          Text(
                            "Oferta",
                            textScaleFactor: 1.5,
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
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
                          RaisedButton(
                            onPressed: () async {
                              //Acá se debe sacar el screenshot de la oferta
                              // o moverlo
                              //**//
                              _ponerOferta(context);
                            },
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.lightBlue,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
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
      title: Text(
        "Emojis",
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmojiPickerWidget(
              onEmojiSelected: onEmojiSelected,
            ),
          ],
        ),
      ),
    );

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
            ..value = Text(temoji, style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.5, decoration: TextDecoration.none),),
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
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    //print();
    //_toastInfo('Permisos');
  }

  /*_toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }*/

  Future _finalizarGuardado(Uint8List imagenEnBytes) async {
    GlobalKey<FormState> _keyValidadorTxtImagen = GlobalKey<FormState>();
    PopUps.popUpCargando(context, 'Cambiando tamaño');
    //Redimensiono imagen en memoria
    imagenEnBytes = await Utils.redimensionarImg(imagenEnBytes, divisionLayout);

    //Cierra popup cargando
    Navigator.of(context, rootNavigator: true).pop();

    /*String dir = (await getTemporaryDirectory()).path;
    File temporal = new File('$dir/screen_widgets.png');
    await temporal.writeAsBytes(imagenEnBytes);*/
    //print(temporal.path);
    String nombreNuevaImagen = "";

    Widget widget =
    SingleChildScrollView(
      child: Card(
        child: Form(
          key: _keyValidadorTxtImagen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Image.memory(
                  imagenEnBytes,
                  width: MediaQuery.of(context).size.width-10,
                  height:MediaQuery.of(context).size.height/3,
                ),
              ),
              Center(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  validator: (textoEscrito){
                    if(textoEscrito.isEmpty){
                      return "Error: Nombre de imagen vacío";
                    }
                    if(textoEscrito.trim().length<= 0){
                      return "Error: Nombre de imagen vacío";
                    }
                    else {
                      nombreNuevaImagen = textoEscrito.trim()
                          .toString() + '.png';
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
                  if(_keyValidadorTxtImagen.currentState.validate()){
                    //Se abre el popup de cargando
                    PopUps.popUpCargando(context, 'Añadiendo imagen...');

                    //Se crea el archivo final del tamaño modificado
                    File temporal = await Utils.crearArchivoTemporalRedimensionado(imagenEnBytes);

                    //Obtengo el resultado del envio
                    var resultado = await PopUps.enviarImagen(nombreNuevaImagen,
                        temporal).then((value) => value);

                    if(resultado){
                      //Si el envío es correcto, se redirecciona
                      Image imagen = Image.network("http://${DatosEstaticos.ipSeleccionada}/ImagenesPostTv/$nombreNuevaImagen");
                      RedireccionarCrearLayout(imagen, "/var/www/html/ImagenesPostTv/$nombreNuevaImagen",true);
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

  // ignore: non_constant_identifier_names
  Future<void> RedireccionarCrearLayout(Widget imagen, String nombre,bool vieneDePopUp) async {
    if (vieneDePopUp){
      //Cierra popup cargando
      Navigator.of(context, rootNavigator: true).pop();
      //Cierra popup imagen
      Navigator.of(context, rootNavigator: true).pop();
    }

    DatosEstaticos.webViewControllerWidget1 = null;
    DatosEstaticos.webViewControllerWidget2 = null;
    DatosEstaticos.webViewControllerWidget3 = null;

    //Se asigna además que porcion del layout se reemplazará
    switch(divisionLayout){
      case '1-1': {
        DatosEstaticos.widget1 = imagen;
        DatosEstaticos.nombreArchivoWidget1 = nombre;
        DatosEstaticos.reemplazarPorcion1 = true;
      }
      break;
      case '2-1': {
        DatosEstaticos.widget1 = imagen;
        DatosEstaticos.nombreArchivoWidget1 = nombre;
        DatosEstaticos.reemplazarPorcion1 = true;
      }
      break;
      case '2-2': {
        DatosEstaticos.widget2 = imagen;
        DatosEstaticos.nombreArchivoWidget2 = nombre;
        DatosEstaticos.reemplazarPorcion2 = true;
      }
      break;
      case '3-1': {
        DatosEstaticos.widget1 = imagen;
        DatosEstaticos.nombreArchivoWidget1 = nombre;
        DatosEstaticos.reemplazarPorcion1 = true;
      }
      break;
      case '3-2': {
        DatosEstaticos.widget2 = imagen;
        DatosEstaticos.nombreArchivoWidget2 = nombre;
        DatosEstaticos.reemplazarPorcion2 = true;
      }
      break;
      case '3-3': {
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
}