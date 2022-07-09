import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/exception/login_exception.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class SignInWidget extends StatefulWidget {
  final Function _changeSignPage;
  final Function _resetPassword;
  final Function _loadingData;
  SignInWidget(this._changeSignPage, this._resetPassword, this._loadingData);

  @override
  _SignInWidgetState createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  late AuthProvider _auth;
  String? _email;
  String? _password;
  bool _isButtonEnable = false;
  bool _passwordVisible = false;
  late GlobalKey<FormState> _formKey;

  _SignInWidgetState() {
    _formKey = GlobalKey<FormState>();
  }
  void _checkValidator() {
    if (_email != null &&
        _password != null &&
        _email!.length > 3 &&
        _password!.length > 3 &&
        _email!.contains('@') &&
        _email!.contains('.')) {
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
    widget._loadingData();
    try {
      await _auth.loginUserWithEmailAndPassword(_email!, _password!);
    } on LoginException catch (e) {
      print("$e");
      widget._loadingData();
    }
  }

  void _signInWithGoogle() async {
    await _auth.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20),
      child: Container(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Login",
                style: Theme.of(context).textTheme.headline4?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(
              thickness: 10,
              color: Colors.orange,
              endIndent: 250,
            ),
            _inputForm(context),
          ],
        ),
      ),
    );
  }

  Widget _inputForm(BuildContext _context) {
    return Expanded(
      flex: 2,
      child: Form(
          key: _formKey,
          onChanged: () {
            _formKey.currentState?.save();
          },
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              _emailBox(_context),
              SizedBox(
                height: 30,
              ),
              _passwordBox(_context),
              SizedBox(
                height: 10,
              ),
              _passwordForgotten(_context),
              SizedBox(
                height: 30,
              ),
              _submitButton(_context),
              SizedBox(
                height: 30,
              ),
              _socialButtons(_context),
              SizedBox(
                height: 50,
              ),
              _signUpSection(_context),
            ],
          )),
    );
  }

  Widget _emailBox(BuildContext _context) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: _emailTextField(_context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _emailTextField(BuildContext _context) {
    return Container(
      child: TextFormField(
        textAlignVertical: TextAlignVertical.bottom,
        textAlign: TextAlign.start,
        autocorrect: false,
        validator: (_input) {
          return _input != null && (_input.length != 0 || _input.contains('@'))
              ? null
              : "Please Enter a Valid Email";
        },
        style: Theme.of(_context)
            .textTheme
            .headline5
            ?.copyWith(fontSize: 18, color: Colors.white),
        onSaved: (_input) {
          if (_input != null) {
            setState(() {
              _email = _input;
              _checkValidator();
            });
          }
        },
        cursorHeight: 20,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: "Email",
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _passwordBox(BuildContext _context) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Expanded(
            child: _passwordTextField(_context),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
            icon: Icon(
              _passwordVisible ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _passwordTextField(BuildContext _context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      obscureText: !_passwordVisible,
      textAlignVertical: TextAlignVertical.bottom,
      textAlign: TextAlign.start,
      autocorrect: false,
      validator: (_input) {
        return _input?.length != 0 ? null : "Inserisci la password";
      },
      style: Theme.of(_context)
          .textTheme
          .headline5
          ?.copyWith(fontSize: 18, color: Colors.white),
      onSaved: (_input) {
        if (_input != null) {
          setState(() {
            _password = _input;
            _checkValidator();
          });
        }
      },
      cursorHeight: 18,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: "Password",
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _passwordForgotten(BuildContext _context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        onPressed: () => widget._resetPassword(),
        child: Text("Password dimenticata?",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange)),
      ),
    );
  }

  Widget _submitButton(BuildContext _context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: CupertinoButton(
        color: Colors.orange,
        child: Text(
          'Accedi',
          style: _isButtonEnable
              ? Theme.of(_context)
                  .textTheme
                  .headline5
                  ?.copyWith(color: Colors.white, fontSize: 18)
              : Theme.of(_context).textTheme.headline5?.copyWith(
                  color: Colors.white.withOpacity(0.5), fontSize: 18),
        ),
        onPressed: () async {
          FocusManager.instance.primaryFocus?.unfocus();
          _isButtonEnable ? _userAuth() : null;
        },
      ),
    );
  }

  Widget _signUpSection(BuildContext _context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Non hai un account? ",
          style: Theme.of(_context)
              .textTheme
              .headline6
              ?.copyWith(fontSize: 16, color: Colors.white),
        ),
        TextButton(
          onPressed: () => widget._changeSignPage(),
          child: Text(
            "Registrati",
            style: Theme.of(_context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange),
          ),
        )
      ],
    );
  }

  Widget _socialButtons(BuildContext _context) {
    double _width = MediaQuery.of(_context).size.width;
    double _height = MediaQuery.of(_context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "--Oppure--",
          style: TextStyle(color: Colors.white),
        ),
        InkWell(
          child: Container(
              width: _width / 2,
              height: _height / 18,
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 30.0,
                    width: 30.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/google_logo.png'),
                          fit: BoxFit.cover),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    'Accedi con Google',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ))),
          onTap: () => _signInWithGoogle(),
        )
      ],
    );
  }
}
