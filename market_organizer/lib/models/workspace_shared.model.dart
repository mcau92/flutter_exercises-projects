class WorkspaceShared {
  String? ownerId;
  String? workspaceId;
  String? permissions;

  WorkspaceShared({
    this.ownerId,
    this.workspaceId,
    this.permissions,
  });

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
