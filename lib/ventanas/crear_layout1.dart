import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';

class CrearLayout1 extends StatefulWidget {
  @override
  _CrearLayout1State createState() => _CrearLayout1State();
}

class _CrearLayout1State extends State<CrearLayout1> {
  //Acá va el cambio desde VSCode
  //Acá va el cambio desde Android

  //dato que indica que parte del layout se quiere modificar y se envia a la
  // selección de contenido correspondiente
  String divisionLayout;
  //Widget dentro del mapa de datos de ventana anterior
  Widget widget1;
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if (DatosEstaticos.wiget1 != null) {
      widget1 = DatosEstaticos.wiget1;
    } else {
      Image _imageSeleccionLayout = Image.asset('imagenes/layout1a.png');
      widget1 = _imageSeleccionLayout;
    }
    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
          child: Container(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (!_visible) {
                    _visible = true;
                  }
                  divisionLayout = '1-1';
                });
              },
              child: Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: widget1)),
            ),
            Visibility(
              visible: _visible,
              child: Container(
                margin: EdgeInsets.only(left: 115.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RaisedButton(
                          onPressed: () {
                            //Va a la otra ventana esperando respuesta
                            navegarYEsperarRespuesta('/seleccionar_imagen');
                          },
                          child: Text('Imagen'),
                        ),
                        RaisedButton(
                          onPressed: () {
                            //Va a la otra ventana esperando respuesta
                            navegarYEsperarRespuesta('/seleccionar_video');
                          },
                          child: Text('Video'),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RaisedButton(
                          onPressed: () {},
                          child: Text('Url'),
                        ),
                        RaisedButton(
                          onPressed: () {},
                          child: Text('Crear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  navegarYEsperarRespuesta(String rutaVentana) async {
    final result = await Navigator.pushNamed(context, rutaVentana, arguments: {
      'division_layout': divisionLayout,
    });
    if (result != null) {
      setState(() {});
    }
  }
}

/*class CrearLayout1 extends StatelessWidget {
  //Datos que se envía completo desde la ventana de selección de media
  Map datosDesdeVentanaAnterior = {};
  //dato que indica que parte del layout se quiere modificar y se envia a la
  // selección de contenido correspondiente
  int divisionLayout;
  //Widget dentro del mapa de datos de ventana anterior
  Widget widget1;

  @override
  Widget build(BuildContext context) {

    //Se le puede pasar cualquier tipo de argumento (incluido widgets completos)
    datosDesdeVentanaAnterior = ModalRoute.of(context).settings.arguments;
    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if(datosDesdeVentanaAnterior != null){
      widget1 = datosDesdeVentanaAnterior['widget1'];
      return Scaffold(
        //Appbar viene de archivo custom_widgets.dart
        appBar: CustomAppBar(),
        body: SingleChildScrollView(
            child: Column(
              children: [
                widget1,
              ],
            )
        ),
        backgroundColor: Colors.green,
      );
    }
    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                GestureDetector(
                    child: Image(
                      image: AssetImage('imagenes/layout1a.png'),
                    )
                ),
                Visibility(

                  child: Container(
                    margin: EdgeInsets.only(left: 120.0),
                    child: Center(

                      child: SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RaisedButton(onPressed: (){},),
                            RaisedButton(onPressed: (){},),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}*/
