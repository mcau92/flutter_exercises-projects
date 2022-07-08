import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/reciptsAndProducts.dart';
import 'package:market_organizer/pages/menu/singleDay/single_day_page.dart';
import 'package:market_organizer/pages/widget/commons/appbar_custom_widget.dart';
import 'package:market_organizer/pages/widget/commons/weekpicker_widget.dart';
import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/service/snackbar_service.dart';
import 'package:market_organizer/utils/utils.dart';
import 'package:provider/provider.dart';

class MenuWidget extends StatefulWidget {
  final String worksapceId;
  MenuWidget(this.worksapceId);

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  late Menu? _currentMenu;

  late DateTime dateStart;

  late DateTime dateEnd;
  //usati per il clona
  late DateTime? _dateStartForClone;
  late DateTime? _dateEndForClone;

  late DateProvider _dateProvider;

/********* OPTIONS ************* */
  Future<void> _cloneSpesa() async {
    if (_dateStartForClone == null && _dateEndForClone == null) {
      _dateStartForClone = dateStart.add(Duration(days: 7));
      _dateEndForClone = dateEnd.add(Duration(days: 7));
    }
    // await DatabaseService.instance.cloneMenuInSpecificWeek(_currentMenu,
    //     _dateStartForClone!, _dateEndForClone!);

    Navigator.of(context).pop();
    SnackBarService.instance
        .showSnackBarSuccesfull("Menu Copiato Correttamente");
  }

  Future<void> _selectWeekClone() {
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
                          "Seleziona settimana.",
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
                        onPressed: () => _cloneSpesa()),
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

