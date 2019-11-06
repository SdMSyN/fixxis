import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ViewOferta extends StatefulWidget {
  ViewOferta({Key key, this.ofertaId}) : super(key: key);
  final String ofertaId;
    
  @override 
  _ViewOfertaState createState() => new _ViewOfertaState();
}

class _ViewOfertaState extends State<ViewOferta>{
  @override
  Widget build(BuildContext context){
    print("************");
    //print(ofertaId);
    print("Hola: $widget.ofertaId" );
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
          top: false,
          bottom: false,
          child: new Form(
            // key : _formKey2,
            autovalidate: true,
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                
              ],
            )
          ),
        ),
    );
  }
}