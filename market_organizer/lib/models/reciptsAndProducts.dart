import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';

class ReciptsAndProducts {
  final List<Ricetta> ricette;
  final List<Product> products;

  ReciptsAndProducts(this.ricette, this.products);
}
