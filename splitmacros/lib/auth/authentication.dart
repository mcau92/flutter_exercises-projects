import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitmacros/auth/widget/forgot_password.dart';
import 'package:splitmacros/auth/widget/signin_widget.dart';
import 'package:splitmacros/auth/widget/signup_widget.dart';
import 'package:splitmacros/provider/auth_provider.dart';
import 'package:splitmacros/service/snackbar_service.dart';
import 'package:splitmacros/utils/constant.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool _isSignIn = true;
  bool _isChangePassword = false;

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

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    SnackBarService.instance.buildContext = context; //init snackbarservice
    return ChangeNotifierProvider<AuthProvider>.value(
      value: AuthProvider.instance,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          height: _height,
          width: _width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(450),
              bottomRight: Radius.circular(200),
            ),
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
              if (_isSignIn && !_isChangePassword)
                SignInWidget(_height, _width, _changeSignPage, _resetPassword)
              else if (!_isSignIn && !_isChangePassword)
                SignUpWidget(_height, _width, _changeSignPage)
              else
                ForgotPasswordWidget(
                  _height,
                  _width,
                )
            ],
          ),
        ),
      ),
    );
  }
}
