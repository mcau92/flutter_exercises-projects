import 'package:flutter/material.dart';
import 'package:market_organizer/models/ricette.dart';
import 'package:market_organizer/homepage/widget/menu/singleDay/single_ricett_widget.dart';

class PastoWidget extends StatelessWidget {
  final String _pastoName;
  final List<Ricette> _ricette;
  PastoWidget(this._pastoName,this._ricette);
  @override
    Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(27, 27, 27, 0.5),
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(71, 71, 71, 1),
            Colors.grey,
          ],
        ),
      ),
      padding: EdgeInsets.only(bottom: 15, top: 10, right: 10, left: 10),
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: [_titleReparto(), _productsList()],
      ),
    );
  }

  Widget _titleReparto() {
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