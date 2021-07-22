import 'package:market_organizer/models/workspace_shared.model.dart';

class UserDataModel {
  String id;
  String email;
  String password;
  String name;
  String surname;
  List<WorkspaceShared> workspaceShared;

  UserDataModel({
    this.id,
    this.email,
    this.password,
    this.name,
    this.surname,
    this.workspaceShared,
  });
  static UserDataModel example = 
    new UserDataModel(
      id: "nadLzn6xd00BJcpy1Gtc",
      email: "92mika@gmail.com",
      password: "testtest",
      name: "michael",
      surname: "cauduro",
      workspaceShared: [],
    );
  /* factory UserDataModel.fromFirestore(DocumentSnapshot _snapshot) {
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
  } */
}
