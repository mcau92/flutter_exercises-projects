import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitmacros/home/widget/calendar_widget.dart';
import 'package:splitmacros/home/widget/generic_user_info_widget.dart';
import 'package:splitmacros/home/widget/plan_user_section_widget.dart';
import 'package:splitmacros/provider/auth_provider.dart';
import 'package:splitmacros/utils/constant.dart';
import '../utils/widget/app_bar.dart';

class HomePage extends StatelessWidget {
  AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(context, _height),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _homePageBody(_height),
      ),
    );
  }

  Widget _homePageBody(double _height) {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Column(
          children: [
            //generic data section
            _genericUserInfo(_context, _height),
            //calendar section
            _calendarSection(_height),
            //plan user section
            _planUserSection(_context, _height),
          ],
        );
      },
    );
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
            size: 22,
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
        _height * 0.13);
  }

  Widget _genericUserInfo(BuildContext _context, double _height) {
    return Container(
      height: _height * 0.22,
      decoration: BoxDecoration(
        color: Theme.of(_context).cardColor,
        border: Border.all(
          width: 0,
          color: Theme.of(_context).cardColor,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: GenericUserInfoWidget("t2GiY0JwgpSZdZW9xcdrPeC8PHG2"),
    );
  }

  Widget _calendarSection(double _height) {
    return Container(
      height: _height * 0.25,
      child: CalendarWidget(),
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
        child: PlanUserSectionWidget("t2GiY0JwgpSZdZW9xcdrPeC8PHG2"),
      ),
    );
  }
}
