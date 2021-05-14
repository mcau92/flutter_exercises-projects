import 'package:flutter/material.dart';
import 'package:splitmacros/auth/authentication.dart';
import 'package:splitmacros/home/homepage.dart';
import 'package:splitmacros/service/navigator_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red[900],
        accentColor: Color.fromRGBO(42, 117, 188, 1),
        backgroundColor: Color.fromRGBO(28, 27, 27, 1),
      ),
      initialRoute: "login",
      routes: {
        "login": (BuildContext _context) => AuthenticationPage(),
        "home": (BuildContext _contex) => HomePage()
      },
    );
  }
}
