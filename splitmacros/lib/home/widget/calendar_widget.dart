import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitmacros/provider/day_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarController _calendarController; //controller creation
  DayProvider _dayProvider;
  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    _dayProvider.updateSelectedDay(day);
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController(); //initializing it
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _dayProvider=Provider.of<DayProvider>(context);
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: _calendar(),
    );
  }

  Widget _calendar() {
    return TableCalendar(
      calendarController: _calendarController,
      startingDayOfWeek: StartingDayOfWeek.monday,
      initialCalendarFormat: CalendarFormat.twoWeeks,
      calendarStyle: CalendarStyle(
        weekdayStyle: Theme.of(context).textTheme.headline4,
        todayStyle: Theme.of(context).textTheme.headline4.copyWith(
              color: Colors.white,
            ),
        selectedStyle: Theme.of(context).textTheme.headline4.copyWith(
              color: Colors.white,
            ),
        weekendStyle: Theme.of(context).textTheme.headline4.copyWith(
              color: Colors.red,
            ),
        selectedColor: Theme.of(context).primaryColor,
        todayColor: Theme.of(context).primaryColor.withOpacity(0.6),
        outsideDaysVisible: true,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleTextStyle: Theme.of(context).textTheme.headline2.copyWith(
              color: Theme.of(context).primaryColor,
            ),
        centerHeaderTitle: true,
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Theme.of(context).primaryColor,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Theme.of(context).primaryColor,
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }
}
