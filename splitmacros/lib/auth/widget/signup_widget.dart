import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:splitmacros/provider/auth_provider.dart';
import 'package:splitmacros/service/database_service.dart';
import 'package:splitmacros/service/navigator_service.dart';
import 'package:splitmacros/service/snackbar_service.dart';

class SignUpWidget extends StatefulWidget {
  final double _heigth;
  final double _width;
  Function _changeSignPage;
  SignUpWidget(this._heigth, this._width, this._changeSignPage);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  AuthProvider _auth;
  String _username;
  String _email;
  String _password;
  bool _isButtonEnable = false;
  GlobalKey<FormState> _formKey;

  _SignUpWidgetState() {
    _formKey = GlobalKey<FormState>();
  }

  void _checkValidator() {
    if (_username != null &&
        _email != null &&
        _password != null &&
        _username.length > 0 &&
        _email.length > 0 &&
        _password.length > 5 &&
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
    _email = _email.trim();
    _username = _username.trim();
    bool isUserAvailable =
        await DatabaseService.instance.checkUserNameIsAvailable(_username);
    bool isEmailAvailable =
        await DatabaseService.instance.checkEmailIsAvailable(_email);
    if (!isUserAvailable) {
      SnackBarService.instance.showSnackBarError("Username already used");
    } else if (!isEmailAvailable) {
      SnackBarService.instance.showSnackBarError("Email already used");
    } else {
      _auth.registerUserWithEmailAndPassword(_email, _password,
          (String _uid) async {
        await DatabaseService.instance
            .createUserInDb(_uid, _email, _username, _password);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    return Container(
      height: widget._heigth * 0.55,
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
                "Welcome !",
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
          ),
          _inputForm(context, widget._changeSignPage),
        ],
      ),
    );
  }

  Widget _inputForm(BuildContext _context, Function _changeSignPage) {
    return Expanded(
      child: Form(
          key: _formKey,
          onChanged: () {
            _formKey.currentState.save();
          },
          child: Column(
            children: [
              _fullNameField(_context),
              _emailTextField(_context),
              _passwordTextField(_context),
              _submitButton(_context),
              _signUpSection(_context, _changeSignPage),
            ],
          )),
    );
  }

  Widget _fullNameField(BuildContext _context) {
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
              "username",
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
            style: Theme.of(_context).textTheme.headline4,
            validator: (_input) {
              return _input.length != 0 ? null : "Please Enter Your Username";
            },
            onSaved: (_input) {
              if (_input != null) {
                setState(() {
                  _username = _input;
                  _checkValidator();
                });
              }
            },
            cursorHeight: 18,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: "Type Your Username Here",
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
                  FontAwesomeIcons.user,
                  color: Colors.black,
                  size: 20,
                ),
                margin: EdgeInsets.all(7),
              ),
            ),
          ),
        ),
      ],
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
                  : "Please Enter a valid email";
            },
            onSaved: (_input) {
              if (_input != null) {
                setState(() {
                  _email = _input;
                  _checkValidator();
                });
              }
            },
            style: Theme.of(_context).textTheme.headline4,
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
            onSaved: (_input) {
              if (_input != null) {
                setState(() {
                  _password = _input;
                  _checkValidator();
                });
              }
            },
            style: Theme.of(_context).textTheme.headline4,
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
      padding: EdgeInsets.symmetric(
        horizontal: 70,
        vertical: 20,
      ),
      child: RaisedButton(
        onPressed: () => _isButtonEnable ? _userAuth() : null,
        color: _isButtonEnable ? Colors.red : Colors.red.withOpacity(0.5),
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            "Sign Up",
            style: _isButtonEnable
                ? Theme.of(_context).textTheme.headline5
                : Theme.of(_context).textTheme.headline5.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _signUpSection(BuildContext _context, Function _changeSignPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: Theme.of(_context).textTheme.headline4,
        ),
        TextButton(
          onPressed: () => _changeSignPage(),
          child: Text(
            "Sign In",
            style: Theme.of(_context)
                .textTheme
                .headline4
                .copyWith(fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
