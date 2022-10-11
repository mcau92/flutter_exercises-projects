import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_timer/pages/break.dart';
import 'package:pomodoro_timer/pages/home.dart';
import 'package:pomodoro_timer/pages/studio.dart';
import 'package:pomodoro_timer/providers/settings_provider.dart';
import 'package:pomodoro_timer/services/navigation_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pomodoroTimer',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(199, 61, 61, 1),
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headline1: TextStyle(
              color: Colors.white,
              fontSize: 70,
              fontStyle: FontStyle.normal), //title
          headline2: TextStyle(
              color: Color.fromRGBO(185, 160, 160, 1),
              fontSize: 25,
              fontStyle: FontStyle.italic),
          headline3: TextStyle(
              color: Color.fromRGBO(185, 160, 160, 1),
              fontSize: 20,
              fontStyle: FontStyle.italic),
        ),
      ),
      initialRoute: "home",
      onGenerateRoute: (settings) {
        if (settings.name == "home") {
          return CupertinoPageRoute(
            builder: (context) {
              return const Home();
            },
          );
        }
        if (settings.name == "studio") {
          return CupertinoPageRoute(
            builder: (context) {
              return const Studio();
            },
          );
        }
        if (settings.name == "break") {
          return CupertinoPageRoute(
            builder: (context) {
              return const Break();
            },
          );
        }
        // if (settings.name == "focuspage") {
        //   SingleProductDetailPageInput args =
        //       settings.arguments as SingleProductDetailPageInput;
        //   return CupertinoPageRoute(builder: (context) {
        //     return SingleProductDetailPage(args);
        //   });
        // }
        // //ricerca prodotto in spesa
        // if (settings.name == "breakpage") {
        //   ProductSpesaSearchInput args =
        //       settings.arguments as ProductSpesaSearchInput;
        //   return CupertinoPageRoute(builder: (context) {
        //     return ProductSpesaSearchPage(args);
        //   });
        // }
        return null;
      },
    );
  }
}
