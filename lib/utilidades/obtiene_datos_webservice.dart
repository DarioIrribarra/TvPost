import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';

class ObtieneDatos {
  String rutEmpresaDevuelto = "Error: Ingrese rut empresa";
  String nombreUsuarioDevuelto = "Error: Ingrese nombre usuario";
  String passwordDevuelto = "Error: Ingrese contraseña";
  /*String rutEmpresaDevuelto = "Error";
  String nombreUsuarioDevuelto = "Error";
  String passwordDevuelto = "Error";*/
  Response responseEmpresa;
  Response responseUsuario;
  static List<dynamic> listadoUsuarios;
  static List<dynamic> listadoEmpresa;
  static List<dynamic> listadoEquipos;

  /// Obtiene los datos completos de la empresa
  Future<void> getDatosEmpresa(String rutEmpresa) async {
    if (rutEmpresa == null) {
      return;
    }
    if (rutEmpresa.trim().length < 8 || rutEmpresa.trim().isEmpty) {
      return;
    }
    responseEmpresa = await get(
        '${DatosEstaticos.hosting}/resttvpost/listarEmpresa.php?f_rut=$rutEmpresa');
  }

  /// Obtiene los datos completos del usuario
  Future<void> getDatosUsuario(String nombreUsuario) async {
    if (nombreUsuario == null) {
      return;
    }
    if (nombreUsuario.length < 1) {
      return;
    }
    responseUsuario = await get(
        '${DatosEstaticos.hosting}/resttvpost/listarUsuarios.php?id_usuario=$nombreUsuario');
  }

  Future<void> getDatosEquipos() async {
    if (DatosEstaticos.rutEmpresa == null) {
      return;
    }
    String rut = DatosEstaticos.rutEmpresa;
    Response responseEquipos = await get('${DatosEstaticos.hosting}/resttvpost/'
        'filtrarEquipoEmpresa.php?f_rut_empresa=$rut');

    try {
      listadoEquipos = jsonDecode(responseEquipos.body);
      return 1;
    } catch (e) {
      return;
    }
  }

  Future<String> updateAliasEquipo(String serial, String alias) async {
    if (serial == null || alias == null) {
      return "Error al actualizar alias: campos no pueden estar vacíos";
    }

    try {
      await post(
          '${DatosEstaticos.hosting}/'
          'resttvpost/updateAlias.php',
          body: {'f_serial': '$serial', 'f_alias': '$alias'});
      //print(responseUpdateEquipo.body);
      return "listo";
    } catch (e) {
      print("Error: ${e.toString()}");
      return "Error al actualizar alias: error de conexión";
    }
  }

  Future<void> updateDatosMediaEquipo({
    @required String serial,
    String f_layoutActual = "1",
    String F_TipoArchivoPorcion1 = "0",
    String F_TipoArchivoPorcion2 = "0",
    String F_TipoArchivoPorcion3 = "0",
    String F_ArchivoPorcion1 = "0",
    String F_ArchivoPorcion2 = "0",
    String F_ArchivoPorcion3 = "0",
  }) async {
    /*if (serial==null){
      return "Error al actualizar equipos: campos no pueden estar vacíos";
    }*/

    try {
      await post(
          '${DatosEstaticos.hosting}/'
          'resttvpost/updateArchivosMediaEquipo.php',
          body: {
            'f_serial': '$serial',
            'f_layoutActual': '$f_layoutActual',
            'F_TipoArchivoPorcion1': '$F_TipoArchivoPorcion1',
            'F_TipoArchivoPorcion2': '$F_TipoArchivoPorcion2',
            'F_TipoArchivoPorcion3': '$F_TipoArchivoPorcion3',
            'F_ArchivoPorcion1': '$F_ArchivoPorcion1',
            'F_ArchivoPorcion2': '$F_ArchivoPorcion2',
            'F_ArchivoPorcion3': '$F_ArchivoPorcion3',
          });
      //return "Actualización finalizada";

    } catch (e) {
      print("Error: ${e.toString()}");
      //return "Error al actualizar alias: error de conexión";
    }
    return;
  }

  Future<int> updateEstadoEquipo({
    @required String serial,
    @required String estado,
    List<dynamic> listadoEquipos,
    Response resultado,
  }) async {
    try {
      if (serial != "-1") {
        resultado = await post(
            '${DatosEstaticos.hosting}/'
                'resttvpost/updateEstadoEquipo.php',
            body: {
              'f_serial': '$serial',
              'f_equipoActivo': '$estado',
            });

        if (resultado.reasonPhrase == 'OK') {
          return 1;
        }
      } else {
        var dato;
        await AdministrarActivacionEquipos(listadoEquipos: listadoEquipos,
            estado: estado).then((value) {dato = value;});
        if (dato == 1){
          return 1;
        }
      }
    } catch (e) {
      print("Error: ${e.toString()}");
      //return "Error al actualizar alias: error de conexión";
    }
    return 0;
  }

