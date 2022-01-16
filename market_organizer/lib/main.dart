import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/pages/home_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/new_receipt_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/searchProduct/single_product_search_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/selected/new_selected_receipt_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/selected/searchProduct/single_product_insert_search_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/selected/searchProduct/single_product_search_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/show/show_receipt_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/show/single_product_insert_show_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/show/single_product_update_show_widget%20copy.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/single_product_insert_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/single_product_update_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/searchProduct/new_product_menu_page.dart';
import 'package:market_organizer/pages/spesa/add_spesa_page.dart';
import 'package:market_organizer/pages/spesa/single_product_detail_page.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_page.dart';
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
        "addReceiptPage": (BuildContext _context) => NewReceiptPage(),
        //inserisco prodotto per menu
        "addProductPageForMenu": (BuildContext _context) =>
            NewProductForMenuPage(),
        "addSelectedReceiptPage": (BuildContext _context) =>
            NewSelectedReceiptPage(),
        "showReceiptPage": (BuildContext _context) => ShowReceiptPage(),
      },
      onGenerateRoute: (settings) {
        //DETTAGLIO PRODOTTO IN SPESA
        if (settings.name == "singleProductDetailPage") {
          SingleProductDetailPageInput args =
              settings.arguments as SingleProductDetailPageInput;
          return MaterialPageRoute(builder: (context) {
            return SingleProductDetailPage(args);
          });
        }

        //DETTAGLIO PRODOTTO IN RICETTA IN FASE DI INSERIMENTO singleProductUpdateDetailPage
        if (settings.name == "singleProductInsertDetailPage") {
          SingleProductInsertInput args =
              settings.arguments as SingleProductInsertInput;
          return MaterialPageRoute(builder: (context) {
            return SingleProductInsertWidget(args);
          });
        }
        //RICERCA PRODOTTO IN FASE DI INSERIMENTO
        if (settings.name == "singleProductSearchDetailPage") {
          SingleProductSearchInput args =
              settings.arguments as SingleProductSearchInput;
          return MaterialPageRoute(builder: (context) {
            return SingleProductSearchWidget(args);
          });
        }
        if (settings.name == "singleProductSearchNewPage") {
          SingleProductSearchNewInput args =
              settings.arguments as SingleProductSearchNewInput;
          return MaterialPageRoute(builder: (context) {
            return SingleProductSearchNewWidget(args);
          });
        }
        //DETTAGLIO PRODOTTO IN RICETTA IN FASE DI INSERIMENTO TRAMITE RICERCA
        if (settings.name == "singleProductInsertSearchDetailPage") {
          SingleProductSearchDetailInput args =
              settings.arguments as SingleProductSearchDetailInput;
          return MaterialPageRoute(builder: (context) {
            return SingleProductInsertSearchWidget(args);
          });
        }
        //DETTAGLIO PRODOTTO IN RICETTA IN FASE DI AGGIORNAMENTO
        if (settings.name == "singleProductUpdateDetailPage") {
          SingleProductUpdateInput args =
              settings.arguments as SingleProductUpdateInput;
          return MaterialPageRoute(builder: (context) {
            return SingleProductUpdateWidget(args);
          });
        }
        //DETTAGLIO PRODOTTO IN RICETTA GIA INSERITA E PRODOTTO DA CREARE NUOVO
        if (settings.name == "singleProductInsertShowDetailPage") {
          SingleProductInsertShownIput args =
              settings.arguments as SingleProductInsertShownIput;
          return MaterialPageRoute(builder: (context) {
            return SingleProductInsertShowWidget(args);
          });
        }
        //DETTAGLIO PRODOTTO IN RICETTA GIA INSERITA E PRODOTTO DA AGGIORNARE
        if (settings.name == "singleProductUpdateShowDetailPage") {
          SingleProductUpdateShownIput args =
              settings.arguments as SingleProductUpdateShownIput;
          return MaterialPageRoute(builder: (context) {
            return SingleProductUpdateShowWidget(args);
          });
        }

        return null;
      },
    );
  }
}
