import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int currentMinutes;
  final int currentSeconds;

  const TimerWidget(
      {Key? key, required this.currentMinutes, required this.currentSeconds})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final String minutesString = strDigits(currentMinutes);
    final String secondsString = strDigits(currentSeconds.remainder(60));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _minutes(minutesString, context),
        _seconds(secondsString, context),
      ],
    );
  }

  Widget _minutes(String minutes, BuildContext context) {
    return Text(
      minutes,
      style: const TextStyle(fontSize: 130, fontWeight: FontWeight.bold),
    );
  }

  Widget _seconds(String seconds, BuildContext context) {
    return Text(
      seconds,
      style: const TextStyle(fontSize: 35, fontStyle: FontStyle.italic),
    );
  }
}
