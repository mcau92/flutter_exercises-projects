import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/homepage/widget/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/homepage/widget/menu/singleDay/pasto_widget.dart';
import 'package:market_organizer/homepage/widget/menu/singleDay/single_day_page_model.dart';
import 'package:market_organizer/utils/utils.dart';

class SingleDayPage extends StatefulWidget {
  const SingleDayPage({Key key}) : super(key: key);

  @override
  _SingleDayPageState createState() => _SingleDayPageState();
}

class _SingleDayPageState extends State<SingleDayPage> {

  SingleDayPageInput singleDayPageInput;
  void _showMealDetailsPage(String pasto) {
    
    Navigator.pushReplacementNamed(
      context,
      "mealDetail",
      arguments: MealDetailModel(singleDayPageInput, pasto),
    );
  }

  void _showMenu(BuildContext ctx) {
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              child: CupertinoActionSheet(
                message: Text("Seleziona un pasto"),
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () => _showMealDetailsPage("Colazione"),
                      child: Text("Colazione")),
                  CupertinoActionSheetAction(
                      onPressed: () => _showMealDetailsPage("Spuntino"),
                      child: Text("Spuntino")),
                  CupertinoActionSheetAction(
                      onPressed: () => _showMealDetailsPage("Pranzo"),
                      child: Text("Pranzo")),
                  CupertinoActionSheetAction(
                      onPressed: () => _showMealDetailsPage("Cena"),
                      child: Text("Cena")),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text(
                    "Cancella",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    
    singleDayPageInput =
        ModalRoute.of(context).settings.arguments as SingleDayPageInput;
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(43, 43, 43, 1),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          singleDayPageInput.day,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.add, color: Colors.white),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      body: _body(singleDayPageInput),
    );
  }

  Widget _body(SingleDayPageInput _input) {
    if (_input.ricette == null || _input.ricette.isEmpty) {
      return Center(
        child: Text(
          "nessuna ricetta inserita",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else {
      List<String> pasti = Utils.instance.getPasti(_input.ricette);
      return Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 7,
            );
          },
          itemCount: pasti.length,
          itemBuilder: (context, index) {
            return PastoWidget(
              pasti[index],
              _input.ricette.where((r) => r.pasto == pasti[index]).toList(),
            );
          },
        ),
      );
    }
  }
}
