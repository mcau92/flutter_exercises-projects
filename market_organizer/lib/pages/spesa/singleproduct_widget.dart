import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/spesa/single_product_detail_page.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/color_costant.dart';
import 'package:market_organizer/utils/measure_converter_utility.dart';

class SingleProductWidget extends StatelessWidget {
  final String _workspaceId;
  final Product _product;
  final Function _updateCheckBox;
  final bool showPrice;
  //
  late String? userimage;

  SingleProductWidget(
      this._workspaceId, this._product, this._updateCheckBox, this.showPrice);

  void _singleProductDetailPage(Product _product) {
    NavigationService.instance.navigateToWithParameters(
        "singleProductDetailPage",
        SingleProductDetailPageInput(_workspaceId, null, _product));
  }

  void _updateCheckBoxIntern(bool value) {
    _product.bought = value;
    _updateCheckBox(_product);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserDataModel>(
        future: DatabaseService.instance.getUserData(_product.ownerId!),
        builder: (ctx, snap) {
          if (snap.hasData) {
            userimage = snap.data!.image;
            return _productCard();
          } else {
            return Container();
          }
        });
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
      trailing: Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: _trailingWidget(),
      ),
    );
  }

  Widget _trailingWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              MeasureConverterUtility.quantityMeasureUnitStringCreation(
                  _product.quantity!, _product.measureUnit!),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _product.bought!
                    ? Colors.white.withOpacity(0.5)
                    : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              showPrice
                  ? _product.price.toString() + " " + _product.currency!
                  : "--.-",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _product.bought!
                    ? Colors.orange.withOpacity(0.5)
                    : Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 20,
        ),
        userBoxName()
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
