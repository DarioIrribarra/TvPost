import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tvpost_flutter/utilidades/custom_widgets.dart';

class CrearLayout3 extends StatefulWidget {
  @override
  _CrearLayout3State createState() => _CrearLayout3State();
}

class _CrearLayout3State extends State<CrearLayout3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar viene de archivo custom_widgets.dart
      appBar: CustomAppBar(),
    );
  }
}
