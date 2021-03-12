import 'package:firebase_auth/firebase_auth.dart';
import 'package:tvpost_flutter/utilidades/datos_estaticos.dart';

class AutenticacionFirebase{

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AutenticacionFirebase();

  static Future<UserCredential> entrar({String email, String password})async{
    email != null ? email = email : email = "${DatosEstaticos.rutEmpresa}@gmail.com";
    password != null ? password = password : password = "${DatosEstaticos.rutEmpresa}";
    try{
      UserCredential credencial = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return credencial;
    } on FirebaseAuthException catch(e){
      print(e.message);
      return null;
    }
  }

  static Future<UserCredential> registrar({String email, String password})async{
    try{
      email != null ? email = email : email = "${DatosEstaticos.rutEmpresa}@gmail.com";
      password != null ? password = password : password = "${DatosEstaticos.rutEmpresa}";
      UserCredential credencial = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return credencial;
    } on FirebaseAuthException catch(e){
      print(e.message);
      return null;
    }
  }
}