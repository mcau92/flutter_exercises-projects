import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/productOperationType.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/productInputForDb.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/measure_unit_list.dart';

//classe usata per mostrare inserimento di un prodotto da zero
class ProductReceiptInput {
  final Function
      manageNewProductAction; //gestisco sia insert che update di prodotto NON ancora salvato a db
  final String workspaceId; //nullo se in fase di aggiornamento
  final int indexKey;
  final Product product; //valorizzato in fase di aggiornamento
  bool isAddToSpesa; //valorizzato se sto ancora inserendo il prodotto
  final ProductOperationType
      operationType; // specifico quale operazione sto per effettuare
  final String
      pasto; //valorizzati e usati se devo inserire prodotto direttamente in menu
  final DateTime date; //valorizzato e usato se devo inserire prodotto in menu
  ProductReceiptInput(
      this.manageNewProductAction,
      this.workspaceId,
      this.indexKey,
      this.product,
      this.isAddToSpesa,
      this.operationType,
      this.date,
      this.pasto);
}

class ProductReceiptPage extends StatefulWidget {
  final ProductReceiptInput input;

  const ProductReceiptPage(this.input);
  @override
  ProductReceiptPageState createState() => ProductReceiptPageState();
}

class ProductReceiptPageState extends State<ProductReceiptPage> {
  GlobalKey<FormState> _formKey;
  TextEditingController _measureController;
  TextEditingController _typeAheadController;

  String _productName = "";
  String _productDescription = "nessuna descrizione";
  String _productReparto;
  double _quantity = 0.0;
  String _measureUnit = "";
  bool _isInsertSelected = false;
  double _price = 0;
  String _currency = "€";

  @override
  void dispose() {
    _measureController.dispose();
    _typeAheadController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _measureController = widget.input.product != null
        ? TextEditingController(text: widget.input.product.measureUnit)
        : TextEditingController();
    _typeAheadController = widget.input.product != null
        ? TextEditingController(text: widget.input.product.reparto)
        : TextEditingController();

    initProd();
    super.initState();
  }

  void initProd() {
    if (widget.input.product != null) {
      _productName = widget.input.product.name;
      _productDescription = widget.input.product.description;
      _productReparto = widget.input.product.reparto;
      _price = widget.input.product.price;
      _quantity = widget.input.product.quantity;
      _measureUnit = widget.input.product.measureUnit;
    }
  }

  bool _isSaveValid() {
    _formKey.currentState.save();
    return _formKey.currentState.validate();
  }

