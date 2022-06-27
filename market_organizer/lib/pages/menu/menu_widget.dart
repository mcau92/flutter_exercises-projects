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
import 'package:market_organizer/utils/utils.dart';
import 'package:provider/provider.dart';

class MenuWidget extends StatefulWidget {
  final String worksapceId;
  MenuWidget(this.worksapceId);

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  late DateTime dateStart;

  late DateTime dateEnd;

  late DateProvider _dateProvider;

  void _addMenu() {}

  @override
  Widget build(BuildContext context) {
    _dateProvider = Provider.of<DateProvider>(context);
    dateStart = _dateProvider.dateStart;
    dateEnd = _dateProvider.dateEnd;
    return Column(children: [
      AppBarCustom(1, _addMenu, false,
          widget.worksapceId), //TODO controllare se i dati sono fetchati
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
          Menu? _currentMenu = _snap.data!.isEmpty ? null : _snap.data![0];
          //se menu non nullo recupero le ricette altrimenti iniziallizo con valori di default
          _weekDaysContainers = initWeekDaysContainers(_context, _currentMenu);
          return GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            children: _weekDaysContainers,
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

  Widget _showCounters(
      Menu? menu, String day, List<Ricetta> ricette, List<Product> products) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              menu != null ? _countRec(ricette, day) : "0",
              style: TextStyle(fontSize: 40, color: Colors.red),
            ),
            Text(
              " ricette",
              style: TextStyle(fontSize: 25, color: Colors.white),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              menu != null ? _countPasti(products, day) : "0",
              style: TextStyle(fontSize: 40, color: Colors.orange),
            ),
            Text(
              " prodotti",
              style: TextStyle(fontSize: 25, color: Colors.white),
            )
          ],
        ),
      ],
    );
  }

  late ReciptsAndProducts _reciptsAndProductsData;
  List<Widget> initWeekDaysContainers(BuildContext context, Menu? menu) {
    return Utils.instance.weekDays.map((day) {
      return GestureDetector(
        onTap: () => _showDay(context, menu, day, _reciptsAndProductsData),
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(10),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(createDateString(day),
                      style: TextStyle(
                          fontSize: 18, color: Colors.white.withOpacity(0.5))),
                ],
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
}
