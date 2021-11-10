import 'package:flutter/material.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:provider/provider.dart';

class WeekPickerWidget extends StatefulWidget {
  @override
  _WeekPickerWidgetState createState() => _WeekPickerWidgetState();
}

class _WeekPickerWidgetState extends State<WeekPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Center(
        child: Container(
          height: 35,
          width: 180,
          decoration: BoxDecoration(
            color: Color.fromRGBO(229, 229, 229, 1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: _datePicker(context),
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          flex: 1,
          child: TextButton(
            onPressed: () => context.read<DateProvider>().decreaseWeek(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              primary: Colors.black,
              minimumSize: Size(50, 30),
            ),
            child: Text("<"),
          ),
        ),
        Flexible(
          flex: 6,
          child: Text(
            context.watch<DateProvider>().dateFormatted,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
          flex: 1,
          child: TextButton(
            onPressed: () => context.read<DateProvider>().increaseWeek(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              primary: Colors.black,
              minimumSize: Size(50, 30),
            ),
            child: Text(">"),
          ),
        ),
      ],
    );
  }
}
