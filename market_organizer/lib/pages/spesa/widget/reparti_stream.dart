import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/pages/spesa/singleproduct_widget.dart';
import 'package:market_organizer/utils/utils.dart';

class RepartiStream extends StatefulWidget {
  final Spesa _currentSpesa;

  RepartiStream(this._currentSpesa);

  @override
  State<RepartiStream> createState() => _RepartiStreamState();
}

class _RepartiStreamState extends State<RepartiStream> {
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
          if (_snapshot.hasData) {
            List<Product> _products = _snapshot.data!;
            if (!widget._currentSpesa.showSelected!) {
              //rimuovo prodotti selezionati
              _products.removeWhere((element) => element.bought!);
            }
            List<String> reparti = Utils.instance
                .getReparti(_products, widget._currentSpesa.orderBy!);

            return ListView.separated(
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 7,
                  );
                },
                itemCount: reparti.length,
                itemBuilder: (context, index) {
                  return reparto(
                    widget._currentSpesa.workspaceIdRef!,
                    reparti[index],
                    _products
                        .where((p) => p.reparto == reparti[index])
                        .toList(),
                  );
                });
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.orange,
            ));
          }
        });
  }

/** REPARTO START */

  Widget reparto(
      String _workspaceId, String repartoName, final List<Product> products) {
    return Container(
      child: Column(
        children: [
          Divider(
            thickness: 0.1,
            color: Colors.grey,
          ),
          _titleReparto(repartoName),
          _productsList(products),
        ],
      ),
    );
  }

  Widget _titleReparto(String repartoName) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0, left: 15, top: 5),
        child: Text(
          repartoName,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _productsList(List<Product> products) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return Divider(
          height: 0,
          thickness: 0.2,
          color: Colors.white,
          indent: 55,
          endIndent: 0,
        );
      },
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
