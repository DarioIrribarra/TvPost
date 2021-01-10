import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';

class EditarReloj extends StatefulWidget {
  @override
  _EditarRelojState createState() => _EditarRelojState();
}

class _EditarRelojState extends State<EditarReloj> {
  // Valores para color de fonddo y texto
  Color pickerColorFondo = HexColor(DatosEstaticos.color_fondo_reloj);
  Color pickerColorTexto = HexColor(DatosEstaticos.color_texto_reloj);

  //Funciones que cambian y devuelven color
  void changeColorFondo(Color color) {
    setState(() {
      pickerColorFondo = color;
      //El valor viene en int, así que para pasarlo al reloj en la pantalla
      //se debe transformar a hex.
      var hex =
          '#${color.value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
      DatosEstaticos.color_fondo_reloj = hex;
    });
  }

  //Funciones que cambian y devuelven color
  void changeColorLetras(Color color) {
    setState(() {
      pickerColorTexto = color;
      //El valor viene en int, así que para pasarlo al reloj en la pantalla
      //se debe transformar a hex.
      var hex =
          '#${color.value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
      DatosEstaticos.color_texto_reloj = hex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: StatefulBuilder(builder: (context, setState) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              contentPadding:
                  EdgeInsets.only(bottom: 20, top: 20, left: 5, right: 5),
              backgroundColor: Colors.grey.withOpacity(0.0),
              content: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: HexColor('#f4f4f4')),
                height: 450,
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "RELOJ",
                      textAlign: TextAlign.center,
                      textScaleFactor: 1,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: pickerColorFondo,
                            ),
                            child: Text(
                              '00:00:00',
                              textScaleFactor: 2.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: pickerColorTexto),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "COLOR DE FONDO",
                                textScaleFactor: 0.8,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ColorPicker(
                              pickerColor: pickerColorFondo,
                              showLabel: false,
                              enableAlpha: false,
                              displayThumbColor: true,
                              pickerAreaHeightPercent: 0.15,
                              onColorChanged: (color) {
                                changeColorFondo(color);
                                setState(() {});
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "COLOR DE HORA",
                                textScaleFactor: 0.8,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            ColorPicker(
                              pickerColor: pickerColorTexto,
                              showLabel: false,
                              enableAlpha: false,
                              displayThumbColor: true,
                              pickerAreaHeightPercent: 0.15,
                              onColorChanged: (color) {
                                changeColorLetras(color);
                                setState(() {});
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: HexColor('#3EDB9B'),
                                      size: 30,
                                    ),
                                    onTap: () {
                                      //Navigator.of(context, rootNavigator: true).pop()
                                      //Diego, acá deberías manejar el estado del reloj en pantalla
                                      //Lo pasas a true y en el crear_layout3.dart preguntas
                                      //por el estado del reloj, si es true, cambias el
                                      //widget del layout por uno con una imagen de reloj
                                      //si es false, muestras el antiguo. Así lo haría yo, pero
                                      //si tu quieres haz otro archivo completamente como veo que lo pensabas
                                      //hacer.
                                      //mira la línea 141 en crear_layout3
                                      DatosEstaticos.relojEnPantalla = true;
                                      Navigator.pop(context);
                                      Navigator.popAndPushNamed(
                                          context, '/crear_layout3');
                                    }),
                                GestureDetector(
                                    child: Icon(
                                      Icons.cancel,
                                      color: HexColor('#FC4C8B'),
                                      size: 30,
                                    ),
                                    onTap: () {
                                      DatosEstaticos.relojEnPantalla = false;
                                      Navigator.pop(context);
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
/*
EditarReloj() {
  // Valores para color de fonddo y texto
  Color pickerColorFondo = HexColor(DatosEstaticos.color_fondo_reloj);
  Color pickerColorTexto = HexColor(DatosEstaticos.color_texto_reloj);

  //Funciones que cambian y devuelven color
  void changeColorFondo(Color color) {
    setState(() {
      pickerColorFondo = color;
      //El valor viene en int, así que para pasarlo al reloj en la pantalla
      //se debe transformar a hex.
      var hex =
          '#${color.value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
      DatosEstaticos.color_fondo_reloj = hex;
    });
  }

  //Funciones que cambian y devuelven color
  void changeColorLetras(Color color) {
    setState(() {
      pickerColorTexto = color;
      //El valor viene en int, así que para pasarlo al reloj en la pantalla
      //se debe transformar a hex.
      var hex =
          '#${color.value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
      DatosEstaticos.color_texto_reloj = hex;
    });
  }

  return StatefulBuilder(builder: (context, setState) {
    return Center(
      child: SingleChildScrollView(
        child: AlertDialog(
          title: Text(
            "Vista Previa Reloj",
            textAlign: TextAlign.center,
          ),
          content: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: pickerColorFondo,
                  ),
                  child: Text(
                    '00:00:00',
                    textScaleFactor: 2.0,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: pickerColorTexto),
                  ),
                ),
              ),
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
                    pickerColor: pickerColorFondo,
                    showLabel: false,
                    enableAlpha: false,
                    displayThumbColor: true,
                    pickerAreaHeightPercent: 0.25,
                    onColorChanged: (color) {
                      changeColorFondo(color);
                      setState(() {});
                    },
                  ),
                  Text(
                    "Hora",
                    textScaleFactor: 1.5,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  ColorPicker(
                    pickerColor: pickerColorTexto,
                    showLabel: false,
                    enableAlpha: false,
                    displayThumbColor: true,
                    pickerAreaHeightPercent: 0.25,
                    onColorChanged: (color) {
                      changeColorLetras(color);
                      setState(() {});
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                            child: Text("Guardar"),
                            onPressed: () {
                              //Navigator.of(context, rootNavigator: true).pop()
                              //Diego, acá deberías manejar el estado del reloj en pantalla
                              //Lo pasas a true y en el crear_layout3.dart preguntas
                              //por el estado del reloj, si es true, cambias el
                              //widget del layout por uno con una imagen de reloj
                              //si es false, muestras el antiguo. Así lo haría yo, pero
                              //si tu quieres haz otro archivo completamente como veo que lo pensabas
                              //hacer.
                              //mira la línea 141 en crear_layout3
                              DatosEstaticos.relojEnPantalla = true;
                              Navigator.pushNamed(context, '/crear_layout3');
                            }
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                            child: Text("Cancelar"),
                            onPressed: () {
                              DatosEstaticos.relojEnPantalla = false;
                              Navigator.pop(context);
                            }
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  });

  */ /*return showDialog(
      context: context,
      barrierDismissible: false,
      child: StatefulBuilder(builder: (context, setState) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              title: Text(
                "Vista Previa Reloj",
                textAlign: TextAlign.center,
              ),
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: pickerColorFondo,
                      ),
                      child: Text(
                        '00:00:00',
                        textScaleFactor: 2.0,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: pickerColorTexto),
                      ),
                    ),
                  ),
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
                        pickerColor: pickerColorFondo,
                        showLabel: false,
                        enableAlpha: false,
                        displayThumbColor: true,
                        pickerAreaHeightPercent: 0.25,
                        onColorChanged: (color) {
                          changeColorFondo(color);
                          setState(() {});
                        },
                      ),
                      Text(
                        "Hora",
                        textScaleFactor: 1.5,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      ColorPicker(
                        pickerColor: pickerColorTexto,
                        showLabel: false,
                        enableAlpha: false,
                        displayThumbColor: true,
                        pickerAreaHeightPercent: 0.25,
                        onColorChanged: (color) {
                          changeColorLetras(color);
                          setState(() {});
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: RaisedButton(
                                child: Text("Guardar"),
                                onPressed: () {
                                  //Navigator.of(context, rootNavigator: true).pop()
                                  //Diego, acá deberías manejar el estado del reloj en pantalla
                                  //Lo pasas a true y en el crear_layout3.dart preguntas
                                  //por el estado del reloj, si es true, cambias el
                                  //widget del layout por uno con una imagen de reloj
                                  //si es false, muestras el antiguo. Así lo haría yo, pero
                                  //si tu quieres haz otro archivo completamente como veo que lo pensabas
                                  //hacer.
                                  //mira la línea 141 en crear_layout3
                                  DatosEstaticos.relojEnPantalla = true;
                                  Navigator.pushNamed(context, '/crear_layout3');
                                }
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: RaisedButton(
                                child: Text("Cancelar"),
                                onPressed: () {
                                  DatosEstaticos.relojEnPantalla = false;
                                  Navigator.pop(context);
                                }
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );*/ /*
}*/
