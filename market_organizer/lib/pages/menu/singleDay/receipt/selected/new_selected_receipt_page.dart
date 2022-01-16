import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/selected/new_selected_receipt_input.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/selected/searchProduct/single_product_search_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/single_product_insert_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/single_product_receipts_widget.dart';
import 'package:market_organizer/service/navigation_service.dart';

class NewSelectedReceiptPage extends StatefulWidget {
  const NewSelectedReceiptPage({Key key}) : super(key: key);

  @override
  _NewSelectedReceiptPageState createState() => _NewSelectedReceiptPageState();
}

class _NewSelectedReceiptPageState extends State<NewSelectedReceiptPage> {
  NewSelectedReceiptInput _receiptInput;
  //
  GlobalKey<FormState> _formKey;
  TextEditingController _controller;
  //
  Ricetta _currentRicetta;
  //
  bool _isInsertSelected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _controller = TextEditingController();
    super.initState();
  }

  //aggiungo prodotto alla lista dei prodotti da inserire
  void insertNewProduct(Product prod, bool inSpesa) {
    setState(() {
      _receiptInput.productsFetched.putIfAbsent(prod, () => inSpesa);
    });
  }

  //creo una mappa di appoggio dove inserisco i prodotti che non sono stati rimossi. la uso quindi solo se valorizzata poichè vorrebbe dire che
  void removeProduct(Product product) {
    setState(() {
      _receiptInput.productsFetched.removeWhere((p, b) =>
          p.name == product.name && p.description == product.description);
    });
  }

  //aggiorno prodotto in lista
  void updateProduct(Product product, bool isToInsert, int index) {
    setState(() {
      //prima rimuovo prodotto poichè non ho l'id devo cercarlo per index con cui è stato creato  (guardare in fondo )
      int i = 0;
      for (var item in _receiptInput.productsFetched.entries) {
        if (i == index) {
          _receiptInput.productsFetched.remove(item);
        } else {
          i++;
        }
      }
      //aggiungo
      _receiptInput.productsFetched.putIfAbsent(product, () => isToInsert);
    });
  }

  /** creazione ricetta di default  */
  void _cleanRicettaData() {
    UserDataModel user = UserDataModel.example;
    _currentRicetta.id = null;
    _currentRicetta.ownerId = user.id;
    _currentRicetta.ownerName = user.name;
    _currentRicetta.date = _receiptInput.singleDayPageInput.dateTimeDay;
    _currentRicetta.menuIdRef = _receiptInput.singleDayPageInput
        .menuIdRef; //può essre nullo se sto creando la prima ricetta
    _currentRicetta.pasto = _receiptInput.pasto;
  }

  //funzione per creare la ricetta
  void _saveRecipt() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      //se non ci sono errori allora posso salvare,prima cancello i dati relativi alla ricetta, anche solo ricetta con nome e basta
      _cleanRicettaData();
      _currentRicetta = await DatabaseService.instance
          .createNewReceiptFromScratch(
              _currentRicetta,
              _receiptInput.singleDayPageInput,
              _receiptInput.pasto,
              _receiptInput.productsFetched);

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
                      _isInsertSelected = true;
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
        "singleProductSearchDetailPage",
        SingleProductSearchInput(
            insertNewProduct, _receiptInput.singleDayPageInput.workspaceId));
  }

  //add new product
  void _addProduct() {
    NavigationService.instance.navigateToWithParameters(
        "singleProductInsertDetailPage",
        SingleProductInsertInput(
            insertNewProduct, _receiptInput.singleDayPageInput.workspaceId));
  }

  // funzione che controlla se ci sono prodotti e se l'utente prova a tornare indietro gli chiede se vuole eliminarli
  void _goback() async {
    if (_receiptInput.productsFetched.length > 0) {
      await showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text(
                  "Tornando indietro perderai tutti i prodotti non salvati"),
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
    _receiptInput =
        ModalRoute.of(context).settings.arguments as NewSelectedReceiptInput;

    _currentRicetta = _receiptInput.selectedRecipt;

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
            child: Text("Inserisci"),
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
      initialValue: _currentRicetta.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Inserisci il nome della ricetta";
        } else {
          return null;
        }
      },
      style: TextStyle(color: Colors.white),
      onChanged: (text) {
        if (text != null && text.isNotEmpty) {
          setState(() {
            _currentRicetta.name = text;
          });
          if (_isInsertSelected) _formKey.currentState.validate();
        }
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
      onChanged: (text) {
        if (text != null && text.isNotEmpty) {
          setState(() {
            _currentRicetta.name = text;
          });
          if (_isInsertSelected) _formKey.currentState.validate();
        }
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

  Widget _productListWidget() {
    if (_currentRicetta.id != null) {
      if (_receiptInput.productsFetched.length > 0) {
        //mostro solo i prodotti da inserire
        List<Product> _prods = _receiptInput.productsFetched.keys.toList();
        return ListView.separated(
          separatorBuilder: (context, index) {
            return Divider(
              height: 20,
              thickness: 0,
            );
          },
          itemCount: _prods.length,
          itemBuilder: (context, index) {
            return Dismissible(
              child: SingleProductReceiptsWidget(
                  _prods[index],
                  _receiptInput.productsFetched[_prods[index]],
                  updateProduct,
                  index),
              key: UniqueKey(),
              onDismissed: (direction) => removeProduct(_prods[index]),
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
            );
          },
        );
      } else {
        return Container();
      }
    }
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
