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
  String  _titulo;
  String  _descripcion;
  String  _urlImage;
  String  _tipoTrabajo;
  String  _idOferta;
  int     _pptoIni;
  int     _pptoFin;
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
                // // In order to have the ink splash appear above the image, you
                // // must use Ink.image. This allows the image to be painted as part
                // // of the Material and display ink effects above it. Using a
                // // standard Image will obscure the ink splash.
                child: Ink.image(
                  image   : ( _urlImage != null ) ? CachedNetworkImageProvider(_urlImage) : AssetImage('assets/icono_1.png') ,
                  fit     : BoxFit.cover,
                  child   : Container(),
                ),
                //child: ( _urlImage != null ) ? CachedNetworkImageProvider(_urlImage) : new Image.asset('assets/icono_1.png') , 
                // child: Ink.image(
                //   image   : ( _urlImage != null ) ? CachedNetworkImageProvider(_urlImage) : new Image.asset('assets/icono_1.png'),
                //   fit     : BoxFit.cover,
                //   child   : Container(),
                // ),
                //child: Image(image: ( _urlImage != null ) ? CachedNetworkImageProvider(_urlImage) : new Image.asset('assets/icono_1.png') , ),
                // child: Image( 
                //   image: ( _urlImage != null ) ? CachedNetworkImageProvider(_urlImage) :  AssetImage('assets/icono_1.png'), 
                //   fit: BoxFit.cover,
                // ),
                // child: Ink.image(
                //   image   : new CachedNetworkImage( placeholder: new AssetImage('assets/icono_1.png'), imageUrl: _urlImage, ) ,
                //   fit     : BoxFit.cover,
                //   child   : Container(),
                // ),
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
        // if (destination.type == CardDemoType.standard)
        //   // share, explore buttons
        //   ButtonBar(
        //     alignment: MainAxisAlignment.start,
        //     children: <Widget>[
        //       FlatButton(
        //         child: Text('SHARE', semanticsLabel: 'Share ${destination.title}'),
        //         textColor: Colors.amber.shade500,
        //         onPressed: () { print('pressed'); },
        //       ),
        //       FlatButton(
        //         child: Text('EXPLORE', semanticsLabel: 'Explore ${destination.title}'),
        //         textColor: Colors.amber.shade500,
        //         onPressed: () { print('pressed'); },
        //       ),
        //     ],
        //   ),
      ],
    );
  }


}