import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataModel {
  String? id;
  String? email;
  String? image;
  String? password;
  String? name;
  List<String>? workspacesIdRef;
  String? favouriteWs;

  UserDataModel({
    this.id,
    this.email,
    this.image,
    this.password,
    this.name,
    this.workspacesIdRef,
    this.favouriteWs,
  });

  factory UserDataModel.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map;
    return UserDataModel(
        id: _snapshot.id,
        email: _data["email"],
        image: _data["image"],
        password: _data["password"],
        name: _data["name"],
        workspacesIdRef: _data["workspacesIdRef"].cast<String>(),
        favouriteWs: _data["favouriteWs"]);
  }
}
