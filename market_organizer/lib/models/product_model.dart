import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  String? ownerId;
  String? ownerName;
  String? color;
  String? name;
  String? description;
  String? measureUnit;
  double? quantity;
  String? image;
  //menu
  String? ricettaIdRef;
  String? menuIdRef; //prodotto inserito singolo in menu
  String? pasto; //pranzo colazione ecc se inserito in menu direttamente
  DateTime? date; // se inserito in menu direttamente
  //spesa
  String? spesaIdRef;
  String? reparto;
  String? currency;
  double? price;
  bool?
      bought; //indica se è comprato o meno per gestire la visualizzazione in spesa
  bool? checkedOnMenu;
  Product({
    this.id,
    this.ownerId,
    this.ownerName,
    this.color,
    this.name,
    this.description,
    this.measureUnit,
    this.quantity,
    this.image,
    this.reparto,
    this.menuIdRef,
    this.pasto,
    this.date,
    this.spesaIdRef,
    this.ricettaIdRef,
    this.currency,
    this.price,
    this.bought,
    this.checkedOnMenu,
  });
  Map<String, dynamic> toMap() {
    return {
      "ownerId": ownerId,
      "ownerName": ownerName,
      "color": color,
      "name": name,
      "description": description,
      "measureUnit": measureUnit,
      "quantity": quantity,
      "image": image,
      "reparto": reparto,
      "menuIdRef": menuIdRef,
      "spesaIdRef": spesaIdRef,
      "ricettaIdRef": ricettaIdRef,
      "currency": currency,
      "price": price,
      "pasto": pasto,
      "date": date,
      "bought": bought,
      "checkedOnMenu": checkedOnMenu,
    };
  }

  factory Product.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;

    return Product(
        id: _snapshot.id,
        name: _data["name"],
        ownerId: _data["ownerId"],
        ownerName: _data["ownerName"],
        color: _data["color"],
        description: _data["description"],
        measureUnit: _data["measureUnit"],
        quantity: _data["quantity"] != null
            ? double.parse(_data["quantity"].toString())
            : 0.0,
        image: _data["image"] == null ? "" : _data["image"],
        reparto: _data["reparto"],
        menuIdRef: _data["menuIdRef"],
        spesaIdRef: _data["spesaIdRef"],
        ricettaIdRef: _data["ricettaIdRef"],
        currency: _data["currency"],
        price: _data["price"] != null
            ? double.parse(_data["price"].toString())
            : 0.0,
        pasto: _data["pasto"],
        date: _data["date"] != null ? _data["date"].toDate() : null,
        bought: _data["bought"] != null ? _data["bought"] : false,
        checkedOnMenu:
            _data["checkedOnMenu"] != null ? _data["checkedOnMenu"] : false);
  }
}
