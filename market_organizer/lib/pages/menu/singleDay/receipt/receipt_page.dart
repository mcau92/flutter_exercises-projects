import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/productOperationType.dart';
import 'package:market_organizer/models/receiptOperationType.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/productSearch_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/product_page.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/product_widget.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:provider/provider.dart';

//input

class NewSelectedReceiptInput {
  final ReceiptOperationType operationType;
  final Ricetta? selectedRecipt;
  Map<Product, bool>?
      productsFetched; //prodotti da usare per cancellare aggioranre ecc in fase di inserimento da ricerca di ricetta
  final RicettaManagementInput
      mealDetailModel; //nullo se in fase di aggiornamento/dettaglio ricetta
  final String pasto; //nullo se in fase di aggiornamento/dettaglio

  NewSelectedReceiptInput(this.operationType, this.selectedRecipt,
      this.productsFetched, this.mealDetailModel, this.pasto);
}

class NewSelectedReceiptPage extends StatefulWidget {
  final NewSelectedReceiptInput _input;

  const NewSelectedReceiptPage(this._input);

  @override
  _NewSelectedReceiptPageState createState() => _NewSelectedReceiptPageState();
}

class _NewSelectedReceiptPageState extends State<NewSelectedReceiptPage> {
  //
  late GlobalKey<FormState> _formKey;
  late TextEditingController _controller;
  //
  bool _isValidationFormAlreadyCalled =
      false; //serve per refreshare le validation dopo che vengono mostrate
  //
  Ricetta _currentRicetta = new Ricetta();
  //
  int _countProductToBeInserted =
      0; //mantengo anche qui i prodotti da inserire in modo da poter vedere se ho avuto modifiche
  //
  List<Product> _productToBeDeleted = []; //prodotti da eliminare

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _controller = TextEditingController();
    _initRicetta(widget._input.selectedRecipt);
    super.initState();
  }

  //aggiungo prodotto alla lista dei prodotti da inserire
  void insertNewProduct(Product prod, bool inSpesa) {
    setState(() {
      if (widget._input.productsFetched == null) {
        widget._input.productsFetched = {};
      }
      widget._input.productsFetched!.putIfAbsent(prod, () => inSpesa);
      _countProductToBeInserted++;
    });
  }

  void removeProduct(Product product, int index) {
    if (product.id == null) {
      _countProductToBeInserted--;
    } else {
      //salvo il prodotto nella lista dei prodotti da cancellare cosi una volta che l'utente conferma lo cancellerò definitivamente

      _productToBeDeleted.add(product);
    }
    //lo rimuovo dalla lista da visualizzare
    //per cancellare devo creare una mappa di appoggio, per ogni prodotto in mappa lo aggiungo tranne quello con index in posizione
    Map<Product, bool> productsFetchedSupport = {};
    for (int i = 0; i < widget._input.productsFetched!.length; i++) {
      if (i != index) {
        productsFetchedSupport.putIfAbsent(
            widget._input.productsFetched!.keys.toList()[i],
            () => widget._input.productsFetched!.values.toList()[i]);
      }
    }
    setState(() {
      widget._input.productsFetched = productsFetchedSupport;
    });
  }

  //aggiorno prodotto in lista
  void updateProduct(Product product, bool isToInsert, int index) {
    setState(() {
      //prima rimuovo prodotto poichè non ho l'id devo cercarlo per index con cui è stato creato  (guardare in fondo )
      int i = 0;
      for (var item in widget._input.productsFetched!.entries) {
        if (i == index) {
          widget._input.productsFetched!.remove(item);
        } else {
          i++;
        }
      }
      //aggiungo
      widget._input.productsFetched!.putIfAbsent(product, () => isToInsert);
    });
  }

  /** creazione ricetta di default  */
  void _initRicetta(Ricetta? _preloadedReceipt) {
    //se sono in fase di ricerca ricetta o creazione da zero inizializzo i dati di default,
    //se in fase di aggiornamento non devo far nulla

    UserDataModel _currentUserData =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    if (widget._input.operationType == ReceiptOperationType.SEARCH) {
      _currentRicetta.id = null;
      _currentRicetta.ownerId = _currentUserData.id;
      _currentRicetta.ownerName = _currentUserData.name;
      _currentRicetta.color = _preloadedReceipt!.color;
      _currentRicetta.name = _preloadedReceipt.name;
      _currentRicetta.description = _preloadedReceipt.description;
      _currentRicetta.pasto = _preloadedReceipt.pasto;
      _currentRicetta.date = widget._input.mealDetailModel.dateTimeDay;
      _currentRicetta.image = _preloadedReceipt
          .image; //può essre nullo se sto creando la prima ricetta
      _currentRicetta.menuIdRef = widget._input.mealDetailModel
          .menuIdRef; //può essre nullo se sto creando la prima ricetta
    } else if (widget._input.operationType == ReceiptOperationType.INSERT) {
      _currentRicetta = new Ricetta();
      _currentRicetta.id = null;
      _currentRicetta.ownerId = _currentUserData.id;
      _currentRicetta.ownerName = _currentUserData.name;
      _currentRicetta.pasto = widget._input.pasto;
      _currentRicetta.date = widget._input.mealDetailModel.dateTimeDay;
    } else {
      //travaso i dati della ricetta in quella nuova cosi poi posso confrontarle
      _currentRicetta.id = _preloadedReceipt!.id;
      _currentRicetta.ownerId = _preloadedReceipt.ownerId;
      _currentRicetta.ownerName = _preloadedReceipt.name;
      _currentRicetta.color = _preloadedReceipt.color;
      _currentRicetta.name = _preloadedReceipt
          .name; //può essre nullo se sto creando la prima ricetta
      _currentRicetta.description = _preloadedReceipt.description;
      _currentRicetta.pasto = _preloadedReceipt.pasto;
      _currentRicetta.date = _preloadedReceipt.date;
      _currentRicetta.image = _preloadedReceipt
          .image; //può essre nullo se sto creando la prima ricetta
      _currentRicetta.menuIdRef = _preloadedReceipt.menuIdRef;
    }
  }

  //funzione per creare la ricetta
  void _saveRecipt() async {
    UserDataModel _currentUserData =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      if (widget._input.operationType == ReceiptOperationType.UPDATE) {
        DateTime dateTimeStart =
            Provider.of<DateProvider>(context, listen: false).dateStart;
        DateTime dateTimeEnd =
            Provider.of<DateProvider>(context, listen: false).dateStart;
        DatabaseService.instance.updateRecipts(
            widget._input.mealDetailModel.workspaceId!,
            _currentRicetta,
            widget._input.productsFetched!,
            _productToBeDeleted,
            dateTimeStart,
            dateTimeEnd,
            _currentUserData.id!);
      } else {
        _currentRicetta = await DatabaseService.instance
            .createNewReceiptFromScratch(
                _currentRicetta,
                widget._input.mealDetailModel,
                widget._input.productsFetched,
                _currentUserData.id!);
      }
      NavigationService.instance.goBackUntil("singleDay");
    } else {
      return await showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text("I dati inseriti non sono validi, ricontrolla"),
              actions: [
                CupertinoDialogAction(
                  child: Text("Ho Capito"),
                  onPressed: () {
                    setState(() {
                      _isValidationFormAlreadyCalled = true;
                    });
                    Navigator.of(
                      ctx,
                      // rootNavigator: true,
                    ).pop(true);
                  },
                ),
              ],
            );
          });
    }
  }
