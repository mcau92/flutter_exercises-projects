import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_organizer/models/product_model.dart';

class Ricetta {
  String id;
  String ownerId;
  String ownerName;
  String color;
  String name;
  String description; //titolo ricetta
  String pasto; //pranzo colazione ecc
  DateTime date;
  String image; //opzionale?
  String menuIdRef;

  Ricetta({
    this.id,
    this.ownerId,
    this.ownerName,
    this.color,
    this.name,
    this.description,
    this.pasto,
    this.date,
    this.image,
    this.menuIdRef,
  });

  factory Ricetta.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    return Ricetta(
      id: _snapshot.id,
      ownerId: _data["ownerId"],
      ownerName: _data["ownerName"],
      color: _data["color"],
      name: _data["name"] != null ? _data["name"] : "default",
      description:
          _data["description"] != null ? _data["description"] : "default",
      pasto: _data["pasto"],
      date: _data["date"].toDate(),
      image: _data["image"],
      menuIdRef: _data["menuIdRef"],
    );
  }
}
