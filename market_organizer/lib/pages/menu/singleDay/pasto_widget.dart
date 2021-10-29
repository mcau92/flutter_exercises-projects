import 'package:flutter/material.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/pages/menu/singleDay/single_ricett_widget.dart';

class PastoWidget extends StatelessWidget {
  final String _pastoName;
  final List<Ricetta> _ricette;
  PastoWidget(this._pastoName,this._ricette);
  @override
    Widget build(BuildContext context) {
    return Container(
      
      padding: EdgeInsets.only(bottom: 15, top: 10, right: 10, left: 10),
      
      child: Column(
        children: [_titlePasto(), _productsList()],
      ),
    );
  }

  Widget _titlePasto() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          _pastoName,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _productsList() {
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) {
          return Divider(
            height: 20,
            thickness: 0,
          );
        },
        itemCount: _ricette.length,
        itemBuilder: (context, index) {
          return SingleRicetta(_ricette[index]);
        });
  }
}