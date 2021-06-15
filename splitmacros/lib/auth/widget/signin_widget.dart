import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitmacros/provider/auth_provider.dart';
import 'package:splitmacros/service/navigator_service.dart';
import 'package:splitmacros/service/snackbar_service.dart';

class SignInWidget extends StatefulWidget {
  final double _heigth;
  final double _width;
  Function _changeSignPage;
  Function _resetPassword;
  SignInWidget(
      this._heigth, this._width, this._changeSignPage, this._resetPassword);

  @override
  _SignInWidgetState createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  AuthProvider _auth;
  String _email;
  String _password;
  bool _isButtonEnable = false;
  GlobalKey<FormState> _formKey;

  _SignInWidgetState() {
    _formKey = GlobalKey<FormState>();
  }
  void _checkValidator() {
    if (_email != null &&
        _password != null &&
        _email.length > 0 &&
        _password.length > 0 &&
        _email.contains('@')) {
      setState(() {
        _isButtonEnable = true;
      });
    } else {
      setState(() {
        _isButtonEnable = false;
      });
    }
  }

  void _userAuth() async {
    _auth.loginUserWithEmailAndPassword(_email, _password);
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    return Container(
      height: widget._heigth * 0.50,
      width: widget._width * 0.8,
      decoration: BoxDecoration(
        color: Color.fromRGBO(196, 196, 196, 1),
        borderRadius: BorderRadius.circular(70),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Center(
              child: Text(
                "Welcome back!",
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
          ),
          _inputForm(context),
        ],
      ),
    );
  }

  Widget _inputForm(BuildContext _context) {
    return Expanded(
      flex: 2,
      child: Form(
          key: _formKey,
          onChanged: () {
            _formKey.currentState.save();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _emailTextField(_context),
              _passwordTextField(_context),
              _submitButton(_context),
              _signUpSection(_context),
              _passwordForgotten(_context),
            ],
          )),
    );
  }

  Widget _emailTextField(BuildContext _context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 30.0,
              top: 10,
            ),
            child: Text(
              "email",
              style: Theme.of(_context).textTheme.headline2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(192),
            color: Theme.of(_context).accentColor,
          ),
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            textAlignVertical: TextAlignVertical.bottom,
            textAlign: TextAlign.start,
            autocorrect: false,
            validator: (_input) {
              return _input.length != 0 || _input.contains('@')
                  ? null
                  : "Please Enter a Valid Email";
            },
            style: Theme.of(_context).textTheme.headline4,
            onSaved: (_input) {
              if (_input != null) {
                setState(() {
                  _email = _input;
                  _checkValidator();
                });
              }
            },
            cursorHeight: 18,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: "Type Your Email here..",
              fillColor: Colors.black,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintStyle: TextStyle(color: Theme.of(_context).buttonColor),
              prefixIcon: Container(
                decoration: BoxDecoration(
                  color: Theme.of(_context).buttonColor,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  CupertinoIcons.mail,
                  color: Colors.black,
                ),
                margin: EdgeInsets.all(7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _passwordTextField(BuildContext _context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 30.0,
              top: 10,
            ),
            child: Text(
              "password",
              style: Theme.of(_context).textTheme.headline2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(192),
            color: Theme.of(_context).accentColor,
          ),
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            textAlignVertical: TextAlignVertical.bottom,
            textAlign: TextAlign.start,
            autocorrect: false,
            validator: (_input) {
              return _input.length != 0 ? null : "Please Enter a Password";
            },
            style: Theme.of(_context).textTheme.headline4,
            onSaved: (_input) {
              if (_input != null) {
                setState(() {
                  _password = _input;
                  _checkValidator();
                });
              }
            },
            cursorHeight: 18,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: "Type password here..",
              fillColor: Colors.black,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              hintStyle: TextStyle(color: Theme.of(_context).buttonColor),
              prefixIcon: Container(
                decoration: BoxDecoration(
                  color: Theme.of(_context).buttonColor,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  Icons.vpn_key,
                  color: Colors.black,
                ),
                margin: EdgeInsets.all(7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _submitButton(BuildContext _context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 70, vertical: 20),
      child: RaisedButton(
        onPressed: () => _isButtonEnable ? _userAuth() : null,
        color: _isButtonEnable ? Colors.green : Colors.green.withOpacity(0.5),
        elevation: 20,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        child: Center(
          child: Text(
            "Sign In",
            style: _isButtonEnable
                ? Theme.of(_context).textTheme.headline5
                : Theme.of(_context)
                    .textTheme
                    .headline5
                    .copyWith(color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }

  Widget _signUpSection(BuildContext _context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(_context).textTheme.headline4,
        ),
        TextButton(
          onPressed: () => widget._changeSignPage(),
          child: Text(
            "Sign Up",
            style: Theme.of(_context).textTheme.headline4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        )
      ],
    );
  }

  Widget _passwordForgotten(BuildContext _context) {
    return Center(
      child: TextButton(
        onPressed: () => widget._resetPassword(),
        child: Text(
          "Forgot Password?",
          style: Theme.of(_context).textTheme.headline4.copyWith(
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