  ///Obtiene el rut de la empresa en base a la respuesta de la llamada de
  ///getDatosEmpresa y lo valida
  Future<void> ValidaRutEmpresa() async {
    if (responseEmpresa == null) {
      rutEmpresaDevuelto = "Error: Rut de empresa incorrecto";
      //rutEmpresaDevuelto = "Error";
      return;
    }
    //Asigna valor obtenido a variable para ser consultada en la validación
    try {
      listadoEmpresa = jsonDecode(responseEmpresa.body);
      rutEmpresaDevuelto = jsonDecode(responseEmpresa.body)[0]['f_rut'];
      String rutEmpresaActiva =
          jsonDecode(responseEmpresa.body)[0]['f_activa'].toString();
      if (rutEmpresaActiva == '0') {
        rutEmpresaDevuelto = "Error: Rut de empresa inactivo";
        //rutEmpresaDevuelto = "Error";
      } else if (rutEmpresaDevuelto != null) {
        //Se asigna la variable estática
        DatosEstaticos.rutEmpresa = rutEmpresaDevuelto;
        //Null para que pase la validación
        rutEmpresaDevuelto = null;
      }
    } catch (e) {
      //Error para mostrar en el textfield
      rutEmpresaDevuelto = "Error: Empresa no existe en base de datos";
      //rutEmpresaDevuelto = "Error";
      return;
    }
  }

  Future<void> ValidaNombreUsuario() async {
    if (responseUsuario == null) {
      nombreUsuarioDevuelto = "Error: Nombre de usuario incorrecto";
      //nombreUsuarioDevuelto = "Error";
      return;
    }
    try {
      if (DatosEstaticos.rutEmpresa == null) {
        return;
      }
      //ForEach para iterar por cada usuario que se obtenga
      listadoUsuarios = jsonDecode(responseUsuario.body);
      if(listadoUsuarios.length <= 0){
        nombreUsuarioDevuelto = "Error: Usuario no asociado a empresa";
        return;
      }
      listadoUsuarios.forEach((usuario) {
        if (usuario['f_rut_empresa'].toString() == DatosEstaticos.rutEmpresa) {
          if (usuario['f_activo'].toString() == '0') {
            return;
          }
          nombreUsuarioDevuelto = usuario['id_usuario'].toString();
        }
      });

      if (nombreUsuarioDevuelto != null) {
        //Se hacen validaciones
        nombreUsuarioDevuelto = null;
        return;
      } else {
        nombreUsuarioDevuelto = "Error: Usuario no asociado a empresa";
        //nombreUsuarioDevuelto = "Error";
      }
    } catch (e) {
      //Error para mostrar en el textfield
      nombreUsuarioDevuelto = "Error: Nombre de usuario no existe en base de datos";
      //nombreUsuarioDevuelto = "Error";
      return;
    }
  }

  Future<void> ValidaPasswordUsuario(
      String password, String nombreUsuario) async {
    if (password == null) {
      nombreUsuarioDevuelto = "Error: Ingrese nombre de usuario";
      //nombreUsuarioDevuelto = "Error";
      return;
    } else if (password.trim().length < 1) {
      nombreUsuarioDevuelto = "Error: Ingrese nombre de usuario";
      //nombreUsuarioDevuelto = "Error";
      return;
    }
    if (password == null) {
      passwordDevuelto = "Error: Ingrese contraseña";
      //passwordDevuelto = "Error";
      return;
    } else if (password.trim().length < 1) {
      passwordDevuelto = "Error: Ingrese contraseña";
      //passwordDevuelto = "Error";
      return;
    }
    if (responseUsuario == null) {
      nombreUsuarioDevuelto = "Error: Nombre de usuario incorrecto";
      //nombreUsuarioDevuelto = "Error";
      return;
    }

    try {
      listadoUsuarios.forEach((usuario) {
        if (usuario['id_usuario'].toString() == nombreUsuario) {
          if (usuario['f_password'].toString() == password) {
            passwordDevuelto = usuario['f_password'].toString();
          } else {
            passwordDevuelto = "Error: Contraseña incorrecta";
            return;
          }
        }
      });

      if (passwordDevuelto == "Error: Contraseña incorrecta"){
        return;
      }

      if (passwordDevuelto != null) {
        //Se hacen validaciones
        passwordDevuelto = null;
        return;
      } else {
        passwordDevuelto = "Error: Contraseña incorrecta";
        //passwordDevuelto = "Error";
      }
    } catch (e) {
      //Error para mostrar en el textfield
      passwordDevuelto = "Error: Nombre de usuario o contraseña incorrectos";
      //passwordDevuelto = "Error";
      return;
    }
  }
}

Future<int> AdministrarActivacionEquipos({List<dynamic> listadoEquipos, String estado}) async {

  try {
    for (int contador = 0; contador<= listadoEquipos.length -1; contador++){
      String serialUtilizar = listadoEquipos[contador]['f_serial'].toString();
      await post(
          '${DatosEstaticos.hosting}/'
              'resttvpost/updateEstadoEquipo.php',
          body: {
            'f_serial': '$serialUtilizar',
            'f_equipoActivo': '$estado',
          });
    }
  }catch(e){
    return 0;
  }

  return 1;
  /*listadoEquipos.forEach((element) {
    String serialListado = element['f_serial'].toString();
    await post(
        '${DatosEstaticos.hosting}/'
            'resttvpost/updateEstadoEquipo.php',
        body: {
          'f_serial': '$serialListado',
          'f_equipoActivo': '$estado',
        }).then((value) {
          contador = contador +1;
          print(contador);

        });
  });*/


}
