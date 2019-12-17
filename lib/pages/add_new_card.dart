import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:stripe_payment/stripe_payment.dart';

class AddNewCard extends StatefulWidget{
  AddNewCard({Key key, this.userKey}) : super(key:key);
  final String userKey;

  @override
  _AddNewCardState createState() => new _AddNewCardState();
}

class _AddNewCardState extends State<AddNewCard>{
  final                           _formKey      = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState>  _scaffoldKey  = new GlobalKey<ScaffoldState>();
  final FirebaseDatabase          _database     = FirebaseDatabase.instance;

  @override
  void initState(){
    super.initState();
    // StripeSource.setPublishableKey('pk_test_ECdiAFZr2hAhqf1d7u0NDIfW00Ul8tKDXB');
  }

  @override 
  Widget build(BuildContext context){
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Añadir tarjeta'),
              textColor: Colors.white,
              color: Colors.green,
              onPressed: () {
                // StripeSource.addSource().then( (token) {
                //   _database.reference().child("tarjetas").push().set({
                //     'userKey': widget.userKey,
                //     'token'  : token
                //   });
                // });
              },
            )
          ],
        )
      )
    );
  }
}