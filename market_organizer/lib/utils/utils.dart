import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/utils/category_enum.dart';

class Utils {
  static Utils instance = Utils();
  List months = [
    'Gen',
    'Feb',
    'Mar',
    'Apr',
    'Mag',
    'Giu',
    'Lug',
    'Ago',
    'Set',
    'Ott',
    'Nov',
    'Dic'
  ];
  List<String> weekDays = [
    "Lunedi",
    "Martedi",
    "Mercoledi",
    "Giovedi",
    "Venerdi",
    "Sabato",
    "Domenica"
  ];

  List pasti = ["Colazione", "Pranzo", "Spuntino", "Cena"];
  List<String> getReparti(List<Product> products, String orderBy) {
    List<String> reparti = [];
    products.forEach((element) {
      if (!reparti.contains(element.reparto)) {
        reparti.add(element.reparto!);
      }
    });
    if (orderBy == CategoryOrder.category.toString()) {
      reparti.sort(
          (a, b) => a.toString().compareTo(b.toString())); //ordine alfabetico

    } else if (orderBy == CategoryOrder.categoryReverse.toString()) {
      reparti.sort(
          (a, b) => b.toString().compareTo(a.toString())); //ordine alfabetico

    }
    return reparti;
  }

  List<Spesa> getCurrentSpesaListByWeek(
      List<Spesa> references, DateTime start, DateTime end) {
    List<Spesa> model = references
        .where((element) => element.startWeek == start)
        .where((element) => element.endWeek == end)
        .toList();
    if (model.isEmpty) {
      return [];
    }
    return model;
  }

  List<Menu> getCurrentMenuListByWeek(
      List<Menu> references, DateTime start, DateTime end) {
    List<Menu> model = references
        .where((element) => element.startWeek!.isAtSameMomentAs(start))
        .where((element) => element.endWeek!.isAtSameMomentAs(end))
        .toList();
    if (model == null || model.isEmpty) {
      return [];
    }
    return model;
  }

  String convertWeekDay(int month) {
    return months[month - 1];
  }

  List<String> getPasti(List<Ricetta> ricette) {
    List<String> pasti = [];
    ricette.forEach((element) {
      if (!pasti.contains(element.pasto)) {
        pasti.add(element.pasto!);
      }
    });
    return pasti;
  }
}
