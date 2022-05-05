import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/utils/color_costant.dart';
import 'package:market_organizer/utils/measure_converter_utility.dart';

//classe che mostra prodotto non ancora inserito a db quando sto creando la ricetta da zero
class ProductSearchWidget extends StatelessWidget {
  final Product _product;

  ProductSearchWidget(this._product);

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
        color: ColorCostant.colorMap[_product.color]!.withOpacity(0.2),
        child: _productCard(),
      ),
    );
  }

  Widget _productCard() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
      dense: true,
      title: Text(_product.name!,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(
        _product.description == null || _product.description!.isEmpty
            ? "(nessuna descrizione)"
            : _product.description!,
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
              _product.quantity!, _product.measureUnit!),
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
