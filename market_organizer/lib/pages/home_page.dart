import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/pages/menu/menu_widget.dart';
import 'package:market_organizer/pages/spesa/spesa_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<UserWorkspace> workspaces;
  UserWorkspace focusedWorkspace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(10.0), // here the desired height
          child: AppBar(
              backgroundColor: Color.fromRGBO(43, 43, 43, 1), elevation: 0)),
      bottomNavigationBar: _bottomBar(),
      /* body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _homePageBody(_height),
      ), */

      body: FutureBuilder<List<UserWorkspace>>(
        future: DatabaseService.instance
            .getUserWorkspace("LMgqupuW0wVW4RZn3QyC0y9Xxrg1"),
        builder: (ctx, _snap) {
          if (_snap.hasData) {
            workspaces = _snap.data;
            focusedWorkspace = workspaces.where((w) => w.focused).first;
            return _bodySelection();
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _bodySelection() {
    if (_selectedIndex == 0)
      return SpesaWidget(
        focusedWorkspace.id,
      );
    else if (_selectedIndex == 1)
      return MenuWidget(
        focusedWorkspace.id,
      );
    else
      return Container();
  }
//header section

  //bottombar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _bottomBar() {
    return CupertinoTabBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.cart),
          label: 'Spesa',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.calendar),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_alt),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      activeColor: Colors.red,
      inactiveColor: Colors.white.withOpacity(0.5),
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      onTap: _onItemTapped,
    );
  }
}
