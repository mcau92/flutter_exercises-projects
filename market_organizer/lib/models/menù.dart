import 'package:market_organizer/models/ricette.dart';

class Menu {
  String name;
  DateTime startWeek;
  DateTime endWeek;
  List<Ricette> recipts;

  Menu({this.name, this.startWeek, this.endWeek,this.recipts});

  
}
