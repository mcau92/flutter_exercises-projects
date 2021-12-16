import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/pages/widget/commons/appbar_custom_widget.dart';
import 'package:market_organizer/pages/widget/commons/weekpicker_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/single_day_page_model.dart';
import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/utils/utils.dart';
import 'package:provider/provider.dart';

class MenuWidget extends StatelessWidget {
  final String worksapceId;
  DateTime dateStart;
  DateTime dateEnd;
  DateProvider _dateProvider;

  void _addMenu() {}
  MenuWidget(this.worksapceId);

  @override
  Widget build(BuildContext context) {
    _dateProvider = Provider.of<DateProvider>(context);
    dateStart = _dateProvider.dateStart;
    dateEnd = _dateProvider.dateEnd;
    return Column(children: [
      AppBarCustom(
          1, _addMenu, false), //TODO controllare se i dati sono fetchati
      WeekPickerWidget(),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _body(),
        ),
      )
    ]);
  }

  //body section
  Widget _body() {
    List<Widget> _weekDaysContainers = [];
    return StreamBuilder<List<Menu>>(
      stream: DatabaseService.instance
          .getMenuFromDate(worksapceId, dateStart, dateEnd),
      builder: (_context, _snap) {
        //if (_snap.hasData && _snap.data.isNotEmpty) {
        //il controllo lo faccio quando devo popolare l'anteprima
        if (_snap.hasData) {
          Menu _currentMenu = _snap.data.isEmpty ? null : _snap.data[0];
          //se menu non nullo recupero le ricette altrimenti iniziallizo con valori di default

          if (_currentMenu != null) {
            return FutureBuilder<List<Ricetta>>(
                future: DatabaseService.instance
                    .getReciptsFromMenuId(_currentMenu.id),
                builder: (_context, _snap) {
                  if (_snap.hasData) {
                    List<Ricetta> _ricette = _snap.data;
                    _weekDaysContainers = initWeekDaysContainers(
                        _context, _currentMenu, _ricette);
                    return GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      children: _weekDaysContainers,
                    );
                  } else {
                    return Center(
                        child: CircularProgressIndicator(
                      backgroundColor: Colors.red,
                    ));
                  }
                });
          } else {
            _weekDaysContainers = initWeekDaysContainers(_context, null, null);
            return GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              children: _weekDaysContainers,
            );
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.red,
          ));
        }
      },
    );
  }

// creation of  week days containers
  String createDateString(String day) {
    return (dateStart.day + (Utils.instance.weekDays.indexOf(day))).toString();
  }

  String _countRec(List<Ricetta> recipts, String day) {
    List dayRecipts = recipts
        .where(
          (element) =>
              element.date.weekday == Utils.instance.weekDays.indexOf(day) + 1,
        )
        .toList();
    if (dayRecipts.isNotEmpty) {
      return dayRecipts.length.toString();
    }
    return "0";
  }

  String _countPast(List<Ricetta> recipts, String day) {
    List<Ricetta> dayRecipts = recipts
        .where(
          (element) =>
              element.date.weekday == Utils.instance.weekDays.indexOf(day) + 1,
        )
        .toList();
    if (dayRecipts.isNotEmpty) {
      List<Ricetta> _filterRecipts = [];
      dayRecipts.forEach((eDay) {
        if (_filterRecipts.isEmpty ||
            !_filterRecipts.any((eFilter) => eFilter.pasto == eDay.pasto)) {
          _filterRecipts.add(eDay);
        }
      });
      print("arrivo");
      return _filterRecipts.length.toString();
    }
    return "0";
  }

  // method to redirect to day page
  void _showDay(BuildContext context, Menu menu, String day) {
    Navigator.pushNamed(
      context,
      "singleDay",
      arguments: SingleDayPageInput(
        worksapceId, //mi serve per inserire il menu se non presente
        day,
        dateStart.add(Duration(days: Utils.instance.weekDays.indexOf(day))),
        dateStart,
        dateEnd,
        menu != null ? menu.id : null, //può essere nullo
      ),
    );
  }

  //list
  List<Widget> initWeekDaysContainers(
      BuildContext context, Menu menu, List<Ricetta> recipts) {
    return Utils.instance.weekDays.map((day) {
      return GestureDetector(
        onTap: () => _showDay(
          context,
          menu,
          day,
        ),
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
                Color.fromRGBO(71, 71, 71, 1),
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
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        menu != null ? _countPast(recipts, day) : "0",
                        style: TextStyle(fontSize: 40, color: Colors.orange),
                      ),
                      Text(
                        " pasti",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        menu != null ? _countRec(recipts, day) : "0",
                        style: TextStyle(fontSize: 40, color: Colors.red),
                      ),
                      Text(
                        " ricette",
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
