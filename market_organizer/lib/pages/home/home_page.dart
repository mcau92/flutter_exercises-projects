import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/pages/home/widget/account_widget.dart';
import 'package:market_organizer/pages/home/widget/workspaces_widget.dart';
import 'package:market_organizer/service/navigation_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _goToNotifyPage() {
    NavigationService.instance.navigateTo("notifyPage");
  }

  void _insertWorkspace() {
    NavigationService.instance.navigateToWithParameters("saveWorkspace", null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 1,
        leading: CupertinoButton(
          child: Icon(
            CupertinoIcons.bell_fill,
            color: Colors.white,
          ),
          onPressed: () => _goToNotifyPage(),
        ),
        title: _selectedIndex == 0 ? Text("I miei workspace") : Text("Account"),
        actions: [
          if (_selectedIndex == 0)
            CupertinoButton(
              child: Icon(
                CupertinoIcons.add,
                color: Colors.white,
              ),
              onPressed: () => _insertWorkspace(),
            )
        ],
      ),
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
      return WorkspacesWidget();
    else
      return UserWidget();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _bottomBar() {
    return CupertinoTabBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.collections),
          label: 'Workspaces',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          label: 'Account',
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
