import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_organizer/models/ricette.dart';

class Menu {
  String id;
  String name;
  String ownerId;
  DateTime startWeek;
  DateTime endWeek;
  String workspaceIdRef;

  Menu({
    this.id,
    this.name,
    this.ownerId,
    this.startWeek,
    this.endWeek,
    this.workspaceIdRef,
  });

  factory Menu.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    return Menu(
      id: _snapshot.id,
      name: _data["name"] != null ? _data["name"] : "default",
      ownerId: _data["ownerId"],
      startWeek: _data["startWeek"].toDate(),
      endWeek: _data["endWeek"].toDate(),
      workspaceIdRef: _data["workspaceIdRef"],
    );
  }
}
