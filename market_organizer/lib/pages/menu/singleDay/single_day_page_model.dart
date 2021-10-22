import 'package:market_organizer/models/ricette.dart';

class SingleDayPageInput {
  final String day;
  final DateTime dateTimeDay;
  final String menuIdRef;
  final List<Ricette> ricette;

  SingleDayPageInput(this.day,this.dateTimeDay,this.menuIdRef, this.ricette);
}
