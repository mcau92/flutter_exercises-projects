import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataModel {
  String id;
  String username;
  String email;
  String password;
  int kcal;
  int mealsSplitType;
  int carbsPerc;
  int proteinsPerc;
  int fatsPerc;

  UserDataModel(
      {this.id,
      this.username,
      this.email,
      this.password,
      this.kcal,
      this.mealsSplitType,
      this.carbsPerc,
      this.proteinsPerc,
      this.fatsPerc});

  factory UserDataModel.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();

    return UserDataModel(
        id: _snapshot.id,
        username: _data["username"],
        email: _data["email"],
        password: _data["password"],
        kcal: _data["kcal"],
        mealsSplitType:_data["mealsSplitType"],
        carbsPerc: _data["carbsPerc"],
        proteinsPerc: _data["proteinsPerc"],
        fatsPerc: _data["fatsPerc"]);
  }
}
