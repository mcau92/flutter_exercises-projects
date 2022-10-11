import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pomodoro_timer/providers/settings_provider.dart';
import 'package:pomodoro_timer/utils/constant.dart';
import 'package:pomodoro_timer/utils/settings_type.dart';
import 'package:pomodoro_timer/widgets/settings_picker_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsFormWidget extends StatefulWidget {
  const SettingsFormWidget({Key? key}) : super(key: key);

  @override
  State<SettingsFormWidget> createState() => _SettingsFormWidgetState();
}

class _SettingsFormWidgetState extends State<SettingsFormWidget> {
  //default
  final List<int> _studyOptions = Constant.getStudyOptions();
  final List<int> _pausaOptions = Constant.getPausaOptions();
  final List<int> _ripetiOptions = Constant.getRipetiOptions();
  //local storadge
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //logger
  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  //functions
  void _updateStudyOption(int value) {
    if (value !=
        Provider.of<SettingsProvider>(context, listen: false).studyMinutes) {
      Provider.of<SettingsProvider>(context, listen: false)
          .changeStudyMinutes(value);
      _prefs.then((SharedPreferences prefs) {
        loggerNoStack.i("update studyMinutes: " + value.toString());
        prefs.setInt('studyMinutes', value);
      });
    }
  }

  void _updateBreakOption(int value) {
    if (value !=
        Provider.of<SettingsProvider>(context, listen: false).breakMinutes) {
      Provider.of<SettingsProvider>(context, listen: false)
          .changeBreakMinutes(value);
      _prefs.then((SharedPreferences prefs) {
        loggerNoStack.i("update breakMinutes: " + value.toString());
        prefs.setInt('breakMinutes', value);
      });
    }
  }

  void _updateRepeatOption(int value) {
    if (value !=
        Provider.of<SettingsProvider>(context, listen: false).numRepeat) {
      Provider.of<SettingsProvider>(context, listen: false).changeRepeat(value);
      _prefs.then((SharedPreferences prefs) {
        loggerNoStack.i("update numRepeat: " + value.toString());
        prefs.setInt('numRepeat', value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 35.0, horizontal: 20),
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: _settingsForm(),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _settingsForm() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: _studySettingsRow(),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: _breakSettingsRow(),
        ),
        _repeatSettingsRow()
      ],
    );
  }

  Widget _studySettingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Studio",
          style: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(color: Colors.black),
        ),
        SettingsPickerWidget(
            settingsType: SettingsType.studio,
            title: "Studio",
            currentSelectedOption:
                Provider.of<SettingsProvider>(context).studyMinutes,
            options: _studyOptions,
            updateOption: _updateStudyOption),
      ],
    );
  }

  Widget _breakSettingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Pausa",
          style: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(color: Colors.black),
        ),
        SettingsPickerWidget(
            settingsType: SettingsType.pausa,
            title: "Pausa",
            currentSelectedOption:
                Provider.of<SettingsProvider>(context).breakMinutes,
            options: _pausaOptions,
            updateOption: _updateBreakOption),
      ],
    );
  }

  Widget _repeatSettingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Ripetizioni",
          style: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(color: Colors.black),
        ),
        SettingsPickerWidget(
            settingsType: SettingsType.ripeti,
            title: "Ripetizioni",
            currentSelectedOption:
                Provider.of<SettingsProvider>(context).numRepeat,
            options: _ripetiOptions,
            updateOption: _updateRepeatOption)
      ],
    );
  }
}
