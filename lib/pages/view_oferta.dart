import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/viewPostulacion.dart';

class ViewOferta extends StatefulWidget {
  ViewOferta({Key key, this.ofertaId}) : super(key: key);
  final String ofertaId;
    
  @override 
  _ViewOfertaState createState() => new _ViewOfertaState();
}

class _ViewOfertaState extends State<ViewOferta>{

  final dBRef = FirebaseDatabase.instance.reference();
  String  _titulo,
          _descripcion,
          _urlImage,
          _tipoTrabajo,
          _idOferta;
  int     _pptoIni,
          _pptoFin;
  bool    _material;
  List<ViewPostulacion> _listPost = new List();

  @override
  void initState() {
    super.initState();
    print("----- initState:");
    print(widget.ofertaId);
    _idOferta = widget.ofertaId;
    dBRef.child('ofertas/$_idOferta').once().then((DataSnapshot dataSnapShot){
      setState(() {
        print(" DATASNAPSHOT::::");
        print(dataSnapShot.value);
        Map<dynamic, dynamic> values = dataSnapShot.value;
        print(values);
        _titulo       = values["titulo"];
        _descripcion  = values["descripcion"];
        _urlImage     = values["urlImg"];
        _tipoTrabajo  = values["tipoTrabajo"];
        _pptoIni      = values["pptoIni"];
        _pptoFin      = values["pptoFin"];
        _material     = values["material"];
      });
    });

    // FIXME: consulta de postulaciones e información de usuarios
    dBRef.child('postulaciones').orderByChild("idOferta").equalTo(widget.ofertaId).once().then((DataSnapshot dataSnapshot){
      print("dataSnapshot:::");
      print(dataSnapshot);
      Map<dynamic, dynamic> values2 = dataSnapshot.value;
      print("********* ViewOferta---InitState");
      print(values2);
      values2.forEach((key2, values2){
        String idUser = values2["idUser"];
        dBRef.child("user").orderByChild("id").equalTo(idUser).once().then((DataSnapshot dataSnapshot3){
          setState(() {
            Map<dynamic, dynamic> values3 = dataSnapshot3.value;
            print("------- ViewOferta---InitState-----USER:");
            print(values3);
            values3.forEach((key3, values3){
              String urlImgTemp = ( values3["urlImg"] == null ) ? "assets/icono_1.png" : values3["urlImg"];

              var snap = {
                "descripcion" : values2["descripcion"],
                "idOferta"    : _idOferta,
                "idUser"      : idUser,
                "nameUser"    : values3["nombre"],
                "days"        : values2["days"],
                "hours"       : values2["hours"],
                "cotizacion"  : values2["cotizacion"],
                "urlImgUser"  : urlImgTemp,
              };

              // _listPost.add(ViewPostulacion.fromSnapshot(newViewPost.toJson()));
              _listPost.add(ViewPostulacion.fromJson( snap ));
            });
          });
        });
      });
    });

  }

