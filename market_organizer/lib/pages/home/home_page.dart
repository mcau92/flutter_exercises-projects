import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/notifiche.dart';
import 'package:market_organizer/pages/home/widget/account_widget.dart';
import 'package:market_organizer/pages/home/widget/workspaces_widget.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:provider/provider.dart';

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
    String userId =
        Provider.of<AuthProvider>(context, listen: false).userData!.id!;
    return StreamBuilder<List<Notifiche>>(
        stream: DatabaseService.instance.countNotificheNotViewed(userId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _scaffolSection(snapshot.data!.length);
          } else {
            return _scaffolSection(0);
          }
        });
  }

  Widget _scaffolSection(int numberOfNotificheToBeViewed) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 1,
        leading: _selectedIndex == 0
            ? CupertinoButton(
                child: numberOfNotificheToBeViewed > 0
                    ? Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            CupertinoIcons.bell_fill,
                            color: Colors.white,
                          ),
                          Positioned(
                            right: -3,
                            top: -8,
                            child: new Container(
                              padding: EdgeInsets.all(3),
                              decoration: new BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: new Text(
                                numberOfNotificheToBeViewed > 99
                                    ? '>99'
                                    : '$numberOfNotificheToBeViewed',
                                style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      )
                    : Icon(
                        CupertinoIcons.bell_fill,
                        color: Colors.white,
                      ),
                onPressed: () => _goToNotifyPage(),
              )
            : Container(),
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
