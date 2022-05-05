import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/pages/menu/menu_widget.dart';
import 'package:market_organizer/pages/spesa/spesa_widget.dart';
import 'package:market_organizer/service/navigation_service.dart';

class DispatchPage extends StatefulWidget {
  @override
  _DispatchPageState createState() => _DispatchPageState();
}

class _DispatchPageState extends State<DispatchPage> {
  int _selectedIndex = 0;
  late UserWorkspace? focusedWorkspace;

  @override
  Widget build(BuildContext context) {
    focusedWorkspace =
        ModalRoute.of(context)!.settings.arguments as UserWorkspace;
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

      body: _bodySelection(),
    );
  }

  Widget _bodySelection() {
    if (_selectedIndex == 0)
      return SpesaWidget(
        focusedWorkspace!.id!,
      );
    else
      return MenuWidget(
        focusedWorkspace!.id!,
      );
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
      ],
      currentIndex: _selectedIndex,
      activeColor: Colors.orange,
      inactiveColor: Colors.white.withOpacity(0.5),
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      onTap: _onItemTapped,
    );
  }
}
