import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitmacros/service/navigator_service.dart';
import 'package:splitmacros/service/snackbar_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error
}

class AuthProvider extends ChangeNotifier {
  User user;
  AuthStatus status;
  FirebaseAuth _auth;
  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    //_checkCurrentUserIsAuthenticated(); TODO remove exception
  }
  /* void _autoLogin() async {
    if (user != null) {
      return NavigationService.instance.navigateToReplacement("home");
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = _auth.currentUser;
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
  } */

  void loginUserWithEmailAndPassword(String _email, String _password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      SnackBarService.instance
          .showSnackBarSuccesfull("Welcome back, ${user.email}");
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      status = AuthStatus.Error;
      SnackBarService.instance
          .showSnackBarError("Error Authenticating,check username or password");
      user = null;
    }
    notifyListeners();
  }

  void registerUserWithEmailAndPassword(String _email, String _password,
      Future<void> onSuccess(String _uid)) async {
    status = AuthStatus.Authenticating;
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid);
      SnackBarService.instance.showSnackBarSuccesfull("Welcome, ${user.email}");
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      print(e);
      status = AuthStatus.Error;
      SnackBarService.instance
          .showSnackBarError("Error Registering, try again");
      user = null;
    }
    notifyListeners();
  }

  void logoutUser(Future<void> onSuccess()) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      await NavigationService.instance.navigateToReplacement("login");
    } catch (e) {
      SnackBarService.instance.showSnackBarError("Error Loging out");
    }
  }

  void sendRecoveryPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      SnackBarService.instance
          .showSnackBarSuccesfull("Check your email to reset your password");
      NavigationService.instance.navigateToReplacement("login");
    } catch (e) {
      print(e);
      SnackBarService.instance
          .showSnackBarError("Error sending recovery email");
    }

    notifyListeners();
  }
}
