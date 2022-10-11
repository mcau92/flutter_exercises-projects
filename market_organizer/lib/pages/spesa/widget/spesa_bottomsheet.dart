import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/utils/category_enum.dart';
import 'package:market_organizer/utils/utils.dart';
import 'package:market_organizer/utils/view_enum.dart';

class SpesaBottomSheet extends StatefulWidget {
  final Spesa _currentSpesa;
  final Function _deleteAll;
  final Function cloneSpesa;
  final Function pop;
  final DateTime dateStart;
  final DateTime dateEnd;

  SpesaBottomSheet(this._currentSpesa, this._deleteAll, this.cloneSpesa,
      this.pop, this.dateStart, this.dateEnd);

  @override
  State<SpesaBottomSheet> createState() => _SpesaBottomSheetState();
}

class _SpesaBottomSheetState extends State<SpesaBottomSheet> {
//usati per il clona
  DateTime? _dateStartForClone;
  DateTime? _dateEndForClone;

  /*** FUNCTIONS */

  Future<bool> _confirmDelete() async {
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
                    rootNavigator: true,
                  ).pop(true);
                },
              ),
              CupertinoDialogAction(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                    rootNavigator: true,
                  ).pop(false);
                },
              ),
            ],
          );
        });
  }

  Future<void> _selectWeekClone() {
    Navigator.pop(context);
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 220.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        onPressed: () {
                          widget.pop();
                          widget.cloneSpesa(
                              _dateStartForClone, _dateEndForClone);
                        }),
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
    DateTime dateStartLoop = widget.dateStart;
    DateTime dateEndLoop = widget.dateEnd;
    return Container(
      padding: EdgeInsets.only(bottom: 50),
      color: Colors.white,
      child: CupertinoPicker(
        itemExtent: 32.0,
        backgroundColor: Colors.white,
        onSelectedItemChanged: (int index) {
          _dateStartForClone =
              dateStartLoop.add(Duration(days: ((index + 1) * 7)));
          _dateEndForClone = dateEndLoop.add(Duration(days: ((index + 1) * 7)));
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

  void _updateShowSelected() async {
    bool value = !widget._currentSpesa.showSelected!;
    widget._currentSpesa.showSelected = value;
    await DatabaseService.instance.updateShowSelected(widget._currentSpesa);
    widget.pop();
  }

  void _updateShowPrice() async {
    bool value = !widget._currentSpesa.showPrice!;
    widget._currentSpesa.showPrice = value;
    await DatabaseService.instance.updateShowPrice(widget._currentSpesa);
    widget.pop();
  }

  Future<void> _updateView(String view) async {
    widget._currentSpesa.spesaView = view;
    await DatabaseService.instance.updateSpesaView(widget._currentSpesa);
    widget.pop();
  }

  void _updateCategory(String category) async {
    widget._currentSpesa.orderBy = category;
    await DatabaseService.instance.updateSpesaOrder(widget._currentSpesa);
    widget.pop();
  }

  /*** BUILD */
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 40),
      color: Colors.white,
      child: Wrap(
        children: [
          _spesaActions(),
          _viewActions(),
          _orderActions(),
        ],
      ),
    );
  }

  Widget _viewActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          visualDensity: VisualDensity(horizontal: 0, vertical: -4),
          enabled: false,
          minVerticalPadding: 0.0,
          title: Text(
            "Visualizzazione",
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
          contentPadding: EdgeInsets.only(left: 5),
          onTap: () async {
            await _updateView(ViewProd.reparti.toString());
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
              key: UniqueKey(),
              activeColor: Colors.green,
              value:
                  widget._currentSpesa.spesaView == ViewProd.reparti.toString(),
              onChanged: (v) async {
                await _updateView(ViewProd.reparti.toString());
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          title: Text(
            "Reparti e Prodotti",
            style: TextStyle(
              color:
                  widget._currentSpesa.spesaView == ViewProd.reparti.toString()
                      ? Colors.green
                      : Colors.black,
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.only(left: 5),
          onTap: () async {
            await _updateView(ViewProd.prodotti.toString());
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
              key: UniqueKey(),
              activeColor: Colors.green,
              value: widget._currentSpesa.spesaView ==
                  ViewProd.prodotti.toString(),
              onChanged: (v) async {
                await _updateView(ViewProd.prodotti.toString());
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          title: Text(
            "Solo Prodotti",
            style: TextStyle(
              color:
                  widget._currentSpesa.spesaView == ViewProd.prodotti.toString()
                      ? Colors.green
                      : Colors.black,
            ),
          ),
        ),
      ],
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
            "Generale",
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
          leading: widget._currentSpesa.showSelected!
              ? Icon(CupertinoIcons.cart_badge_minus)
              : Icon(CupertinoIcons.cart_badge_plus),
          title: widget._currentSpesa.showSelected!
              ? Text("Nascondi Selezionati")
              : Text("Mostra Selezionati"),
        ),
        ListTile(
          onTap: () => _updateShowPrice(),
          leading: Icon(CupertinoIcons.tags),
          title: widget._currentSpesa.showPrice != null
              ? widget._currentSpesa.showPrice!
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
          onTap: () async {
            Navigator.of(context, rootNavigator: true).pop();
            await _confirmDelete() ? await widget._deleteAll() : null;
          },
          leading: Icon(CupertinoIcons.delete),
          title: Text("Rimuovi Tutto"),
        ),
      ],
    );
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
          contentPadding: EdgeInsets.only(left: 5),
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
              key: UniqueKey(),
              activeColor: Colors.green,
              value: widget._currentSpesa.orderBy ==
                  CategoryOrder.category.toString(),
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
              color: widget._currentSpesa.orderBy ==
                      CategoryOrder.category.toString()
                  ? Colors.green
                  : Colors.black,
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.only(left: 5),
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
              key: UniqueKey(),
              activeColor: Colors.green,
              value: widget._currentSpesa.orderBy ==
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
              color: widget._currentSpesa.orderBy ==
                      CategoryOrder.categoryReverse.toString()
                  ? Colors.green
                  : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
