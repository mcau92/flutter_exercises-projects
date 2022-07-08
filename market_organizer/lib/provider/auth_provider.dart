import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/exception/login_exception.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/service/snackbar_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error
}

class AuthProvider extends ChangeNotifier {
  User? user;
  late UserDataModel? userData;
  late AuthStatus status;
  late FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late FirebaseFirestore _db;
  static AuthProvider instance = AuthProvider();

  String _userCollection = "users";
  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _db = FirebaseFirestore.instance;
    _checkCurrentUserIsAuthenticated();
  }

  void refreshUserData(UserDataModel userDataNew) async {
    userData = userDataNew;
    notifyListeners();
  }

  Future<UserDataModel> _getUserData() async {
    var _ref = _db.collection(_userCollection).doc(_auth.currentUser!.uid);
    return await _ref.get().then(
          (_snapshot) => UserDataModel.fromFirestore(_snapshot),
        );
  }

  void dispatchToRightPageAfterLogin(UserDataModel userData) async {
    if (userData.workspacesIdRef!.isEmpty) {
      NavigationService.instance.navigateToReplacement("home");
    } else {
      if (userData.favouriteWs != null && userData.favouriteWs!.isNotEmpty) {
        UserWorkspace focused = await DatabaseService.instance
            .getWorkspaceFromId(userData.favouriteWs!);
        NavigationService.instance
            .navigateToReplacementWithParameters("dispatchPage", focused);
      } else {
        NavigationService.instance.navigateToReplacement("home");
      }
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = _auth.currentUser;
    await Future.delayed(Duration(seconds: 1));
    if (user != null) {
      userData = await _getUserData();
      dispatchToRightPageAfterLogin(userData!);
      notifyListeners();
    } else {
      notifyListeners();
      NavigationService.instance.navigateToReplacement("auth");
    }
  }

  Future<void> loginUserWithEmailAndPassword(
      String _email, String _password) async {
    List<String> fetchMethods = await _auth.fetchSignInMethodsForEmail(_email);
    if (fetchMethods.contains("google.com")) {
      SnackBarService.instance
          .showSnackBarError("Utente registrato via google api");
      throw LoginException("Utente registrato via google api");
    }
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;

      status = AuthStatus.Authenticated;
      print("arrivo");
      userData = await _getUserData();
      SnackBarService.instance
          .showSnackBarSuccesfull("Ciao " + userData!.name! + "!");
      dispatchToRightPageAfterLogin(userData!);
    } catch (e) {
      status = AuthStatus.Error;
      SnackBarService.instance.showSnackBarError("Autenticazione fallita!");
      user = null;
      throw new LoginException("$e");
    }

    notifyListeners();
  }

  Future<void> registerUserWithEmailAndPassword(String _email, String _password,
      Future<void> onSuccess(String _uid)) async {
    List<String> fetchMethods = await _auth.fetchSignInMethodsForEmail(_email);

    if (fetchMethods.contains("google.com")) {
      SnackBarService.instance
          .showSnackBarError("utente gia creato via google");
      throw LoginException("utente gia creato via google");
    }
    status = AuthStatus.Authenticating;
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user!.uid);
      userData = await _getUserData();
      SnackBarService.instance
          .showSnackBarSuccesfull("Benvenuto " + userData!.name! + "!");
      NavigationService.instance.navigateToReplacement("home");
    } catch (e) {
      print(e);
      status = AuthStatus.Error;

      SnackBarService.instance.showSnackBarError("Registrazione fallita!");
      user = null;
      throw LoginException("$e");
    }
    notifyListeners();
  }

  void deleteAndlogoutUser() async {
    try {
      await user!.delete();
      user = null;
      userData = null;
      status = AuthStatus.NotAuthenticated;

      NavigationService.instance.navigateToReplacement("auth");

      notifyListeners();
    } catch (e) {}
  }

  void logoutUser() async {
    try {
      List<String> fetchMethods =
          await _auth.fetchSignInMethodsForEmail(_auth.currentUser!.email!);

      if (fetchMethods.contains("google.com")) {
        await _googleSignIn.signOut();
      }

      await _auth.signOut();

      user = null;
      userData = null;
      status = AuthStatus.NotAuthenticated;
      notifyListeners();
      NavigationService.instance.navigateToReplacement("auth");
    } catch (e) {
      print(e);
    }
  }

  void sendRecoveryPassword(String email) {
    _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
    List<String> fetchMethods =
        await _auth.fetchSignInMethodsForEmail(googleSignInAccount!.email);
    for (var string in fetchMethods) {
      print(string);
    }
    if (fetchMethods.contains("password")) {
      SnackBarService.instance
          .showSnackBarError("utente gia creato via login page");
      return;
    }

    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );
    UserCredential authResult = await _auth.signInWithCredential(credential);
    user = authResult.user;

    if (fetchMethods.isEmpty) {
      //register user otherwise is still register in db
      await DatabaseService.instance
          .createUserInDb(user!.uid, user!.email!, user!.displayName!);
    }

    userData = await _getUserData();
    dispatchToRightPageAfterLogin(userData!);
  }
}
