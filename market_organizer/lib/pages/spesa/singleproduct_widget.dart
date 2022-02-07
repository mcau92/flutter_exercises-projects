import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/pages/spesa/single_product_detail_page.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/color_costant.dart';
import 'package:market_organizer/utils/measure_converter_utility.dart';

class SingleProductWidget extends StatelessWidget {
  final String _workspaceId;
  final Product _product;
  SingleProductWidget(this._workspaceId, this._product);

  void _singleProductDetailPage(Product _product) {
    NavigationService.instance.navigateToWithParameters(
        "singleProductDetailPage",
        SingleProductDetailPageInput(_workspaceId, _product));
  }

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 18, color: Colors.white),
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
        SizedBox(width: 30),
        Text(
          _product.price.toString() + _product.currency,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }
}