  void _showNoUpdateDialog() async {
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

  void _saveProduct() async {
    if (widget.input.operationType == ProductOperationType.INSERT ||
        widget.input.operationType ==
            ProductOperationType.INSERT_FROM_RECEIPT) {
      //retrive the color for the new product
      String _color = await DatabaseService.instance
          .getUserColor(widget.input.workspaceId, UserDataModel.example.id);
      print(_color);
      Product _product = new Product();
      _product.ownerId = UserDataModel.example.id;
      _product.ownerName = UserDataModel.example.name;
      _product.name = _productName;
      _product.description = _productDescription;
      _product.reparto = _productReparto;
      _product.measureUnit = _measureUnit;
      _product.quantity = _quantity;
      _product.currency = _currency;
      _product.price = _price;
      _product.color = _color;

//inserisco direttamente in menu
      if (widget.input.operationType == ProductOperationType.INSERT) {
        _product.pasto = widget.input.pasto;
        _product.date = widget.input.date;
        await DatabaseService.instance.insertNewProductInMenu(
            ProductInputForDb(_product, widget.input.workspaceId),
            widget.input.isAddToSpesa);
        NavigationService.instance.goBackUntil("singleDay");
      } else {
        widget.input.manageNewProductAction(
            _product, widget.input.isAddToSpesa); //sto inserendo

        NavigationService.instance.goBack();
      }
    } else {
      widget.input.product.name = _productName;
      widget.input.product.description = _productDescription;
      widget.input.product.reparto = _productReparto;
      widget.input.product.measureUnit = _measureUnit;
      widget.input.product.quantity = _quantity;
      widget.input.product.price = _price;

      if (widget.input.operationType == ProductOperationType.UPDATE) {
        await DatabaseService.instance.updateProductOnMenu(
            ProductInputForDb(widget.input.product, widget.input.workspaceId));
        NavigationService.instance.goBackUntil("singleDay");
      } else {
        widget.input.manageNewProductAction(widget.input.product,
            widget.input.isAddToSpesa, widget.input.indexKey); //sto aggiornando

        NavigationService.instance.goBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(43, 43, 43, 1),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
            onPressed: () => NavigationService.instance.goBack(),
          ),
          actions: [
            CupertinoButton(
              child: Text(
                  widget.input.operationType == ProductOperationType.INSERT ||
                          widget.input.operationType ==
                              ProductOperationType.INSERT_FROM_RECEIPT
                      ? "Inserisci"
                      : "Fatto"),
              onPressed: () =>
                  _isSaveValid() ? _saveProduct() : _showNoUpdateDialog(),
            )
          ],
          title: Text(
            "Aggiorna Prodotto",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: _body(),
        backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      ),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20.0, right: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _toSpesaSwitch(),
            SizedBox(height: 10),
            _descriptionContainer(),
            widget.input.isAddToSpesa ? SizedBox(height: 50) : Container(),
            widget.input.isAddToSpesa
                ? _productRepartoContainer()
                : Container(),
            SizedBox(height: 50),
            _quantityContainer(),
            SizedBox(height: 50),
            widget.input.isAddToSpesa ? _priceContainer() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _toSpesaSwitch() {
    return Row(
      children: [
        Text(
          "Aggiungi in Spesa corrente",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        Transform.scale(
          scale: 0.8,
          child: CupertinoSwitch(
            value: widget.input.isAddToSpesa,
            onChanged: (bool value) {
              setState(() {
                widget.input.isAddToSpesa = value;
              });
            },
          ),
        )
      ],
    );
  }

  Widget _descriptionContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(52, 52, 52, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _productNameWidget(),
          _productDescriptionWidget(),
        ],
      ),
    );
  }

  Widget _productNameWidget() {
    return TextFormField(
      initialValue:
          widget.input.product != null ? widget.input.product.name : "",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Inserisci il nome del prodotto";
        } else {
          return null;
        }
      },
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(color: Colors.white),
      onChanged: (text) {
        if (_isInsertSelected) _formKey.currentState.validate();
      },
      onSaved: ((text) {
        setState(() {
          _productName = text;
        });
      }),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        fillColor: Colors.white,
        hintText: "Nome",
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

  Widget _productDescriptionWidget() {
    return TextFormField(
      initialValue: widget.input.product != null &&
              widget.input.product.description != null
          ? widget.input.product.description
          : "",
      onSaved: ((text) {
        setState(() {
          _productDescription = text;
        });
      }),
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        fillColor: Colors.white,
        hintText: "Descrizione (opzionale)",
        errorStyle: TextStyle(
          height: 1.5,
        ),
        hintStyle: TextStyle(color: Colors.white24),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }

  Widget _productRepartoContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(52, 52, 52, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: _productRepartoForm(),
    );
  }

  Widget _productRepartoForm() {
    return TypeAheadFormField(
      initialValue: null,
      textFieldConfiguration: TextFieldConfiguration(
        controller: this._typeAheadController,
        style: TextStyle(
          color: Colors.white,
        ),
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          fillColor: Colors.white,
          hintText: "Reparto",
          errorStyle: TextStyle(
            height: 1.5,
          ),
          hintStyle: TextStyle(color: Colors.white24),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
      suggestionsCallback: (pattern) {
        return DatabaseService.instance
            .getUserRepartiByInput(pattern, UserDataModel.example.id);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (suggestion) {
        this._typeAheadController.text = suggestion;
      },
      transitionBuilder: (context, suggestionsBox, animationController) =>
          FadeTransition(
        child: suggestionsBox,
        opacity: CurvedAnimation(
            parent: animationController, curve: Curves.fastOutSlowIn),
      ),
      hideOnEmpty: true,
      hideOnLoading: true,
      suggestionsBoxDecoration:
          SuggestionsBoxDecoration(borderRadius: BorderRadius.circular(10)),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Inserisci il reparto del prodotto";
        } else {
          return null;
        }
      },
      onSaved: (text) {
        setState(() {
          _productReparto = text;
        });
        if (_isInsertSelected) _formKey.currentState.validate();
      },
    );
  }

  Widget _quantityContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(52, 52, 52, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _productQuantity(),
          _productMeasure(),
        ],
      ),
    );
  }

  Widget _productQuantity() {
    return TextFormField(
      initialValue:
          widget.input.product != null && widget.input.product.quantity != null
              ? widget.input.product.quantity.toString()
              : "",
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            double.tryParse(value) == null ||
            double.parse(value) == 0) {
          return "Inserisci una quantità valida";
        } else
          return null;
      },
      onChanged: (text) {
        if (_isInsertSelected) _formKey.currentState.validate();
      },
      onSaved: (text) {
        if (text != null && text.isNotEmpty && double.tryParse(text) != null) {
          setState(() {
            _quantity = double.parse(text);
          });
        }
      },
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        fillColor: Colors.white,
        hintText: "Quantità",
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

  void _showCupertinoPicker() {
    FocusScope.of(context).requestFocus(new FocusNode());
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return Container(
            height: 200,
            color: Colors.grey,
            child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: _measureUnit == null || _measureUnit.isEmpty
                      ? 0
                      : MeasureUnitList.units.keys
                          .toList()
                          .indexOf(_measureUnit),
                ),
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  String key = MeasureUnitList.units.keys.toList()[index];
                  if (key == "nessun valore") {
                    setState(() {
                      _measureUnit = "";
                      this._measureController.text = _measureUnit;
                    });
                  } else {
                    setState(() {
                      _measureUnit = key;
                      this._measureController.text = _measureUnit;
                    });
                  }

                  if (_isInsertSelected) _formKey.currentState.validate();
                },
                children: MeasureUnitList.units.keys.map((v) {
                  return Center(child: Text(v));
                }).toList()),
          );
        });
  }

  Widget _productMeasure() {
    return TextFormField(
      controller: this._measureController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Seleziona un'unità di misura";
        } else {
          return null;
        }
      },
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        errorStyle: TextStyle(
          height: 1.5,
        ),
        fillColor: Colors.white,
        hintText: "Unità di Misura",
        hintStyle: TextStyle(color: Colors.white24),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
      ),
      onTap: () => _showCupertinoPicker(),
    );
  } //price

  Widget _priceContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(52, 52, 52, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _priceSection(),
          //_currencyMeasure(),
        ],
      ),
    );
  }

  Widget _priceSection() {
    return TextFormField(
      initialValue:
          widget.input.product != null && widget.input.product.price != null
              ? widget.input.product.price.toString()
              : null,
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            double.tryParse(value) == null ||
            double.parse(value) == 0) {
          return "Inserisci una quantità valida";
        } else
          return null;
      },
      onChanged: (text) {
        if (_isInsertSelected) _formKey.currentState.validate();
      },
      onSaved: (text) {
        if (text != null && text.isNotEmpty && double.tryParse(text) != null) {
          setState(() {
            _price = double.parse(text);
          });
          if (_isInsertSelected) _formKey.currentState.validate();
        }
      },
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        fillColor: Colors.white,
        hintText: "Prezzo",
        hintStyle: TextStyle(color: Colors.white24),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}
