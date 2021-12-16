import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/measure_unit_list.dart';

class SingleProductUpdateShownIput {
  Product _product;
  String _menuId;
  SingleProductUpdateShownIput(this._product, this._menuId);
}

class SingleProductUpdateShowWidget extends StatefulWidget {
  final SingleProductUpdateShownIput input;

  const SingleProductUpdateShowWidget(this.input);
  @override
  SingleProductUpdateShowWidgetState createState() =>
      SingleProductUpdateShowWidgetState();
}

class SingleProductUpdateShowWidgetState
    extends State<SingleProductUpdateShowWidget> {
  GlobalKey<FormState> _formKey;
  TextEditingController _measureController;
  TextEditingController _typeAheadController;

  String _productName = "";
  String _productDescription = "";
  double _quantity = 0.0;
  String _measureUnit = "";
  bool _isInsertSelected = false;

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
        TextEditingController(text: widget.input._product.measureUnit);
    _typeAheadController =
        TextEditingController(text: widget.input._product.reparto);

    initProd();
    super.initState();
  }

  void initProd() {
    if (widget.input._product != null) {
      _productName = widget.input._product.name;
      _productDescription = widget.input._product.description;
      _quantity = widget.input._product.quantity;
      _measureUnit = widget.input._product.measureUnit;
    }
  }

  bool _isUpdateValid() {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      return (_productName != widget.input._product.name ||
          _productDescription != widget.input._product.description ||
          _quantity != widget.input._product.quantity ||
          this._measureController.text != widget.input._product.measureUnit);
    } else {
      return false;
    }
  }

  void _showNoUpdateDialog() async {
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
                "Nessun cambiamento rillevato, aggiorna uno o più campi per procedere"),
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
    if (_formKey.currentState.validate()) {
      widget.input._product.name = _productName;
      widget.input._product.description = _productDescription;
      widget.input._product.quantity = _quantity;
      widget.input._product.measureUnit = _measureUnit;
      await DatabaseService.instance
          .updateProductOnReceipt(widget.input._product, widget.input._menuId);
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
              child: Text("Aggiorna"),
              onPressed: () =>
                  _isUpdateValid() ? _saveProduct() : _showNoUpdateDialog(),
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
            SizedBox(height: 10),
            _descriptionContainer(),
            SizedBox(height: 50),
            _quantityContainer(),
            SizedBox(height: 10),
            // widget.input._product.spesaIdRef != null
            //     ? _allertProductOnSpesa()
            //     : Container(),
          ],
        ),
      ),
    );
  }
//IN FUTURO MAGARI GESTIRò IL CASO DI POTER AGGIORNARE IL RIFERIMENTO AL PRODOTTO IN SPESA
  // Widget _allertProductOnSpesa() {
  //   return Builder(builder: (context) {
  //     return Align(
  //       alignment: Alignment.center,
  //       child: Container(
  //         margin: EdgeInsets.symmetric(vertical: 10),
  //         child: Padding(
  //           padding: const EdgeInsets.only(left: 15.0),
  //           child: Text(
  //             "Questo prodotto è presente in spesa, se lo aggiorni assicurati di farlo anche li",
  //             style: TextStyle(
  //               color: Colors.red,
  //               fontSize: 12,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   });
  // }

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
      initialValue: widget.input._product.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Inserisci il nome del prodotto";
        } else {
          return null;
        }
      },
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
      initialValue: widget.input._product.description != null
          ? widget.input._product.description
          : "",
      onSaved: ((text) {
        setState(() {
          _productDescription = text;
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
      initialValue: widget.input._product.quantity != null
          ? widget.input._product.quantity.toString()
          : "",
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

}
