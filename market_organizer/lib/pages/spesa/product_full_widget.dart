import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/pages/spesa/single_product_detail_page.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/color_costant.dart';
import 'package:market_organizer/utils/measure_converter_utility.dart';

//classe che mostra prodotto non ancora inserito a db quando sto creando la ricetta da zero
class ProductFullWidget extends StatelessWidget {
  final String _workspaceId;
  final Product _product;
  final Function _updateCheckBox;
  final bool showPrice;

  ProductFullWidget(
      this._workspaceId, this._product, this._updateCheckBox, this.showPrice);

  void _singleProductDetailPage(Product _product) {
    NavigationService.instance.navigateToWithParameters(
        "singleProductDetailPage",
        SingleProductDetailPageInput(_workspaceId, null, _product));
  }

  void _updateCheckBoxIntern(bool value) {
    HapticFeedback.heavyImpact();
    _product.bought = value;
    _updateCheckBox(_product);
  }

  @override
  Widget build(BuildContext context) {
    return _productCard();
  }

  Widget _productCard() {
    return ListTile(
      onTap: () => _singleProductDetailPage(_product),
      contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      horizontalTitleGap: 10,
      leading: Transform.scale(
        scale: 1.5,
        child: Checkbox(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeColor: Colors.green,
          value: _product.bought,
          onChanged: (v) => _updateCheckBoxIntern(v!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      title: Text(
          _product.name!.length > 17
              ? "${_product.name!.substring(0, 14)}..."
              : _product.name!,
          style: TextStyle(
              color: _product.bought!
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: 16)),
      subtitle: Text(
        _product.description == null || _product.description!.isEmpty
            ? "(nessuna descrizione)"
            : _product.description!,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      trailing: _trailing(),
    );
  }

  Widget _trailing() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, top: 10),
                  child: Text(
                    _product.reparto!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: _trailingWidget(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: userBoxName(),
        ),
      ],
    );
  }

  Widget _trailingWidget() {
    double ammount = _product.price ?? 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _product.quantity! >= 100
                        ? "--.-"
                        : _product.quantity!.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    MeasureConverterUtility.fixMeasure(_product.measureUnit!),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ammount >= 100 ? "-.-" : ammount.toStringAsFixed(2),
                  ),
                  Text(" €"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget userBoxName() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      width: 27,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 0.5,
          ),
        ],
        color: _product.bought!
            ? ColorCostant.colorMap[_product.color]!.withOpacity(0.5)
            : ColorCostant.colorMap[_product.color],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          _product.ownerName![0].toUpperCase(),
          style: TextStyle(
              fontSize: 15,
              color: _product.bought!
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white),
        ),
      ),
    );
  }
}
