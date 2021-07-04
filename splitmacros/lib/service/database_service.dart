import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splitmacros/model/user_data_model.dart';
import 'package:splitmacros/model/user_meals_model.dart';
import 'package:splitmacros/utils/constant.dart';

class DatabaseService {
  static DatabaseService instance = DatabaseService();
  FirebaseFirestore _db;
  var batch;
  //user
  String _userCollection = "Users";
  String _mealInfoCollection = "meals";
  //food

  DatabaseService() {
    _db = FirebaseFirestore.instance;
    batch = _db.batch();
  }

  Future<bool> checkUserNameIsAvailable(String _username) async {
    bool isValid = true;
    await _db
        .collection(_userCollection)
        .where("username", isEqualTo: _username)
        .get()
        .then((event) => {
              if (event.docs.isNotEmpty) {isValid = false}
            })
        .catchError((e) => print("error fetching data: $e"));
    return isValid;
  }

  Future<bool> checkEmailIsAvailable(String _email) async {
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
  }

  Future<void> createUserInDb(
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
  }

  // user generica data
  Stream<UserDataModel> getUserData(String _userID) {
    var _ref = _db.collection(_userCollection).doc(_userID);
    return _ref.get().asStream().map(
          (_snapshot) => UserDataModel.fromFirestore(_snapshot),
        );
  }

  Stream<List<UserMealModel>> getUserMealInfo(String _userID) {
    var _ref = _db
        .collection(_userCollection)
        .doc(_userID)
        .collection(_mealInfoCollection);
    return _ref.snapshots().map((_snapshot) => _snapshot.docs.map(
              (_doc) {
                return UserMealModel.fromFirestore(_doc);
              },
            ).toList()
        /* .sort((a, b) {
        var adate = a.mealNumber; //before -> var adate = a.expiry;
        var bdate = b.mealNumber; //before -> var bdate = b.expiry;
        return bdate.compareTo(adate);
      }), */
        );
  }

  Future<void> updateMealSplitType(int number, String _userId) async {
    try {
      return await _db.collection(_userCollection).doc(_userId).update(
        {
          "mealsSplitType": number,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> setDefaultMealSplit(String _userId) async {
    Constant.defaultMealSplit.forEach((element) {
      var docRef = _db
          .collection(_userCollection)
          .doc(_userId)
          .collection(_mealInfoCollection)
          .doc();
      batch.set(docRef, element);
    });
    return await batch.commit();
  }
}
