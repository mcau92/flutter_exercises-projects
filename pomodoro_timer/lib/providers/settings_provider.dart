import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  late int studyMinutes = 0;
  late int breakMinutes = 0;
  late int numRepeat = 0;
  late int numRepeatRem = 1;

  static SettingsProvider instance = SettingsProvider();

  void changeStudyMinutes(int value) {
    studyMinutes = value;
    notifyListeners();
  }

  void changeBreakMinutes(int value) {
    breakMinutes = value;
    notifyListeners();
  }

  void changeRepeat(int value) {
    numRepeat = value;
    notifyListeners();
  }

  String getNumRepeatRemString() {
    return (numRepeatRem).toString();
  }

  String getNumRepeatString() {
    return (numRepeat).toString();
  }

  void updateAll(int studyMinutes, int breakMinutes, int numRepeat) {
    this.studyMinutes = studyMinutes;
    this.breakMinutes = breakMinutes;
    this.numRepeat = numRepeat;
    notifyListeners();
  }
}
