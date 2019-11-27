import 'package:firebase_database/firebase_database.dart';

class NewEditPerfil{
  String key;
  String nombre;
  String urlImg;

  NewEditPerfil( this.nombre, this.urlImg );

  NewEditPerfil.fromSnapshot(DataSnapshot snapshot) :
    key       = snapshot.key,
    nombre    = snapshot.value["perfilName"],
    urlImg    = snapshot.value["perfilUrlImg"];

    toJson() {
      return {
        "nombre"  : nombre,
        "urlImg"  : urlImg,
      };
    }

}