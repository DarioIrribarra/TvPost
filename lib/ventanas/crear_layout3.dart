import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';

class CrearLayout3 extends StatefulWidget {
  @override
  _CrearLayout3State createState() => _CrearLayout3State();
}

class _CrearLayout3State extends State<CrearLayout3> {
  //dato que indica que parte del layout se quiere modificar y se envia a la
  // selección de contenido correspondiente
  String divisionLayout;
  //Widget dentro del mapa de datos de ventana anterior
  Widget widget1;
  Widget widget2;
  Widget widget3;
  bool _visible = false;
  BoxDecoration _decorationPorcion1;
  BoxDecoration _decorationPorcion2;
  BoxDecoration _decorationPorcion3;

  @override
  void initState() {
    PorcionSeleccionada(0);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if (DatosEstaticos.wiget1 != null) {
      widget1 = DatosEstaticos.wiget1;
    } else {
      Widget _imageSeleccionLayout = Image.asset('imagenes/layout1a.png');
      widget1 = _imageSeleccionLayout;
    }

    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if (DatosEstaticos.wiget2 != null) {
      widget2 = DatosEstaticos.wiget2;
    } else {
      Widget _imageSeleccionLayout = Image.asset('imagenes/layout1a.png');
      widget2 = _imageSeleccionLayout;
    }

    //Si ya se seleccionó un archivo de media se crea un nuevo layout
    if (DatosEstaticos.wiget3 != null) {
      widget3 = DatosEstaticos.wiget3;
    } else {
      Widget _imageSeleccionLayout = Image.asset('imagenes/layout1a.png');
      widget3 = _imageSeleccionLayout;
    }


    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 5)),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/3,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.169),
                        height:MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.779),
                        decoration: _decorationPorcion1,
                        child: InkWell(
                            enableFeedback: true,
                            onTap: () {
                              setState(() {
                                PorcionSeleccionada(1);
                                if (!_visible) {
                                  _visible = true;
                                }
                                divisionLayout = '3-1';
                              });
                            },
                            child: widget1
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.88),
                        height:MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.779),
                        decoration: _decorationPorcion2,
                        child: InkWell(
                            enableFeedback: true,
                            onTap: () {
                              setState(() {
                                PorcionSeleccionada(2);
                                if (!_visible) {
                                  _visible = true;
                                }
                                divisionLayout = '3-2';
                              });
                            },
                            child: widget2
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - (MediaQuery.of(context).size.height * 0.91),
                    decoration: _decorationPorcion3,
                    child: InkWell(
                        enableFeedback: true,
                        onTap: () {
                          setState(() {
                            PorcionSeleccionada(3);
                            if (!_visible) {
                              _visible = true;
                            }
                            divisionLayout = '3-3';
                          });
                        },
                        child: widget3
                    ),
                  ),
                ],
              ),
            ),

            //Acá va el widget de los botones
            OpcionesSeleccionMedia(
              visible: _visible,
              divisionLayout: divisionLayout,
              //Función que al ser ejecutada desde la ventana siguiente
              //actualiza el state (puede hacer cualquier cosa)
              actualizaEstado: () {
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }

  void PorcionSeleccionada (int seleccionada){
    switch(seleccionada){
      case 0:
        _decorationPorcion1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationPorcion2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 1:
        _decorationPorcion1 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        _decorationPorcion2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationPorcion3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 2:
        _decorationPorcion1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationPorcion2 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        _decorationPorcion3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 3:
        _decorationPorcion1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationPorcion2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationPorcion3 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        break;
    }
  }

}
