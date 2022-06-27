import 'package:cloud_firestore/cloud_firestore.dart';

class UserWorkspace {
  String? id;
  String? name;
  String? ownerId;
  Map<String, String>?
      userColors; //mappa che salva per ogni id utente il suo colore nel workspace sia per ricetta che per menu
  List<String>? contributorsId;

  UserWorkspace({
    this.id,
    this.name,
    this.ownerId,
    this.userColors,
    this.contributorsId,
  });

  factory UserWorkspace.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;

    Map<String, String> userColors = {};
    if (_data["userColors"] != null) {
      Map.from(_data["userColors"]).entries.forEach((element) {
        userColors.putIfAbsent(element.key, () => element.value);
      });
    }
    return UserWorkspace(
      id: _snapshot.id,
      name: _data["name"],
      ownerId: _data["ownerId"],
      userColors: userColors, //forse non corretto
      contributorsId: _data["contributorsId"] == null
          ? []
          : _data["contributorsId"].cast<String>(),
    );
  }
}
