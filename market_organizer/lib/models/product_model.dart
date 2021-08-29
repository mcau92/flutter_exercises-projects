import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String id;
  String ownerId;
  String ownerName;
  String color;
  String name;
  String description;
  String measureUnit;
  double quantity;
  String image;
  String reparto;
  String spesaIdRef;

  Product(
      {this.id,
      this.ownerId,
      this.ownerName,
      this.color,
      this.name,
      this.description,
      this.measureUnit,
      this.quantity,
      this.image,
      this.reparto,this.spesaIdRef});

  factory Product.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    
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
      spesaIdRef:_data["spesaIdRef"]
    );
  }
}
