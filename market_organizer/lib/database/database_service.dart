import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_model.dart';
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

  Future<List<Ricetta>> getReciptsFromMenuId(String menuId) async {
    return await _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_ricettaCollection)
        .get()
        .then((value) =>
            value.docs.map((ds) => Ricetta.fromFirestore(ds)).toList());
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

  Future<List<Ricetta>> searchRicetteByName(String string) async {
    //per ogni menu, aggiungo le ricette che non sono duplicate
    //vado quindi a cercare se una certa ricetta nel menu corrente è presente guardando il nome e la descrizione
    List<Ricetta> ricette = [];
    await _db.collection(_menuCollection).get().then(
          (qs) => qs.docs.map(
            (qd) => qd.reference.collection(_ricettaCollection).get().then(
                  (qs) => ricette.add(
                    Ricetta.fromFirestore(qd),
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

/*
*metodo che inserisce o aggiorna un menu inserendo una nuova ricetta
* riceve una ricetta, una mappa prodotto e boolean per capire se inserirli anche nella spesa e riceve altri dati utili all'inserimento
* la ricetta che arriva sarà gia senza id per poter gestire l'inserimento da lista consigli o nuova 
*/
  void insertSearchedRicettaOnMenu(
    Ricetta ricetta,
    MealDetailModel details,
    Map<Product, bool> products,
  ) //prodotti da inserire, booleano che indica se devo inserire in spesa
  async {
    String menuId = details.singleDayPageInput.menuIdRef;
    if (menuId == null) {
      //creo menu nuovo
      DocumentReference docRef = await _db.collection(_menuCollection).add({
        "name": "default",
        "ownerId": ricetta.ownerId,
        "startWeek": details.singleDayPageInput.dateStart,
        "endWeek": details.singleDayPageInput.dateEnd,
        "workspaceIdRef": details.singleDayPageInput.workspaceId
      });
      //aggiorno il menu con il suo nuovo id
      menuId = docRef.id;
    }
    String _color = await getUserColorForRecipt(
      details.singleDayPageInput.workspaceId,
      ricetta.ownerId,
    );
    //inserisco ricetta
    DocumentReference ricettaDocRef = await _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_ricettaCollection)
        .add({
      "ownerId": ricetta.ownerId,
      "ownerName": ricetta.ownerName,
      "color": _color,
      "name": ricetta.name,
      "description": ricetta.description,
      "pasto": ricetta.pasto,
      "date": ricetta.date,
      "image": "",
      "menuIdRef": menuId,
    });
    //aggiorno i product e aggiungo il riferimento alla ricetta e metto a null l'id perchè cosi gestico anche il fatto che siano prodotti creati da zero o meno
    //transazione
    _db.runTransaction((transaction) async {
      products.entries.forEach((entry) async {
        Product p = entry.key;
        p.id = null;
        p.ricettaIdRef = ricettaDocRef.id;
        CollectionReference prodRef = _db
            .collection(_menuCollection)
            .doc(menuId)
            .collection(_ricettaCollection)
            .doc(ricettaDocRef.id)
            .collection(_productCollection);
        transaction
            .set(prodRef.doc(), {
              'ownerId': p.ownerId,
              'ownerName': p.ownerName,
              'color': "",
              'name': p.name,
              'description': p.description,
              'measureUnit': p.measureUnit,
              'quantity': p.quantity,
              'image': p.image,
              'reparto': p.reparto,
              'spesaIdRef': p.spesaIdRef,
              'ricettaIdRef': p.ricettaIdRef,
              'currency': p.currency,
              'price': p.price,
            });
        if (entry.value) {
          //insert on spesa and update CONTINUARE
        }
      });
    });
  }

  Future<String> getUserColorForRecipt(
      String workspaceId, String ownerId) async {
    String color;
    UserWorkspace workspaceData = await _db
        .collection(_workspaceCollection)
        .doc(workspaceId)
        .get()
        .then((d) => UserWorkspace.fromFirestore(d));
    color =
        workspaceData.userColors[ownerId]; //recupero il colore può essere nullo
    if (color == null) {
      List<String> colorsUsed = [];
      workspaceData.userColors.values.forEach((color) {
        colorsUsed.add(color);
      });
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
