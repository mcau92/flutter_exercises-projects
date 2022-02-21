import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/productOperationType.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/pages/menu/singleDay/pasto_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/productSearch_page.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/utils.dart';

//input

class SingleDayPageInput {
  final String workspaceId;
  final String day;
  final DateTime dateTimeDay; //giorno selezionato
  final DateTime dateStart;
  final DateTime dateEnd;
  final String menuIdRef;
  final Map<DateTime, Map<String, bool>> isToExpandPastoMap;

  SingleDayPageInput(this.workspaceId, this.day, this.dateTimeDay,
      this.dateStart, this.dateEnd, this.menuIdRef, this.isToExpandPastoMap);
}

class SingleDayPage extends StatefulWidget {
  const SingleDayPage({Key key}) : super(key: key);

  @override
  _SingleDayPageState createState() => _SingleDayPageState();
}

class _SingleDayPageState extends State<SingleDayPage> {
  SingleDayPageInput singleDayPageInput;

  //navigo al dettaglio del pasto , se isRicetta false allora inserisco prodotto
  void _showMealDetailsPage(String pasto, bool isRicetta) {
    if (isRicetta) {
      Navigator.pushNamed(
        context,
        "ricettaSearchPage",
        arguments:
            RicettaManagementInput.fromSingleDayPage(singleDayPageInput, pasto),
      ).then((value) {
        setState(() {});
      });
    } else {
      NavigationService.instance.navigateToWithParameters(
        "productSearchPage",
        ProductSearchInput(
          null,
          singleDayPageInput.workspaceId,
          ProductOperationType.INSERT,
          pasto,
          singleDayPageInput.dateTimeDay,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    singleDayPageInput =
        ModalRoute.of(context).settings.arguments as SingleDayPageInput;

    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(43, 43, 43, 1),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          singleDayPageInput.day,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _showReparti(),
    );
  }

//da aggiungere anche prodotti
  Widget _showReparti() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: Utils.instance.pasti.length,
        itemBuilder: (context, index) {
          return PastoWidget(
              Utils.instance.pasti[index],
              RicettaManagementInput.fromSingleDayPage(
                singleDayPageInput,
                Utils.instance.pasti[index],
              ),
              _showMealDetailsPage,
              singleDayPageInput.isToExpandPastoMap
                          .containsKey(singleDayPageInput.dateTimeDay) &&
                      singleDayPageInput
                          .isToExpandPastoMap[singleDayPageInput.dateTimeDay]
                          .containsKey(Utils.instance.pasti[index])
                  ? singleDayPageInput
                          .isToExpandPastoMap[singleDayPageInput.dateTimeDay]
                      [Utils.instance.pasti[index]]
                  : false);
        },
      ),
    );
  }
}
