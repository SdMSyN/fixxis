import 'package:firebase_database/firebase_database.dart';

class ViewPostulacion{
  String  descripcion,
          idOferta,
          idUser,
          key,
          urlImgUser,
          nameUser;
  int     days,
          hours,
          cotizacion;

  ViewPostulacion( this.idOferta, this.idUser, this.nameUser, this.urlImgUser, this.descripcion, this.days, this.hours, this.cotizacion );

  ViewPostulacion.fromSnapshot(DataSnapshot snapshot) :
    key         = snapshot.key,
    descripcion = snapshot.value['descripcion'],
    idOferta    = snapshot.value['idOferta'],
    idUser      = snapshot.value['idUser'],
    days        = snapshot.value['days'],
    hours       = snapshot.value['hours'],
    cotizacion  = snapshot.value['cotizacion'],
    urlImgUser  = snapshot.value['urlImgUser'];

    toJson(){
      return {
        "descripcion" : descripcion,
        "idOferta"    : idOferta,
        "idUser"      : idUser,
        "days"        : days,
        "hours"       : hours,
        "cotizacion"  : cotizacion,
        "urlImgUser"  : urlImgUser,
      };
    }

  ViewPostulacion.fromJson(var json){
    // return ViewPostulacion(
      this.descripcion = json['descripcion'];
      this.idOferta    = json['idOferta'];
      this.idUser      = json['idUser'];
      this.nameUser    = json['nameUser'];
      this.days        = json['days'];
      this.hours       = json['hours'];
      this.cotizacion  = json['cotizacion'];
      this.urlImgUser  = json['urlImgUser'];
    // );
  }

}