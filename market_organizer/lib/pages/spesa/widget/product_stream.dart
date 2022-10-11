import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/pages/spesa/singleproduct_widget.dart';
import 'package:market_organizer/utils/category_enum.dart';
import 'package:market_organizer/utils/utils.dart';

class ProductStream extends StatefulWidget {
  final Spesa _currentSpesa;

  ProductStream(this._currentSpesa);

  @override
  State<ProductStream> createState() => _SpesaStreamState();
}

class _SpesaStreamState extends State<ProductStream> {
/*********** FUNCTIONS */

  Future<void> _deleteProduct(Product _product) async {
    //check if spesa contains product
    int spesaProdSize = await DatabaseService.instance
        .getSpesaProductsSize(_product.spesaIdRef!);
    await DatabaseService.instance.deleteProduct(_product);

    if (spesaProdSize == 1) {
      //ask user if want to delete spesa with 0 prods
      await DatabaseService.instance.deleteSpesa(_product.spesaIdRef!);
    }
  }

  Future<void> _boughtProduct(Product _product) async {
    await DatabaseService.instance.updateProductBoughtOnSpesa(_product);
  }

/*********** END FUNCTIONS */

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
        stream: DatabaseService.instance
            .getProductsBySpesa(widget._currentSpesa.id!),
        builder: (context, _snapshot) {
          if (_snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.orange,
            ));
          } else if (_snapshot.hasData) {
            List<Product> _products = _snapshot.data!;
            _products.sort(((a, b) => a.reparto!.compareTo(b.reparto!)));
            if (widget._currentSpesa.orderBy ==
                CategoryOrder.categoryReverse.toString()) {
              _products = _products.reversed.toList();
            }
            if (!widget._currentSpesa.showSelected!) {
              //rimuovo prodotti selezionati
              _products.removeWhere((element) => element.bought!);
            }

            return _productsContainer(_products);
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.orange,
            ));
          }
        });
  }

  Widget _productsContainer(final List<Product> products) {
    return Container(
      child: Column(
        children: [
          Divider(
            thickness: 0.1,
            color: Colors.grey,
          ),
          Expanded(child: _productsList(products)),
        ],
      ),
    );
  }

  Widget _productsList(List<Product> products) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
          thickness: 0.2,
          color: Colors.white,
          indent: 55,
          endIndent: 0,
        );
      },
      padding: EdgeInsets.all(0),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _dismissibleProd(products, index);
      },
    );
  }

  Widget _dismissibleProd(List<Product> products, int index) {
    return Dismissible(
      child: SingleProductWidget(widget._currentSpesa.workspaceIdRef!,
          products[index], _boughtProduct, widget._currentSpesa.showPrice!),
      key: UniqueKey(),
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart)
          HapticFeedback.heavyImpact();
        _deleteProduct(products[index]);
      },
      dismissThresholds: {DismissDirection.endToStart: 0.4},
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) return true;

        return false;
      },
      direction: DismissDirection.endToStart,
      background: Container(),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 25.0),
            child: Icon(
              CupertinoIcons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String createString(double ammount) {
    String tot = "Tot. ";
    return tot + num.parse(ammount.toStringAsFixed(2)).toString() + " €";
  }
}
