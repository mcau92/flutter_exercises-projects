import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/show/show_recipt_input.dart';
import 'package:market_organizer/pages/menu/singleDay/single_ricetta_widget.dart';

class PastoWidget extends StatefulWidget {
  final String _workspaceId;
  final String _pastoName;
  final List<Ricetta> _ricette;
  PastoWidget(this._workspaceId, this._pastoName, this._ricette);

  @override
  State<PastoWidget> createState() => _PastoWidgetState();
}

class _PastoWidgetState extends State<PastoWidget> {
  void _showReceiptDetails(Ricetta _ricetta) {
    //ricetta può essere nulla se sono in fase di creazione da zero altrimenti è valorizzata con quella selezionata
    ShowReceiptInput receiptInput =
        new ShowReceiptInput(widget._workspaceId, _ricetta);
    Navigator.pushNamed(context, "showReceiptPage",
            arguments:
                receiptInput) //cosi facendo quando nelle pagine successivo faccio pop e arrivo a questa fa il refresh
        .then((value) => setState(() {}));
  }

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
          widget._pastoName,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  //
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
        itemCount: widget._ricette.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () => _showReceiptDetails(widget._ricette[index]),
              child: SingleRicetta(widget._ricette[index]));
        });
  }
}
