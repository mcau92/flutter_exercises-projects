import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricette.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/utils/color_costant.dart';

class DatabaseService {
  static DatabaseService instance = DatabaseService();

  String _spesaCollection = "spesa";
  String _menuCollection = "menu";
  String _ricettaCollection = "recipts";
  String _userCollection = "users";
  String _workspaceCollection = "workspace";
  String _productCollection = "product";

  FirebaseFirestore _db;
  var batch;
  DatabaseService() {
    _db = FirebaseFirestore.instance;
    batch = _db.batch();
  }
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

  Future<UserDataModel> getUserData(String _userID) async {
    var _ref = _db.collection(_userCollection).doc(_userID);
    return await _ref.get().then(
          (_snapshot) => UserDataModel.fromFirestore(_snapshot),
        );
  }

  Future<List<UserWorkspace>> getUserWorkspace(String _userID) async {
    var _ref = _db
        .collection(_workspaceCollection)
        .where("ownerId", isEqualTo: _userID);
    return await _ref.get().then(
        (_qs) => _qs.docs.map((e) => UserWorkspace.fromFirestore(e)).toList());
  }

  Future<UserWorkspace> getWorkspaceFromId(String _wsId) async {
    var _ref = _db.collection(_workspaceCollection).doc(_wsId);
    return await _ref.get().then((_ds) => UserWorkspace.fromFirestore(_ds));
  }

  Stream<List<Spesa>> getSpesaFromIdAndDate(
      String workspaceIdsRef, DateTime start, DateTime end) {
    var _ref = _db
        .collection(_spesaCollection)
        .where("workspaceIdRef", isEqualTo: workspaceIdsRef)
        .where("startWeek", isEqualTo: start)
        .where("endWeek", isEqualTo: end);
    return _ref.snapshots().map(
          (_q) => _q.docs.map(
            (_d) {
              return Spesa.fromFirestore(_d);
            },
          ).toList(),
        );
  }

