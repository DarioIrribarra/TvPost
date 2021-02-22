import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'datos_estaticos.dart';

class CloudStorage{

  /// Sube archivos a Firebase.
  static Future<String> SubirImagenFirebase(List<File> archivo) async {

    String _urlFile = "";

    //Se instancia la colección en la base de datos
    CollectionReference fileReferenceInDB = FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('imagenes');
    try
    {
      for (int i = 0; i < archivo.length; i++){
        var _idUnica = new Uuid().v4();

        //Se instancia el storage
        FirebaseStorage storage = FirebaseStorage.instance;

        //Se pasan los datos de ruta de carpeta
        Reference reference = storage.ref().child(DatosEstaticos.rutEmpresa).child('imagenes').child(_idUnica);

        //Se crea el objeto que realiza la tarea de subida
        UploadTask uploadTask = reference.putFile(archivo[i]);

        //Se procesa la subida y luego se obtiene el nombre del archivo
        _urlFile = await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
        _urlFile = _urlFile.toString();

        //Se añade archivo a la colección a la bd
        fileReferenceInDB.doc(_idUnica).set({"id":_idUnica,"url":_urlFile});

      }

      return _urlFile;

    }
    catch (ex){

      return null;
    }
  }

  ///ELIMINA ARCHIVOS DESDE BASE DE DATOS REAL TIME EN FIREBASE PASANDO
  ///EL CONJUNTO DE IDs
  static Future<bool> EliminarImagenFirebase(List<String> nombreArchivoAEliminar) async {

    String id = "";
    //Se instancia la colección en la base de datos
    CollectionReference fileReferenceInDB = FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('imagenes');

    try
    {
      for (int i = 0; i < nombreArchivoAEliminar.length; i++){

        //Id que maneja la referencia al documento
        id = nombreArchivoAEliminar[i];

        //Se obtiene el conjunto de datos para extraer la url
        var datos = await fileReferenceInDB.doc(id).get();

        //Se extrae la url
        var url = datos.get("url");

        //Se instancia el storage
        FirebaseStorage storage = FirebaseStorage.instance;

        //Se elimina de bd pasando el id
        await fileReferenceInDB.doc(id).delete();

        //Se elimina del bucket pasando la url
        await storage.refFromURL(url).delete();
      }

      return true;

    }
    catch (ex){

      return false;
    }
  }
}