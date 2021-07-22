import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/homepage/widget/body_widget.dart';
import 'package:market_organizer/models/userworkspace.model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<UserWorkspace> workspaces;
  UserWorkspace focusedWorkspace;
  BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(25.0), // here the desired height
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      /* body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _homePageBody(_height),
      ), */
      body: StreamBuilder<List<UserWorkspace>>(
        stream:
            DatabaseService.instance.getUserWorkspace("nadLzn6xd00BJcpy1Gtc"),
        builder: (context, snapshot) {
          print(snapshot.hasData);
          if (snapshot.hasData) {
            workspaces = snapshot.data;
            focusedWorkspace =
                workspaces.where((element) => element.focused == true).first;
            return Column(
              children: [
                _header(),
                _body(),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.black,
              ),
            );
          }
        },
      ),
    );
  }

//header section
  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _workspaceTitle(),
        _addButton(),
      ],
    );
  }

  Widget _workspaceTitle() {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text(
          focusedWorkspace.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 40,
          ),
        ),
      ),
      Icon(Icons.arrow_drop_down),
    ]);
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 25.0),
      child: Icon(
        Icons.add,
        color: Colors.black,
        size: 30,
      ),
    );
  }
  //end header section

  //body section
  Widget _body() {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 30),
          _userListBar(),
          _workspaceBar(),
          BodyWidget(focusedWorkspace),
        ],
      ),
    );
  }

  String createString(int _days) {
    if (_days == 0) return "La tua spesa è prevista oggi";
    if (_days == 1) return "La tua spesa è prevista domani";
    return "La tua spesa è prevista tra " + _days.toString() + " giorni";
  }

  Widget _userListBar() {
    return Row(
      children: [
        Container(
          height: 30,
          width: 40,
          decoration: BoxDecoration(
            color: Theme.of(_context).cardColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _workspaceBar() {
    int _days = focusedWorkspace.date.difference(DateTime.now()).inDays;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(_context).cardColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15, top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              createString(_days),
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
            IconButton(icon: Icon(Icons.more_horiz), onPressed: () {})
          ],
        ),
      ),
    );
  }
}
