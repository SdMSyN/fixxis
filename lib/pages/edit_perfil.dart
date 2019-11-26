import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditPerfil extends StatefulWidget{
  EditPerfil({Key key, this.userId}) : super(key: key);
  final String userId;
  
  @override 
  _EditPerfilState createState() => new _EditPerfilState();
}

class _EditPerfilState extends State<EditPerfil>{
  // variables
  final _formKey                              = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseDatabase _database            = FirebaseDatabase.instance;

  String _mailProfile, _urlImgProfile, _nameProfile;
  File _image;

  @override 
  void initState(){
    super.initState();
    // obtenemos la información del perfi ldel usuario
    _database.reference().child("user").orderByChild("id").equalTo(widget.userId).once().then((DataSnapshot dataSnapShot){
      setState(() {
        Map<dynamic, dynamic> values = dataSnapShot.value;
        values.forEach( ( key, values ) {
          _mailProfile    = values["correo"];
          _urlImgProfile  = ( values["urlImg"] != null ) ? values["urlImg"] : "";
          _nameProfile    = ( values["nombre"] != null ) ? values["nombre"] : "";
        } );
      } );
    } );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('FIXXIS'),
        actions: <Widget>[
          new FlatButton(
            child: new Text(
              'Atrás',
              style: new TextStyle(fontSize: 17.0, color: Colors.white),
            ),
            onPressed: () { Navigator.pop(context, 'Atrás' );},
          ),
        ],
      ),
      body: new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
          key: _formKey,
          autovalidate: false,
          child: new ListView(
            padding: const EdgeInsets.symmetric( horizontal: 16.0, vertical: 10.0 ),
            children: <Widget>[
              _showPerfilImg(),
              _showPerfilMail(),
              _showPerfilName(),
              _showButtonSubmit(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _showPerfilImg(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _image != null 
          ? new CircleAvatar(
            backgroundColor: Colors.red,
            // child: new Image.file(_image),
            backgroundImage: new FileImage(_image),
            radius: 64.0,
          )
          : new CircleAvatar(
            radius: 64.0,
            backgroundImage: ( _urlImgProfile != null && _urlImgProfile != "" ) ? CachedNetworkImage( imageUrl: _urlImgProfile ) : AssetImage('assets/icono_1.png') ,
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.red, 
          ),
        new FloatingActionButton(
          child: Icon(Icons.camera_alt),
          backgroundColor: Colors.red,
          elevation: 20.0,
          onPressed: () { 
            print("Camara"); 
            chooseFile();
          },
          mini: true,
        ),
      ],
    );
  }

  Future chooseFile() async{
    await ImagePicker.pickImage( source: ImageSource.gallery).then((image){
      setState(() {
        _image = image;
      });
    });
  }

  Widget _showPerfilMail(){
    return new Container(
      padding : EdgeInsets.only(top: 10.0),
      child   : Center(
        child: Text(
          "$_mailProfile", 
          style: TextStyle(
            fontWeight : FontWeight.bold,
            fontSize   : 18,
          )
        ),
      ),
    );
  } 

  Widget _showPerfilName(){
    return new TextFormField(
      decoration:  InputDecoration(
        icon      : Icon(Icons.person),
        hintText  : ( _nameProfile != null && _nameProfile != "" ) ? '$_nameProfile' : 'Nombre completo',
        labelText : ( _nameProfile != null && _nameProfile != "" ) ? '$_nameProfile' : 'Nombre completo', 
      ),
      inputFormatters: [new LengthLimitingTextInputFormatter(50)],
      validator: (value) => value.isEmpty ? 'Favor de escribir tu nombre' : null,
    );
  }

  Widget _showButtonSubmit(){ // TODO: actualización de perfil
    return new Container(
      padding : const EdgeInsets.only( top: 20.0 ),
      child   : new RaisedButton(
        child     : Text("Actualizar"),
        onPressed : _submitForm,
        color     : Colors.blueAccent,
      ),
    );
  }

  void _submitForm(){
    print("Enviando...");
  }


}