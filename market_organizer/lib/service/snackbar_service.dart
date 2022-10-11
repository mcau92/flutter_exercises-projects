import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackBarService {
  late BuildContext _buildContext;

  static SnackBarService instance = SnackBarService();

  SnackBarService();

  set buildContext(BuildContext _context) {
    _buildContext = _context;
  }

  void showSnackBarError(String _message) {
    ScaffoldMessenger.of(_buildContext).showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        margin: EdgeInsets.all(20),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        content: Text(
          _message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSnackBarSuccesfull(String _message) {
    ScaffoldMessenger.of(_buildContext).showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        content: Text(
          _message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}