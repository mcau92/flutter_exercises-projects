import 'package:market_organizer/models/product_model.dart';

class Ricette {
  String ownerId;
  String ownerName;
  int color;
  String name;
  String description; //titolo ricetta
  String pasto; //pranzo colazione ecc
  DateTime date;
  List<Product> products; //lista prodotti per fare la ricetta
  String image; //opzionale?

  Ricette({
    this.ownerId,
    this.ownerName,
    this.color,
    this.name,
    this.description,
    this.pasto,
    this.date,
    this.products,
    this.image,
  });

  
}