  @override
  Widget build(BuildContext context){
    print("************");
    print("Oferta: $widget.ofertaId" );
    print(widget.ofertaId);
    return new Scaffold(
        // key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('FIXXIS'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Atrás',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () { Navigator.pop(context, 'Atras'); },
            ),
          ],
        ),
        body: new SafeArea(
          child: _viewCard(),
        ),
    );
  }

  _viewCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Photo and title.
        SizedBox(
          height: 184.0,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Ink.image(
                  image   : ( _urlImage != null ) 
                    ? CachedNetworkImageProvider( _urlImage ) 
                    : AssetImage('assets/icono_1.png') ,
                  fit     : BoxFit.cover,
                  child   : Container(),
                ),
              ),
              Positioned(
                bottom  : 16.0,
                left    : 16.0,
                right   : 16.0,
                child   : FittedBox(
                  fit       : BoxFit.scaleDown,
                  alignment : Alignment.centerLeft,
                  child     : Text( 
                    (_titulo != null ) ? _titulo : "", 
                    style: TextStyle(
                      color       : Colors.white,
                      fontWeight  : FontWeight.bold,
                      fontSize    : 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Description and share/explore buttons.
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: DefaultTextStyle(
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.subhead,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // three line description
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    ( _descripcion != null ) ? _descripcion : "",
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      ( _tipoTrabajo != null ) ? _tipoTrabajo : "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ( _material != null && _material ) ? Text(" - Se requiere comprar material") : Text("No se requiere material") ,
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text( ( _pptoIni != null && _pptoFin != null ) ? "Presupuesto: \$$_pptoIni - \$$_pptoFin " : "" ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Expanded( child: Divider(color: Colors.red, indent: 5.0,) ),
        Expanded(
          // child: Text("Hola"),
            child: new ListView.builder(
              itemCount: _listPost.length,
              itemBuilder: (BuildContext context, int index){
                // return Card( child: ListTile(title: Text("Luigi")));
                return _showPostulaciones(  
                  _listPost[index].urlImgUser, 
                  _listPost[index].nameUser, 
                  _listPost[index].cotizacion,
                  _listPost[index].descripcion,
                  _listPost[index].days,
                  _listPost[index].hours,
                );
            }),
        ),
      ],
    );
  }

  Widget _showPostulaciones( urlImgAvatar, nombre, cotizacion, descripcion, dias, horas ){
    // new ListView.builder(itemBuilder: (BuildContext context, int index){
      return new Container(
        margin      : EdgeInsets.all(16.0),
        padding     : EdgeInsets.all(3.0),
        child: Card(
          color: Colors.purple[900],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width : 130,
                child: leftColumn( urlImgAvatar, nombre ),
              ),
              rightColumn( cotizacion, descripcion, dias, horas ),
            ],
          ), 
        ), 
      );
    // });
  }

  // final leftColumn = Container(
  Widget leftColumn( urlImgProfile, nameProfile ) {
    return new Container(
      padding: EdgeInsets.all( 10 ),
      child: Column(
        children: <Widget>[
          new CircleAvatar(
            radius: 32.0,
            backgroundColor: Colors.red,
            backgroundImage: ( urlImgProfile == "assets/icono_1.png" ) 
              ? AssetImage( urlImgProfile )
              : CachedNetworkImageProvider( urlImgProfile ),
          ),
          Text(
            '$nameProfile',
            style: TextStyle( 
              color: Colors.white, 
              fontSize: 12.0, 
            ),
          ), 
          _showStars(),
        ],
      ),
    );
  }

  Widget _showStars(){
    return new Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.green[500], size: 12.0,),
          Icon(Icons.star, color: Colors.green[500], size: 12.0,),
          Icon(Icons.star, color: Colors.green[500], size: 12.0,),
          Icon(Icons.star, color: Colors.green[500], size: 12.0,),
          Icon(Icons.star, color: Colors.black, size: 12.0,),
        ],
      ),
    );
  }


  // final rightColumn = Container(
  Widget rightColumn( cotizacion, descripcion, dias, horas ) {
    return new  Container(
      padding: EdgeInsets.fromLTRB( 5, 5, 8, 5 ),
      alignment: Alignment.topLeft,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only( right : 8.0 ),
                child  : Icon(
                  Icons.attach_money,
                  color : Colors.greenAccent
                ),
              ),
              Text( 
                '$cotizacion', // cotización
                style : TextStyle( color: Colors.white ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              SizedBox( 
                width: 150,
                child: Text('$descripcion',
                  style : TextStyle( color : Colors.white60 ),
                )
              ),
              // Text(
              //   '$descripcion',
              //   maxLines: 5,
              //   style : TextStyle( color : Colors.white60 ),
              // ),
            ],
          ),
          // Row(
          //   children: <Widget>[
          //     new Flexible(
          //       child: new Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: <Widget>[
          //           Text(
          //             '$descripcion',
          //             style : TextStyle( color : Colors.white60 ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          Row(
            children : <Widget>[
              Column(
                children: [
                  Icon(Icons.wb_sunny, color: Colors.green),
                  Text(
                    '$dias', 
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ), 
              Column(
                children: [
                  Icon(Icons.access_time, color: Colors.green),
                  Text(
                    '$horas', 
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

}