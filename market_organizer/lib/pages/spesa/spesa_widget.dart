import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/pages/spesa/singleproduct_widget.dart';
import 'package:market_organizer/pages/widget/commons/appbar_custom_widget.dart';
import 'package:market_organizer/pages/widget/commons/weekpicker_widget.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/utils.dart';
import 'package:provider/provider.dart';

class SpesaWidget extends StatefulWidget {
  final String worksapceId;

  SpesaWidget(this.worksapceId);

  @override
  _SpesaWidgetState createState() => _SpesaWidgetState();
}

class _SpesaWidgetState extends State<SpesaWidget> {
  DateTime dateStart;

  DateTime dateEnd;

  DateProvider _dateProvider;
  Spesa _currentSpesa;

  bool _showCart = false;

  void _addToSpesa() {
    NavigationService.instance
        .navigateToWithParameters("addSpesaPage", _currentSpesa);
  }

  Future<bool> _confirmDelete() async {
    Navigator.pop(context);
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
                "Confermi di cancellare tutti i prodotti di questa spesa?"),
            actions: [
              CupertinoDialogAction(
                child: Text("Si"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                    // rootNavigator: true,
                  ).pop(true);
                },
              ),
              CupertinoDialogAction(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                    // rootNavigator: true,
                  ).pop(false);
                },
              ),
            ],
          );
        });
  }

  void _deleteAll() {
    DatabaseService.instance.deleteAllProductsOnSpesa(_currentSpesa.id);
  }

  void _showOptions(BuildContext ctx) {
    showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
              child: CupertinoActionSheet(
                message: Text("Opzioni Spesa"),
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () async =>
                          await _confirmDelete() ? _deleteAll() : {},
                      child: Text("Elimina tutto")),
                  CupertinoActionSheetAction(
                      onPressed: () => {}, child: Text("Duplica Spesa")),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text(
                    "Cancella",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    _dateProvider = Provider.of<DateProvider>(context);
    dateStart = _dateProvider.dateStart;
    dateEnd = _dateProvider.dateEnd;
    return Column(children: [
      AppBarCustom(0, _addToSpesa, false),
      WeekPickerWidget(),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _body(),
        ),
      )
    ]);
  }

  Widget _body() {
    return StreamBuilder<List<Spesa>>(
      stream: DatabaseService.instance
          .getSpesaStreamFromIdAndDate(widget.worksapceId, dateStart, dateEnd),
      builder: (_context, _snap) {
        if (_snap.hasData) {
          if (_snap.data.isNotEmpty) {
            List<Spesa> _spesaList = _snap.data;
            _currentSpesa = _spesaList[0];
            return Column(
              children: [
                _workspaceBar(_currentSpesa),
                Expanded(
                  child: _repartoList(_currentSpesa),
                ),
              ],
            );
          } else {
            _currentSpesa = new Spesa(
                workspaceIdRef: widget.worksapceId,
                startWeek: dateStart,
                endWeek: dateEnd,
                ownerId: "LMgqupuW0wVW4RZn3QyC0y9Xxrg1");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _workspaceBar(null),
                  Expanded(
                      child: Center(
                    child: _noSpesaWidget(),
                  )),
                ],
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _noSpesaWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _image(),
        _description(),
        _addSpesaButton(),
      ],
    );
  }

  Widget _noProdInSpesa() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _image(),
        _descriptionNoProdInSpesa(),
      ],
    );
  }

  Widget _descriptionNoProdInSpesa() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          "Nessun Prodotto In Carrello",
          style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
    );
  }

