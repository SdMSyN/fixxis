import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../pages/login_signup_page.dart';
import '../services/authentication.dart';
import '../pages/home_page.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final DBRef = FirebaseDatabase.instance.reference();
  Query _todoQuery;
  int _perfil;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user){
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;

    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  void _getPerfil(String userId ){
    DBRef.child('user').orderByChild("id").equalTo(userId).once().then((DataSnapshot dataSnapShot){
      Map<dynamic, dynamic> values = dataSnapShot.value;
      values.forEach((key, values){
        _perfil = values["perfil"];
      });
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        // child: CircularProgressIndicator(),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 50.0,
          child: Image.asset('assets/icono_1.png'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignUpPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          _getPerfil( _userId );
          print("PERFIL:");
          print(_perfil);
          if( _perfil == 0 ){
            return new HomePage(
              userId: _userId,
              auth: widget.auth,
              onSignedOut: _onSignedOut,
            );
          }else{
            return new HomePage(
              userId: _userId,
              auth: widget.auth,
              onSignedOut: _onSignedOut,
            );
          }
        } else return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}