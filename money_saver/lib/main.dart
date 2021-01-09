import 'package:flutter/material.dart';
import 'package:money_saver/ui/screen/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Saver',
      theme: ThemeData(primaryColor: Colors.green[200]),
      home: Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}
