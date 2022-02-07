import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/receiptOperationType.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/receipt_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/ricetta_widget.dart';

class PastoWidget extends StatefulWidget {
  final String _pastoName;
  final List<Ricetta> _ricette;
  final MealDetailModel mealDetailModel;
  PastoWidget(this._pastoName, this._ricette, this.mealDetailModel);

  @override
  State<PastoWidget> createState() => _PastoWidgetState();
}

class _PastoWidgetState extends State<PastoWidget> {
  void _showReceiptDetails(Ricetta _ricetta) async {
    //ricetta può essere nulla se sono in fase di creazione da zero altrimenti è valorizzata con quella selezionata
    Map<Product, bool> fetchedProd = await DatabaseService.instance
        .getProductsByReceiptWithDefaultFalseInSpesa(
            _ricetta.menuIdRef, _ricetta.id);
    NewSelectedReceiptInput receiptInput = new NewSelectedReceiptInput(
        ReceiptOperationType.UPDATE,
        _ricetta,
        fetchedProd,
        widget.mealDetailModel,
        widget._pastoName);
    Navigator.pushNamed(context, "receiptPage",
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
              //spostare qui il dismissable in modo da eliminare anche il pasto
              child: SingleRicetta(widget._ricette[index]));
        });
  }
}
