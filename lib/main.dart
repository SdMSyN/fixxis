import 'package:flutter/material.dart';
import 'services/authentication.dart';
import 'pages/root_page.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'FIXXIS 0.0.1',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.deepOrange,
          // primarySwatch: Colors.blue,
        ),
        home: new RootPage(auth: new Auth()));
  }
} 