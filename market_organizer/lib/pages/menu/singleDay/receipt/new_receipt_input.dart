import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/pages/menu/singleDay/single_day_page_model.dart';

class NewReceiptInput {
  final SingleDayPageInput singleDayPageInput;
  final String pasto;

  NewReceiptInput(this.singleDayPageInput, this.pasto);
}
