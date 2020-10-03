import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';

class SeleccionarLayout extends StatefulWidget {
  @override
  _SeleccionarLayoutState createState() => _SeleccionarLayoutState();
}

class _SeleccionarLayoutState extends State<SeleccionarLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: FlatButton(
                  child: Image.asset('imagenes/layout1a.png'),
                  onPressed: (){
                    Navigator.pushNamed(context, '/crear_layout1');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: FlatButton(
                  child: Image.asset('imagenes/layout2b.png'),
                  onPressed: (){
                    Navigator.pushNamed(context, '/crear_layout2');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: FlatButton(
                  child: Image.asset('imagenes/layout3c.png'),
                  onPressed: (){
                    Navigator.pushNamed(context, '/crear_layout3');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

