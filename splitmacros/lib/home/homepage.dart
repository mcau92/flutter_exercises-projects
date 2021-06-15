import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:splitmacros/home/widget/calendar_widget.dart';
import 'package:splitmacros/utils/constant.dart';
import '../utils/widget/app_bar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: _appBar(context, _height),
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          children: [
            //generic data section
            _genericUserInfo(context, _height),
            //calendar section
            _calendarSection(_height),
            //plan user section
            _planUserSection(context, _height),
          ],
        ));
  }

  Widget _appBar(BuildContext _context, double _height) {
    return AppBarWidget(
        Text(
          Constant().title,
          style: Theme.of(_context).textTheme.headline1.copyWith(
                color: Colors.white,
                fontSize: 30,
              ),
        ),
        null,
        ElevatedButton(
          child: Icon(
            CupertinoIcons.person,
            size: 30,
            color: Colors.black,
          ),
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            padding: EdgeInsets.all(15),
            elevation: 20,
            shape: CircleBorder(),
          ),
        ),
        Theme.of(_context).cardColor,
        _height * 0.15);
  }

  Widget _genericUserInfo(BuildContext _context, double _height) {
    return Container(
      height: _height * 0.35,
      decoration: BoxDecoration(
        color: Theme.of(_context).cardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
    );
  }

  Widget _calendarSection(double _height) {
    return Container(
      height: _height * 0.25,
      child: CalendarWidget(_height),
    );
  }

  Widget _planUserSection(BuildContext context, double height) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: Center(
          child: Text("homepage"),
        ),
      ),
    );
  }
}
