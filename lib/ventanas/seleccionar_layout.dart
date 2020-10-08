import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';
import 'package:tvpost_flutter/utilidades/obtiene_datos_webservice.dart';

class SeleccionarLayout extends StatefulWidget {
  @override
  _SeleccionarLayoutState createState() => _SeleccionarLayoutState();
}

class _SeleccionarLayoutState extends State<SeleccionarLayout> {
  //Decoración que permite el poner un borde al seleccionar la porción de
  // pantalla
  BoxDecoration _decorationLayoutSeleccionado1;
  BoxDecoration _decorationLayoutSeleccionado2;
  BoxDecoration _decorationLayoutSeleccionado3;

  @override
  void initState() {
    // TODO: implement initState
    //recargarListadoEquipos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0),
          child: FutureBuilder(
            future: recargarListadoEquipos(),
            builder: (context, snapshot){
              if (snapshot.connectionState == ConnectionState.done){
                if (snapshot.data!=null){
                  PorcionSeleccionada(snapshot.data);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Layout actual seleccionado',textAlign: TextAlign.center,),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          decoration: _decorationLayoutSeleccionado1,
                          child: FlatButton(
                            child: Image.asset('imagenes/layout1a.png'),
                            onPressed: (){
                              //Se asigna layout seleccionado a 1
                              DatosEstaticos.layoutSeleccionado = 1;
                              Navigator.pushNamed(context, '/crear_layout1');
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          decoration: _decorationLayoutSeleccionado2,
                          child: FlatButton(
                            child: Image.asset('imagenes/layout2b.png'),
                            onPressed: (){
                              //Se asigna layout seleccionado a 2
                              DatosEstaticos.layoutSeleccionado = 2;
                              Navigator.pushNamed(context, '/crear_layout2');
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: _decorationLayoutSeleccionado3,
                          child: FlatButton(
                            child: Image.asset('imagenes/layout3c.png'),
                            onPressed: (){
                              //Se asigna layout seleccionado a 3
                              DatosEstaticos.layoutSeleccionado = 3;
                              Navigator.pushNamed(context, '/crear_layout3');
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }
              return Center(child: CircularProgressIndicator(),);
            },
          )
        ),
      ),
    );
  }

  recargarListadoEquipos() async{
    //Se actualizan los datos de equipo cada vez que se selecciona
    // un tipo de layout
    ObtieneDatos datos = ObtieneDatos();
    await datos.getDatosEquipos();

    //Acá se preparan los widgets iniciales

    int _layoutSeleccionado = int.parse(ObtieneDatos.listadoEquipos[0]['f_layoutActual']);
    return _layoutSeleccionado;
  }

  void PorcionSeleccionada (int seleccionada){
    switch(seleccionada){
      case 1:
        _decorationLayoutSeleccionado1 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        _decorationLayoutSeleccionado2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 2:
        _decorationLayoutSeleccionado1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado2 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        _decorationLayoutSeleccionado3 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        break;
      case 3:
        _decorationLayoutSeleccionado1 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado2 = BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 10));
        _decorationLayoutSeleccionado3 = BoxDecoration(
            border: Border.all(color: Colors.red, width: 10));
        break;
    }
  }
}

