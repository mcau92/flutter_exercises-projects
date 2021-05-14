import 'package:flutter/cupertino.dart';

class SignInWidget extends StatefulWidget {
  final double _heigth;
  final double _width;
  SignInWidget(this._heigth, this._width);
  @override
  _SignInWidgetState createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.widget._heigth * 0.50,
      width: this.widget._width * 0.7,
      decoration: BoxDecoration(
        color: Color.fromRGBO(196, 196, 196, 1),
        borderRadius: BorderRadius.circular(70),
      ),
    );
  }
}
