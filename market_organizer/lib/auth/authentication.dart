import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:market_organizer/auth/widget/forgot_password.dart';
import 'package:market_organizer/auth/widget/signin_widget.dart';
import 'package:market_organizer/auth/widget/signup_widget.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/snackbar_service.dart';

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
    SnackBarService.instance.buildContext = context; //init snackbarservice
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
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
                  ? SignInWidget(_changeSignPage, _resetPassword)
                  : SignUpWidget(_changeSignPage),
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
        )

        // else
        //   ForgotPasswordWidget(
        //     _height,
        //     _width,
        //   )

        );
  }
}
