import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'create_postulacion.dart';

class ViewOfertaTrabajador extends StatefulWidget {
  ViewOfertaTrabajador({ Key key, this.ofertaId, this.userId }) : super(key: key);
  final String ofertaId;
  final String userId;
    
  @override 
  _ViewOfertaTrabajadorState createState() => new _ViewOfertaTrabajadorState();
}

class _ViewOfertaTrabajadorState extends State<ViewOfertaTrabajador>{

  final dBRef = FirebaseDatabase.instance.reference();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String  _titulo;
  String  _descripcion;
  String  _urlImage;
  String  _tipoTrabajo;
  String  _idOferta;
  String  _idUser;
  String  _keyPrimary;
  String  _descPos;
  int     _pptoIni,
          _pptoFin,
          _hoursPos,
          _daysPos;
  int  _cotizacion;
  bool    _material,
          _postulado = false;

  @override
  void initState() {
    super.initState();
    print("----- initState:");
    print(widget.ofertaId);
    _idOferta   = widget.ofertaId;
    _idUser     = widget.userId;
    _keyPrimary = _idOferta+"/"+_idUser;
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
    // Validamos que la oferta no haya sido aún postulada
    dBRef.child("postulaciones").orderByChild("keyPrimary").equalTo(_keyPrimary).once().then((DataSnapshot dataSnapShot){
      setState(() {
        Map<dynamic, dynamic> values = dataSnapShot.value;
        print("Validación postulación");
        if( values == null ){
          print("NO postulado");
        }else{
          values.forEach((key, values){
            print("YA...");
            print(values);
            print(values["descripcion"]);
            _postulado  = true;
            _descPos    = values["descripcion"];
            _daysPos    = values["days"];
            _hoursPos   = values["hours"];
            _cotizacion = values["cotizacion"];
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context){
    print("************");
    print("Oferta: $widget.ofertaId" );
    print(widget.ofertaId);
    return new Scaffold(
        key: _scaffoldKey,
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
                // // In order to have the ink splash appear above the image, you
                // // must use Ink.image. This allows the image to be painted as part
                // // of the Material and display ink effects above it. Using a
                // // standard Image will obscure the ink splash.
                child: Ink.image(
                  image   : ( _urlImage != null ) ? 
                    CachedNetworkImageProvider( _urlImage, ) : 
                    AssetImage('assets/icono_1.png') ,
                  // image: CachedNetworkImage(imageUrl: _urlImage,),
                  fit     : BoxFit.cover,
                  child   : Container(),
                ),
                // child: ( _urlImage != null ) ? CachedNetworkImage( imageUrl: _urlImage, ) : Image.asset('assets/icono_1.png'),
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
              // Text(destination.location),
              ],
            ),
          ),
        ),
        // if (destination.type == CardDemoType.standard)
        //   // share, explore buttons
        ( _postulado == false ) ? 
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              FlatButton(
                child: Text('Postularse', semanticsLabel: 'Share '),
                textColor: Colors.white60,
                color: Colors.deepOrangeAccent,
                splashColor: Colors.blueAccent,
                onPressed: () { 
                  _navigatedAndDisplay(context);
                },
              ),
            ],
          ) : _showPostulacion(),


      ],
    );
  }

  _navigatedAndDisplay(BuildContext context) async{
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePostulacion( userId: _idUser, ofertaId: _idOferta ) ),
    );
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("$result")));
  }

  Widget _showPostulacion(){
    return Container(
      margin      : EdgeInsets.all(16.0),
      padding     : EdgeInsets.all(16.0),
      decoration  : BoxDecoration(
        color         : Colors.purple[900],
        border        : Border.all(),
        borderRadius  : BorderRadius.all(Radius.circular(3.0)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding : EdgeInsets.only(right: 8.0),
                child   : Icon(
                  Icons.attach_money, 
                  color: Colors.greenAccent
                ),
              ),
              Text(
                '$_cotizacion', 
                style: TextStyle(color: Colors.white)
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                '$_descPos',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Column(
                children: [
                  Icon(Icons.wb_sunny, color: Colors.green),
                  Text(
                    '$_daysPos', 
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.access_time, color: Colors.green),
                  Text(
                    '$_hoursPos', 
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
        ],
      )
    ); 
  }

}