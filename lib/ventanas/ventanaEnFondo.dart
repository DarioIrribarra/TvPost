import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VentanaFondo extends StatefulWidget {
  @override
  _VentanaFondoState createState() => _VentanaFondoState();
}

class _VentanaFondoState extends State<VentanaFondo> {

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() async {
    var duration = Duration(seconds: 1);
    return Timer(duration, ruta);
  }

  ruta(){
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }


}

