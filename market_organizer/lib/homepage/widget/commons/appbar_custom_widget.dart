import 'package:flutter/material.dart';

class AppBarCustom extends StatelessWidget {
  final int _selectedIndex;
  final Function _addItem;
  final bool _isLoadingData;
  AppBarCustom(this._selectedIndex, this._addItem, this._isLoadingData);

  @override
  Widget build(BuildContext context) {
    return _header();
  }

  Widget _header() {
    return Container(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(alignment: Alignment.bottomLeft, child: _workspaceTitle()),
          Align(alignment: Alignment.bottomRight, child: _addButton()),
        ],
      ),
    );
  }

  Widget _workspaceTitle() {
    String title = "";
    if (_selectedIndex == 0)
      title = "Spesa";
    else if (_selectedIndex == 1)
      title = "Menù";
    else
      title = "Profile";
    return Row(children: [
      Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
      ),
      Icon(
        Icons.arrow_drop_down,
        color: Colors.white,
      ),
    ]);
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 25.0),
      child: IconButton(
        disabledColor:Colors.white.withOpacity(0.5) ,
        icon: Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () => _isLoadingData ? null : _addItem(),
      ),
    );
  }
}
