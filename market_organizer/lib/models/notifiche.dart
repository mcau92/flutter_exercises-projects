import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_organizer/models/product_model.dart';

class Notifiche {
  String? id;
  String? userOwner;
  String? workspaceIdRef;
  bool? viewed;
  String? accepted;
  DateTime? date;

  Notifiche(
      {this.id,
      this.userOwner,
      this.viewed,
      this.accepted,
      this.workspaceIdRef,
      this.date});
  factory Notifiche.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;
    return Notifiche(
      id: _snapshot.id,
      userOwner: _data["userOwner"],
      viewed: _data["viewed"],
      accepted: _data["accepted"],
      workspaceIdRef: _data["workspaceIdRef"],
      date: _data["date"].toDate(),
    );
  }
}
