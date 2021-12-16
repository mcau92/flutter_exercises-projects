import 'package:cloud_firestore/cloud_firestore.dart';
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
  static UserDataModel example = new UserDataModel(
    id: "LMgqupuW0wVW4RZn3QyC0y9Xxrg1",
    email: "92mika@gmail.com",
    password: "testtest",
    name: "michael",
    surname: "cauduro",
    workspaceShared: [],
  );

  factory UserDataModel.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data();
    List _wks = _data["workspaceShared"];
    if (_wks != null && _wks != []) {
      _wks = _wks.map((_w) {
        return WorkspaceShared(
            ownerId: _w["ownerId"],
            permissions: _w["permissions"],
            workspaceId: _w["workspaceId"]);
      }).toList();
    } else {
      _wks = [];
    }
    return UserDataModel(
      id: _snapshot.id,
      email: _data["email"],
      password: _data["password"],
      name: _data["name"],
      surname: _data["surname"],
      workspaceShared: _wks,
    );
  }
}
