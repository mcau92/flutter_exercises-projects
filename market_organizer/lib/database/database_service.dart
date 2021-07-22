import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';

class DatabaseService{

  static DatabaseService instance = DatabaseService();

  String _userCollection = "users";
  String _workspaceCollection = "workspace";
  String _productsCollection = "products";

  /* Future<bool> checkEmailIsAvailable(String _email) async {
    bool isValid = true;
    await _db
        .collection(_userCollection)
        .where("email", isEqualTo: _email)
        .get()
        .then((event) => {
              if (event.docs.isNotEmpty) {isValid = false}
            })
        .catchError((e) => print("error fetching data: $e"));
    return isValid;
  } */

  /* Future<void> createUserInDb(
      String _userId, String _email, String _username, String _password) async {
    try {
      return await _db.collection(_userCollection).doc(_userId).set(
        {
          "username": _username,
          "email": _email,
          "password": _password,
        },
      );
    } catch (e) {
      print(e);
    }
  } */

  Stream<UserDataModel> getUserData(String _userID) {
    /* var _ref = _db.collection(_userCollection).doc(_userID);
    return _ref.get().asStream().map(
          (_snapshot) => UserDataModel.fromFirestore(_snapshot),
        ); */
    return Stream.value(UserDataModel.example);
  }

  Stream<List<UserWorkspace>> getUserWorkspace(String _userID) {
    /* var _ref = _db.collection(_userCollection).doc(_userID);
    return _ref.get().asStream().map(
          (_snapshot) => UserDataModel.fromFirestore(_snapshot),
        ); */
    return Stream.value(UserWorkspace.example);
  }
}