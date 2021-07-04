import 'package:flutter/material.dart';
import 'package:splitmacros/model/user_meals_model.dart';

class MealWidget extends StatelessWidget {
  final UserMealModel _mealInfo;

  MealWidget(this._mealInfo);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: Text(
                  _mealInfo.mealNumber.toString() +
                      ". " +
                      "Meal - " +
                      _mealInfo.mealName,
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(5),
              child: Text("25%",
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.white)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 8),
              child: Text(
                  "C." +
                      _mealInfo.mealCarbsPerc.toString() +
                      "% , " +
                      "P." +
                      _mealInfo.mealProteinsPerc.toString() +
                      "% , " +
                      "C." +
                      _mealInfo.mealFatsPerc.toString() +
                      "%",
                  style: Theme.of(context).textTheme.headline4),
            ),
          ],
        ),
      ),
    );
  }
}
