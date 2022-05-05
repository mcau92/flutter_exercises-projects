import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_organizer/models/product_model.dart';

class Spesa {
  String? id;
  String? name;
  String? ownerId;
  DateTime? startWeek;
  DateTime? endWeek;
  DateTime? date;
  double? ammount;
  String? workspaceIdRef;
  String? orderBy;
  bool? showSelected;
  bool? showPrice;

  Spesa({
    this.id,
    this.name,
    this.ownerId,
    this.startWeek,
    this.endWeek,
    this.date,
    this.ammount,
    this.workspaceIdRef,
    this.orderBy,
    this.showSelected,
    this.showPrice,
  });
  factory Spesa.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;
    return Spesa(
        id: _snapshot.id,
        name: _data["name"] != null ? _data["name"] : "default",
        ownerId: _data["ownerId"],
        startWeek: _data["startWeek"].toDate(),
        endWeek: _data["endWeek"].toDate(),
        date: _data["date"] != null ? _data["date"].toDate() : null,
        ammount: _data["ammount"] != null
            ? double.parse(_data["ammount"].toString())
            : 0.0,
        workspaceIdRef: _data["workspaceIdRef"],
        orderBy: _data["orderBy"],
        showSelected: _data["showSelected"],
        showPrice: _data["showPrice"]);
  }
}
