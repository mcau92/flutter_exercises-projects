import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/utils/color_costant.dart';

class SingleRicetta extends StatelessWidget {
  final Ricetta _ricetta;
  SingleRicetta(this._ricetta);

  Future<void> _deleteReceipt() async {
    await DatabaseService.instance.deleteReceiptById(_ricetta);
  }

// conferma eliminazione prodotto
  Future<bool> _confirmDismiss(BuildContext context) async {
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text("Confermi di cancellare questo elemento?"),
            actions: [
              CupertinoDialogAction(
                child: Text("si"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                    // rootNavigator: true,
                  ).pop(true);
                },
              ),
              CupertinoDialogAction(
                child: Text("no"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                  ).pop(false);
                },
              )
            ],
          );
        });
  }

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
      child: Dismissible(
        child: Container(
          color: ColorCostant.colorMap[_ricetta.color].withOpacity(0.2),
          child: _productCard(),
        ),
        key: UniqueKey(),
        onDismissed: (direction) => _deleteReceipt(),
        direction: DismissDirection.startToEnd,
        dismissThresholds: {DismissDirection.startToEnd: 0.3},
        confirmDismiss: (direction) => _confirmDismiss(context),
        background: Container(
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(10)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Icon(
                CupertinoIcons.delete,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _productCard() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
      dense: true,
      title: Text(_ricetta.name,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(
        _ricetta.description == null || _ricetta.description.isEmpty
            ? "(nessuna descrizione)"
            : _ricetta.description,
        style: TextStyle(
          color: Colors.black.withOpacity(0.7),
        ),
      ),
      leading: _trailingWidget(),
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
          _ricetta.ownerName[0].toUpperCase(),
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
