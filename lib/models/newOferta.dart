import 'package:firebase_database/firebase_database.dart';

class NewOferta{
  String titulo;
  String tipoTrabajo;
  int pptoIni = 0;
  int pptoFin = 0;
  bool material;
  String descripcion;
  String idUser;
  String key;
  String urlImg;

  NewOferta(this.titulo, this.tipoTrabajo, this.pptoIni, this.pptoFin, this.material, this.descripcion, this.idUser, this.urlImg);

  // NewOferta.map(dynamic obj){
  //   this.titulo       = obj['titulo'];
  //   this.tipoTrabajo  = obj['tipoTrabajo'];
  //   this.pptoIni      = obj['pptoIni'];
  //   this.pptoFin      = obj['pptoFin'];
  //   this.material     = obj['material'];
  //   this.descripcion  = obj['descripcion'];
  // }

  NewOferta.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    titulo      = snapshot.value['titulo'],
    tipoTrabajo = snapshot.value['tipoTrabajo'],
    pptoIni     = snapshot.value['pptoIni'],
    pptoFin     = snapshot.value['pptoFin'],
    material    = snapshot.value['material'],
    descripcion = snapshot.value['descripcion'],
    idUser      = snapshot.value['userId'],
    urlImg      = snapshot.value['urlImg'];

    toJson() {
      return {
        "userId"      : idUser,
        "titulo"      : titulo,
        "tipoTrabajo" : tipoTrabajo,
        "pptoIni"     : pptoIni,
        "pptoFin"     : pptoFin,
        "material"    : material,
        "descripcion" : descripcion,
        "urlImg"      : urlImg,
      };
    }
  }
