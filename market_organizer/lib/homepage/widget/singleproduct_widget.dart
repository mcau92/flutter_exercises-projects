import 'package:flutter/material.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/utils/color_costant.dart';
import 'package:market_organizer/utils/measure_converter_utility.dart';

class SingleProductWidget extends StatelessWidget {
  final Product _product;
  SingleProductWidget(this._product);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorCostant.colorMap[_product.color].withOpacity(0.24),
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: _productCard(),
    );
  }

  Widget _productCard() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
      dense: true,
      leading: Image.network(
        _product.image,
        height: 40,
      ),
      title: Text(_product.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      subtitle: Text(_product.description),
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 30,
        ),
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: ColorCostant.colorMap[_product.color],
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              _product.ownerName[0].toUpperCase(),
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
