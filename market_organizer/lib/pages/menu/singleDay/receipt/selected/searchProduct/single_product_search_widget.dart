import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/selected/searchProduct/single_product_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/single_product_update_widget.dart';
import 'package:market_organizer/service/navigation_service.dart';

//classe usata per mostrare inserimento di un prodotto da zero
class SingleProductSearchInput {
  Function
      insertNewProduct; //gestisco sia insert che update di prodotto NON ancora salvato a db
  String workspaceId;
  SingleProductSearchInput(this.insertNewProduct, this.workspaceId);
}

class SingleProductSearchWidget extends StatefulWidget {
  final SingleProductSearchInput input;

  const SingleProductSearchWidget(this.input);
  @override
  SingleProductSearchWidgetState createState() =>
      SingleProductSearchWidgetState();
}

class SingleProductSearchWidgetState extends State<SingleProductSearchWidget> {
  TextEditingController _textController;
  List<Product> _products; //lista di prodotti trovati

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  void _updateResearch(String string) async {
    if (string != null && string != "") {
      List<Product> _result =
          await DatabaseService.instance.searchProductByName(string);
      setState(() {
        _products = _result;
      });
    } else {
      setState(() {
        _products = [];
      });
    }
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
          "Cerca Prodotto",
          style: TextStyle(color: Colors.white),
        ),
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

  Widget _productList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleProductWidget(
                _products[index], widget.input.insertNewProduct),
          );
        });
  }
}
