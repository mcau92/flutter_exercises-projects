import 'package:flutter/material.dart';
import 'package:pomodoro_timer/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SessionTitleWidget extends StatelessWidget {
  final String title;
  const SessionTitleWidget({Key? key, required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _title(context),
        _rep(context),
      ],
    );
  }

  Widget _title(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headline1,
    );
  }

  Widget _rep(BuildContext context) {
    return Text(
      Provider.of<SettingsProvider>(context, listen: false)
              .getNumRepeatRemString() +
          "/" +
          Provider.of<SettingsProvider>(context, listen: false)
              .getNumRepeatString(),
      style: Theme.of(context).textTheme.headline2,
    );
  }
}
