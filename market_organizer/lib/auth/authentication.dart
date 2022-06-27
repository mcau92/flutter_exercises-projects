import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/auth/widget/signin_widget.dart';
import 'package:market_organizer/auth/widget/signup_widget.dart';
import 'package:market_organizer/service/snackbar_service.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool _isSignIn = true;
  bool _isChangePassword = false;
  bool _isLoadingData = false;

  void _changeSignPage() {
    setState(() {
      _isSignIn = !_isSignIn;
    });
  }

  void _resetPassword() {
    setState(() {
      _isChangePassword = true;
    });
  }

  void _loadingData() {
    setState(() {
      _isLoadingData = !_isLoadingData;
    });
  }

  @override
  Widget build(BuildContext context) {
    SnackBarService.instance.buildContext = context; //init snackbarservice
    double _heigth = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _body(_width),
          if (_isLoadingData) _loader(_heigth, _width),
        ],
      ),
    );
  }

  Widget _body(double _width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          width: _width / 2,
          decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(_width / 2),
              )),
        ),
        SizedBox(
          height: 20,
        ),
        Expanded(
          child: (_isSignIn && !_isChangePassword)
              ? SignInWidget(_changeSignPage, _resetPassword, _loadingData)
              : SignUpWidget(_changeSignPage, _loadingData),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 150,
            width: _width / 2,
            decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_width / 2),
                )),
          ),
        ),
      ],
    );
  }

  Widget _loader(double _height, double _width) {
    return Container(
      width: _width,
      height: _height,
      color: Color.fromRGBO(43, 43, 43, 1).withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      ),
    );
  }
}