//search product

//search
  void _searchProduct() {
    NavigationService.instance.navigateToWithParameters(
      "productSearchPage",
      ProductSearchInput(
        insertNewProduct,
        widget._input.mealDetailModel.workspaceId!,
        ProductOperationType.INSERT_FROM_RECEIPT,
        widget._input.mealDetailModel.pasto!,
        widget._input.mealDetailModel.dateTimeDay!,
      ),
    );
  }

  //add new product
  void _addProduct() {
    NavigationService.instance.navigateToWithParameters(
      "productPageReceipt",
      ProductReceiptInput(
        insertNewProduct,
        widget._input.mealDetailModel.workspaceId,
        null, //index nulla in fase di creazione
        null, //prodotto nullo in fase di creazione
        true, //default in fase di creazione
        ProductOperationType.INSERT_FROM_RECEIPT, null, null,
      ),
    );
  }

  // funzione che controlla se ci sono prodotti e se l'utente prova a tornare indietro gli chiede se vuole eliminarli
  void _goback() async {
    //ricetta nuova quindi in input nulla
    if ((widget._input.selectedRecipt == null &&
            _countProductToBeInserted > 0) ||
        (widget._input.selectedRecipt != null &&
            (_countProductToBeInserted > 0 ||
                _productToBeDeleted.isNotEmpty ||
                (_currentRicetta != null &&
                    _currentRicetta.name != null &&
                    _currentRicetta.name !=
                        widget._input.selectedRecipt!.name!) ||
                (_currentRicetta != null &&
                    _currentRicetta.description != null &&
                    _currentRicetta.description !=
                        widget._input.selectedRecipt!.description!)))) {
      await showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text(
                  "Tornando indietro perderai tutte le modifiche apportate"),
              actions: [
                CupertinoDialogAction(
                  child: Text("Annulla"),
                  onPressed: () {
                    Navigator.of(
                      ctx,
                      // rootNavigator: true,
                    ).pop(true);
                  },
                ),
                CupertinoDialogAction(
                  child: Text("Conferma"),
                  onPressed: () {
                    Navigator.of(
                      ctx,
                      // rootNavigator: true,
                    ).pop(true);
                    NavigationService.instance.goBack();
                  },
                ),
              ],
            );
          });
    } else {
      NavigationService.instance.goBack();
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(43, 43, 43, 1),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () => _goback(),
        ),
        actions: [
          CupertinoButton(
            child: Text(
                widget._input.operationType == ReceiptOperationType.UPDATE
                    ? "Aggiorna"
                    : "Inserisci"),
            onPressed: () => _saveRecipt(),
          )
        ],
        title: Text(
          "Crea la Ricetta",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _body(),
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20.0, right: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _reciptContainer(),
            SizedBox(height: 20),
            _productTitle(),
            SizedBox(height: 10),
            Expanded(child: _productListWidget()),
          ],
        ),
      ),
    );
  }

  Widget _reciptContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(52, 52, 52, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _receiptName(),
          _receiptDescription(),
        ],
      ),
    );
  }

  Widget _receiptName() {
    return TextFormField(
      keyboardType: TextInputType.text,
      initialValue: _currentRicetta.name,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Inserisci il nome della ricetta";
        } else {
          return null;
        }
      },
      style: TextStyle(color: Colors.white),
      onChanged: (text) {
        setState(() {
          _currentRicetta.name = text;
        });
        if (_isValidationFormAlreadyCalled) _formKey.currentState!.validate();
      },
      onSaved: (text) {
        if (text != null && text.isNotEmpty) {
          setState(() {
            _currentRicetta.name = text;
          });
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        fillColor: Colors.white,
        hintText: "Nome Ricetta",
        hintStyle: TextStyle(color: Colors.white24),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.white12,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.white12,
          ),
        ),
      ),
    );
  }

  Widget _receiptDescription() {
    return TextFormField(
      initialValue: _currentRicetta.description,
      style: TextStyle(color: Colors.white),
      textCapitalization: TextCapitalization.sentences,
      onChanged: (text) {
        if (text != null && text.isNotEmpty) {
          setState(() {
            _currentRicetta.description = text;
          });
          if (_isValidationFormAlreadyCalled) _formKey.currentState!.validate();
        }
      },
      onSaved: (text) {
        if (text != null && text.isNotEmpty) {
          setState(() {
            _currentRicetta.description = text;
          });
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        fillColor: Colors.white,
        hintText: "Descrizione (opzionale)",
        hintStyle: TextStyle(color: Colors.white24),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }

  //
  Widget _productTitle() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Prodotti",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      Row(
        children: [
          _searchProductButton(),
          SizedBox(
            width: 10,
          ),
          _productAddButton()
        ],
      ),
    ]);
  }

  //
  Future<bool> _confirmDismiss(BuildContext context) async {
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
                "Sicuro di rimuovere questo elemento? per confermare dovrai aggiornare la ricetta"),
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

