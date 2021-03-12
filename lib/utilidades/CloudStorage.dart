import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tvpost_flutter/utilidades/CloudAuthentication.dart';
import 'package:uuid/uuid.dart';
import 'datos_estaticos.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as p;


class CloudStorage{

  /// SUBE IMÁGENES A FIREBASE DEVOLVIENDO ID UNICO Y URL
  /// {0} = ID IMAGEN
  /// {1} = URL IMAGEN
  static Future<List<String>> SubirImagenFirebase(List<File> listadoVideos) async {

    //SI NO ESTÁ LOGEADO, SE IDENTIFICA EL USUARIO
    if (FirebaseAuth.instance.currentUser == null)
      await AutenticacionFirebase.entrar();

    List<String> listadoRespuesta = new List<String>();
    String _urlFile = "";

    //Se instancia la colección en la base de datos
    CollectionReference fileReferenceInDB = FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('imagenes');
    try
    {
      for (int i = 0; i < listadoVideos.length; i++){
        //Se limpia el listado por cada nueva imagen a subir
        listadoRespuesta.clear();

        String extension = p.extension(listadoVideos[i].path);
        var _idUnica = new Uuid().v4();
        _idUnica = _idUnica + extension;

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

        listadoRespuesta.add(_idUnica);
        listadoRespuesta.add(_urlFile);
      }

      return listadoRespuesta;

    }
    catch (ex){

      return null;
    }
  }

  ///ELIMINA IMAGENES DESDE BASE DE DATOS REAL TIME EN FIREBASE PASANDO
  ///EL CONJUNTO DE IDs
  static Future<bool> EliminarImagenFirebase(List<String> archivosAEliminar) async {

    //SI NO ESTÁ LOGEADO, SE IDENTIFICA EL USUARIO
    if (FirebaseAuth.instance.currentUser == null)
      await AutenticacionFirebase.entrar();

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
  /// RETORNA UN LISTADO CON LOS SIGUIENTES VALORES
  /// [0] = idUnicaVIdeo
  /// [1] = urlVideo
  /// [2] = idThumbnail
  /// [3] = urlThumbnail
  static Future<List<String>> SubirVideosFirebase(List<File> listadoVideos) async {

    //SI NO ESTÁ LOGEADO, SE IDENTIFICA EL USUARIO
    if (FirebaseAuth.instance.currentUser == null)
      await AutenticacionFirebase.entrar();

    String _urlFileVideo = "";
    String _urlFileThumbnail = "";
    List<String> listadoResultado = new List<String>();

    //Se instancia el storage
    FirebaseStorage storage = FirebaseStorage.instance;

    //Se instancia la colección en la base de datos
    CollectionReference fileReferenceInDB = FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('videos');
    try
    {
      for (int i = 0; i < listadoVideos.length; i++){
        //Se limpia el listado por cada registrio para solo tomar el último
        listadoResultado.clear();

        String extension = p.extension(listadoVideos[i].path);

        var _idUnicaVideo = new Uuid().v4();
        _idUnicaVideo = _idUnicaVideo + extension;
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

        listadoResultado.add(_idUnicaVideo);
        listadoResultado.add(_urlFileVideo);
        listadoResultado.add(_idUnicaThumbnail);
        listadoResultado.add(_urlFileThumbnail);

      }

      //Se devuelve el thumbnail
      return listadoResultado;

    }
    catch (ex){

      return null;
    }
  }

  ///ELIMINA VIDEOS DESDE BASE DE DATOS REAL TIME EN FIREBASE PASANDO
  ///EL CONJUNTO DE IDs
  static Future<bool> EliminarVideoFirebase(List<String> archivosAEliminar) async {

    //SI NO ESTÁ LOGEADO, SE IDENTIFICA EL USUARIO
    if (FirebaseAuth.instance.currentUser == null)
      await AutenticacionFirebase.entrar();

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

  static Future<List<String>> GetUrlVideYThumbnail(String idVideo) async{

    //SI NO ESTÁ LOGEADO, SE IDENTIFICA EL USUARIO
    if (FirebaseAuth.instance.currentUser == null)
      await AutenticacionFirebase.entrar();

    var listadoUrl = new List<String>();

    try {
      //Se instancia la colección en la base de datos
      CollectionReference fileReferenceInDB = FirebaseFirestore.instance.collection('empresas').doc(DatosEstaticos.rutEmpresa).collection('videos');

      //Se obtiene el conjunto de datos para extraer la url
      var datos = await fileReferenceInDB.doc(idVideo).get();

      //Se extrae la url
      var urlVideo = datos.get("url");
      var urlThumbnail = datos.get("thumbnail");

      listadoUrl.add(urlVideo);
      listadoUrl.add(urlThumbnail);
    }
    catch (ex){
      return null;

    }

    return listadoUrl;

  }
}