import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import '../services/authentication.dart';
import '../models/newOferta.dart';
import 'create_trabajo.dart';
import 'view_oferta_trabajador.dart';

class HomePageTrabajador extends StatefulWidget {
  HomePageTrabajador({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageTrabajadorState();
}

class _HomePageTrabajadorState extends State<HomePageTrabajador> {
  List<NewOferta> _todoList;
  String _idUser;

  final FirebaseDatabase _database    = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey  = GlobalKey<FormState>();
  final _scaffoldKey                  = GlobalKey<ScaffoldState>();

  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _todoQuery;

  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    _checkEmailVerification();

    _todoList = new List();
    _todoQuery = _database
        .reference()
        .child("ofertas"); // this is the collection in firebase
        // .orderByChild("userId")
        // .equalTo(widget.userId); 
    _onTodoAddedSubscription    = _todoQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription  = _todoQuery.onChildChanged.listen(_onEntryChanged);
    _idUser                     = widget.userId;
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail(){
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Favor de verificar tu cuenta"),
          content: new Text("Por favor verifica tu cuenta, desde el enlace enviado a tu correo electrónico."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Reenviar enlace"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verifica tu cuenta"),
          content: new Text("El enlace de verificación, ha sido enviado a tu correo electrónico."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  _onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] = NewOferta.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      _todoList.add(NewOferta.fromSnapshot(event.snapshot));
    });
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  Widget _showTodoList(){
    if (_todoList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _todoList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId   = _todoList[index].key;
            String subject  = _todoList[index].titulo;
            bool completed  = _todoList[index].material;
            String userId   = _todoList[index].idUser;
            String urlImg   = _todoList[index].urlImg;
            return ListTile(
              leading   : ( urlImg != null ) ? Image.network(urlImg) : Image.asset('assets/icono_1.png'),
              title     : Text(subject),
              subtitle  : Text(todoId),
              trailing  : Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ViewOfertaTrabajador(ofertaId: todoId, userId: _idUser) )
                );
              },
            );
          });
    } else {
      return Center(
        child     : Text("Welcome to the Mictlán.",
        textAlign : TextAlign.center,
        style     : TextStyle(fontSize: 30.0),)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('FIXXIS'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Cerrar sesión',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: _showTodoList(),
    );
  }

  _navigatedAndDisplay(BuildContext context) async{
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTrabajo( userId: _idUser ) ),
    );
    _scaffoldKey.currentState.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("$result")));
  }

}