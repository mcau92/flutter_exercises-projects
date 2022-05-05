import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_organizer/models/product_model.dart';

class Notifiche {
  String? id;
  String? userOwner;
  String? workspaceIdRef;
  bool? viewed;
  int? accepted;

  Notifiche({
    this.id,
    this.userOwner,
    this.viewed,
    this.accepted,
    this.workspaceIdRef,
  });
  factory Notifiche.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;
    return Notifiche(
      id: _snapshot.id,
      userOwner: _data["userOwner"],
      viewed: _data["viewed"],
      accepted: _data["accepted"],
      workspaceIdRef: _data["workspaceIdRef"],
    );
  }
}
