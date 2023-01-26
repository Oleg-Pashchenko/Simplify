import 'package:app/screens/loginScreen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      title: 'My App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen()
      },
    );
  }
}