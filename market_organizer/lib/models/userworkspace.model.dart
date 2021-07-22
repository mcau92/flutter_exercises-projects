import 'package:market_organizer/models/product_model.dart';

class UserWorkspace {
  String id;
  String name;
  String ownerId;
  List<String> contributorsId;
  DateTime date;
  List<Product> products;
  bool focused; //last user selected workspace on homepage

  UserWorkspace(
      {this.id, this.name, this.ownerId, this.contributorsId,this.date,this.products, this.focused});

  static List<UserWorkspace> example = [
    new UserWorkspace(
        id: "nadLzn6xd00BJcpy1Gtc",
        name: "Spesa",
        ownerId: "nadLzn6xd00BJcpy1Gtc",
        contributorsId: ["nadLzn6xd00BJcpy1Gtc","nBwscXIfGQogH4BxkrtX"],
        date: DateTime.now().add(Duration(days: 7),),
        products: [
          Product(
              ownerId: "nadLzn6xd00BJcpy1Gtc",
              ownerName: "michael",
              color: "blue",
              description: "1 casco di banane mature",
              name: "Banane",
              measureUnit: "piece",
              quantity: 4,
              image:
                  "https://cdn.iconscout.com/icon/free/png-256/banana-1624204-1375362.png",
              reparto: "Frutta e verdura"),
          Product(
              ownerId: "nBwscXIfGQogH4BxkrtX",
              ownerName: "giulia",
              color: "pink",
              description: "pollo a fettine",
              name: "Petto di pollo",
              measureUnit: "g",
              quantity: 200,
              image:
                  "https://image.flaticon.com/icons/png/512/1046/1046751.png",
              reparto: "Macelleria")
        ],
        focused: true),
  ];
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
