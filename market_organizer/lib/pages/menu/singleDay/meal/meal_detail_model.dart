import 'package:market_organizer/pages/menu/singleDay/single_day_page.dart';

class MealDetailModel {
  final String workspaceId;
  final String day;
  final DateTime dateTimeDay; //giorno selezionato
  final DateTime dateStart;
  final DateTime dateEnd;
  final String menuIdRef;

  final String pasto;

  MealDetailModel(this.workspaceId, this.day, this.dateTimeDay, this.dateStart,
      this.dateEnd, this.menuIdRef, this.pasto);

  MealDetailModel.fromSingleDayPage(
      SingleDayPageInput singleDayPageInput, String pasto)
      : this.workspaceId = singleDayPageInput.workspaceId,
        this.day = singleDayPageInput.day,
        this.dateTimeDay = singleDayPageInput.dateTimeDay,
        this.dateStart = singleDayPageInput.dateStart,
        this.dateEnd = singleDayPageInput.dateEnd,
        this.menuIdRef = singleDayPageInput.menuIdRef,
        this.pasto = pasto;
}
