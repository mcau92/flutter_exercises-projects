import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/measure_unit_list.dart';
import 'package:provider/provider.dart';

class AddSpesaPage extends StatefulWidget {
  @override
  _AddSpesaPageState createState() => _AddSpesaPageState();
}

class _AddSpesaPageState extends State<AddSpesaPage> {
  GlobalKey<FormState> _formKey;
  TextEditingController _controller;
  TextEditingController _typeAheadController;
  Spesa _currentSpesa;
  String _productName = "";
  String _productDescription = "";
  String _productReparto = "";
  double _quantity = 0.0;
  String _measureUnit = "";
  bool _isInsertSelected = false;
  String _currency ;
  double _price ;

  @override
  void dispose() {
    _controller.dispose();
    _typeAheadController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _controller = TextEditingController();
    _typeAheadController = TextEditingController();
    super.initState();
  }

  void _saveProduct() async {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      if (_currentSpesa.id == null) {
        //create new spesa
        _currentSpesa =
            await DatabaseService.instance.createNewSpesa(_currentSpesa);
      }
      await DatabaseService.instance.insertProductOnSpesa(
        _currentSpesa.id,
        _currentSpesa.ownerId,
        _productName,
        _productDescription,
        _productReparto,
        _quantity,
        _measureUnit,
        _currency,
        _price,
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

  @override
  Widget build(BuildContext context) {
    _currentSpesa = ModalRoute.of(context).settings.arguments as Spesa;
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
              child: Text("Inserisci"),
              onPressed: () => _saveProduct(),
            )
          ],
          title: Text(
            "Aggiungi Prodotto",
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
            _priceContainer()
          ],
        ),
      ),
    );
  }

//description
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Inserisci il nome del prodotto";
        } else {
          return null;
        }
      },
      style: TextStyle(color: Colors.white),
      onChanged: (text) {
        if (text != null && text.isNotEmpty) {
          setState(() {
            _productName = text;
          });
          if (_isInsertSelected) _formKey.currentState.validate();
        }
      },
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
      onChanged: (text) {
        setState(() {
          _productDescription = text;
        });
      },
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

//reparto
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
            .getUserRepartiByInput(pattern, _currentSpesa.ownerId);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (suggestion) {
        this._typeAheadController.text = suggestion;
        setState(() {
          _productReparto = suggestion;
        });
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

  //quantity
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
        if (text != null && text.isNotEmpty && double.tryParse(text) != null) {
          setState(() {
            _quantity = double.parse(text);
          });
          if (_isInsertSelected) _formKey.currentState.validate();
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
                            .indexOf(_measureUnit)),
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    String key = MeasureUnitList.units.keys.toList()[index];
                    if (key == "nessun valore") {
                      _measureUnit = "";
                      this._controller.text = _measureUnit;
                    } else {
                      _measureUnit = key;
                      this._controller.text = _measureUnit;
                    }
                  });

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
      controller: _controller,
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
  }

  //price
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