  Future<bool> _confirmDelete() async {
    Navigator.pop(context);
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
                "Confermi di cancellare tutto il menu di questa settimana?"),
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
        });
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
          onTap: () async => await _selectWeekClone(),
          leading: Icon(CupertinoIcons.arrow_up_right_diamond),
          title: Text("Clona Menù"),
          enabled: _currentMenu != null,
        ),
        ListTile(
          onTap: () async => await _confirmDelete() ? _deleteAll() : null,
          leading: Icon(CupertinoIcons.delete),
          title: Text("Rimuovi Tutto"),
          enabled: _currentMenu != null,
        ),
      ],
    );
  }

  Widget _dateAndDayPicker() {
    DateTime dateStartLoop = dateStart;
    DateTime dateEndLoop = dateEnd;
    return Container(
      padding: EdgeInsets.only(bottom: 50),
      color: Colors.white,
      child: CupertinoPicker(
        itemExtent: 32.0,
        backgroundColor: Colors.white,
        onSelectedItemChanged: (int index) {
          _dateStartForClone =
              dateStartLoop.add(Duration(days: ((index + 1) * 7)));
          _dateEndForClone = dateEndLoop.add(Duration(days: ((index + 1) * 7)));
        },
        children: [
          for (int i = 7; i < 29; i += 7)
            Center(child: _createTimeWidget(dateStartLoop, dateEndLoop, i))
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

  void _deleteAll() {
    DatabaseService.instance.deleteAllInMenu(_currentMenu!.id!);
  }

/*************** BUILD ****************** */
  @override
  Widget build(BuildContext context) {
    _dateProvider = Provider.of<DateProvider>(context);
    dateStart = _dateProvider.dateStart;
    dateEnd = _dateProvider.dateEnd;
    return Column(children: [
      AppBarCustom(1, _showOptions, widget.worksapceId),
      WeekPickerWidget(),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _body(),
        ),
      )
    ]);
  }

  Widget _body() {
    List<Widget> _weekDaysContainers = [];
    return StreamBuilder<List<Menu>>(
      stream: DatabaseService.instance
          .getMenuFromDate(widget.worksapceId, dateStart, dateEnd),
      builder: (_context, _snap) {
        //if (_snap.hasData && _snap.data.isNotEmpty) {
        //il controllo lo faccio quando devo popolare l'anteprima
        if (_snap.hasData) {
          _currentMenu = _snap.data!.isEmpty ? null : _snap.data![0];
          //se menu non nullo recupero le ricette altrimenti iniziallizo con valori di default
          _weekDaysContainers = initWeekDaysContainers(_context, _currentMenu);
          return Column(
            children: [
              _tooltip(),
              SizedBox(
                height: 20,
              ),
              //_addsBox(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 150, // here set custom Height You Want
                    ),
                    itemCount: _weekDaysContainers.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return _weekDaysContainers[index];
                    },
                  ),
                ),
              ),
            ],
          );
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.orange,
          ));
        }
      },
    );
  }

  String createDateString(String day) {
    return (dateStart.day + (Utils.instance.weekDays.indexOf(day))).toString();
  }

  String _countRec(List<Ricetta> recipts, String day) {
    List dayRecipts = recipts
        .where(
          (element) =>
              element.date!.weekday == Utils.instance.weekDays.indexOf(day) + 1,
        )
        .toList();
    if (dayRecipts.isNotEmpty) {
      return dayRecipts.length.toString();
    }
    return "0";
  }

  String _countPasti(List<Product> product, String day) {
    List<Product> dayProd = product
        .where(
          (element) =>
              element.date!.weekday == Utils.instance.weekDays.indexOf(day) + 1,
        )
        .toList();
    if (dayProd.isNotEmpty) {
      return dayProd.length.toString();
    }
    return "0";
  }

  void _showDay(BuildContext context, Menu? menu, String day,
      ReciptsAndProducts reciptsAndProducts) {
    NavigationService.instance
        .navigateToWithParameters(
          "singleDay",
          SingleDayPageInput(
            widget.worksapceId, //mi serve per inserire il menu se non presente
            day,
            dateStart.add(Duration(days: Utils.instance.weekDays.indexOf(day))),
            dateStart,
            dateEnd,
            menu != null ? menu.id : null,
          ),
        )
        .then((value) => setState(() {}));
  }

  late ReciptsAndProducts _reciptsAndProductsData;
  List<Widget> initWeekDaysContainers(BuildContext context, Menu? menu) {
    return Utils.instance.weekDays.map((day) {
      return GestureDetector(
        onTap: () => _showDay(context, menu, day, _reciptsAndProductsData),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Color.fromRGBO(27, 27, 27, 0.5),
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 125, 125, 125),
                Colors.grey,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(day,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(createDateString(day),
                      style: TextStyle(
                          fontSize: 18, color: Colors.white.withOpacity(0.5))),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              FutureBuilder<ReciptsAndProducts>(
                  future: menu != null
                      ? DatabaseService.instance
                          .getReciptsAndProductForMenu(menu.id!)
                      : Future.value(new ReciptsAndProducts([], [])),
                  builder: (_context, _snap) {
                    if (_snap.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      );
                    }
                    _reciptsAndProductsData = _snap.data!;
                    return _showCounters(
                        menu,
                        day,
                        _reciptsAndProductsData.ricette,
                        _reciptsAndProductsData.products);
                  }),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _showCounters(
      Menu? menu, String day, List<Ricetta> ricette, List<Product> products) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              menu != null ? _countRec(ricette, day) : "0",
              style: TextStyle(fontSize: 22, color: Colors.red),
            ),
            Text(
              " ricette",
              style: TextStyle(fontSize: 18, color: Colors.white),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              menu != null ? _countPasti(products, day) : "0",
              style: TextStyle(fontSize: 22, color: Colors.orange),
            ),
            Text(
              " prodotti",
              style: TextStyle(fontSize: 18, color: Colors.white),
            )
          ],
        ),
      ],
    );
  }

  Widget _addsBox() {
    return Container(
      color: Colors.red,
      height: 150,
      width: 150,
      child: Center(
        child: Text("Box Pubblicità"),
      ),
    );
  }

  Widget _tooltip() {
    return Builder(builder: (context) {
      return Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Text(
                    "Il menu previsto per questa settimana..",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 5,
              thickness: 0.1,
              color: Colors.white,
            ),
          ],
        ),
      );
    });
  }
}
