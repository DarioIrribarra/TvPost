import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'datos_estaticos.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CloudStorage{

  /// SUBE IMÁGENES A FIREBASE
  static Future<String> SubirImagenFirebase(List<File> listadoVideos) async {

    String _urlFile = "";

    //Se instancia la colección en la base de datos
    CollectionReference fileReferenceInDB = FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('imagenes');
    try
    {
      for (int i = 0; i < listadoVideos.length; i++){
        var _idUnica = new Uuid().v4();

        //Se instancia el storage
        FirebaseStorage storage = FirebaseStorage.instance;

        //Se pasan los datos de ruta de carpeta
        Reference reference = storage.ref().child(DatosEstaticos.rutEmpresa).child('imagenes').child(_idUnica);

        //Se crea el objeto que realiza la tarea de subida
        UploadTask uploadTask = reference.putFile(listadoVideos[i]);

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

  ///ELIMINA IMAGENES DESDE BASE DE DATOS REAL TIME EN FIREBASE PASANDO
  ///EL CONJUNTO DE IDs
  static Future<bool> EliminarImagenFirebase(List<String> archivosAEliminar) async {

    String id = "";
    //Se instancia la colección en la base de datos
    CollectionReference fileReferenceInDB = FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('imagenes');

    try
    {
      for (int i = 0; i < archivosAEliminar.length; i++){

        //Id que maneja la referencia al documento
        id = archivosAEliminar[i];

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

  /// SUBE VIDEOS A FIREBASE
  static Future<String> SubirVideosFirebase(List<File> listadoVideos) async {

    String _urlFileVideo = "";
    String _urlFileThumbnail = "";

    //Se instancia el storage
    FirebaseStorage storage = FirebaseStorage.instance;

    //Se instancia la colección en la base de datos
    CollectionReference fileReferenceInDB = FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('videos');
    try
    {
      for (int i = 0; i < listadoVideos.length; i++){
        var _idUnicaVideo = new Uuid().v4();
        var _idUnicaThumbnail = new Uuid().v4();

        //Se toma el thumbnail para subirlo
        final uint8list = await VideoThumbnail.thumbnailFile(
          video: listadoVideos[i].path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 400, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 100,
        );

        //Se transforma thumbnail en File
        File thumbnail = File(uint8list);
        //File thumbnail = new File(thumbnailString);
        //Referencia para subir thumbnail
        Reference referenceThumbnail = storage.ref().child(DatosEstaticos.rutEmpresa).child('thumbnails').child(_idUnicaThumbnail);
        //Se crea el objeto que realiza la tarea de subida de thumbnail
        UploadTask uploadTaskThumbnail = referenceThumbnail.putFile(thumbnail);
        //Se procesa la subida y luego se obtiene el nombre del archivo
        _urlFileThumbnail = await (await uploadTaskThumbnail.whenComplete(() => null)).ref.getDownloadURL();
        _urlFileThumbnail = _urlFileThumbnail.toString();

        //Referencia para subir video
        Reference referenceVideo = storage.ref().child(DatosEstaticos.rutEmpresa).child('videos').child(_idUnicaVideo);
        //Se crea el objeto que realiza la tarea de subida
        UploadTask uploadTask = referenceVideo.putFile(listadoVideos[i]);
        //Se procesa la subida y luego se obtiene el nombre del archivo
        _urlFileVideo = await (await uploadTask.whenComplete(() => null)).ref.getDownloadURL();
        _urlFileVideo = _urlFileVideo.toString();

        //Se añade archivo a la colección a la bd
        //Se agrega un thumbnail para visualizar el video
        fileReferenceInDB.doc(_idUnicaVideo).set({
          "idVideo":_idUnicaVideo,
          "url":_urlFileVideo,
          "thumbnail": _urlFileThumbnail,
          "idThumbnail":_idUnicaThumbnail
        });

      }

      //Se devuelve el thumbnail
      return _urlFileThumbnail;

    }
    catch (ex){

      return null;
    }
  }

  ///ELIMINA VIDEOS DESDE BASE DE DATOS REAL TIME EN FIREBASE PASANDO
  ///EL CONJUNTO DE IDs
  static Future<bool> EliminarVideoFirebase(List<String> archivosAEliminar) async {

    String id = "";
    //Se instancia la colección en la base de datos
    CollectionReference fileReferenceInDB = FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('videos');
    //Se instancia el storage
    FirebaseStorage storage = FirebaseStorage.instance;
    try
    {
      for (int i = 0; i < archivosAEliminar.length; i++){

        //Id que maneja la referencia al documento
        id = archivosAEliminar[i];

        //Se obtiene el conjunto de datos para extraer la url
        var datos = await fileReferenceInDB.doc(id).get();

        //Se extrae la url
        var urlVideo = datos.get("url");
        var urlThumbnail = datos.get("thumbnail");

        //Se elimina de bd pasando el id
        await fileReferenceInDB.doc(id).delete();

        //Se elimina video y thumbnail del bucket pasando la url
        await storage.refFromURL(urlVideo).delete();
        await storage.refFromURL(urlThumbnail).delete();
      }

      return true;

    }
    catch (ex){

      return false;
    }
  }

}