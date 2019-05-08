import 'package:flutter/material.dart';
import 'app/recognition_app.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flutter App',
      home: RecognitionApp(),
    );
  }
}
