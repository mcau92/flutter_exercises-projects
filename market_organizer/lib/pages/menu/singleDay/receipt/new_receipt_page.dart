import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/new_receipt_input.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/single_product_insert_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/single_product_receipts_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/single_day_page_model.dart';
import 'package:market_organizer/service/navigation_service.dart';

//creo nuova ricetta da zero
class NewReceiptPage extends StatefulWidget {
  const NewReceiptPage({Key key}) : super(key: key);

  @override
  _NewReceiptPageState createState() => _NewReceiptPageState();
}

class _NewReceiptPageState extends State<NewReceiptPage> {
  NewReceiptInput _receiptInput;
  //
  GlobalKey<FormState> _formKey;
  TextEditingController _controller;
  //
  Ricetta _currentRicetta;
  Map<Product, bool> _newProductList = {};
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
      _newProductList.putIfAbsent(prod, () => inSpesa);
    });
  }

  //rimuovo prodotto dalla lista
  void removeProduct(Product product) {
    setState(() {
      _newProductList.remove(product);
    });
  }

  //aggiorno prodotto in lista
  void updateProduct(Product product, bool isToInsert, int index) {
    setState(() {
      //prima rimuovo prodotto poichè non ho l'id devo cercarlo per index con cui è stato creato  (guardare in fondo )
      int i = 0;
      for (var item in _newProductList.entries) {
        if (i == index) {
          _newProductList.remove(item);
        } else {
          i++;
        }
      }
      //aggiungo
      _newProductList.putIfAbsent(product, () => isToInsert);
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
    _currentRicetta.description = ""; //default essendo non obbligatoria
  }

  //funzione per creare la ricetta
  void _saveRecipt() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      //se non ci sono errori allora posso salvare, anche solo ricetta con nome e basta

      _currentRicetta = await DatabaseService.instance
          .createNewReceiptFromScratch(
              _currentRicetta,
              _receiptInput.singleDayPageInput,
              _receiptInput.pasto,
              _newProductList);

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

  //add new product
  void _addProduct() {
    NavigationService.instance.navigateToWithParameters(
        "singleProductInsertDetailPage",
        SingleProductInsertInput(
            insertNewProduct, _receiptInput.singleDayPageInput.workspaceId));
  }

  // funzione che controlla se ci sono prodotti e se l'utente prova a tornare indietro gli chiede se vuole eliminarli
  void _goback() async {
    if (_newProductList.length > 0) {
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
        ModalRoute.of(context).settings.arguments as NewReceiptInput;

    _currentRicetta = new Ricetta();

    //cancello e aggiorno i dati di id e nome
    _cleanRicettaData();
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
            _productListWidget(),
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
            _currentRicetta.description = text;
          });
          if (_isInsertSelected) _formKey.currentState.validate();
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
      _productAddButton()
    ]);
  }

  //

  Widget _productListWidget() {
    if (_newProductList.length > 0) {
      //mostro solo i prodotti da inserire
      List<Product> _prods = _newProductList.keys.toList();
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) {
          return Divider(
            height: 20,
            thickness: 0,
          );
        },
        itemCount: _prods.length,
        itemBuilder: (context, index) {
          return SingleProductReceiptsWidget(
              _prods[index],
              _newProductList[_prods[index]],
              removeProduct,
              updateProduct,
              index);
        },
      );
    } else {
      return Container();
    }
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
