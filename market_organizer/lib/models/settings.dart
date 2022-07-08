import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings {
  String? id;
  String? language;
  bool showPrice;
  int saveMenuDays;

  bool showSelected;

  UserSettings(
      {this.id,
      this.language,
      required this.showPrice,
      required this.showSelected,
      required this.saveMenuDays});
  factory UserSettings.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;
    return UserSettings(
        id: _snapshot.id,
        language: _data["language"],
        showPrice: _data["showPrice"],
        showSelected: _data["showSelected"],
        saveMenuDays: _data["saveMenuDays"]);
  }
}
