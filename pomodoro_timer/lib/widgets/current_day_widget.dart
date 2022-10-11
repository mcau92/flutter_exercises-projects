import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrentDayWidget extends StatefulWidget {
  const CurrentDayWidget({Key? key}) : super(key: key);

  @override
  State<CurrentDayWidget> createState() => _CurrentDayWidgetState();
}

class _CurrentDayWidgetState extends State<CurrentDayWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _time(),
            _day(),
          ],
        );
      },
    );
  }

  Widget _time() {
    return Text(
      DateFormat('HH:mm').format(DateTime.now()),
      style: Theme.of(context).textTheme.headline1,
    );
  }

  Widget _day() {
    int weekday = DateTime.now().weekday;
    String day = getDayStringFromWeekday(weekday);
    return Text(
      day,
      style: Theme.of(context).textTheme.headline2,
    );
  }

  String getDayStringFromWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return "Lunedì";
      case 2:
        return "Martedì";
      case 3:
        return "Mercoledì";
      case 4:
        return "Giovedì";
      case 5:
        return "Venerdì";
      case 6:
        return "Sabato";
      case 7:
        return "Domenica";
      default:
        return "";
    }
  }
}
