import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/models/ricette.dart';

class SingleRicetta extends StatelessWidget {
  final Ricette _ricetta;
  SingleRicetta(this._ricetta);
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.primaries[_ricetta.color].withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: _productCard(),
      ),
    );
  }

  Widget _productCard() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
      dense: true,
      leading: Container(
        clipBehavior: Clip.hardEdge,
        height: 40,
        width: 40,
        padding: _ricetta.image == null? EdgeInsets.all(10):EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Color.fromRGBO(229, 229, 229, 1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: _ricetta.image == null
              ? Icon(CupertinoIcons.photo_camera,size: 20,)
              : Image.network(
                  _ricetta.image,
                  fit: BoxFit.fill,
                  height: 40,
                ),
        ),
      ),
      title: Text(_ricetta.name,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(
        _ricetta.description,
        style: TextStyle(
          color: Colors.black.withOpacity(0.7),
        ),
      ),
      trailing: _trailingWidget(),
    );
  }

  Widget _trailingWidget() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.primaries[_ricetta.color],
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          _ricetta.ownerName[0].toUpperCase(),
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
      ),
    );
  }
}
