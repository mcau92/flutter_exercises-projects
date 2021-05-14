import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splitmacros/auth/authentication.dart';
import 'package:splitmacros/home/homepage.dart';
import 'package:splitmacros/service/navigator_service.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  /* SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(MyApp())); */
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
        primaryColor: Color.fromRGBO(234, 142, 35, 1),
        backgroundColor: Color.fromRGBO(73, 67, 67, 1),
        textTheme: TextTheme(
          headline1: GoogleFonts.satisfy(color: Colors.white, fontSize: 50),
          headline2:
              TextStyle(fontSize: 22, color: Theme.of(context).backgroundColor),
        ),
      ),
      initialRoute: "login",
      routes: {
        "login": (BuildContext _context) => AuthenticationPage(),
        "home": (BuildContext _contex) => HomePage()
      },
    );
  }
}
