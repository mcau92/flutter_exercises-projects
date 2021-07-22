
import 'package:market_organizer/utils/measure_unit_enum.dart';

class MeasureConverterUtility{

  
  static String quantityMeasureUnitStringCreation(int quantity, String measure_unit){
    return quantity.toString()+" "+measure_unit;
    //manage error
  }
}