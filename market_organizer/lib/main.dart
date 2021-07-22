import 'package:flutter/material.dart';
import 'package:market_organizer/homepage/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'spesa',
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.black,
        cardColor: Color.fromRGBO(229, 229, 229, 1),//light grey
        primarySwatch: Colors.blue,
      ),
      initialRoute: "home",
      routes: {
        "home": (BuildContext _contex) => HomePage()
      },
    );
  }
}

