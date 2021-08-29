import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/ricette.dart';

class Datas {
  static Datas instance = new Datas();

  List<Menu> exampleMenu = [
    Menu(
      name: "menù",
      startWeek: new DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .subtract(
        Duration(days: DateTime.now().weekday - 1),
      ),
      endWeek: new DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .add(
        Duration(days: DateTime.daysPerWeek - DateTime.now().weekday),
      ),
      recipts: [
        Ricette(
            ownerId: "nadLzn6xd00BJcpy1Gtc",
            ownerName: "michael",
            color: 5,
            name: "Petto di pollo con patate",
            description: "Pollo su piastra e patate fritte",
            pasto: "Pranzo",
            date: new DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day)
                .subtract(Duration(days: DateTime.now().weekday - 1)),
            image:
                "https://blog.giallozafferano.it/ricetteditina/wp-content/uploads/2015/08/Straccetti-di-pollo-con-patate.jpg"),
      ],
    ),
  ];
}
