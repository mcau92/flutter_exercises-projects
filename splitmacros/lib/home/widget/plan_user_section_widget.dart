import 'package:flutter/material.dart';
import 'package:splitmacros/home/widget/meal_widget.dart';
import 'package:splitmacros/model/user_data_model.dart';
import 'package:splitmacros/model/user_meals_model.dart';
import 'package:splitmacros/service/database_service.dart';

class PlanUserSectionWidget extends StatelessWidget {
  String _userId;
  PlanUserSectionWidget(this._userId);

  UserDataModel _userData;
  int _userMealType;

  Future<void> _setDefaultMealSplit() async{
    await DatabaseService.instance.setDefaultMealSplit(_userId);
  }
  Future<void> _getUserData() async {
    _userData = await DatabaseService.instance.getUserData(_userId).first;
    _userMealType = _userData.mealsSplitType;
  }

  void _updateMealSplitType(int number, Function setState) async {
    DatabaseService.instance
        .updateMealSplitType(number, _userId)
        .whenComplete(() => setState(() {
              _userMealType = number;
            }));
  }

  Future<void> _alterDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        // Get available height and width of the build area of this widget. Make a choice depending on the size.
        double height = MediaQuery.of(context).size.height;
        double width = MediaQuery.of(context).size.width;

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(2),
            contentPadding: EdgeInsets.all(5),
            titlePadding: EdgeInsets.only(top: 10, left: 5, bottom: 5),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            actions: [
              FlatButton(
                child: Text("Done"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            title: Center(
              child: Text(
                "Select your meal split",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
            ),
            content: _contentWidget(height, width, context, setState),
          );
        });
      },
    );
  }

  Widget _contentWidget(
      double height, double width, BuildContext context, Function setState) {
    return Container(
      height: height * 0.5,
      width: width * 0.9,
      child: Column(children: [
        _baseWidget(3, context, setState),
        SizedBox(height: 10),
        _baseWidget(4, context, setState),
        SizedBox(height: 10),
        _baseWidget(5, context, setState),
      ]),
    );
  }

  Widget _baseWidget(int number, BuildContext context, Function setState) {
    return Flexible(
      flex: 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              _updateMealSplitType(number, setState);
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: _userMealType == number
                      ? [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 20.0,
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.transparent,
                            blurRadius: 20.0,
                          ),
                        ],
                ),
                child: _mealstimesWidget(context, number)),
          ),
          Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: _userMealType == number
                  ? Icon(
                      Icons.verified_rounded,
                      color: Colors.green,
                      size: 30,
                    )
                  : Container())
        ],
      ),
    );
  }

  Widget _mealstimesWidget(BuildContext context, int times) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                times.toString() + " times a day",
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.more_horiz,
                color: Colors.black,
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.black,
          endIndent: 0,
          indent: 0,
          height: 0,
        ),
        _mealsSubSection(context, (100 / times).round(), times),
      ],
    );
  }

  Widget _mealsSubSection(BuildContext context, int percMeals, int times) {
    List<Widget> widgets = [];
    for (int i = 1; i <= times; i++) {
      widgets.add(_mealType(context, i.toString(), percMeals.toString()));
      if (i != times) {
        widgets.add(VerticalDivider(color: Colors.black));
      }
    }
    return Expanded(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widgets
              .map(
                (w) => w,
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _mealType(BuildContext context, String number, String perc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: Center(
            child: Text(
              number + "- Meal",
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(perc + "%"),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, _) {
        print(_userMealType);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(flex: 2, child: _titleSection(context)),
            Flexible(
              flex: 5,
              child: _listMealSection(),
            ),
            Flexible(
              flex: 1,
              child: _quoteSection(context),
            ),
          ],
        );
      },
      future: _getUserData(),
    );
  }

  Widget _titleSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          "Your Daily Plan",
          style: Theme.of(context)
              .textTheme
              .headline3
              .copyWith(color: Theme.of(context).primaryColor),
        ),
        InkWell(
            child: Center(
                child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Icon(Icons.assignment))),
            onTap: () => _alterDialog(context))
      ],
    );
  }

  Widget _listMealSection() {
    return Builder(builder: (BuildContext context) {
      return StreamBuilder<List<UserMealModel>>(
          stream: DatabaseService.instance.getUserMealInfo(_userId),
          builder: (context, snapshot) {
            List<UserMealModel> _mealsData = snapshot.data;
            if (_mealsData != null && _mealsData.isNotEmpty) {
              _setDefaultMealSplit();
            }
            return ListView.builder(
                itemCount: _mealsData.length,
                itemBuilder: (context, index) {
                  return MealWidget(_mealsData[index]);
                }); //TODO mostrare qualcosa di più fikko
          });
    });
  }

  Widget _quoteSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(100),
        ),
      ),
      child: Center(
        child: Text(
          "qua devo mettere la frase random",
          style: Theme.of(context)
              .textTheme
              .headline4
              .copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
