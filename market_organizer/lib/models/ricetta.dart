import 'package:cloud_firestore/cloud_firestore.dart';

class Ricetta {
  String? id;
  String? ownerId;
  String? ownerName;
  String? color;
  String? name;
  String? description; //titolo ricetta
  String? pasto; //pranzo colazione ecc
  DateTime? date;
  String? image; //opzionale?
  String? menuIdRef;

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

  bool isEqualToAnother(Ricetta ricetta) {
    return ricetta.name == this.name &&
        ricetta.ownerId == this.ownerId &&
        ricetta.ownerName == this.ownerName &&
        ricetta.color == this.color &&
        ricetta.pasto == this.pasto;
  }

  factory Ricetta.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;
    return Ricetta(
      id: _snapshot.id,
      ownerId: _data["ownerId"],
      ownerName: _data["ownerName"],
      color: _data["color"],
      name: _data["name"] != null ? _data["name"] : "default",
      description: _data["description"] != null ? _data["description"] : "",
      pasto: _data["pasto"],
      date: _data["date"].toDate(),
      image: _data["image"],
      menuIdRef: _data["menuIdRef"],
    );
  }
}