/** REPARTO START */

  Widget _repartoList(Spesa _spesa) {
    return StreamBuilder<List<Product>>(
        stream: DatabaseService.instance.getProductsBySpesa(_spesa.id),
        builder: (context, _snapshot) {
          if (_snapshot.hasData) {
            if (_snapshot.data != null && _snapshot.data.isNotEmpty) {
              List<Product> _products = _snapshot.data;
              List<Product> _notBouthgtProd =
                  _products.where((p) => p.bought == _showCart).toList();
              List<String> reparti = Utils.instance.getReparti(_notBouthgtProd);
              if (reparti != null && reparti.isNotEmpty) {
                return ListView.separated(
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 7,
                      );
                    },
                    itemCount: reparti.length,
                    itemBuilder: (context, index) {
                      return reparto(
                        _spesa.workspaceIdRef,
                        reparti[index],
                        _notBouthgtProd
                            .where((p) => p.reparto == reparti[index])
                            .toList(),
                      );
                    });
              } else {
                return Center(
                    child: _showCart ? _noProdInSpesa() : _noSpesaWidget());
              }
            } else {
              return Center(
                child: Text("nessuna spesa inserita"),
              );
            }
          } else {
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.red,
            ));
          }
        });
  }

  Widget reparto(
      String _workspaceId, String repartoName, final List<Product> products) {
    return Container(
      padding: EdgeInsets.only(bottom: 5, top: 5, right: 15, left: 15),
      child: Column(
        children: [
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
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          repartoName,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(Product _product) async {
    //check if spesa contains product
    int spesaProdSize = await DatabaseService.instance
        .getSpesaProductsSize(_product.spesaIdRef);
    await DatabaseService.instance.deleteProduct(_product);

    if (spesaProdSize == 1) {
      //ask user if want to delete spesa with 0 prods
      await DatabaseService.instance.deleteSpesa(_product.spesaIdRef);
    }
  }

  Future<void> _boughtProduct(Product _product) async {
    _product.bought = _product.bought != null ? !_product.bought : true;
    await DatabaseService.instance.updateProductBoughtOnSpesa(_product);
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

  Widget _productsList(List<Product> products) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return Divider(
          height: 20,
          thickness: 0,
        );
      },
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: _dismissibleProd(products, index),
        );
      },
    );
  }

  Widget _dismissibleProd(List<Product> products, int index) {
    return Dismissible(
      child: SingleProductWidget(widget.worksapceId, products[index]),
      key: UniqueKey(),
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart)
          _deleteProduct(products[index]);
        else if (direction == DismissDirection.startToEnd)
          _boughtProduct(products[index]);
      },
      dismissThresholds: {
        DismissDirection.startToEnd: 0.2,
        DismissDirection.endToStart: 0.2
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart)
          return _confirmDismiss(context);
        else
          return true;
      },
      background: Container(
        decoration: BoxDecoration(
            color: products[index].bought ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(10)),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Icon(
              products[index].bought
                  ? CupertinoIcons.cart_fill_badge_minus
                  : CupertinoIcons.cart_fill_badge_plus,
              color: Colors.white,
            ),
          ),
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(10)),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(
              CupertinoIcons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

/** REPARTO END */
  Widget _addSpesaButton() {
    return CupertinoButton(
      onPressed: () => _addToSpesa(),
      child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text("AGGIUNGI", style: TextStyle(color: Colors.red[600]))),
    );
  }

  Widget _description() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          "Nessun Prodotto Presente",
          style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
    );
  }

  Widget _image() {
    return Container(
      padding: EdgeInsets.all(30),
      clipBehavior: Clip.hardEdge,
      height: 200,
      width: 200,
      child: SvgPicture.asset(
        'assets/images/empty_spesa.svg',
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(150),
      ),
    );
  }

  String createString(double ammount) {
    String tot = "Tot. ";
    if (ammount == null) return tot + "0.0 €";
    return tot + num.parse(ammount.toStringAsFixed(2)).toString() + " €";
  }

  Widget _workspaceBar(Spesa _currentSpesa) {
    return Builder(builder: (context) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentSpesa == null
                      ? "Tot. 0 €"
                      : createString(_currentSpesa.ammount),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    CupertinoButton(
                      child: Icon(
                        _showCart
                            ? CupertinoIcons.doc_plaintext
                            : CupertinoIcons.cart_badge_plus,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _showCart = !_showCart;
                        });
                      },
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.all(0),
                      child: Icon(
                        CupertinoIcons.ellipsis,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          _currentSpesa == null ? {} : _showOptions(context),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
