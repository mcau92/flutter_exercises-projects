import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/show/show_recipt_input.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/show/single_product_insert_show_widget.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/show/single_product_receipts_show_widget.dart';
import 'package:market_organizer/service/navigation_service.dart';

class ShowReceiptPage extends StatefulWidget {
  const ShowReceiptPage({Key key}) : super(key: key);

  @override
  _ShowReceiptPageState createState() => _ShowReceiptPageState();
}

class _ShowReceiptPageState extends State<ShowReceiptPage> {
  ShowReceiptInput _receiptInput;
  //
  GlobalKey<FormState> _formKey;
  TextEditingController _controller;
  //
  Ricetta _currentRicetta;
  //
  bool _isInsertSelected = false;
  bool _isRicettaUpdated =
      false; //controllo se l'utente ha aggiornato la ricetta
  String _name = "";
  String _description = "";

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

  //funzione per creare la ricetta
  void _updateReceipt() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      //se non ci sono errori allora posso salvare, anche solo ricetta con nome e basta
      _currentRicetta.name = _name;
      _currentRicetta.description = _description;
      await DatabaseService.instance.updateRecipts(
        _receiptInput.workspaceId,
        _currentRicetta,
      );

      NavigationService.instance.goBack();
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
        "singleProductInsertShowDetailPage",
        SingleProductInsertShownIput(
            _currentRicetta.menuIdRef,
            _receiptInput.workspaceId,
            _currentRicetta.id,
            _currentRicetta.color));
  }

  // funzione che controlla se ci sono prodotti e se l'utente prova a tornare indietro gli chiede se vuole eliminarli
  void _goback() async {
    NavigationService.instance.goBack();
  }

  //
  @override
  Widget build(BuildContext context) {
    _receiptInput =
        ModalRoute.of(context).settings.arguments as ShowReceiptInput;

    _currentRicetta = _receiptInput.ricetta;
    _name = _currentRicetta.name;
    _description = _currentRicetta.description;

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
            child: _isRicettaUpdated
                ? Text("Aggiorna")
                : Text("Aggiorna",
                    style: TextStyle(
                        color: Theme.of(context)
                            .buttonTheme
                            .colorScheme
                            .primary
                            .withOpacity(0.2))),
            onPressed: () => _isRicettaUpdated ? _updateReceipt() : {},
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
        if (text != null) {
          setState(() {
            if (text.trim() != _currentRicetta.name) {
              _isRicettaUpdated = true;
            } else {
              _isRicettaUpdated = false;
            }
            _name = text;
          });
          if (_isInsertSelected) _formKey.currentState.validate();
        }
      },
      onSaved: (text) {
        if (text != null) {
          setState(() {
            if (text.trim() != _currentRicetta.name.trim()) {
              _isRicettaUpdated = true;
            } else {
              _isRicettaUpdated = false;
            }
            _name = text;
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
        if (text != null) {
          setState(() {
            if (text.trim() != _currentRicetta.description.trim()) {
              _isRicettaUpdated = true;
            } else {
              _isRicettaUpdated = false;
            }
            _description = text;
          });
          if (_isInsertSelected) _formKey.currentState.validate();
        }
      },
      onSaved: (text) {
        if (text != null) {
          setState(() {
            if (text.trim() != _currentRicetta.description.trim()) {
              _isRicettaUpdated = true;
            } else {
              _isRicettaUpdated = false;
            }
            _description = text;
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
    if (_currentRicetta.id != null) {
      return StreamBuilder<List<Product>>(
          stream: DatabaseService.instance.getProductsByRecipt(
              _currentRicetta.menuIdRef, _currentRicetta.id),
          builder: (context, _snapshot) {
            //se trovo prodotti

            List<Product> _prods = [];
            if (_snapshot.hasData) {
              _prods = _snapshot.data;
            }
            return ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  height: 20,
                  thickness: 0,
                );
              },
              itemCount: _prods.length,
              itemBuilder: (context, index) {
                return SingleProductReceiptsShowWidget(
                    _currentRicetta.menuIdRef, _prods[index]);
              },
            );
          });
    }
    return Container();
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
