import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopUps{
  //Se crea popup de cargando
  static popUpCargando(BuildContext context, String texto){
    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 20),child:Text(texto)),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  //Crear un popup con cualquier widget de contenido
  static PopUpConWidget(BuildContext context, Widget contenidoPopUp){
    AlertDialog alert=AlertDialog(
      content: contenidoPopUp,
    );
    showDialog(barrierDismissible: true,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }
}

class CustomAppBar extends PreferredSize{
  final double height;

  CustomAppBar({
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(5.0),
              margin: EdgeInsets.only(right: 30.0),
              child: Image.asset('imagenes/logohorizontal.png'),
            ),
            IconButton(
              icon: Icon(
                Icons.menu,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class OpcionesSeleccionMedia extends StatefulWidget {

  OpcionesSeleccionMedia({
    @required this.visible,
    @required this.divisionLayout,
    //Se requiere la función que hará que algo pase en la ventan anterior
    @required this.actualizaEstado,
  });

  final bool visible;
  final String divisionLayout;
  //Función que devuelve algo a la ventana anterior
  final VoidCallback actualizaEstado;

  @override
  _OpcionesSeleccionMediaState createState() => _OpcionesSeleccionMediaState();
}

class _OpcionesSeleccionMediaState extends State<OpcionesSeleccionMedia> {

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
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
    );
  }

  navegarYEsperarRespuesta(String rutaVentana) async {
    final result = await Navigator.pushNamed(context, rutaVentana, arguments: {
      'division_layout': widget.divisionLayout,
    });
    if (result != null) {
      //Si se selecciona la imagen, esto le dice a la ventana anterior que se
      //Ejecutó. La ventana anterior, ejecuta un setstate
      widget.actualizaEstado();
    }
  }

}

