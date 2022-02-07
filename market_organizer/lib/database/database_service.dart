import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/productInputForDb.dart';
import 'package:market_organizer/provider/date_provider.dart';
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

  Stream<List<Spesa>> getSpesaStreamFromIdAndDate(
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

  Future<List<Spesa>> getSpesaListFromIdAndDate(
      String workspaceIdsRef, DateTime start, DateTime end) {
    var _ref = _db
        .collection(_spesaCollection)
        .where("workspaceIdRef", isEqualTo: workspaceIdsRef)
        .where("startWeek", isEqualTo: start)
        .where("endWeek", isEqualTo: end);
    return _ref.get().then(
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
  //recupero ricette in base al menu e al giorno specifico , questo metodo servirà per caricare le ricette del singolo giorno del menu

  Stream<List<Ricetta>> getReciptsFromMenuIdAndDate(
      String menuIdRef, DateTime day) {
    return _db
        .collection(_menuCollection)
        .doc(menuIdRef)
        .collection(_ricettaCollection)
        .where("date", isEqualTo: day)
        .snapshots()
        .map((value) =>
            value.docs.map((ds) => Ricetta.fromFirestore(ds)).toList());
  }

  //recupero menu tra due date
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
//ricerca prodotto per nome

  Future<List<Product>> searchProductByName(String string) async {
    //recupero tutti i prodotti in spesa o in ricetta creati dall'utente corrente che matchano la stringa richiesta
    List<Product> products = await _db
        .collectionGroup(_productCollection)
        .where("ownerId", isEqualTo: UserDataModel.example.id)
        .where("name", isGreaterThanOrEqualTo: string)
        .where("name", isLessThanOrEqualTo: string + '\uf8ff')
        .get()
        .then((_qs) =>
            _qs.docs.map((_ds) => Product.fromFirestore(_ds)).toList());
    //filtro i doppioni
    List<Product> filteredList = [];
    await products.forEach((prod) {
      if (filteredList.indexWhere((element) =>
              element.name == prod.name ||
              element.description == prod.description) <
          0) {
        filteredList.add(prod);
      }
    });
    return filteredList;
  }

  //metodo che ritorna la lista delle ricerche suggerite con il path utilizzato nell'input per l'utente corrente
  Future<List<Ricetta>> searchRicetteByName(String string) async {
    //per ogni menu, aggiungo le ricette che non sono duplicate
    //vado quindi a cercare se una certa ricetta nel menu corrente è presente guardando il nome e la descrizione
    List<Ricetta> ricette = await _db
        .collectionGroup(_ricettaCollection)
        .where("ownerId", isEqualTo: UserDataModel.example.id)
        .where("name", isGreaterThanOrEqualTo: string)
        .where("name", isLessThanOrEqualTo: string + '\uf8ff')
        .get()
        .then((_qs) =>
            _qs.docs.map((_ds) => Ricetta.fromFirestore(_ds)).toList());
    return ricette;
  }

  Future<void> insertNewProductInMenu(
      ProductInputForDb productInputForDb, bool isAddToSpesa) async {
    Product _productToBeInserted = productInputForDb.product;
    String _menuId = productInputForDb.product.menuIdRef;
    if (_menuId == null) {
      //creo menu nuovo
      DocumentReference docRef = await _db.collection(_menuCollection).add({
        "name": "default",
        "ownerId": _productToBeInserted.ownerId,
        "startWeek": productInputForDb.dateStart,
        "endWeek": productInputForDb.dateEnd,
        "workspaceIdRef": productInputForDb.workspaceId
      });
      //aggiorno il menu con il suo nuovo id
      _menuId = docRef.id;
    }
    String _color = await getUserColor(
      productInputForDb.workspaceId,
      _productToBeInserted.ownerId,
    );
    _db.runTransaction((transaction) async {
      Spesa currentSpesa = null;
      if (isAddToSpesa) {
        List<Spesa> spesaList = await getSpesaListFromIdAndDate(
            productInputForDb.workspaceId,
            productInputForDb.dateStart,
            productInputForDb.dateEnd);
        if (spesaList != null && spesaList.isNotEmpty) {
          currentSpesa = spesaList.first;
        } else {
          currentSpesa = await createNewSpesa(new Spesa(
              ownerId: UserDataModel.example.id,
              startWeek: productInputForDb.dateStart,
              endWeek: productInputForDb.dateEnd,
              workspaceIdRef: productInputForDb.workspaceId));
        }
      }
      CollectionReference prodRef = _db
          .collection(_menuCollection)
          .doc(_menuId)
          .collection(_productCollection);

      transaction.set(prodRef.doc(), {
        'ownerId': _productToBeInserted.ownerId,
        'ownerName': _productToBeInserted.ownerName,
        'color': _productToBeInserted.color,
        'name': _productToBeInserted.name,
        'description': _productToBeInserted.description,
        'measureUnit': _productToBeInserted.measureUnit,
        'quantity': _productToBeInserted.quantity,
        'image': _productToBeInserted.image,
        'spesaIdRef': currentSpesa != null ? currentSpesa.id : null,
        'menuIdRef': _menuId,
        //'productIdSpesa': _productIdSpesa,
      });
      if (isAddToSpesa) {
        //insert on spesa and update CONTINUARE A SALVARE I PRODOTTI IN SPESA SE SONO A TRUE
        CollectionReference dcref = _db
            .collection(_spesaCollection)
            .doc(currentSpesa.id)
            .collection(_productCollection);
        transaction.set(dcref.doc(), {
          "color": _color,
          "description": _productToBeInserted.description,
          "image": "",
          "measureUnit": _productToBeInserted.measureUnit,
          "name": _productToBeInserted.name,
          "ownerId": _productToBeInserted.ownerId,
          "ownerName": _productToBeInserted.ownerName,
          "quantity": _productToBeInserted.quantity,
          "reparto": _productToBeInserted.reparto,
          "spesaIdRef": currentSpesa.id, //c'è per forza
          "currency": _productToBeInserted.price != null ? "€" : null,
          "price": _productToBeInserted.price
        });
        transaction.update(
            _db.collection(_spesaCollection).doc(currentSpesa.id),
            {"ammount": FieldValue.increment(_productToBeInserted.price)});
      }
    });
  }

  /**
   * metodo per inserire una ricetta da zero tramite il pulsante di add nella pagina di aggiunta ricetta
   */
  Future<Ricetta> createNewReceiptFromScratch(
    Ricetta ricetta,
    MealDetailModel mealDetailModel,
    Map<Product, bool> products,
  ) async {
    String menuId = mealDetailModel.menuIdRef;
    if (menuId == null) {
      //creo menu nuovo
      DocumentReference docRef = await _db.collection(_menuCollection).add({
        "name": "default",
        "ownerId": ricetta.ownerId,
        "startWeek": mealDetailModel.dateStart,
        "endWeek": mealDetailModel.dateEnd,
        "workspaceIdRef": mealDetailModel.workspaceId
      });
      //aggiorno il menu con il suo nuovo id
      menuId = docRef.id;
    }
    String _color = await getUserColor(
      mealDetailModel.workspaceId,
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
    //se esiste almeno un prodotto da inserire in spesa,recupero la spesa corrente se esiste mi servirà successivamente se devo inserire un prodotto in spesa

    //aggiorno i product e aggiungo il riferimento alla ricetta e metto a null l'id perchè cosi gestico anche il fatto che siano prodotti creati da zero o meno
    //transazione
    _db.runTransaction((transaction) async {
      Spesa currentSpesa = null;
      if (products != null &&
          products.isNotEmpty &&
          products.values.any((element) => true)) {
        List<Spesa> spesaList = await getSpesaListFromIdAndDate(
            mealDetailModel.workspaceId,
            mealDetailModel.dateStart,
            mealDetailModel.dateEnd);
        if (spesaList != null && spesaList.isNotEmpty) {
          currentSpesa = spesaList.first;
        } else {
          currentSpesa = await createNewSpesa(new Spesa(
              ownerId: UserDataModel.example.id,
              startWeek: mealDetailModel.dateStart,
              endWeek: mealDetailModel.dateEnd,
              workspaceIdRef: mealDetailModel.workspaceId));
        }
      }
      if (products != null && products.isNotEmpty) {
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

          transaction.set(prodRef.doc(), {
            'ownerId': p.ownerId,
            'ownerName': p.ownerName,
            'color': p.color,
            'name': p.name,
            'description': p.description,
            'measureUnit': p.measureUnit,
            'quantity': p.quantity,
            'image': p.image,
            'spesaIdRef': entry.value ? currentSpesa.id : null,
            'ricettaIdRef': p.ricettaIdRef,
            //'productIdSpesa': _productIdSpesa,
          });
          if (entry.value) {
            //insert on spesa and update CONTINUARE A SALVARE I PRODOTTI IN SPESA SE SONO A TRUE
            CollectionReference dcref = _db
                .collection(_spesaCollection)
                .doc(currentSpesa.id)
                .collection(_productCollection);
            transaction.set(dcref.doc(), {
              "color": _color,
              "description": entry.key.description,
              "image": "",
              "measureUnit": entry.key.measureUnit,
              "name": entry.key.name,
              "ownerId": entry.key.ownerId,
              "ownerName": entry.key.ownerName,
              "quantity": entry.key.quantity,
              "reparto": entry.key.reparto,
              "spesaIdRef": currentSpesa.id,
              "currency": entry.key.price != null ? "€" : null,
              "price": entry.key.price
            });
            transaction.update(
                _db.collection(_spesaCollection).doc(currentSpesa.id),
                {"ammount": FieldValue.increment(entry.key.price)});
          }
        });
      }
    });
    return ricetta;
  }

/**metodo che aggiorna ricetta solo nome e descr*/
  Future<void> updateRecipts(
      String workspaceId,
      Ricetta ricetta,
      Map<Product, bool> productToBeInsertedOrUpdated,
      List<Product> productsToBeDeleted) async {
    await _db
        .collection(_menuCollection)
        .doc(ricetta.menuIdRef)
        .collection(_ricettaCollection)
        .doc(ricetta.id)
        .update({
      "name": ricetta.name,
      "description": ricetta.description,
    });
    //inserisco nuovi prodotti
    if (productToBeInsertedOrUpdated != null &&
        productToBeInsertedOrUpdated.isNotEmpty) {
      productToBeInsertedOrUpdated.forEach((product, isAddToSpesa) async {
        if (product.id == null) {
          //inserisco
          print("inserisco prod");
          product.ricettaIdRef = ricetta.id;
          await insertProductOnReceipt(
              ricetta.menuIdRef, workspaceId, product, isAddToSpesa);
        } else {
          //aggiorno
          await updateProductOnReceipt(product, ricetta.menuIdRef);
        }
      });
    }
    //cancello se presenti i prodotti
    if (productsToBeDeleted != null && productsToBeDeleted.isNotEmpty) {
      productsToBeDeleted.forEach((product) {
        deleteProductRecipt(ricetta.menuIdRef, product);
      });
    }
  }

  Future<void> insertProductOnReceipt(String menuId, String workspaceId,
      Product product, bool isAddToSpesa) async {
    Spesa currentSpesa = null;
    if (isAddToSpesa) {
      List<Spesa> spesaList = await getSpesaListFromIdAndDate(workspaceId,
          DateProvider.instance.dateStart, DateProvider.instance.dateEnd);
      if (spesaList != null && spesaList.isNotEmpty) {
        currentSpesa = spesaList.first;
      } else {
        currentSpesa = await createNewSpesa(new Spesa(
            ownerId: UserDataModel.example.id,
            startWeek: DateProvider.instance.dateStart,
            endWeek: DateProvider.instance.dateEnd,
            workspaceIdRef: workspaceId));
      }
    }
    _db.runTransaction((transaction) async {
      CollectionReference prodRef = _db
          .collection(_menuCollection)
          .doc(menuId)
          .collection(_ricettaCollection)
          .doc(product.ricettaIdRef)
          .collection(_productCollection);
      transaction.set(prodRef.doc(), {
        'ownerId': product.ownerId,
        'ownerName': product.ownerName,
        'color': product.color,
        'name': product.name,
        'description': product.description,
        'measureUnit': product.measureUnit,
        'quantity': product.quantity,
        'image': product.image,
        'spesaIdRef': currentSpesa != null
            ? currentSpesa.id
            : null, //se ad esempio ho deciso di non inserirlo in spesa
        'ricettaIdRef': product.ricettaIdRef,
        //'productIdSpesa': _productIdSpesa,
      });
      if (isAddToSpesa) {
        //insert on spesa and update CONTINUARE A SALVARE I PRODOTTI IN SPESA SE SONO A TRUE
        CollectionReference dcref = _db
            .collection(_spesaCollection)
            .doc(currentSpesa.id)
            .collection(_productCollection);
        transaction.set(dcref.doc(), {
          "color": product.color,
          "description": product.description,
          "image": "",
          "measureUnit": product.measureUnit,
          "name": product.name,
          "ownerId": product.ownerId,
          "ownerName": product.ownerName,
          "quantity": product.quantity,
          "reparto": product.reparto,
          "spesaIdRef": currentSpesa.id,
          "currency": product.currency,
          "price": product.price
        });
        transaction.update(
            _db.collection(_spesaCollection).doc(currentSpesa.id),
            {"ammount": FieldValue.increment(product.price)});
      }
    });
  }

  Future<void> deleteProductRecipt(String menuId, Product product) async {
    await _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_ricettaCollection)
        .doc(product.ricettaIdRef)
        .collection(_productCollection)
        .doc(product.id)
        .delete();
  }

  Future<String> getUserColor(String workspaceId, String ownerId) async {
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

  Future<Map<Product, bool>> getProductsByReceiptWithDefaultFalseInSpesa(
      String menuId, String ricettaId) async {
    List<Product> productsFetched = await _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_ricettaCollection)
        .doc(ricettaId)
        .collection(_productCollection)
        .get()
        .then(
          (qs) => qs.docs.map(
            (_d) {
              return Product.fromFirestore(_d);
            },
          ).toList(),
        );
    Map<Product, bool> prods = {};
    productsFetched.forEach((element) {
      prods.putIfAbsent(element, () => false);
    });
    return prods;
  }

  //recupero prodotti dato id ricetta
  Future<List<Product>> getProductsByRecipt(
      String menuId, String ricettaId) async {
    return _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_ricettaCollection)
        .doc(ricettaId)
        .collection(_productCollection)
        .get()
        .then(
          (qs) => qs.docs.map(
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
    List<Product> prods = await _db
        .collectionGroup(_productCollection)
        .where("ownerId", isEqualTo: UserDataModel.example.id)
        .where("reparto", isGreaterThanOrEqualTo: pattern)
        .where("reparto", isLessThanOrEqualTo: pattern + '\uf8ff')
        .get()
        .then((_qs) =>
            _qs.docs.map((_ds) => Product.fromFirestore(_ds)).toList());
    prods.forEach((p) => {
          if (!mergedReparti.contains(p.reparto)) {mergedReparti.add(p.reparto)}
        });
    return mergedReparti;
  }

  Future<void> insertProductOnSpesa(
      String workspaceId,
      String spesaIdRef,
      String ownerId,
      String productName,
      String productDescription,
      String productReparto,
      double quantity,
      String measureUnit,
      String currency,
      double price) async {
    String _color = await getUserColor(workspaceId, ownerId);
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

  Future<void> updateProductOnReceipt(Product product, String menuId) async {
    _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_ricettaCollection)
        .doc(product.ricettaIdRef)
        .collection(_productCollection)
        .doc(product.id)
        .update({
      "description": product.description,
      "measureUnit": product.measureUnit,
      "name": product.name,
      "quantity": product.quantity,
    });
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

  Future<void> deleteReceiptById(Ricetta ricetta) async {
    return await _db
        .collection(_menuCollection)
        .doc(ricetta.menuIdRef)
        .collection(_ricettaCollection)
        .doc(ricetta.id)
        .delete();
  }
}
