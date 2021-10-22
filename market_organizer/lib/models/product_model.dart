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
  String ricettaIdRef;
  String currency;
  double price;
  //campi per gestire il fatto che inserisco in spesa dal menu e posso gestire la cancellazione opzionale di entrambi quando cancello uno
  //esempio: inserisco un prodotto ne menu, chiedo all'utente se desidera aggiungerlo in spesa, se accetta metto un link nel prodotto ricetta al prodotto spesa e viceversa, cosi se volessi cancellarlo successivamente posso chiedere all'utente di cancellarlo anche dall'altra parte o meno
  String productIdSpesa;
  String productIdRicetta;

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
      this.reparto,
      this.spesaIdRef,
      this.ricettaIdRef,
      this.currency,
      this.price,
      this.productIdSpesa,
      this.productIdRicetta});
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
      "spesaIdRef": spesaIdRef,
      "ricettaIdRef": ricettaIdRef,
      "currency": currency,
      "price": price,
      "productIdSpesa": productIdSpesa,
      "productIdRicetta": productIdRicetta
    };
  }

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
        spesaIdRef: _data["spesaIdRef"],
        ricettaIdRef: _data["ricettaIdRef"],
        currency: _data["currency"],
        price: _data["price"] != null
            ? double.parse(_data["price"].toString())
            : 0.0,
        productIdSpesa: _data["productIdSpesa"],
        productIdRicetta: _data["productIdRicetta"]);
  }
}
