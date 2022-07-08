import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/productOperationType.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/product_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/product_search_widget.dart';
import 'package:market_organizer/pages/spesa/single_product_detail_page.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:provider/provider.dart';

//classe usata per mostrare inserimento di un prodotto da zero
class ProductSpesaSearchInput {
  final String worksapceId; //sempre presente per ricercare prodotti in db
  final Spesa? _currentSpesa; //può essere nulla se primo inserimento
  ProductSpesaSearchInput(this.worksapceId, this._currentSpesa);
}

class ProductSpesaSearchPage extends StatefulWidget {
  final ProductSpesaSearchInput input;

  const ProductSpesaSearchPage(this.input);
  @override
  ProductSpesaSearchPageState createState() => ProductSpesaSearchPageState();
}

class ProductSpesaSearchPageState extends State<ProductSpesaSearchPage> {
  late TextEditingController _textController;
  bool isSearchStarted = false;
  List<Product>? _products; //lista di prodotti trovati
  List<Product>?
      _histroryProducts; //lista prodotti recuperati senza filtro da parte dell'utente
  List<Product>?
      _histroryProductsFiltered; //lista prodotti filtrata con la barra

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  void _searchProductResearch(String string) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.focusedChild?.unfocus();
    }
    UserDataModel _currentUserData =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    if (string != "") {
      List<Product> _result = await DatabaseService.instance
          .searchProductByName(string, _currentUserData.id!);
      setState(() {
        isSearchStarted = true;
        _products = _result;
      });
    } else {
      setState(() {
        _products = [];
      });
    }
  }

  void _updateResearch(String string) async {
    if (isSearchStarted) {
      setState(() {
        isSearchStarted = false;
      });
    }
    setState(() {
      _histroryProductsFiltered = _histroryProducts!
          .where((prod) => prod.name!.startsWith(string))
          .toList();
    });
  }

  void _insertNewProduct() {
    //pagina di inserimento ricetta generale
    setState(() {
      _textController.text = "";
      isSearchStarted = false;
      _products = [];
    });
    NavigationService.instance
        .navigateToWithParameters("addSpesaPage", widget.input._currentSpesa)
        .then((value) => NavigationService.instance.goBack());
  }

  //show prod
  void showProduct(Product product) {
    setState(() {
      _textController.text = "";
      _products = [];
    });
    //update product info for new user
    UserDataModel _currentUserData =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    product.id = null;
    product.ownerId = _currentUserData.id;
    product.ownerName = _currentUserData.name;
    product.spesaIdRef = widget.input._currentSpesa == null
        ? null
        : widget.input._currentSpesa!.id;
    NavigationService.instance
        .navigateToWithParameters(
            "singleProductDetailPage",
            SingleProductDetailPageInput(
                widget.input.worksapceId, widget.input._currentSpesa, product))
        .then((value) => NavigationService.instance.goBack());
    ;
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
    return Column(
      children: [
        _searchBar(),
        if (isSearchStarted) _customDivider("Risultati della ricerca"),
        if (isSearchStarted) _suggestedProductsListContainer(),
        if (!isSearchStarted) _customDivider("Storico"),
        if (!isSearchStarted)
          _textController.text.isNotEmpty
              ? _historyProductsList(_histroryProductsFiltered!)
              : _historyProductsListContainer(),
        if (!isSearchStarted && _textController.text.isNotEmpty)
          _showSearchProductTab()
      ],
    );
  }

  Widget _showSearchProductTab() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.search,
            color: Colors.white,
            size: 18,
          ),
          CupertinoButton(
              child: Text(
                  "Cerca tutti i prodotti per: '" + _textController.text + "'"),
              onPressed: () => _searchProductResearch(_textController.text)),
        ],
      ),
    );
  }

  Widget _customDivider(String text) {
    return Container(
      color: Color.fromRGBO(43, 43, 43, 1),
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 7),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 0.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CupertinoSearchTextField(
        controller: _textController,
        itemColor: Colors.white38,
        placeholder: "Ricerca un prodotto..",
        style: TextStyle(color: Colors.white),
        onChanged: (string) => _updateResearch(string),
      ),
    );
  }

  Widget _suggestedProductsListContainer() {
    return _suggestedProductsList();
  }

  Widget _historyProductsListContainer() {
    DateProvider dateProvider = Provider.of<DateProvider>(context);
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    return StreamBuilder<List<Product>>(
        stream: DatabaseService.instance.getHistoryProducts30days(
            authProvider.user!.uid, dateProvider.dateEnd),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(snapshot.connectionState);
            List<Product> prodWithoutDuplicate = [];
            snapshot.data!.forEach((prod) {
              if (prodWithoutDuplicate
                      .where((prod2) => prod2.isEqualToAnother(prod))
                      .length ==
                  0) {
                prodWithoutDuplicate.add(prod);
              }
            });

            _histroryProducts = prodWithoutDuplicate;
            return _historyProductsList(_histroryProducts!);
          } else {
            return Container();
          }
        });
  }

  Widget _historyProductsList(List<Product> historyProducts) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: historyProducts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () => showProduct(historyProducts[index]),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: ProductSearchWidget(
                  historyProducts[index],
                ),
              ),
            ),
          );
        });
  }

  Widget _suggestedProductsList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: _products!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
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
