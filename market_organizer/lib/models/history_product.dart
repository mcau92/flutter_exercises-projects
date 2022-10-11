import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryProduct {
  String? id;
  String? name;
  String? description;
  String? measureUnit;
  double? quantity;
  String? reparto;
  String? currency;
  double? price;
  DateTime? date;

  HistoryProduct({
    this.id,
    this.name,
    this.description,
    this.measureUnit,
    this.quantity,
    this.reparto,
    this.currency,
    this.price,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "description": description,
      "measureUnit": measureUnit,
      "quantity": quantity,
      "reparto": reparto,
      "currency": currency,
      "price": price,
      "date": date
    };
  }

  factory HistoryProduct.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;

    return HistoryProduct(
      id: _snapshot.id,
      name: _data["name"],
      description: _data["description"],
      measureUnit: _data["measureUnit"],
      quantity: _data["quantity"] != null
          ? double.parse(_data["quantity"].toString())
          : 0.00,
      reparto: _data["reparto"],
      currency: _data["currency"],
      price: _data["price"] != null
          ? double.parse(_data["price"].toString())
          : 0.00,
      date: _data["date"] != null ? _data["date"].toDate() : null,
    );
  }
}
