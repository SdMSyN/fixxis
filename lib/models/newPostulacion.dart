import 'package:firebase_database/firebase_database.dart';

class NewPostulacion{
  String  descripcion,
          idOferta,
          idUser,
          key;
  int     days,
          hours,
          cotizacion;
  double  comision,
          ganancia;
  bool    estatus;

  NewPostulacion( this.idOferta, this.idUser, this.estatus, this.descripcion, this.days, this.hours, this.cotizacion, this.comision, this.ganancia );

  NewPostulacion.fromSnapshot(DataSnapshot snapshot) :
    key         = snapshot.key,
    descripcion = snapshot.value['descripcion'],
    idOferta    = snapshot.value['idOferta'],
    idUser      = snapshot.value['idUser'],
    days        = snapshot.value['days'],
    hours       = snapshot.value['hours'],
    cotizacion  = snapshot.value['cotizacion'],
    comision    = snapshot.value['comision'],
    ganancia    = snapshot.value['ganancia'],
    estatus     = snapshot.value['estatus'];

    toJson(){
      return {
        "descripcion" : descripcion,
        "idOferta"    : idOferta,
        "idUser"      : idUser,
        "days"        : days,
        "hours"       : hours,
        "cotizacion"  : cotizacion,
        "comision"    : comision,
        "ganancia"    : ganancia,
        "estatus"     : estatus,
      };
    }

}