import 'package:flutter/material.dart';
import 'package:market_organizer/utils/utils.dart';

class DateProvider with ChangeNotifier {
  DateTime dateStart;
  DateTime dateEnd;
  String dateFormatted;

  static DateProvider instance = DateProvider();

  DateProvider() {
    dateStart = new DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day)
        .subtract(Duration(days: DateTime.now().weekday - 1));
    dateEnd = new DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day)
        .add(Duration(days: DateTime.daysPerWeek - DateTime.now().weekday));
    createString();
  }

  void increaseWeek() {
    dateStart = dateStart.add(Duration(
      days: 7,
    ));
    dateEnd = dateEnd.add(
      Duration(
        days: 7,
      ),
    );
    createString();
    notifyListeners();
  }

  void decreaseWeek() {
    dateStart = dateStart.subtract(Duration(
      days: 7,
    ));
    dateEnd = dateEnd.subtract(
      Duration(
        days: 7,
      ),
    );
    createString();
    notifyListeners();
  }

  void createString() {
    dateFormatted = dateStart.day.toString() +
        " " +
        Utils.instance.convertWeekDay(dateStart.month) +
        " - " +
        dateEnd.day.toString() +
        " " +
        Utils.instance.convertWeekDay(dateEnd.month);
    notifyListeners();
  }
}
