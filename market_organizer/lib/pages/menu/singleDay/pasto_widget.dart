import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/productOperationType.dart';
import 'package:market_organizer/models/receiptOperationType.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/product_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/product_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/receipt_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/ricetta_widget.dart';
import 'package:market_organizer/service/navigation_service.dart';

class PastoWidget extends StatefulWidget {
  final String _pastoName;
  final RicettaManagementInput mealDetailModel;
  final Function(String pasto, bool isRicetta) showMealDetailsPage;
  PastoWidget(
    this._pastoName,
    this.mealDetailModel,
    void Function(String pasto, bool isRicetta) this.showMealDetailsPage,
  );

  @override
  State<PastoWidget> createState() => _PastoWidgetState();
}

class _PastoWidgetState extends State<PastoWidget> {
  bool expandFlag = false;
  void _showReceiptDetails(Ricetta _ricetta) async {
    //ricetta può essere nulla se sono in fase di creazione da zero altrimenti è valorizzata con quella selezionata
    Map<Product, bool> fetchedProd = await DatabaseService.instance
        .getProductsByReceiptWithDefaultFalseInSpesa(
            _ricetta.menuIdRef!, _ricetta.id!);
    NewSelectedReceiptInput receiptInput = new NewSelectedReceiptInput(
        ReceiptOperationType.UPDATE,
        _ricetta,
        fetchedProd,
        widget.mealDetailModel,
        widget._pastoName);
    Navigator.pushNamed(context, "receiptPage",
            arguments:
                receiptInput) //cosi facendo quando nelle pagine successivo faccio pop e arrivo a questa fa il refresh
        .then((value) => setState(() {}));
  }

  void _showProductDetails(Product _product) async {
    NavigationService.instance.navigateToWithParameters(
      "productPageReceipt",
      ProductReceiptInput(
        null, //gestisco la chiamata nella pagina stessa
        widget.mealDetailModel.workspaceId,
        null, //index nullo
        _product, //prodotto nullo in fase di creazione
        false, //default in fase di creazione
        ProductOperationType.UPDATE,
        _product.date,
        _product.pasto,
      ),
    );
  }

  void _showMealDetailsPage(bool isRicetta) {
    widget.showMealDetailsPage(widget._pastoName, isRicetta);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData().copyWith(unselectedWidgetColor: Colors.black),
      child: ExpansionTile(
        initiallyExpanded: true,
        iconColor: Colors.white,
        title: _titleBar(),
        children: [_body()],
      ),
    );
  }

  Widget _body() {
    return Container(
      padding: EdgeInsets.only(bottom: 15, right: 20, left: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Divider(
              color: Colors.white,
              height: 0,
            ),
            SizedBox(
              height: 10,
            ),
            widget.mealDetailModel.menuIdRef != null
                ? _ricettaList()
                : Container(),
            widget.mealDetailModel.menuIdRef != null
                ? _productsList()
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _titleBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _title(),
        _buttons(),
      ],
    );
  }

  Widget _title() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        widget._pastoName,
        style: TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buttons() {
    return Row(
      children: [
        TextButton(
            onPressed: () => _showMealDetailsPage(true),
            child: Text(
              "Ricetta",
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            )),
        TextButton(
          onPressed: () => _showMealDetailsPage(false),
          child: Text(
            "Prodotto",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.orange),
          ),
        ),
      ],
    );
  }

  //

  // conferma eliminazione prodotto
  Future<bool> _confirmDismissRicetta(BuildContext context) async {
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text("Confermi di rimuovere questa ricetta?"),
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

  Future<void> _deleteReceipt(Ricetta _ricetta) async {
    await DatabaseService.instance.deleteReceiptById(_ricetta);
  }

  Widget _ricettaList() {
    return StreamBuilder<List<Ricetta>>(
      stream: DatabaseService.instance.getReciptsFromMenuIdAndDateAndPasto(
          widget.mealDetailModel.menuIdRef!,
          widget.mealDetailModel.dateTimeDay!,
          widget.mealDetailModel.pasto!),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.orange,
            ),
          );
        } else {
          List<Ricetta> _ricette = snap.data!;
          return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 10,
                );
              },
              itemCount: _ricette.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showReceiptDetails(_ricette[index]),
                  //spostare qui il dismissable in modo da eliminare anche il pasto
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Dismissible(
                        child: SingleRicetta(_ricette[index]),
                        key: UniqueKey(),
                        onDismissed: (direction) =>
                            _deleteReceipt(_ricette[index]),
                        direction: DismissDirection.endToStart,
                        dismissThresholds: {DismissDirection.endToStart: 0.4},
                        confirmDismiss: (direction) =>
                            _confirmDismissRicetta(context),
                        background: Container(),
                        secondaryBackground: Container(
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10)),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: Icon(
                                CupertinoIcons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
        }
      },
    );
  }

  Future<bool> _confirmDismiss(BuildContext context) async {
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text("Confermi di rimuovere questo prodotto?"),
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

  Future<void> _removeProduct(Product product) async {
    await DatabaseService.instance.deleteProductInMenu(product);
  }

  Widget _productsList() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: StreamBuilder<List<Product>>(
        stream: DatabaseService.instance.getProductsFromMenuIdAndDateAndPasto(
            widget.mealDetailModel.menuIdRef!,
            widget.mealDetailModel.dateTimeDay!,
            widget.mealDetailModel.pasto!),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            );
          } else {
            List<Product> _products = snap.data!;
            return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 10,
                  );
                },
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showProductDetails(_products[index]),
                    //spostare qui il dismissable in modo da eliminare anche il pasto
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Dismissible(
                          child: ProductReceiptWidget(
                            _products[index],
                          ),
                          key: UniqueKey(),
                          onDismissed: (direction) =>
                              _removeProduct(_products[index]),
                          direction: DismissDirection.endToStart,
                          dismissThresholds: {DismissDirection.endToStart: 0.4},
                          confirmDismiss: (direction) =>
                              _confirmDismiss(context),
                          background: Container(),
                          secondaryBackground: Container(
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10)),
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
                        ),
                      ),
                    ),
                  );
                });
          }
        },
      ),
    );
  }
}
