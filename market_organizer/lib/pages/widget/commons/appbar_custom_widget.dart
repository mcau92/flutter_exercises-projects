import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/service/navigation_service.dart';

class AppBarCustom extends StatelessWidget {
  final int _selectedIndex;
  final Function _addItem;
  final String worksapceId;
  AppBarCustom(this._selectedIndex, this._addItem, this.worksapceId);

  @override
  Widget build(BuildContext context) {
    return _header();
  }

  Widget _header() {
    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              constraints: BoxConstraints(),
              padding: EdgeInsets.all(15),
              icon: Icon(
                CupertinoIcons.home,
                color: Colors.white,
              ),
              onPressed: () => _goToHome(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(alignment: Alignment.bottomLeft, child: _workspaceTitle()),
              Align(
                alignment: Alignment.bottomRight,
                child: _addButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _workspaceTitle() {
    String title = "";
    if (_selectedIndex == 0)
      title = "Spesa";
    else
      title = "Menù";

    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 40,
        ),
      ),
    );
  }

  void _goToHome() {
    NavigationService.instance.navigateToReplacement("home");
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: IconButton(
        disabledColor: Colors.white.withOpacity(0.5),
        icon: Icon(CupertinoIcons.ellipsis_vertical,
            color: Colors.white, size: 25),
        onPressed: () => _addItem(),
      ),
    );
  }
}
