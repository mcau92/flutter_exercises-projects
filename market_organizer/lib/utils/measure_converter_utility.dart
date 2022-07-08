import 'package:market_organizer/utils/measure_unit_list.dart';

class MeasureConverterUtility {
  static String _checkMeasure(String measureUnit) {
    return (measureUnit.length > 3)
        ? (measureUnit.substring(0, 2) + ".")
        : measureUnit;
  }

  static String quantityMeasureUnitStringCreation(
      double quantity, String measureUnit) {
    if (MeasureUnitList.units.containsKey(measureUnit)) {
      return quantity.toString() + " " + MeasureUnitList.units[measureUnit]!;
    } else {
      return quantity.toString() + " " + _checkMeasure(measureUnit);
    }
    //manage error
  }
}
