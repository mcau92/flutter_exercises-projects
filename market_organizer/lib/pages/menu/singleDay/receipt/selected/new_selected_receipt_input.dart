import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/pages/menu/singleDay/single_day_page_model.dart';

class NewSelectedReceiptInput {
  final Ricetta selectedRecipt;
  final SingleDayPageInput singleDayPageInput;
  final String pasto;

  NewSelectedReceiptInput(
      this.selectedRecipt, this.singleDayPageInput, this.pasto);
}
