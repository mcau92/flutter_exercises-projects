import 'package:flutter/material.dart';
import 'package:market_organizer/models/ricetta.dart';

class RicettaSearchWidget extends StatelessWidget {
  final Ricetta _ricetta;
  RicettaSearchWidget(this._ricetta);
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: _ricettaCard(),
    );
  }

  Widget _ricettaCard() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
      dense: true,
      title: Text(_ricetta.name!,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(
        _ricetta.description!,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}
