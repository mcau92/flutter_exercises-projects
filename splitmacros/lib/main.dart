import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:splitmacros/auth/authentication.dart';
import 'package:splitmacros/home/homepage.dart';
import 'package:splitmacros/provider/auth_provider.dart';
import 'package:splitmacros/provider/day_provider.dart';
import 'package:splitmacros/service/navigator_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  /* SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(MyApp())); */
  await Firebase.initializeApp(); //init firebase
  //setting up firestore cache
  /* FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: 50,
  ); */
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DayProvider>.value(value: DayProvider.instance),
      ],
      child: MyApp(),
    ),
  );
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
        backgroundColor: Color.fromRGBO(205, 199, 199, 1),
        cardColor: Color.fromRGBO(73, 67, 67, 1),
        accentColor: Color.fromRGBO(218, 218, 218, 1),
        buttonColor: Color.fromRGBO(196, 196, 196, 1),
        textTheme: TextTheme(
          headline1: GoogleFonts.satisfy(
              color: Colors.white, fontSize: 50), //main title signin
          headline2: GoogleFonts.sahitya(
              color: Colors.black, fontSize: 22), //title input form
          headline3: GoogleFonts.sahitya(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold), //title section
          headline4: GoogleFonts.sahitya(
              color: Colors.black, fontSize: 18), //input form
          headline5: GoogleFonts.sahitya(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ), //button white text
          headline6: GoogleFonts.sahitya(
            color: Colors.black,
            fontSize: 22,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
      initialRoute: "home",
      routes: {
        "login": (BuildContext _context) => AuthenticationPage(),
        "home": (BuildContext _contex) => HomePage()
      },
    );
  }
}
