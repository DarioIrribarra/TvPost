import 'dart:convert';
import 'package:http/http.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';

class ObtieneDatos {

  String rutEmpresaDevuelto = "Error: Ingrese rut empresa";
  String nombreUsuarioDevuelto = "Error: Ingrese nombre usuario";
  String passwordDevuelto = "Error: Ingrese contraseña";
  Response responseEmpresa;
  Response responseUsuario;
  static List<dynamic> listadoUsuarios;
  static List<dynamic> listadoEmpresa;
  static List<dynamic> listadoEquipos;

  /// Obtiene los datos completos de la empresa
  Future<void> getDatosEmpresa(String rutEmpresa) async {
    if (rutEmpresa == null){
      return;
    }
    if (rutEmpresa.trim().length<8 || rutEmpresa.trim().isEmpty){
      return;
    }
    responseEmpresa = await get(
        'http://drioxmaster.cl/resttvpost/listarEmpresa.php?f_rut=$rutEmpresa');
  }

  /// Obtiene los datos completos del usuario
  Future<void> getDatosUsuario(String nombreUsuario) async {
    if (nombreUsuario == null){
      return;
    }
    if (nombreUsuario.length<1){
      return;
    }
    responseUsuario = await get(
        'http://drioxmaster.cl/resttvpost/listarUsuarios.php?id_usuario=$nombreUsuario');
  }

  Future<void> getDatosEquipos() async{
    if(DatosEstaticos.rutEmpresa == null){
      return;
    }
    String rut = DatosEstaticos.rutEmpresa;
    Response responseEquipos = await get('http://drioxmaster.cl/resttvpost/'
        'filtrarEquipoEmpresa.php?f_rut_empresa=$rut');

    try{
      listadoEquipos = jsonDecode(responseEquipos.body);
    } catch(e){
      return;
    }
  }

  Future<String> updateAliasEquipo(String serial, String alias) async{
    if (serial==null || alias == null){
      return "Error al actualizar alias: campos no pueden estar vacíos";
    }

    try{
      Response responseUpdateEquipo = await post('http://drioxmaster.cl/'
          'resttvpost/updateAlias.php',
          body: {'f_serial':'$serial', 'f_alias':'$alias'});
      //print(responseUpdateEquipo.body);
      return "listo";
    } catch (e) {
      print("Error: ${e.toString()}");
      return "Error al actualizar alias: error de conexión";
    }
  }

  ///Obtiene el rut de la empresa en base a la respuesta de la llamada de
  ///getDatosEmpresa y lo valida
  Future<void> ValidaRutEmpresa() async{
    if (responseEmpresa==null){
      rutEmpresaDevuelto = "Error: Rut de empresa incorrecto";
      return;
    }
    //Asigna valor obtenido a variable para ser consultada en la validación
    try{
      listadoEmpresa= jsonDecode(responseEmpresa.body);
      rutEmpresaDevuelto = jsonDecode(responseEmpresa.body)[0]['f_rut'];
      String rutEmpresaActiva = jsonDecode(
          responseEmpresa.body)[0]['f_activa'].toString();
      if (rutEmpresaActiva == '0'){
        rutEmpresaDevuelto = "Error: Rut de empresa inactivo";
      }else if(rutEmpresaDevuelto!=null){
        //Se asigna la variable estática
        DatosEstaticos.rutEmpresa = rutEmpresaDevuelto;
        //Null para que pase la validación
        rutEmpresaDevuelto = null;
      }
    } catch(e){
      //Error para mostrar en el textfield
      rutEmpresaDevuelto = "Error: Empresa no existe en base de datos";
      return;
    }
  }

  Future<void> ValidaNombreUsuario() async{
    if (responseUsuario==null){
      nombreUsuarioDevuelto = "Error: Nombre de usuario incorrecto";
      return;
    }
    try{
      if (DatosEstaticos.rutEmpresa == null) {return;}
      //ForEach para iterar por cada usuario que se obtenga
      listadoUsuarios= jsonDecode(responseUsuario.body);
      listadoUsuarios.forEach((usuario) {
        if(usuario['f_rut_empresa'].toString() == DatosEstaticos.rutEmpresa){
            if (usuario['f_activo'].toString() == '0') {
              return;
            }
            nombreUsuarioDevuelto = usuario['id_usuario'].toString();
          }
        }
      );

      if(nombreUsuarioDevuelto!=null){
        //Se hacen validaciones
        nombreUsuarioDevuelto = null;
        return;
      } else {
        nombreUsuarioDevuelto = "Error: Usuario no asociado a empresa";
      }
    } catch(e){
      //Error para mostrar en el textfield
      nombreUsuarioDevuelto = "Error: Nombre de usuario no existe en base de datos";
      return;
    }
  }

  Future<void> ValidaPasswordUsuario(String password, String nombreUsuario) async{
    if (password == null){
      nombreUsuarioDevuelto = "Error: Ingrese nombre de usuario";
      return;
    } else if(password.trim().length < 1){
      nombreUsuarioDevuelto = "Error: Ingrese nombre de usuario";
      return;
    }
    if (password == null){
      passwordDevuelto = "Error: Ingrese contraseña";
      return;
    } else if(password.trim().length < 1){
      passwordDevuelto = "Error: Ingrese contraseña";
      return;
    }
    if (responseUsuario==null){
      nombreUsuarioDevuelto = "Error: Nombre de usuario incorrecto";
      return;
    }

    try{
      listadoUsuarios.forEach((usuario) {
        if(usuario['id_usuario'].toString() == nombreUsuario){
          if(usuario['f_password'].toString() == password){
            passwordDevuelto = usuario['f_password'].toString();
          }
        }
      }
      );
      if(passwordDevuelto!=null){
        //Se hacen validaciones
        passwordDevuelto = null;
        return;
      } else {
        passwordDevuelto = "Error: Contraseña incorrecta";
      }
    } catch(e){
      //Error para mostrar en el textfield
      passwordDevuelto = "Error: Nombre de usuario o contraseña incorrectos";
      return;
    }

  }
}