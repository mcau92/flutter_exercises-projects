import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/show/single_product_update_show_widget%20copy.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/color_costant.dart';
import 'package:market_organizer/utils/measure_converter_utility.dart';

class SingleProductReceiptsShowWidget extends StatefulWidget {
  final _menuId;
  final Product _product;

  SingleProductReceiptsShowWidget(this._menuId, this._product);

  @override
  State<SingleProductReceiptsShowWidget> createState() =>
      _SingleProductReceiptsShowWidgetState();
}

class _SingleProductReceiptsShowWidgetState
    extends State<SingleProductReceiptsShowWidget> {
  Future<void> _deleteProduct() async {
    await DatabaseService.instance
        .deleteProductRecipt(widget._menuId, widget._product);
  }

  void _singleProductDetailPage(Product _product) {
    NavigationService.instance
        .navigateToWithParameters("singleProductUpdateShowDetailPage",
            SingleProductUpdateShownIput(_product, widget._menuId))
        .then((value) => setState(() {}));
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
      color: ColorCostant.colorMap[widget._product.color].withOpacity(0.2),
      child: _productCard(),
    );
  }

  Widget _productCard() {
    return ListTile(
      onTap: () => _singleProductDetailPage(widget._product),
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
      dense: true,
      leading: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: 27,
        decoration: BoxDecoration(
          color: ColorCostant.colorMap[widget._product.color],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            widget._product.ownerName[0].toUpperCase(),
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      ),
      title: Text(widget._product.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(
        widget._product.description,
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
              widget._product.quantity, widget._product.measureUnit),
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