  Future<List<Ricette>> getReciptsFromMenuId(String menuId) async {
    return await _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_ricettaCollection)
        .get()
        .then((value) =>
            value.docs.map((ds) => Ricette.fromFirestore(ds)).toList());
  }

  Stream<List<Menu>> getMenuFromDate(
      String workspaceIdsRef, DateTime start, DateTime end) {
    var _ref = _db
        .collection(_menuCollection)
        .where("workspaceIdRef", isEqualTo: workspaceIdsRef)
        .where("startWeek", isEqualTo: start)
        .where("endWeek", isEqualTo: end);
    return _ref.snapshots().map(
          (_q) => _q.docs.map(
            (_d) {
              return Menu.fromFirestore(_d);
            },
          ).toList(),
        );
  }

  Future<List<Ricette>> searchRicetteByName(String string) async {
    //per ogni menu, aggiungo le ricette che non sono duplicate
    //vado quindi a cercare se una certa ricetta nel menu corrente è presente guardando il nome e la descrizione
    List<Ricette> ricette = [];
    await _db.collection(_menuCollection).get().then(
          (qs) => qs.docs.map(
            (qd) => qd.reference.collection(_ricettaCollection).get().then(
                  (qs) => ricette.add(
                    Ricette.fromFirestore(qd),
                  ),
                ),
          ),
        );
    return ricette.isNotEmpty
        ? ricette
            .where((r) => r.name.toUpperCase().startsWith(string.toUpperCase()))
            .toList()
        : [];
  }

  void insertSearchedRicettaOnMenu(
      Ricette ricetta,
      Map<Product, bool>
          products, //prodotti da inserire, booleano che indica se devo inserire in spesa
      Menu menu,
      String pasto,
      String ownerId,
      String ownerName,
      DateTime date) async {
    if (menu.id == null) {
      //creo menu nuovo
      DocumentReference docRef = await _db.collection(_menuCollection).add({
        "name": "default",
        "ownerId": ownerId,
        "startWeek": menu.startWeek,
        "endWeek": menu.endWeek,
        "workspaceIdRef": menu.workspaceIdRef
      });
      //aggiorno il menu con il suo nuovo id
      menu.id = docRef.id;
    }
    ricetta.pasto = pasto;
    ricetta.date = date;
    String _color = await getUserColorForRecipt(menu.id, ownerId);
    ricetta.color = _color;
    ricetta.ownerId = ownerId;
    ricetta.ownerName = ownerName;
    //inserisco ricetta
    DocumentReference ricettaDocRef = await _db
        .collection(_menuCollection)
        .doc(menu.id)
        .collection(_ricettaCollection)
        .add({
      "ownerId": ownerId,
      "ownerName": ownerName,
      "color": _color,
      "name": ricetta.name,
      "description": ricetta.description,
      "pasto": pasto,
      "date": date,
      "image": "",
      "menuIdRef": menu.id,
    });
    //aggiorno i product e aggiungo il riferimento alla ricetta e metto a null l'id perchè cosi gestico anche il fatto che siano prodotti creati da zero o meno

    products.entries.forEach((entry) async{
      Product p = entry.key;
      p.id = null;
      p.ricettaIdRef = ricettaDocRef.id;
      DocumentReference pRef = await _db
          .collection(_menuCollection)
          .doc(menu.id)
          .collection(_ricettaCollection)
          .add(p.toMap());
          if(entry.value){
            //insert on spesa and update CONTINUARE
          }
    });
  }

  Future<String> getUserColorForRecipt(String menuId, String ownerId) async {
    String color;
    if (menuId == null) {
      return ColorCostant.colorMap.keys.first;
    }
    var _recRef = _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_ricettaCollection);
    color = await _recRef.where("ownerId", isEqualTo: ownerId).get().then(
      (qs) {
        if (qs.docs.isNotEmpty) {
          return qs.docs.first["color"];
        } else
          return null;
      },
    );
    if (color == null) {
      List<String> colorsUsed = [];
      await _recRef
          .get()
          .then((qs) => qs.docs.map((ds) => colorsUsed.add(ds["color"])));
      if (colorsUsed.isNotEmpty) {
        //filter color
        color = ColorCostant.colorMap.keys
            .where((c) => !colorsUsed.contains(c))
            .first;
      } else {
        color = ColorCostant.colorMap.keys.first; //first product
      }
    }
    return color;
  }

