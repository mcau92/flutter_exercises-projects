import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/exception/login_exception.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/service/snackbar_service.dart';
import 'package:provider/provider.dart';

class SignUpWidget extends StatefulWidget {
  Function _changeSignPage;
  final Function _loadingData;
  SignUpWidget(this._changeSignPage, this._loadingData);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  late AuthProvider _auth;
  String? _name;
  String? _email;
  String? _password;

  bool _passwordVisible = false;
  bool _isButtonEnable = false;
  late GlobalKey<FormState> _formKey;

  _SignUpWidgetState() {
    _formKey = GlobalKey<FormState>();
  }

  void _checkValidator() {
    if (_name != null &&
        _name!.length > 0 &&
        _email != null &&
        _password != null &&
        _email!.length > 0 &&
        _password!.length > 5 &&
        (_email!.contains('@') && _email!.contains('.'))) {
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
    //detect keyboard and close
    _email = _email!.trim();
    _name = _name!.trim();
    widget._loadingData();
    try {
      await _auth.registerUserWithEmailAndPassword(_email!, _password!,
          (String _uid) async {
        try {
          await DatabaseService.instance.createUserInDb(_uid, _email!, _name!);
        } on LoginException catch (e) {
          print("$e");
          SnackBarService.instance.showSnackBarError(
              "impossibile creare l'utente, riprovare in un secondo momento");

          widget._loadingData();
        }
      });
    } on LoginException catch (e) {
      print("$e");
      widget._loadingData();
    }
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20),
      child: Container(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Registrati",
                style: Theme.of(context).textTheme.headline4?.copyWith(
                    color: Colors.black, fontWeight: FontWeight.bold),
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
              _nameBox(_context),
              SizedBox(
                height: 30,
              ),
              _emailBox(_context),
              SizedBox(
                height: 30,
              ),
              _passwordBox(_context),
              SizedBox(
                height: 50,
              ),
              _submitButton(_context),
              SizedBox(
                height: 30,
              ),
              _signUpSection(_context),
            ],
          )),
    );
  }

  Widget _nameBox(BuildContext _context) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: _nameField(_context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _nameField(BuildContext _context) {
    return Container(
      child: TextFormField(
        textAlignVertical: TextAlignVertical.bottom,
        textAlign: TextAlign.start,
        autocorrect: false,
        style: Theme.of(_context).textTheme.headline5?.copyWith(fontSize: 18),
        validator: (_input) {
          return _input?.length != 0 ? null : "Inserisci il tuo nome";
        },
        onSaved: (_input) {
          if (_input != null) {
            setState(() {
              _name = _input;
              _checkValidator();
            });
          }
        },
        cursorHeight: 20,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: "Nome",
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _emailBox(BuildContext _context) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: _emailTextField(_context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.black,
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
        style: Theme.of(_context).textTheme.headline5?.copyWith(fontSize: 18),
        onSaved: (_input) {
          if (_input != null) {
            setState(() {
              _email = _input;
              _checkValidator();
            });
          }
        },
        cursorHeight: 20,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: "Email",
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(color: Colors.black),
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
            icon: Icon(_passwordVisible
                ? CupertinoIcons.eye_slash
                : CupertinoIcons.eye),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.black,
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
      style: Theme.of(_context).textTheme.headline5?.copyWith(fontSize: 18),
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
        hintText: "Password",
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _submitButton(BuildContext _context) {
    double _width = MediaQuery.of(_context).size.width;

    double _height = MediaQuery.of(_context).size.height;
    return InkWell(
        child: Container(
          width: _width / 2,
          height: _height / 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.orange,
          ),
          child: Center(
            child: Text(
              'Registrati',
              style: _isButtonEnable
                  ? Theme.of(_context)
                      .textTheme
                      .headline5
                      ?.copyWith(color: Colors.white, fontSize: 18)
                  : Theme.of(_context).textTheme.headline5?.copyWith(
                      color: Colors.white.withOpacity(0.5), fontSize: 18),
            ),
          ),
        ),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          _isButtonEnable ? _userAuth() : null;
        });
  }

  Widget _signUpSection(BuildContext _context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Hai gia un account? ",
            style:
                Theme.of(_context).textTheme.headline6?.copyWith(fontSize: 16),
          ),
          TextButton(
            onPressed: () => widget._changeSignPage(),
            child: Text(
              "Accedi",
              style: Theme.of(_context)
                  .textTheme
                  .headline6
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
