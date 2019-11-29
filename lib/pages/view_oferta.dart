import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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

  @override
  void initState() {
    super.initState();
    print("----- initState:");
    print(widget.ofertaId);
    _idOferta = widget.ofertaId;
    dBRef.child('ofertas/$_idOferta').once().then((DataSnapshot dataSnapShot){
      setState(() {
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
        _showPostulaciones(),
      ],
    );
  }

  Widget _showPostulaciones(){
    return new Container(
      margin      : EdgeInsets.all(16.0),
      padding     : EdgeInsets.all(3.0),
      // decoration  : BoxDecoration(
      //   color       : Colors.purple[800],
      //   border      : Border.all(),
      //   borderRadius: BorderRadius.all( Radius.circular( 3.0 ) ),
      // ),
      child: Card(
        color: Colors.purple[900],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width : 130,
              child: leftColumn,
            ),
            rightColumn,
          ],
        ), 
      ),
    );
  }

  var stars = Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star, color: Colors.green[500]),
      Icon(Icons.star, color: Colors.green[500]),
      Icon(Icons.star, color: Colors.green[500]),
      Icon(Icons.star, color: Colors.black),
      Icon(Icons.star, color: Colors.black),
    ],
  );

  final leftColumn = Container(
    padding: EdgeInsets.all( 10 ),
    child: Column(
      children: <Widget>[
        CircleAvatar(
          radius: 32.0,
          backgroundColor: Colors.red,
        ),
        Text(
          'Nombre Completo',
          style: TextStyle( color: Colors.white ),
        ),
        stars, // FIXME: 
      ],
    ),
  );

  

  final rightColumn = Container(
    padding: EdgeInsets.fromLTRB( 5, 5, 8, 5 ),
    child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only( right : 8.0 ),
              child  : Icon(
                Icons.attach_money,
                color : Colors.greenAccent
              ),
            ),
            Text( 
              'Hola', // cotización
              style : TextStyle( color: Colors.white ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              'Descripción',
              style : TextStyle( color : Colors.white60 ),
            ),
          ],
        ),
        Row(
          children : <Widget>[
            Column(
              children: [
                Icon(Icons.wb_sunny, color: Colors.green),
                Text(
                  'Días', 
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ), 
            Column(
              children: [
                Icon(Icons.access_time, color: Colors.green),
                Text(
                  'Horas', 
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