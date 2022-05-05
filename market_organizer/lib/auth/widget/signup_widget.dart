import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/snackbar_service.dart';
import 'package:provider/provider.dart';

class SignUpWidget extends StatefulWidget {
  Function _changeSignPage;
  SignUpWidget(this._changeSignPage);

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  late AuthProvider _auth;
  late String _name;
  late String _email;
  late String _password;
  late bool _isButtonEnable = false;
  late GlobalKey<FormState> _formKey;

  _SignUpWidgetState() {
    _formKey = GlobalKey<FormState>();
  }

  void _checkValidator() {
    if (_name != null &&
        _name.length > 0 &&
        _email != null &&
        _password != null &&
        _email.length > 0 &&
        _password.length > 5 &&
        (_email.contains('@') && _email.contains('.'))) {
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
    _name = _name.trim();
    _auth.registerUserWithEmailAndPassword(_email, _password,
        (String _uid) async {
      try {
        await DatabaseService.instance.createUserInDb(_uid, _email, _name);
      } catch (e) {
        SnackBarService.instance.showSnackBarError(
            "impossibile creare l'utente, riprovare in un secondo momento");
      }
    });
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
              _nameField(_context),
              SizedBox(
                height: 30,
              ),
              _emailTextField(_context),
              SizedBox(
                height: 30,
              ),
              _passwordTextField(_context),
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
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(color: Colors.black),
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
              : "Inserisci un'email valida";
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
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _passwordTextField(BuildContext _context) {
    return Container(
      child: TextFormField(
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
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: TextStyle(color: Colors.black),
        ),
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
      onTap: () => _isButtonEnable ? _userAuth() : null,
    );
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
