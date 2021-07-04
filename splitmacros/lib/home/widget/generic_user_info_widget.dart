import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:splitmacros/model/user_data_model.dart';
import 'package:splitmacros/service/database_service.dart';

class GenericUserInfoWidget extends StatefulWidget {
  String _userId;
  GenericUserInfoWidget(this._userId);
  @override
  _GenericUserInfoWidgetState createState() => _GenericUserInfoWidgetState();
}

class _GenericUserInfoWidgetState extends State<GenericUserInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserDataModel>(
        stream: DatabaseService.instance.getUserData(widget._userId),
        builder: (context, snapshot) {
          var _userData = snapshot.data;
          return Container(
            margin: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _col1(),
                _col2(_userData),
                Expanded(child: _col3(_userData)),
              ],
            ),
          );
        });
  }

  Widget _col1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
          ),
          child: Text(
            "Your daily goal",
            style: Theme.of(context).textTheme.headline2.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: () => {}, //TODO
          icon: Icon(
            FontAwesomeIcons.ellipsisH,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _col2(UserDataModel _userData) {
    return _userData != null
        ? Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: RichText(
                text: TextSpan(
                  text: _userData.kcal.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .copyWith(fontSize: 40),
                  children: <InlineSpan>[
                    TextSpan(
                        text: "kcal",
                        style: Theme.of(context).textTheme.headline4),
                  ],
                ),
              ),
            ),
          )
        : SpinKitWanderingCubes(
            color: Colors.red,
            size: 20.0,
          );
  }

  Widget _col3(UserDataModel _userData) {
    return _userData != null
        ? Padding(
            padding: const EdgeInsets.only(
              right: 10.0,
              bottom: 10,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "C." +
                    _userData.carbsPerc.toString() +
                    "% P." +
                    _userData.proteinsPerc.toString() +
                    "% F." +
                    _userData.fatsPerc.toString() +
                    "% (55g, 25g, 20g)",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          )
        : SpinKitWanderingCubes(
            color: Colors.red,
            size: 20.0,
          );
  }
}
