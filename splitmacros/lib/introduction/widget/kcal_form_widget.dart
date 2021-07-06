import 'package:flutter/material.dart';

class KcalFormWidget extends StatefulWidget {
  GlobalKey<FormState> _formKey;
  void Function(int kcal) setKcal;

  KcalFormWidget({this.setKcal}) {
    _formKey = GlobalKey<FormState>();
  }
  @override
  _KcalFormWidgetState createState() => _KcalFormWidgetState();
}

class _KcalFormWidgetState extends State<KcalFormWidget> {
  void _checkValidator(int _kcal) {
    if (_kcal != null && _kcal > 0) {
      widget.setKcal(_kcal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget._formKey,
        onChanged: () {
          widget._formKey.currentState.save();
        },
        child: _kcalWidget(context));
  }

  Widget _kcalWidget(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(192),
          color: Theme.of(context).accentColor,
        ),
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
            textAlignVertical: TextAlignVertical.bottom,
            textAlign: TextAlign.start,
            autocorrect: false,
            keyboardType: TextInputType.number,
            validator: (_input) {
              return _input.length != 0 && int.parse(_input) > 0
                  ? null
                  : "Please Enter a Valid kcal number";
            },
            style: Theme.of(context).textTheme.headline4,
            onSaved: (_input) {
              if (_input != null) {
                _checkValidator(int.parse(_input));
              }
            },
            cursorHeight: 18,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: "kcal..",
              fillColor: Colors.black,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintStyle: TextStyle(color: Theme.of(context).buttonColor),
            )));
  }
}
