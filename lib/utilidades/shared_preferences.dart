import 'package:shared_preferences/shared_preferences.dart';

class shared_preferences_tvPost {
  static String rutEmpresa;
  static String nombreUsuario;
  static String password;

  static CargarSharedPreferences() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    rutEmpresa = prefs.getString('rutEmpresa');
    nombreUsuario = prefs.getString('nombreUsuario');
    password = prefs.getString('password');
  }

}