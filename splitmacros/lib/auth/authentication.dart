import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:splitmacros/auth/widget/signin_widget.dart';
import 'package:splitmacros/auth/widget/signup_widget.dart';
import 'package:splitmacros/service/snackbar_service.dart';
import 'package:splitmacros/utils/constant.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool _isSignIn = true;

  void _changeSignPage() {
    setState(() {
      _isSignIn = !_isSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    SnackBarService.instance.buildContext = context; //init snackbarservice
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: _height,
        width: _width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: _isSignIn ? Radius.circular(450) : Radius.circular(0),
              topRight: _isSignIn ? Radius.circular(0) : Radius.circular(450),
              bottomRight:
                  _isSignIn ? Radius.circular(200) : Radius.circular(0),
              bottomLeft:
                  _isSignIn ? Radius.circular(0) : Radius.circular(200)),
          color: Theme.of(context).primaryColor,
        ),
        
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: _height * 0.30,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    Constant().title,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ),
              SizedBox(height: _height * 0.03),
              _isSignIn
                  ? SignInWidget(_height, _width, _changeSignPage)
                  : SignUpWidget(_height, _width, _changeSignPage),
            ],
          ),
        ),
      
    );
  }
}
