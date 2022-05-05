import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:provider/provider.dart';

class AppBarCustom extends StatelessWidget {
  final int _selectedIndex;
  final Function _addItem;
  final bool _isLoadingData;
  final String worksapceId;
  AppBarCustom(this._selectedIndex, this._addItem, this._isLoadingData,
      this.worksapceId);

  @override
  Widget build(BuildContext context) {
    return _header();
  }

//metodo generico per aggiungere utente al nostro workspace
  void _addUser() {
    NavigationService.instance
        .navigateToWithParameters("shareToUserPage", worksapceId);
  }

  Widget _header() {
    return Container(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(alignment: Alignment.bottomLeft, child: _workspaceTitle()),
          Align(
            alignment: Alignment.bottomRight,
            child: _selectedIndex == 0 ? _spesaButtons() : _menuButtons(),
          ),
        ],
      ),
    );
  }

  Widget _spesaButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_homeButton(), _addUserButton(), _addButton()],
    );
  }

  Widget _menuButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_homeButton(), _addUserButtonWithPadding()],
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

  Widget _homeButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: IconButton(
        icon: Icon(
          CupertinoIcons.home,
          color: Colors.white,
        ),
        onPressed: () => _goToHome(),
      ),
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: IconButton(
        disabledColor: Colors.white.withOpacity(0.5),
        icon: Icon(CupertinoIcons.add, color: Colors.white, size: 25),
        onPressed: () => _isLoadingData ? null : _addItem(),
      ),
    );
  }

  Widget _addUserButton() {
    return IconButton(
      disabledColor: Colors.white.withOpacity(0.5),
      icon: Icon(CupertinoIcons.person_add, color: Colors.white, size: 25),
      onPressed: () => _isLoadingData ? null : _addUser(),
    );
  }

  Widget _addUserButtonWithPadding() {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: IconButton(
        disabledColor: Colors.white.withOpacity(0.5),
        icon: Icon(CupertinoIcons.person_add, color: Colors.white, size: 25),
        onPressed: () => _isLoadingData ? null : _addUser(),
      ),
    );
  }
}
