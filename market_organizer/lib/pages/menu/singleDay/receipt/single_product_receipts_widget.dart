import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/single_product_update_widget.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/color_costant.dart';
import 'package:market_organizer/utils/measure_converter_utility.dart';

//classe che mostra prodotto non ancora inserito a db quando sto creando la ricetta da zero
class SingleProductReceiptsWidget extends StatelessWidget {
  final Product _product;
  final bool _isAddToSpesa;
  final Function _updateFromList;
  final Function
      _removeFromList; //funzione usata per cancellare quando il prodotto non è ancora inserito a db
  //usato per identificare univocamente l'oggetto da cancellare
  final int _indexKey;
  SingleProductReceiptsWidget(this._product, this._isAddToSpesa,
      this._updateFromList, this._removeFromList, this._indexKey);

  void _singleProductDetailPage(Product _product) {
    NavigationService.instance.navigateToWithParameters(
        "singleProductUpdateDetailPage",
        SingleProductUpdateInput(_updateFromList, _indexKey, _product,
            _isAddToSpesa)); //key usata per poter aggiornare il prodotto se in fase di inserimento
  }

  Future<void> _deleteProduct() async {
    _removeFromList(_product);
  }

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
          child: _container(),
          key: UniqueKey(),
          onDismissed: (direction) => _deleteProduct(),
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
        ));
  }

  Widget _container() {
    return Container(
      color: ColorCostant.colorMap[_product.color].withOpacity(0.2),
      child: _productCard(),
    );
  }

  Widget _productCard() {
    return ListTile(
      onTap: () => _singleProductDetailPage(_product),
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
      dense: true,
      leading: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: 27,
        decoration: BoxDecoration(
          color: ColorCostant.colorMap[_product.color],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            _product.ownerName[0].toUpperCase(),
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      ),
      title: Text(_product.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(
        _product.description,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black.withOpacity(0.7),
        ),
      ),
      trailing: _trailingWidget(),
    );
  }

  Widget _trailingWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          MeasureConverterUtility.quantityMeasureUnitStringCreation(
              _product.quantity, _product.measureUnit),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }
}
