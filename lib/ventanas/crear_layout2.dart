import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';

class CrearLayout2 extends StatefulWidget {
  @override
  _CrearLayout2State createState() => _CrearLayout2State();
}

class _CrearLayout2State extends State<CrearLayout2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
    );
  }
}
