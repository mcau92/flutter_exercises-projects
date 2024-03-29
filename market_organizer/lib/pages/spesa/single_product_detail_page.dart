import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/category_enum.dart';
import 'package:market_organizer/utils/measure_unit_list.dart';
import 'package:provider/provider.dart';

class SingleProductDetailPageInput {
  String workspaceId;
  Spesa?
      _currentSpesa; //valorizzato se ho selezionato il prodotto dalla ricerca per poter creare eventualmente la spesa
  Product product;
  SingleProductDetailPageInput(
      this.workspaceId, this._currentSpesa, this.product);
}

class SingleProductDetailPage extends StatefulWidget {
  final SingleProductDetailPageInput input;
  const SingleProductDetailPage(this.input);
  @override
  _SingleProductDetailPageState createState() =>
      _SingleProductDetailPageState();
}

class _SingleProductDetailPageState extends State<SingleProductDetailPage> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _measureController;
  late TextEditingController _typeAheadController;

  String _productName = "";
  String _productDescription = "";
  String _productReparto = "";
  double _quantity = 0.0;
  String _measureUnit = "";
  bool _isInsertSelected = false;
  String? _currency;
  double? _price;

  @override
  void dispose() {
    _measureController.dispose();
    _typeAheadController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _measureController =
        TextEditingController(text: widget.input.product.measureUnit);
    _typeAheadController =
        TextEditingController(text: widget.input.product.reparto);
    super.initState();
  }

  void initProd() {
    _productName = widget.input.product.name!;
    _productDescription = widget.input.product.description!;
    _productReparto = widget.input.product.reparto ?? "";
    _quantity = widget.input.product.quantity!;
    _measureUnit = widget.input.product.measureUnit!;
    _currency = widget.input.product.currency;
    _price = widget.input.product.price;
  }

  void _saveProduct() async {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      if (widget.input.product.id == null) {
        //sto inserendo il prodotto dalla ricerca quindi lo inserisco nuovo
        String? spesaId = widget.input.product.spesaIdRef;
        if (spesaId == null) {
          //create new spesa
          Spesa _currentSpesa = widget.input._currentSpesa!;
          _currentSpesa.orderBy = CategoryOrder.category.toString();
          _currentSpesa.showPrice = true;
          _currentSpesa.showSelected = true;
          _currentSpesa =
              await DatabaseService.instance.createNewSpesa(_currentSpesa);
          spesaId = _currentSpesa.id;
        }
        await DatabaseService.instance.insertProductOnSpesa(
          widget.input.workspaceId,
          spesaId!,
          widget.input.product.ownerId!,
          widget.input.product.ownerName!,
          _productName,
          _productDescription,
          _productReparto,
          _quantity,
          _measureUnit,
          _currency,
          _price!,
        );
      } else {
        await DatabaseService.instance.updateProductOnSpesa(
            widget.input.product.id!,
            widget.input.product.spesaIdRef!,
            _productName,
            _productDescription,
            _productReparto,
            _quantity,
            this._measureController.text,
            _currency!,
            _price!,
            _price! - widget.input.product.price!);
      }
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

  @override
  Widget build(BuildContext context) {
    initProd();
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
                  widget.input.product.id != null ? "Aggiorna" : "Inserisci"),
              onPressed: () => _saveProduct(),
            )
          ],
          title: Text(
            widget.input.product.id != null
                ? "Aggiorna Prodotto"
                : "Aggiungi Prodotto",
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
      padding: const EdgeInsets.only(top: 50, left: 20.0, right: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _descriptionContainer(),
            SizedBox(height: 50),
            _productRepartoContainer(),
            SizedBox(height: 50),
            _quantityContainer(),
            SizedBox(height: 50),
            _priceContainer(),
          ],
        ),
      ),
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
      initialValue: widget.input.product.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Inserisci il nome del prodotto";
        } else {
          return null;
        }
      },
      style: TextStyle(color: Colors.white),
      onChanged: (text) {
        if (_isInsertSelected) _formKey.currentState!.validate();
      },
      onSaved: ((text) {
        print(text);
        setState(() {
          _productName = text!;
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
      initialValue: widget.input.product.description,
      onSaved: ((text) {
        setState(() {
          _productDescription = text as String;
        });
      }),
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
      suggestionsCallback: (pattern) async {
        UserDataModel _currentUserData =
            Provider.of<AuthProvider>(context, listen: false).userData!;

        return await DatabaseService.instance
            .getUserRepartiByInput(pattern, _currentUserData.id!);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion as String),
        );
      },
      getImmediateSuggestions: true,
      onSuggestionSelected: (suggestion) {
        this._typeAheadController.text = suggestion as String;
        setState(() {
          _productReparto = suggestion;
        });
      },
      transitionBuilder: (context, suggestionsBox, animationController) =>
          FadeTransition(
        child: suggestionsBox,
        opacity: CurvedAnimation(
            parent: animationController as AnimationController,
            curve: Curves.fastOutSlowIn),
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
          _productReparto = text as String;
        });
        if (_isInsertSelected) _formKey.currentState!.validate();
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
      initialValue: widget.input.product.quantity.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
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
        if (_isInsertSelected) _formKey.currentState!.validate();
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

                  if (_isInsertSelected) _formKey.currentState!.validate();
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
      initialValue: widget.input.product.price != null
          ? widget.input.product.price.toString()
          : null,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (text) {
        if (_isInsertSelected) _formKey.currentState!.validate();
      },
      onSaved: (text) {
        if (text != null && text.isNotEmpty && double.tryParse(text) != null) {
          setState(() {
            _price = double.parse(text);
          });
          if (_isInsertSelected) _formKey.currentState!.validate();
        } else {
          setState(() {
            _price = 0;
          });
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
