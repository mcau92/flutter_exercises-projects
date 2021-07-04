import 'package:flutter/material.dart';

class DayProvider extends ChangeNotifier {
  DateTime _selectedDay = DateTime.now();
  static DayProvider instance = DayProvider();

  get selectedDay {
    return _selectedDay;
  }

  void updateSelectedDay(DateTime _date) {
    _selectedDay = _date;
    notifyListeners();
  }
}
