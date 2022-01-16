import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/pages/menu/singleDay/single_day_page_model.dart';

class NewSelectedReceiptInput {
  final Ricetta selectedRecipt;
  final Map<Product, bool>
      productsFetched; //prodotti da usare per cancellare aggioranre ecc in fase di inserimento da ricerca di ricetta
  final SingleDayPageInput singleDayPageInput;
  final String pasto;

  NewSelectedReceiptInput(this.selectedRecipt, this.productsFetched,
      this.singleDayPageInput, this.pasto);
}
