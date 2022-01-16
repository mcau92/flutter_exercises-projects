import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/pages/widget/commons/appbar_custom_widget.dart';
import 'package:market_organizer/pages/widget/commons/weekpicker_widget.dart';
import 'package:market_organizer/pages/spesa/body_widget.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/provider/date_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:provider/provider.dart';

class SpesaWidget extends StatefulWidget {
  final String worksapceId;

  SpesaWidget(this.worksapceId);

  @override
  _SpesaWidgetState createState() => _SpesaWidgetState();
}

class _SpesaWidgetState extends State<SpesaWidget> {
  DateTime dateStart;

  DateTime dateEnd;

  DateProvider _dateProvider;
  Spesa _currentSpesa;

  void _addToSpesa() {
    NavigationService.instance
        .navigateToWithParameters("addSpesaPage", _currentSpesa);
  }

  void _cloneSpesa() {}
  void _newSpesa() {
    //controllo se è la prima spesa o se esiste gia
    _currentSpesa != null
        ? NavigationService.instance
            .navigateToWithParameters("addSpesaPage", _currentSpesa)
        : _currentSpesa = new Spesa(
            workspaceIdRef: widget.worksapceId,
            startWeek: dateStart,
            endWeek: dateEnd,
            ownerId: "LMgqupuW0wVW4RZn3QyC0y9Xxrg1");
    NavigationService.instance
        .navigateToWithParameters("addSpesaPage", _currentSpesa);
  }

  @override
  Widget build(BuildContext context) {
    _dateProvider = Provider.of<DateProvider>(context);
    dateStart = _dateProvider.dateStart;
    dateEnd = _dateProvider.dateEnd;
    return Column(children: [
      AppBarCustom(0, _addToSpesa, false),
      WeekPickerWidget(),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: _body(),
        ),
      )
    ]);
  }

  Widget _body() {
    return StreamBuilder<List<Spesa>>(
      stream: DatabaseService.instance
          .getSpesaStreamFromIdAndDate(widget.worksapceId, dateStart, dateEnd),
      builder: (_context, _snap) {
        if (_snap.hasData) {
          if (_snap.data.isNotEmpty) {
            List<Spesa> _spesaList = _snap.data;
            _currentSpesa = _spesaList[0];
            return Column(
              children: [
                _workspaceBar(_currentSpesa),
                BodyWidget(_currentSpesa),
              ],
            );
          } else {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                _image(),
                _description(),
                _addSpesaButton(),
              ],
            ));
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _addSpesaButton() {
    return CupertinoButton(
      onPressed: () => _newSpesa(),
      child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text("AGGIUNGI", style: TextStyle(color: Colors.red[600]))),
    );
  }

  Widget _description() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          "Nessun Prodotto Presente",
          style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.bold,
              fontSize: 18),
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

  Widget _workspaceBar(Spesa _currentSpesa) {
    return Builder(builder: (context) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    createString(_currentSpesa.ammount),
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                      padding: EdgeInsets.all(0),
                      child: Icon(
                        CupertinoIcons.ellipsis,
                        color: Colors.white,
                      ),
                      onPressed: () => _cloneSpesa())
                ],
              )),
        ),
      );
    });
  }
}
