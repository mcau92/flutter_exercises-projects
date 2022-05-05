import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/productOperationType.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/productInputForDb.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/product_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/product_search_widget.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:provider/provider.dart';

//classe usata per mostrare inserimento di un prodotto da zero
class ProductSearchInput {
  final Function?
      insertNewProduct; //gestisco sia insert che update di prodotto NON ancora salvato a db
  final String workspaceId;
  final ProductOperationType operationType;
  final String pasto;
  final DateTime date;
  ProductSearchInput(this.insertNewProduct, this.workspaceId,
      this.operationType, this.pasto, this.date);
}

class ProductSearchPage extends StatefulWidget {
  final ProductSearchInput input;

  const ProductSearchPage(this.input);
  @override
  ProductSearchPageState createState() => ProductSearchPageState();
}

class ProductSearchPageState extends State<ProductSearchPage> {
  late TextEditingController _textController;
  List<Product>? _products; //lista di prodotti trovati

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  void _updateResearch(String string) async {
    UserDataModel _currentUserData =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    if (string != "") {
      List<Product> _result = await DatabaseService.instance
          .searchProductByName(string, _currentUserData.id!);
      setState(() {
        _products = _result;
      });
    } else {
      setState(() {
        _products = [];
      });
    }
  }

  void _insertNewProduct() {
    //pagina di inserimento ricetta generale
    setState(() {
      _textController.text = "";
      _products = [];
    });
    NavigationService.instance.navigateToWithParameters(
      "productPageReceipt",
      ProductReceiptInput(
        widget.input
            .insertNewProduct, //nulla se sto inserendo un prodotto direttamente nel menu questo perchè poi gestisco l'inserimento direttamente dopo aggiornando il prodotto
        widget.input.workspaceId,
        null, //index nulla in fase di creazione
        null, //prodotto nullo in fase di creazione
        false, //default in fase di creazione
        widget.input.operationType,
        widget.input.date,
        widget.input.pasto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(43, 43, 43, 1),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
            onPressed: () => NavigationService.instance.goBack()),
        title: Text(
          "Prodotto",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.add, color: Colors.white),
            onPressed: () => _insertNewProduct(),
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(children: [_searchBar(), _resultRecipts()]);
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSearchTextField(
        controller: _textController,
        itemColor: Colors.white38,
        placeholder: "Ricerca un prodotto..",
        style: TextStyle(color: Colors.white),
        onChanged: (string) => _updateResearch(string),
      ),
    );
  }

  Widget _resultRecipts() {
    return _products != null ? Expanded(child: _productList()) : Container();
  }

//show prod
  void showProduct(Product product) {
    setState(() {
      _textController.text = "";
      _products = [];
    });
    NavigationService.instance.navigateToWithParameters(
        "productPageReceipt",
        ProductReceiptInput(
          widget.input.insertNewProduct,
          widget.input.workspaceId,
          null, //index nulla in fase di creazione
          product, //prodotto nullo in fase di creazione
          false, //default in fase di creazione
          widget.input.operationType,
          widget.input.date,
          widget.input.pasto,
        ));
  }

  Widget _productList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _products!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => showProduct(_products![index]),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: ProductSearchWidget(
                  _products![index],
                ),
              ),
            ),
          );
        });
  }
}
