import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/pages/home_page.dart';
import 'package:market_organizer/pages/spesa/add_spesa_page.dart';
import 'package:market_organizer/pages/spesa/single_product_detail_page.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/pages/widget/menu/singleDay/meal/meal_detail_page.dart';
import 'package:market_organizer/pages/menu/singleDay/single_day_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //init firebase
  runApp(ChangeNotifierProvider(
      create: (context) => DateProvider(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'spesa',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.black,
        cardColor: Color.fromRGBO(229, 229, 229, 1), //light grey
        primarySwatch: Colors.blue,
      ),
      initialRoute: "home",
      routes: {
        "home": (BuildContext _contex) => HomePage(),
        "singleDay": (BuildContext _context) => SingleDayPage(),
        "mealDetail": (BuildContext _context) => MealDetailPage(),
        "addSpesaPage": (BuildContext _context) => AddSpesaPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == "singleProductDetailPage") {
          SingleProductDetailPageInput args = settings.arguments as SingleProductDetailPageInput;
          print(args.product.color);
          return MaterialPageRoute(builder: (context) {
            return SingleProductDetailPage(args);
          });
        }
        return null;
      },
    );
  }
}
