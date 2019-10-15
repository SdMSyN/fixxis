import 'package:flutter/material.dart';
import '../services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => new _LoginSignUpPageState();
}

enum FormMode { LOGIN, SIGNUP }
enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  String _email;
  String _password;
  String _errorMessage;
    String err = "";

  // Initial form is login form
  FormMode _formMode = FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });

        _database.reference().child("user").push().set({
          "correo"  : _email,
          "perfil"  : "trabajador" // FIXME: añadir validación y tipo de perfil
        });
        if (userId.length > 0 && userId != null && _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
        }

      } catch (e) {
        switch (e.message){
          case 'The email address is badly formatted.':
            err = "Formato de correo electrónico incorrecto.";
            break;
          case 'The password is invalid or the user does not have a password.':
            err = "Contraseña incorrecta.";
            break;
          case 'The given password is invalid. [ Password should be at least 6 characters ]':
            err = "La contraseña es muy corta, debe de tener más de 6 caracteres";
            break;
          default:
            err = 'Probablemente es nuestra culpa, pero diremos y asumiremos que es culpa de tu dispositivo y/o Internet.';
        }
        print('The error is $err');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: $err';
        });
      }
    }
  }


  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('FIXXIS'),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 100.0,
          child: Image.asset('assets/icono_1.png'),
        )
      );
      // return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);

  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Favor de verificar tu cuenta"),
          content: new Text("El enlace para activar tu cuenta ha sido enviado a tu correo electrónico"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Aceptar"),
              onPressed: () {
                _changeFormToLogin();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showBody(){
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showEmailInput(),
              _showPasswordInput(),
              _showPrimaryButton(),
              _showSecondaryButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/logo_2.png'),
          // child: Image.asset('assets/flutter-icon.png'),
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Correo electrónico',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        // validator: (value) => value.isEmpty ? 'El correo electrónico no puede estar vacio' : null,
        validator: (value) {
          if( value.isEmpty ){
            setState(() {
               _isLoading = false;
            });
            return 'El correo electrónico no puede estar vacio.';
          } return null;
        },
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Contraseña',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) {
          if( value.isEmpty ){
            setState(() {
               _isLoading = false;
            });
            return 'La contraseña no puede estar vacia.';
          } return null;
        },
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text('Crear una cuenta',
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
          : new Text('¿Ya tienes una cuenta? Inicia sesión',
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.deepOrange[300],
            child: _formMode == FormMode.LOGIN
                ? new Text('Iniciar sesión',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text('Crear una cuenta',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }
}