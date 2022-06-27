import 'package:flutter/material.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/utils/color_costant.dart';

class SingleRicetta extends StatelessWidget {
  final Ricetta _ricetta;
  SingleRicetta(this._ricetta);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorCostant.colorMap[_ricetta.color]!.withOpacity(0.2),
      child: _reciptCard(),
    );
  }

  Widget _reciptCard() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
      dense: true,
      title: Text(_ricetta.name!,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(
        _ricetta.description == null || _ricetta.description!.isEmpty
            ? "(nessuna descrizione)"
            : _ricetta.description!,
        style: TextStyle(
          color: Colors.black.withOpacity(0.7),
        ),
      ),
      trailing: _trailingWidget(),
    );
  }

  Widget _trailingWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: 27,
      decoration: BoxDecoration(
        color: ColorCostant.colorMap[_ricetta.color],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          _ricetta.ownerName![0].toUpperCase(),
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }
}
