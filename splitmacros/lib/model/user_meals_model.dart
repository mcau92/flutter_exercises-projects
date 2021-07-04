import 'package:cloud_firestore/cloud_firestore.dart';

class UserMealModel {
  String id;
  String mealName;
  int mealNumber;
  String mealPercImportance;
  int mealKcal;
  int mealCarbsPerc;
  int mealProteinsPerc;
  int mealFatsPerc;

  UserMealModel(
      {this.id,
      this.mealName,
      this.mealNumber,
      this.mealPercImportance,
      this.mealKcal,
      this.mealCarbsPerc,
      this.mealProteinsPerc,
      this.mealFatsPerc});

  factory UserMealModel.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();

    return UserMealModel(
        id: _snapshot.id,
        mealName: _data["mealName"],
        mealNumber: _data["mealNumber"],
        mealPercImportance: _data["mealPercImportance"],
        mealKcal: _data["mealKcal"],
        mealCarbsPerc: _data["mealCarbsPerc"],
        mealProteinsPerc: _data["mealProteinsPerc"],
        mealFatsPerc: _data["mealFatsPerc"]);
  }
}