//
  Stream<List<Product>> getProductsBySpesa(String spesaId) {
    var _ref = _db
        .collection(_spesaCollection)
        .doc(spesaId)
        .collection(_productCollection);
    return _ref.snapshots().map(
          (_q) => _q.docs.map(
            (_d) {
              return Product.fromFirestore(_d);
            },
          ).toList(),
        );
  }

  Future<List<String>> getUserRepartiByInput(
      String pattern, String userId) async {
    List<String> mergedReparti = [];
    if (pattern == null || pattern.isEmpty) {
      return mergedReparti;
    }
    var _ref =
        _db.collection(_spesaCollection).where("ownerId", isEqualTo: userId);
    await _ref.get().then((qs) => qs.docs.forEach((doc) {
          doc.reference
              .collection(_productCollection)
              //.where("reparto", isGreaterThanOrEqualTo: pattern)
              .get()
              .then((prodQuery) => prodQuery.docs.forEach((product) {
                    if (product["reparto"]
                            .toString()
                            .toLowerCase()
                            .startsWith(pattern.toLowerCase()) &&
                        mergedReparti.indexWhere((element) =>
                                element.toLowerCase() ==
                                product["reparto"].toString().toLowerCase()) ==
                            -1) {
                      mergedReparti.add(product["reparto"]);
                    }
                  }));
        }));
    return mergedReparti;
  }

  Future<String> getUserColorForSpesa(String spesaId, String ownerId) async {
    String color;
    var _prodRef = _db
        .collection(_spesaCollection)
        .doc(spesaId)
        .collection(_productCollection);
    color = await _prodRef.where("ownerId", isEqualTo: ownerId).get().then(
      (qs) {
        if (qs.docs.isNotEmpty) {
          return qs.docs.first["color"];
        } else
          return null;
      },
    );
    if (color == null) {
      List<String> colorsUsed = [];
      await _prodRef
          .get()
          .then((qs) => qs.docs.map((ds) => colorsUsed.add(ds["color"])));
      if (colorsUsed.isNotEmpty) {
        //filter color
        color = ColorCostant.colorMap.keys
            .where((c) => !colorsUsed.contains(c))
            .first;
      } else {
        color = ColorCostant.colorMap.keys.first; //first product
      }
    }
    return color;
  }

  Future<void> insertProductOnSpesa(
      String spesaIdRef,
      String ownerId,
      String productName,
      String productDescription,
      String productReparto,
      double quantity,
      String measureUnit,
      String currency,
      double price) async {
    String _color = await getUserColorForSpesa(spesaIdRef, ownerId);
    await _db
        .collection(_spesaCollection)
        .doc(spesaIdRef)
        .collection(_productCollection)
        .doc()
        .set({
      "color": _color,
      "description": (productDescription == null || productDescription.isEmpty)
          ? "nessuna descrizione"
          : productDescription,
      "image": "",
      "measureUnit": measureUnit,
      "name": productName,
      "ownerId": ownerId,
      "ownerName": "Michael",
      "quantity": quantity,
      "reparto": productReparto,
      "spesaIdRef": spesaIdRef,
      "currency": price != null ? "€" : null,
      "price": price
    });
    await _db
        .collection(_spesaCollection)
        .doc(spesaIdRef)
        .update({"ammount": FieldValue.increment(price)});
  }

  Future<void> updateProductOnSpesa(
      String productId,
      String spesaIdRef,
      String ownerId,
      String productName,
      String productDescription,
      String productReparto,
      double quantity,
      String measureUnit,
      String currency,
      double price,
      double priceDifference) async {
    await _db
        .collection(_spesaCollection)
        .doc(spesaIdRef)
        .collection(_productCollection)
        .doc(productId)
        .update({
      "name": productName,
      "description": (productDescription == null || productDescription.isEmpty)
          ? "nessuna descrizione"
          : productDescription,
      "image": "",
      "measureUnit": measureUnit,
      "quantity": quantity,
      "reparto": productReparto,
      "currency": price != null ? "€" : null,
      "price": price
    });
    if (priceDifference != 0)
      await _db
          .collection(_spesaCollection)
          .doc(spesaIdRef)
          .update({"ammount": FieldValue.increment(priceDifference)});
  }

  Future<Spesa> createNewSpesa(Spesa spesa) async {
    var docRef = await _db.collection(_spesaCollection).add({
      "ownerId": spesa.ownerId,
      "startWeek": spesa.startWeek,
      "endWeek": spesa.endWeek,
      "ammount": 0.0,
      "workspaceIdRef": spesa.workspaceIdRef
    });
    spesa.id = docRef.id;
    return spesa;
  }

  Future<void> deleteProduct(Product product) async {
    await _db
        .collection(_spesaCollection)
        .doc(product.spesaIdRef)
        .collection(_productCollection)
        .doc(product.id)
        .delete();
    await _db
        .collection(_spesaCollection)
        .doc(product.spesaIdRef)
        .update({"ammount": FieldValue.increment(0 - product.price)});
  }

  Future<int> getSpesaProductsSize(String spesaIdRef) async {
    int prods = await _db
        .collection(_spesaCollection)
        .doc(spesaIdRef)
        .collection(_productCollection)
        .get()
        .then((value) => value.size);
    return prods;
  }

  Future<void> deleteSpesa(String spesaIdRef) async {
    return await _db.collection(_spesaCollection).doc(spesaIdRef).delete();
  }
}
