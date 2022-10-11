import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pomodoro_timer/providers/settings_provider.dart';
import 'package:pomodoro_timer/widgets/current_day_widget.dart';
import 'package:pomodoro_timer/widgets/settings_form_widget.dart';
import 'package:pomodoro_timer/widgets/start_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//logger
  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Provider.of<SettingsProvider>(context, listen: false).studyMinutes ==
        0) {
      _prefs.then((SharedPreferences prefs) {
        int studyMinutes = prefs.getInt('studyMinutes') ?? 60;
        int breakMinutes = prefs.getInt('breakMinutes') ?? 15;
        int numRepeat = prefs.getInt('numRepeat') ?? 1;
        loggerNoStack
            .i("get breakMinutes from storage: " + studyMinutes.toString());
        loggerNoStack
            .i("get breakMinutes from storage: " + breakMinutes.toString());
        loggerNoStack
            .i("get breakMinutes from storage: " + numRepeat.toString());
        Provider.of<SettingsProvider>(context, listen: false)
            .updateAll(studyMinutes, breakMinutes, numRepeat);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: _homeBody(),
    );
  }

  Widget _homeBody() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 190.0),
          child: Column(
            children: const [
              CurrentDayWidget(),
              SizedBox(
                height: 100,
              ),
              SettingsFormWidget(),
            ],
          ),
        ),
        const StartButton(),
      ],
    );
  }
}
