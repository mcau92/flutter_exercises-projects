import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/spesa/singleproduct_widget.dart';
import 'package:market_organizer/pages/widget/commons/appbar_custom_widget.dart';
import 'package:market_organizer/pages/widget/commons/weekpicker_widget.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/service/snackbar_service.dart';
import 'package:market_organizer/utils/category_enum.dart';
import 'package:market_organizer/utils/utils.dart';
import 'package:provider/provider.dart';

class SpesaWidget extends StatefulWidget {
  final String worksapceId;

  SpesaWidget(this.worksapceId);

  @override
  _SpesaWidgetState createState() => _SpesaWidgetState();
}

class _SpesaWidgetState extends State<SpesaWidget> {
  late DateTime dateStart;

  late DateTime dateEnd;
//usati per il clona
  late DateTime? _dateStartForClone;
  late DateTime? _dateEndForClone;

  late DateProvider _dateProvider;
  late Spesa _currentSpesa;

  void _addToSpesa() {
    NavigationService.instance
        .navigateToWithParameters("addSpesaPage", _currentSpesa);
  }

  Future<bool> _confirmDelete() async {
    Navigator.pop(context);
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
                "Confermi di cancellare tutti i prodotti di questa spesa?"),
            actions: [
              CupertinoDialogAction(
                child: Text("Si"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                    // rootNavigator: true,
                  ).pop(true);
                },
              ),
              CupertinoDialogAction(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                    // rootNavigator: true,
                  ).pop(false);
                },
              ),
            ],
          );
        });
  }

  Future<void> _cloneSpesa() async {
    UserDataModel _currentUserData =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    if (_dateStartForClone == null && _dateEndForClone == null) {
      _dateStartForClone = dateStart.add(Duration(days: 7));
      _dateEndForClone = dateEnd.add(Duration(days: 7));
    }
    await DatabaseService.instance.cloneSpesa(_currentSpesa,
        _dateStartForClone!, _dateEndForClone!, _currentUserData.id!);

    Navigator.of(context).pop();
    SnackBarService.instance
        .showSnackBarSuccesfull("Spesa Copiata Correttamente");
  }

  Future<void> _selectWeekClone() {
    Navigator.pop(context);
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 190.0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CupertinoButton(
                      child: Text(
                        "Annulla",
                        style: TextStyle(fontSize: 15),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "Seleziona settimana.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    CupertinoButton(
                        child: Text(
                          "Clona",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () => _cloneSpesa()),
                  ],
                ),
                Expanded(
                  child: _dateAndDayPicker(),
                ),
              ],
            ),
          );
        });
  }

  Widget _dateAndDayPicker() {
    DateTime dateStartLoop = dateStart;
    DateTime dateEndLoop = dateEnd;
    return Container(
      padding: EdgeInsets.only(bottom: 50),
      color: Colors.white,
      child: CupertinoPicker(
        itemExtent: 32.0,
        backgroundColor: Colors.white,
        onSelectedItemChanged: (int index) {
          print(index);
          setState(() {
            _dateStartForClone =
                dateStartLoop.add(Duration(days: ((index + 1) * 7)));
            _dateEndForClone =
                dateEndLoop.add(Duration(days: ((index + 1) * 7)));
          });
        },
        children: [
          for (int i = 7; i < 29; i += 7)
            Center(child: _createTimeWidget(dateStartLoop, dateEndLoop, i))
        ],
      ),
    );
  }

  Widget _createTimeWidget(
      DateTime dateStartLoop, DateTime dateEndLoop, int duration) {
    dateStartLoop = dateStartLoop.add(Duration(days: duration));
    dateEndLoop = dateEndLoop.add(Duration(days: duration));
    return Text(dateStartLoop.day.toString() +
        " " +
        Utils.instance.convertWeekDay(dateStartLoop.month) +
        " - " +
        dateEndLoop.day.toString() +
        " " +
        Utils.instance.convertWeekDay(dateEndLoop.month));
  }

  void _deleteAll() {
    DatabaseService.instance.deleteAllProductsOnSpesa(_currentSpesa.id!);
  }

  void _updateShowSelected() {
    _currentSpesa.showSelected = !_currentSpesa.showSelected!;
    DatabaseService.instance.updateShowSelected(_currentSpesa);
    Navigator.pop(context);
  }

  void _updateShowPrice() {
    _currentSpesa.showPrice = !_currentSpesa.showPrice!;
    DatabaseService.instance.updateShowPrice(_currentSpesa);
    Navigator.pop(context);
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        child: Column(
          children: [_spesaActions(), _orderActions()],
        ),
      ),
    );
  }

  Widget _spesaActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          enabled: false,
          minVerticalPadding: 0.0,
          title: Text(
            "Spesa",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(
          thickness: 0.2,
          color: Colors.black,
        ),
        ListTile(
          onTap: () => _updateShowSelected(),
          leading: _currentSpesa.showSelected!
              ? Icon(CupertinoIcons.cart_badge_minus)
              : Icon(CupertinoIcons.cart_badge_plus),
          title: _currentSpesa.showSelected!
              ? Text("Nascondi Selezionati")
              : Text("Mostra Selezionati"),
        ),
        ListTile(
          onTap: () => _updateShowPrice(),
          leading: Icon(CupertinoIcons.tags),
          title: _currentSpesa.showPrice != null
              ? _currentSpesa.showPrice!
                  ? Text("Nascondi Prezzi")
                  : Text("Mostra Prezzi")
              : Text(""),
        ),
        ListTile(
          onTap: () async => await _selectWeekClone(),
          leading: Icon(CupertinoIcons.arrow_up_right_diamond),
          title: Text("Clona Spesa"),
        ),
        ListTile(
          onTap: () async => await _confirmDelete() ? _deleteAll() : null,
          leading: Icon(CupertinoIcons.delete),
          title: Text("Rimuovi Tutto"),
        ),
      ],
    );
  }

  void _updateCategory(String category) async {
    _currentSpesa.orderBy = category;
    await DatabaseService.instance.updateSpesaOrder(_currentSpesa);
    Navigator.pop(context);
  }

  Widget _orderActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          enabled: false,
          minVerticalPadding: 0.0,
          title: Text(
            "Ordinamento",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(
          thickness: 0.2,
          color: Colors.black,
        ),
        ListTile(
          onTap: () {
            _updateCategory(CategoryOrder.category.toString());
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.black),
          ),
          leading: Theme(
            data: ThemeData(
              primarySwatch: Colors.blue,
              unselectedWidgetColor: Colors.black, // Your color
            ),
            child: Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: Colors.green,
              value: _currentSpesa.orderBy == CategoryOrder.category.toString(),
              onChanged: (v) {
                _updateCategory(CategoryOrder.category.toString());
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          title: Text(
            "Per Categoria A-Z",
            style: TextStyle(
              color: _currentSpesa.orderBy == CategoryOrder.category.toString()
                  ? Colors.green
                  : Colors.black,
            ),
          ),
        ),
        ListTile(
          onTap: () {
            _updateCategory(CategoryOrder.categoryReverse.toString());
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.black),
          ),
          leading: Theme(
            data: ThemeData(
              primarySwatch: Colors.blue,
              unselectedWidgetColor: Colors.black, // Your color
            ),
            child: Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: Colors.green,
              value: _currentSpesa.orderBy ==
                  CategoryOrder.categoryReverse.toString(),
              onChanged: (v) {
                _updateCategory(CategoryOrder.categoryReverse.toString());
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          title: Text(
            "Per Categoria Z-A",
            style: TextStyle(
              color: _currentSpesa.orderBy ==
                      CategoryOrder.categoryReverse.toString()
                  ? Colors.green
                  : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _dateProvider = Provider.of<DateProvider>(context);
    dateStart = _dateProvider.dateStart;
    dateEnd = _dateProvider.dateEnd;

    SnackBarService.instance.buildContext = context; //init snackbarservice
    return Column(
      children: [
        AppBarCustom(0, _addToSpesa, false, widget.worksapceId),
        WeekPickerWidget(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: _body(),
          ),
        )
      ],
    );
  }

  Widget _body() {
    return StreamBuilder<List<Spesa>>(
      stream: DatabaseService.instance
          .getSpesaStreamFromIdAndDate(widget.worksapceId, dateStart, dateEnd),
      builder: (_context, _snap) {
        if (_snap.hasData) {
          if (_snap.data!.isNotEmpty) {
            List<Spesa> _spesaList = _snap.data!;
            _currentSpesa = _spesaList[0];
            return Column(
              children: [
                _workspaceBar(_currentSpesa),
                Expanded(
                  child: _repartoList(_currentSpesa),
                ),
              ],
            );
          } else {
            _currentSpesa = new Spesa(
                workspaceIdRef: widget.worksapceId,
                startWeek: dateStart,
                endWeek: dateEnd,
                ownerId: "LMgqupuW0wVW4RZn3QyC0y9Xxrg1");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _workspaceBar(null),
                  Expanded(
                      child: Center(
                    child: _noSpesaWidget(),
                  )),
                ],
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }

  Widget _noSpesaWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _image(),
        _description(),
        _addSpesaButton(),
      ],
    );
  }

/** REPARTO START */

  Widget _repartoList(Spesa _spesa) {
    return StreamBuilder<List<Product>>(
        stream: DatabaseService.instance.getProductsBySpesa(_spesa.id!),
        builder: (context, _snapshot) {
          if (_snapshot.hasData) {
            if (_snapshot.data != null && _snapshot.data!.isNotEmpty) {
              List<Product> _products = _snapshot.data!;
              if (!_currentSpesa.showSelected!) {
                //rimuovo prodotti selezionati
                _products.removeWhere((element) => element.bought!);
              }
              List<String> reparti =
                  Utils.instance.getReparti(_products, _currentSpesa.orderBy!);
              if (reparti != null && reparti.isNotEmpty) {
                return ListView.separated(
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 7,
                      );
                    },
                    itemCount: reparti.length,
                    itemBuilder: (context, index) {
                      return reparto(
                        _spesa.workspaceIdRef!,
                        reparti[index],
                        _products
                            .where((p) => p.reparto == reparti[index])
                            .toList(),
                      );
                    });
              } else {
                return Center(child: _noSpesaWidget());
              }
            } else {
              return Center(
                child: Text("nessuna spesa inserita"),
              );
            }
          } else {
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.orange,
            ));
          }
        });
  }

  Widget reparto(
      String _workspaceId, String repartoName, final List<Product> products) {
    return Container(
      padding: EdgeInsets.only(bottom: 5, top: 5, left: 15),
      child: Column(
        children: [
          _titleReparto(repartoName),
          _productsList(products),
        ],
      ),
    );
  }

  Widget _titleReparto(String repartoName) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          repartoName,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(Product _product) async {
    //check if spesa contains product
    int spesaProdSize = await DatabaseService.instance
        .getSpesaProductsSize(_product.spesaIdRef!);
    await DatabaseService.instance.deleteProduct(_product);

    if (spesaProdSize == 1) {
      //ask user if want to delete spesa with 0 prods
      await DatabaseService.instance.deleteSpesa(_product.spesaIdRef!);
    }
  }

  Future<void> _boughtProduct(Product _product) async {
    await DatabaseService.instance.updateProductBoughtOnSpesa(_product);
  }

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

  Widget _productsList(List<Product> products) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return Divider(
          height: 5,
          thickness: 0.2,
          color: Colors.white,
          indent: 55,
          endIndent: 0,
        );
      },
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _dismissibleProd(products, index);
      },
    );
  }

  Widget _dismissibleProd(List<Product> products, int index) {
    return Dismissible(
      child: SingleProductWidget(widget.worksapceId, products[index],
          _boughtProduct, _currentSpesa.showPrice!),
      key: UniqueKey(),
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart)
          _deleteProduct(products[index]);
      },
      dismissThresholds: {DismissDirection.endToStart: 0.2},
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart)
          return _confirmDismiss(context);
        else
          return false;
      },
      direction: DismissDirection.endToStart,
      background: Container(),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.orange,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Icon(
              CupertinoIcons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

/** REPARTO END */
  Widget _addSpesaButton() {
    return CupertinoButton(
      onPressed: () => _addToSpesa(),
      child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text("AGGIUNGI", style: TextStyle(color: Colors.orange))),
    );
  }

  Widget _description() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          "Nessun Prodotto Presente",
          style: TextStyle(
              color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _image() {
    return Container(
      padding: EdgeInsets.all(30),
      clipBehavior: Clip.hardEdge,
      height: 200,
      width: 200,
      child: SvgPicture.asset(
        'assets/images/empty_spesa.svg',
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(150),
      ),
    );
  }

  String createString(double ammount) {
    String tot = "Tot. ";
    if (ammount == null) return tot + "0.0 €";
    return tot + num.parse(ammount.toStringAsFixed(2)).toString() + " €";
  }

  Widget _workspaceBar(Spesa? _currentSpesa) {
    return Builder(builder: (context) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                _currentSpesa == null
                    ? "Tot. 0 €"
                    : _currentSpesa.showPrice!
                        ? createString(_currentSpesa.ammount!)
                        : "Tot --.-",
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CupertinoButton(
                padding: EdgeInsets.all(0),
                child: Icon(
                  CupertinoIcons.ellipsis,
                  color: Colors.white,
                ),
                onPressed: () => _currentSpesa == null ? {} : _showOptions(),
              ),
            ),
          ],
        ),
      );
    });
  }
}
