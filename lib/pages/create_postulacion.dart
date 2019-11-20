import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

import '../models/newPostulacion.dart'; 

class CreatePostulacion extends StatefulWidget {
  CreatePostulacion({Key key, this.userId, this.ofertaId}) : super(key: key);
  final String userId, ofertaId;
    
  @override 
  _CreatePostulacionState createState() => new _CreatePostulacionState();
}

class _CreatePostulacionState extends State<CreatePostulacion>{

  final _formKey3                             = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseDatabase _database            = FirebaseDatabase.instance;
  final dbRef                                 = FirebaseDatabase.instance.reference();
  static final TextEditingController _textController = TextEditingController();

  String _idOferta,
         _idUser,
         _descripcion,
         _keyPrimary;
  int    _pptoIni, 
         _pptoFin,
         _valFin   = 0,
         _numHours = 0,
         _numDays  = 0; 
  double _comision = 0.0,
         _ganancia = 0.0;
  bool   _material;

  static const double minValue = 0;
  static const double maxValue = 10;

  RangeValues _values   = RangeValues( 1, 1000 );
  RangeLabels _labels   = RangeLabels( '1', '5000' );


  @override 
  void initState(){
    super.initState();
    _textController.text = "";
    print("----------------- InitState");
    _idOferta = widget.ofertaId;
    _idUser = widget.userId;
    _keyPrimary = _idOferta+"/"+_idUser;
    print('Oferta = $_idOferta - Usuario = $_idUser ');
    dbRef.child('ofertas/$_idOferta').once().then((DataSnapshot dataSnapShot){
      setState((){
        Map<dynamic, dynamic> values = dataSnapShot.value;
        print(values);
        _pptoIni      = values["pptoIni"];
        _pptoFin      = values["pptoFin"];
        _material     = values["material"];
        _valFin       = _pptoIni;
        _comision = _valFin * 0.1;
        _ganancia = _valFin - _comision;
      });
    });
  }

  @override
  Widget build(BuildContext context){
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
        top: false,
        bottom: false,
        child: new Form(
          key: _formKey3,
          autovalidate: true,
          child: new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0 ),
            children: <Widget>[
              _showInputDescripcion(),
              _showInputDias(),
              _showInputHoras(),
              _showInputPresupuesto(),
              _showComision(),
              _showGanancia(),
              _showButtonSend(),
            ],
          ),
        )
      ),
    );
  }

  Widget _showInputDescripcion(){
    return new TextFormField(
      controller  : _textController,
      maxLines    : 8,
      decoration  : InputDecoration( 
        hintText    : 'Da una breve descripción de por que deberían de contratarte', 
        border      : OutlineInputBorder(),
        labelText   : 'Descripción',
        counterText : _textController.text.length.toString(),
      ),
      inputFormatters : [new LengthLimitingTextInputFormatter(1000)],
      validator       : (value) => value.isEmpty ? 'Explica por que deberían de contratarte' : null,
      onSaved         : (value) => _descripcion = value,
    );
  }

  Widget _showInputPresupuesto(){
    return Row(
      children: <Widget>[
        Container(
          child: Text('Cotización: '),
        ),
        Container(
          child: Text('\$$_valFin'),
        ),
        Container(
          child: RangeSlider(
            min: 1,
            max: 5000,
            values : _values,
            labels: _labels,
            divisions: 100,
            onChanged: (value){
              print('START: ${value.start}, END: ${value.end}');
              setState(() {
                _values = RangeValues( 1, value.end );
                _labels = RangeLabels( '1', '\$${value.end.toInt().toString()}' );
                _valFin = value.end.toInt();
                _comision = _valFin * 0.1;
                _ganancia = _valFin - _comision;
              });
            },
          ), 
        ),
      ],
    );
  }

  Widget _showComision(){
    return Text("Comisión (10%): \$$_comision");
  }

  Widget _showGanancia(){
    return Text("Ganancia real: \$$_ganancia", 
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _showInputDias(){
    return new TextFormField(
      // controller: _textDias,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
          labelText:"¿Cuántos días tardarás?", 
          hintText: "0",
          icon: Icon(Icons.wb_sunny)
      ),
      validator: (value) {
        var cadErr = '';
        cadErr = ( value.isEmpty ) ? 'Favor de colocar el número de días' :  '';
        if( value.isNotEmpty ){
          cadErr = ( int.parse(value) < 0 ) ? 'Los días no pueden ser negativos' : '';
          cadErr = ( int.parse(value) > 10 ) ? 'Los días no pueden ser más de 10' : '';
        }
        if( cadErr == '' ) cadErr = null;
        return cadErr;
      },
      onSaved : (value) => _numDays = int.parse(value),
    );
  }

  Widget _showInputHoras(){
    return new TextFormField(
      // controller: _textHoras,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
          WhitelistingTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
          labelText:"¿Cuántas horas tardarás?", 
          hintText: "0",
          icon: Icon(Icons.access_time)
      ),
      validator: (value) {
        var cadErr = '';
        cadErr = ( value.isEmpty ) ? 'Favor de colocar el número de horas' :  '';
        if( value.isNotEmpty ){
          cadErr = ( int.parse(value) < 0 ) ? 'Las horas no pueden ser negativas' : '';
          cadErr = ( int.parse(value) > 24 ) ? 'No pueden ser más de 24 horas' : '';
        }
        if( cadErr == '' ) cadErr = null;
        return cadErr;
      },
      onSaved : (value) => _numHours = int.parse(value),
    );
  }

  Widget _showButtonSend(){
    return new Container(
      padding: const EdgeInsets.only(left: 40.0, top: 20.0),
      child: new RaisedButton(
        child: const Text('Crear'),
        onPressed: _submitForm,
      )
    );
  }

  void _submitForm(){
    final FormState formAddNew = _formKey3.currentState;
    if( !formAddNew.validate() ){
      print('Formulario incorrecto');
      showMessage('Formulario incorrecto, valida tu información.');
    }else{
      formAddNew.save();
      print('Éxito*********');
      print("$_idOferta");
      print("$_idUser");
      print("$_descripcion");
      print("$_numDays");
      print("$_numHours");
      print("$_valFin");
      print("$_comision");
      print("$_ganancia");
      _addNewPostulacion();
      showMessage( '¡Te haz postulado con éxito!', Colors.blue );
      Navigator.pop(context, '¡Te haz postulado con éxito!');
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]){
    _scaffoldKey.currentState.showSnackBar(new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  _addNewPostulacion(){
    NewPostulacion newPostulacion = new NewPostulacion(
      _idOferta,
      _idUser,
      false,
      _descripcion,
      _numDays,
      _numHours,
      _valFin, // Cotización
      _comision,
      _ganancia,
      _keyPrimary
    );
    _database.reference().child("postulaciones").push().set(newPostulacion.toJson());
  }

}