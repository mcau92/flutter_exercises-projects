import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/productOperationType.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/pages/menu/singleDay/pasto_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/productSearch_page.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/service/snackbar_service.dart';
import 'package:market_organizer/utils/utils.dart';
import 'package:provider/provider.dart';

//input

class SingleDayPageInput {
  final String workspaceId;
  final String day;
  final DateTime dateTimeDay; //giorno selezionato
  final DateTime dateStart;
  final DateTime dateEnd;
  final String? menuIdRef;

  SingleDayPageInput(this.workspaceId, this.day, this.dateTimeDay,
      this.dateStart, this.dateEnd, this.menuIdRef);
}

class SingleDayPage extends StatefulWidget {
  const SingleDayPage({Key? key}) : super(key: key);

  @override
  _SingleDayPageState createState() => _SingleDayPageState();
}

class _SingleDayPageState extends State<SingleDayPage> {
  late SingleDayPageInput singleDayPageInput;
  //USATI SOLO PER IL CLONE
  String? _dayForClone;
  late DateTime _dateTimeDayForClone;
  DateTime? _dateStartForClone;
  DateTime? _dateEndForClone;

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
      NavigationService.instance
          .navigateToWithParameters(
        "productSearchPage",
        ProductSearchInput(
          null,
          singleDayPageInput.workspaceId,
          ProductOperationType.INSERT,
          pasto,
          singleDayPageInput.dateTimeDay,
        ),
      )
          .then((value) {
        setState(() {});
      });
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 20),
          child: _spesaActions(),
        ),
      ),
    );
  }

  Future<void> _cloneDayMenu() async {
    UserDataModel _currentUserData =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    //se null vuol dire che lo user si è soffermato al default che viene visualizzato al caricamento ovvero lunedi e prima settimana dopo la attuale

    if (_dayForClone == null) {
      _dayForClone = "Lunedi";
    }
    if (_dateStartForClone == null && _dateEndForClone == null) {
      _dateStartForClone = singleDayPageInput.dateStart.add(Duration(days: 7));
      _dateEndForClone = singleDayPageInput.dateEnd.add(Duration(days: 7));
    }
    _dateTimeDayForClone = _dateStartForClone!
        .add(Duration(days: Utils.instance.weekDays.indexOf(_dayForClone!)));
    await DatabaseService.instance.cloneMenuInSpecificDay(
        singleDayPageInput.menuIdRef!,
        singleDayPageInput.dateTimeDay,
        _dateStartForClone!,
        _dateEndForClone!,
        _dateTimeDayForClone,
        _currentUserData.id!,
        _currentUserData.name!);

    Navigator.of(context).pop();
    SnackBarService.instance
        .showSnackBarSuccesfull("Menu Copiato Correttamente");
  }

  Future<void> _selectWeekCloneAndPasto() {
    Navigator.pop(context);
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 190.0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CupertinoButton(
                      child: Text(
                        "Annulla",
                        style: TextStyle(fontSize: 15),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "Seleziona settimana e giorno.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    CupertinoButton(
                        child: Text(
                          "Clona",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () => _cloneDayMenu()),
                  ],
                ),
                Expanded(
                  child: _dateAndDayPicker(),
                ),
              ],
            ),
          );
        });
  }

  Widget _dateAndDayPicker() {
    DateTime dateStartLoop = singleDayPageInput.dateStart;
    DateTime dateEndLoop = singleDayPageInput.dateEnd;
    return Container(
      padding: EdgeInsets.only(bottom: 50),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: CupertinoPicker(
              itemExtent: 32.0,
              backgroundColor: Colors.white,
              onSelectedItemChanged: (int index) {
                _dateStartForClone =
                    dateStartLoop.add(Duration(days: ((index + 1) * 7)));
                _dateEndForClone =
                    dateEndLoop.add(Duration(days: ((index + 1) * 7)));
              },
              children: [
                for (int i = 7; i < 29; i += 7)
                  Center(
                      child: _createTimeWidget(dateStartLoop, dateEndLoop, i))
              ],
            ),
          ),
          Expanded(
            child: CupertinoPicker(
                itemExtent: 32.0,
                backgroundColor: Colors.white,
                onSelectedItemChanged: (int index) {
                  _dayForClone = Utils.instance.weekDays[index];
                },
                children: [
                  for (String day in Utils.instance.weekDays)
                    Center(
                      child: Text(day),
                    )
                ]),
          ),
        ],
      ),
    );
  }

  Widget _createTimeWidget(
      DateTime dateStartLoop, DateTime dateEndLoop, int duration) {
    dateStartLoop = dateStartLoop.add(Duration(days: duration));
    dateEndLoop = dateEndLoop.add(Duration(days: duration));
    return Text(dateStartLoop.day.toString() +
        " " +
        Utils.instance.convertWeekDay(dateStartLoop.month) +
        " - " +
        dateEndLoop.day.toString() +
        " " +
        Utils.instance.convertWeekDay(dateEndLoop.month));
  }

  Widget _spesaActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          enabled: false,
          minVerticalPadding: 0.0,
          title: Text(
            "Opzioni",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(
          thickness: 0.2,
          color: Colors.black,
        ),
        ListTile(
          onTap: () async => await _selectWeekCloneAndPasto(),
          leading: Icon(CupertinoIcons.arrow_up_right_diamond),
          title: Text("Clona Giornata"),
        ),
        ListTile(
          onTap: () async => await _confirmDelete() ? _deleteAll() : null,
          leading: Icon(CupertinoIcons.delete),
          title: Text("Rimuovi Tutto"),
        ),
      ],
    );
  }

  Future<bool> _confirmDelete() async {
    Navigator.pop(context);
    return await showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text("Confermi di cancellare il menu per questa giornata?"),
          actions: [
            CupertinoDialogAction(
              child: Text("Si"),
              onPressed: () {
                Navigator.of(
                  ctx,
                  // rootNavigator: true,
                ).pop(true);
              },
            ),
            CupertinoDialogAction(
              child: Text("No"),
              onPressed: () {
                Navigator.of(
                  ctx,
                  // rootNavigator: true,
                ).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAll() async {
    await DatabaseService.instance
        .deleteAllInMenu(singleDayPageInput.menuIdRef!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    singleDayPageInput =
        ModalRoute.of(context)!.settings.arguments as SingleDayPageInput;
    SnackBarService.instance.buildContext = context; //init snackbarservice

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
        actions: [
          CupertinoButton(
            child: Icon(
              CupertinoIcons.ellipsis_vertical,
              color: Colors.white,
            ),
            onPressed: () =>
                singleDayPageInput.menuIdRef != null ? _showOptions() : {},
          )
        ],
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
    return ListView.builder(
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
        );
      },
    );
  }
}
