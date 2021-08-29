import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/homepage/widget/commons/appbar_custom_widget.dart';
import 'package:market_organizer/homepage/widget/commons/weekpicker_widget.dart';
import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/ricette.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/homepage/widget/menu/singleDay/single_day_page_model.dart';
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
      AppBarCustom(1, _addMenu,false),//TODO controllare se i dati sono fetchati
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
      stream: DatabaseService.instance.getMenuFromDate(dateStart, dateEnd),
      builder: (_context, _snap) {
        //if (_snap.hasData && _snap.data.isNotEmpty) {
        //il controllo lo faccio quando devo popolare l'anteprima
        if (_snap.hasData) {
          Menu _currentMenu =
              (!_snap.hasData || _snap.data.isEmpty) ? null : _snap.data[0];
          _weekDaysContainers = initWeekDaysContainers(_context, _currentMenu);
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
      },
    );
  }

// creation of  week days containers
  String createDateString(String day) {
    return (dateStart.day + (Utils.instance.weekDays.indexOf(day))).toString();
  }

  String _countPasti(Menu _menu, String day) {
    List dayRecipts = _menu.recipts
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

  String _countRecipts(Menu _menu, String day) {
    List dayRecipts = _menu.recipts
        .where(
          (element) =>
              element.date.weekday == Utils.instance.weekDays.indexOf(day) + 1,
        )
        .toList();
    if (dayRecipts.isNotEmpty) {
      List<Ricette> _filterRecipts = [];
      dayRecipts.forEach((eDay) {
        if (!_filterRecipts.any((eFilter) => eFilter.pasto = eDay.pasto)) {
          _filterRecipts.add(eDay);
        }
      });
      return _filterRecipts.length.toString();
    }
    return "0";
  }

  // method to redirect to day page
  void _showDay(BuildContext context, String day, List<Ricette> ricette) {
    Navigator.pushNamed(
      context,
      "singleDay",
      arguments: SingleDayPageInput(
          day,
          dateStart.add(Duration(days: Utils.instance.weekDays.indexOf(day))),
          ricette),
    );
  }

  //list
  List<Widget> initWeekDaysContainers(BuildContext context, Menu _menu) {
    return Utils.instance.weekDays.map((day) {
      return GestureDetector(
        onTap: () => _showDay(
          context,
          day,
          _menu.recipts
              .where((element) =>
                  element.date.weekday ==
                  Utils.instance.weekDays.indexOf(day) + 1)
              .toList(),
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
                        _menu != null ? _countPasti(_menu, day) : "0",
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
                        _menu != null ? _countRecipts(_menu, day) : "0",
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
