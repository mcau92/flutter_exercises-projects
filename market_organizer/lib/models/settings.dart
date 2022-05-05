import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings {
  String? id;
  String? language;

  UserSettings({
    this.id,
    this.language,
  });
  factory UserSettings.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;
    return UserSettings(
      id: _snapshot.id,
      language: _data["language"],
    );
  }
}
