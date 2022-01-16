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
  final int _indexKey;
  SingleProductReceiptsWidget(
      this._product, this._isAddToSpesa, this._updateFromList, this._indexKey);

  void _singleProductDetailPage(Product _product) {
    NavigationService.instance.navigateToWithParameters(
        "singleProductUpdateDetailPage",
        SingleProductUpdateInput(_updateFromList, _indexKey, _product,
            _isAddToSpesa)); //key usata per poter aggiornare il prodotto se in fase di inserimento
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
      child: _container(),
    );
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