//show prod
  void showProduct(int index, Product product, bool isAddToSpesa) {
    NavigationService.instance.navigateToWithParameters(
        "productPageReceipt",
        ProductReceiptInput(
          updateProduct,
          widget._input.mealDetailModel.workspaceId,
          index,
          product, //prodotto nullo in fase di creazione
          isAddToSpesa, //default in fase di creazione
          ProductOperationType.UPDATE_FROM_RECEIPT,
          null, null,
        ));
  }

  Widget _productListWidget() {
    if (widget._input.productsFetched != null &&
        widget._input.productsFetched!.length > 0) {
      //mostro solo i prodotti da inserire
      List<Product> _prods = widget._input.productsFetched!.keys.toList();
      if (_prods != null && _prods.isNotEmpty) {
        return ListView.separated(
          separatorBuilder: (context, index) {
            return Divider(
              height: 20,
              thickness: 0,
            );
          },
          itemCount: _prods.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => showProduct(index, _prods[index],
                  widget._input.productsFetched![_prods[index]]!),
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
                        _prods[index] //sto aggiornando il prodotto
                        ),
                    key: UniqueKey(),
                    onDismissed: (direction) =>
                        removeProduct(_prods[index], index),
                    direction: DismissDirection.startToEnd,
                    dismissThresholds: {DismissDirection.startToEnd: 0.3},
                    confirmDismiss: (direction) => _confirmDismiss(context),
                    background: Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10)),
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
                  ),
                ),
              ),
            );
          },
        );
      }
    }
    //else
    return Container();
  }

  Widget _searchProductButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: CupertinoButton(
        color: Color.fromRGBO(52, 52, 52, 1),
        padding: EdgeInsets.all(2),
        onPressed: () => _searchProduct(),
        child: Icon(Icons.search, color: Colors.white24),
      ),
    );
  }

  Widget _productAddButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: CupertinoButton(
        color: Color.fromRGBO(52, 52, 52, 1),
        padding: EdgeInsets.all(2),
        onPressed: () => _addProduct(),
        child: Icon(Icons.add, color: Colors.white24),
      ),
    );
  }
}
