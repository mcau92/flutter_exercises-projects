import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/pages/spesa/spesa_widget.dart';

class DispatchPage extends StatefulWidget {
  @override
  _DispatchPageState createState() => _DispatchPageState();
}

class _DispatchPageState extends State<DispatchPage> {
  int _selectedIndex = 0;
  late UserWorkspace focusedWorkspace;

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
      //bottomNavigationBar: _bottomBar(),  NEXT RELEASE
      /* body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _homePageBody(_height),
      ), */

      body: _bodySelection(),
    );
  }

  Widget _bodySelection() {
    return SpesaWidget(
      focusedWorkspace.id!,
    );
    // if (_selectedIndex == 0)
    //   return SpesaWidget(
    //     focusedWorkspace.id!,
    //   );
    // else
    //   return MenuWidget(
    //     focusedWorkspace.id!,
    //   );
  }
//header section

  //bottombar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _bottomBar() {
    return Container(
      height: 100,
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => _onItemTapped(0),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.cart,
                  size: 30,
                  color: _selectedIndex == 1
                      ? Colors.grey.withOpacity(0.5)
                      : Color.fromRGBO(255, 152, 0, 1),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Spesa",
                  style: TextStyle(
                    color: _selectedIndex == 1
                        ? Colors.grey.withOpacity(0.5)
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _onItemTapped(1),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  color: _selectedIndex == 0
                      ? Colors.grey.withOpacity(0.5)
                      : Colors.orange,
                  size: 30,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Menu",
                  style: TextStyle(
                    color: _selectedIndex == 0
                        ? Colors.grey.withOpacity(0.5)
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
