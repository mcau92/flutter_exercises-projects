import 'package:market_organizer/models/ricetta.dart';

class SingleDayPageInput {
  final String workspaceId;
  final String day;
  final DateTime dateTimeDay;//giorno selezionato
  final DateTime dateStart;
  final DateTime dateEnd;
  final String menuIdRef;
  final List<Ricetta> ricette;

  SingleDayPageInput(
    this.workspaceId,
    this.day,
    this.dateTimeDay,
    this.dateStart,
    this.dateEnd,
    this.menuIdRef,
    this.ricette,
  );
}
