import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // For image picker
import 'package:path/path.dart' as Path;

import '../models/newOferta.dart';

class CreateTrabajo extends StatefulWidget {
  CreateTrabajo({Key key, this.userId}) : super(key: key);
  final String userId;
    
  @override 
  _CreateTrabajoState createState() => new _CreateTrabajoState();
}

class _CreateTrabajoState extends State<CreateTrabajo>{

  final _formKey2                             = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseDatabase _database            = FirebaseDatabase.instance;

  List<String> _tiposTrabajo                  = <String>['','Plomeria','Carpinteria','Aluminio','Albañileria'];

  String _idUser;
  String _tipoTrabajo                         = '';
  String _titulo;
  String _descripcion;
  String _uploadedFileURL;

  RangeValues _values                         = RangeValues(1, 1000);
  RangeLabels _labels                         = RangeLabels('1', '5000');

  int _valIni                                 = 0;
  int _valFin                                 = 0;

  bool _isSwitched                            = true;

  File _image;
  StreamSubscription<Event> _onOfertaAddedSubscription;
  Query _ofertaQuery;

  // @override
  // void dispose() {
  //   _onOfertaAddedSubscription.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context){
    print("************");
    //print(userId);
    print("Hola: $widget.userId" );
    print(widget.userId);
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
            key : _formKey2,
            autovalidate: true,
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                // Crear widgets de los elementos del formulario
                _showInputTitulo(),
                _showInputTipoEmpleo(),
                _showInputPresupuesto(),
                _showInputComprarMaterial(),
                // _showInputHorario(),
                // _showInputDireccion(),
                _showInputDescripcion(),
                _showUploadImage(),
                
                new Container(
                  padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                  child: new RaisedButton(
                    child: const Text('Crear'),
                    onPressed: _submitForm,
                  )
                ),
              ],
            )
          ),
        ),
    );
  }

  Widget _showInputTitulo(){
    return new TextFormField(
      decoration: const InputDecoration(
        icon      : const Icon(Icons.person),
        hintText  : 'Título del proyecto',
        labelText : 'Título del proyecto',
      ),
      inputFormatters: [new LengthLimitingTextInputFormatter(50)],
      validator: (value)  => value.isEmpty ? 'Favor de colocar un título' : null,
      onSaved: (value)    => _titulo = value,
    );
  }

  Widget _showInputTipoEmpleo(){
    return new FormField(
      builder: (FormFieldState<String> state){
        return InputDecorator(
          decoration: InputDecoration(
            icon      : const Icon(Icons.format_paint),
            labelText : 'Tipo de trabajo',
            errorText : state.hasError ? state.errorText : null,
          ),
          isEmpty: _tipoTrabajo == '',
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton<String>(
              value     : _tipoTrabajo,
              isDense   : true,
              onChanged : (String newValue){
                setState(() {
                  _tipoTrabajo = newValue;
                  print(_tipoTrabajo);
                  state.didChange(newValue);
                });
              },
              items: _tiposTrabajo.map((String value) {
                return new DropdownMenuItem(
                  value: value, 
                  child: new Text(value),
                );
              }).toList(),
            )
          )
        );
      },
      validator: (value) {
        return value != '' ? null : 'Selecciona el tipo de la compostura.';
      },
    );
  }
  
  Widget _showInputPresupuesto(){
    return Row(
      children: <Widget>[
        Container(
          child: Text('PPTO.:'),
        ),
        Container(
          padding: const EdgeInsets.only( right: 1.0 ),
          child: Text('\$$_valIni - \$$_valFin'),
        ),
        Container(
          child: RangeSlider(
            min       : 1,
            max       : 5000,
            values    : _values,
            labels    : _labels,
            divisions : 100,
            onChanged : (value){
              print('START: ${value.start}, END: ${value.end}');
              setState((){
                _values = value;
                _labels = RangeLabels('${value.start.toInt().toString()}\$', '${value.end.toInt().toString()}\$');
                _valIni = value.start.toInt();
                _valFin = value.end.toInt();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _showInputComprarMaterial(){
    return Row(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("¿Se requiere material?"),
        Switch(
          value: _isSwitched,
          onChanged: (value){
            setState((){
              _isSwitched = value;
              print(_image);
              print(_uploadedFileURL);
            });
          },
          activeTrackColor: Colors.orangeAccent,
          activeColor     : Colors.deepOrangeAccent,
        ),
      ],
    );
  }
  
  // Widget _showInputHorario(){}
  
  // Widget _showInputDireccion(){}
  
  Widget _showInputDescripcion(){
    return TextFormField(
        maxLines    : 8,
        decoration  : InputDecoration(hintText: "Describe tu problema lo más detallado posible.", border: OutlineInputBorder(),
        labelText   : 'Detalle de la oferta'
      ),
      inputFormatters: [new LengthLimitingTextInputFormatter(1000)],
      validator : (value) => value.isEmpty ? 'Favor de describir el tipo de trabajo a realizar.' : null,
      onSaved   : (value) => _descripcion = value,
    );
  }

  Widget _showUploadImage(){
    return Column(
      children: <Widget>[
        Text('Selecciona una imagen'),
        // _image != null ? Image.asset(_image.path, height: 150,) : Container(height: 150),
        _image != null ? Image.file(_image, height: 150,) : Container(height: 150),
        _image == null ? 
          RaisedButton( 
              child     : Text('Escoger una imagen'), 
              onPressed : chooseFile, 
              color     : Colors.cyan
          ) : Container(),
        _image != null ? 
          RaisedButton(
            child     : Text('Subir imagen'),
            onPressed : uploadFile,
            color     : Colors.cyan
          ) : Container(),
        // _image != null ?
        //   RaisedButton(
        //     child: Text('Limpiar'),
        //     onPressed: clearSelection,
        //   ), Container(),
        Text('Imagen a subir'),
        _uploadedFileURL != null ?
          Image.network(
            _uploadedFileURL, 
            height: 150,
          ) : Container(),
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

  Future uploadFile() async{
    StorageReference storageReference = FirebaseStorage.instance
      .ref()
      .child('ofertas/${Path.basename(_image.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('Imagen subida');
    storageReference.getDownloadURL().then((fileURL){
      setState(() {
       _uploadedFileURL = fileURL; 
      });
    });
  }

  void _submitForm(){
    final FormState formAddNew = _formKey2.currentState;
    if( !formAddNew.validate() ){
      print('Formulario invalido. Por favor revisa y corrije.');
      showMessage('Formulario incorrecto, valida tu información.');
    }
    else{
      formAddNew.save();
      print('Formulario guardado*******************************');
      print('Título: $_titulo');
      print('Tipo: $_tipoTrabajo');
      print('\$ Inicio: $_valIni');
      print('\$ Fin: $_valFin');
      print('Material: $_isSwitched');
      print('Descripción: $_descripcion');
      _addNewOferta();
      showMessage('¡Nueva oferta creada!', Colors.blue);
      Navigator.pop(context, '¡Nueva oferta creada!');
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]){
    _scaffoldKey.currentState.showSnackBar(new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  _addNewOferta(){
    NewOferta newOferta = new NewOferta(
      _titulo, 
      _tipoTrabajo, 
      _valIni, 
      _valFin, 
      _isSwitched, 
      _descripcion,
      widget.userId,
      _uploadedFileURL
    );
    _database.reference().child("ofertas").push().set(newOferta.toJson());
  }

}