import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/exception/login_exception.dart';
import 'package:market_organizer/models/invites.dart';
import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/notifiche.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/reciptsAndProducts.dart';
import 'package:market_organizer/models/ricetta.dart';
import 'package:market_organizer/models/settings.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/pages/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/pages/menu/singleDay/receipt/product/productInputForDb.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/category_enum.dart';
import 'package:market_organizer/utils/color_costant.dart';

class DatabaseService {
  static DatabaseService instance = DatabaseService();

  String _spesaCollection = "spesa";
  String _menuCollection = "menu";
  String _ricettaCollection = "recipts";
  String _userCollection = "users";
  String _workspaceCollection = "workspace";
  String _productCollection = "product";
  String _notificheCollection = "notifiche";
  String _settingsCollection = "settings";
  String _invitesCollection = "invites";

  late FirebaseFirestore _db;
  late FirebaseStorage _storage;
  var batch;
  DatabaseService() {
    _db = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;
    batch = _db.batch();
  }

  Future<void> updateViewNotifications(String userId) async {
    QuerySnapshot _qs = await _db
        .collection(_userCollection)
        .doc(userId)
        .collection(_notificheCollection)
        .get();
    _qs.docs.forEach(
      (document) => document.reference.update(
        {"viewed": true},
      ),
    );
  }

  Future<List<Notifiche>> getUserNotifies(String userId) async {
    return await _db
        .collection(_userCollection)
        .doc(userId)
        .collection(_notificheCollection)
        .orderBy("date", descending: true)
        .get()
        .then(
          (_q) => _q.docs.map(
            (_d) {
              return Notifiche.fromFirestore(_d);
            },
          ).toList(),
        );
  }

  Stream<List<UserSettings>> getUserSettings(String userId) {
    return _db
        .collection(_userCollection)
        .doc(userId)
        .collection(_settingsCollection)
        .snapshots()
        .map(
          (_q) => _q.docs.map(
            (_d) {
              return UserSettings.fromFirestore(_d);
            },
          ).toList(),
        );
  }

  Future<void> updateUserSettings(String userId, UserSettings settings) async {
    return await _db
        .collection(_userCollection)
        .doc(userId)
        .collection(_settingsCollection)
        .doc(settings.id)
        .update({
      "language": settings.language,
      "showPrice": settings.showPrice,
      "showSelected": settings.showSelected,
      "saveMenuDays": settings.saveMenuDays,
    });
  }

  Future<bool> checkEmailIsAvailable(String _email) async {
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
  }

  Future<void> createUserInDb(
      String _userId, String _email, String _name) async {
    try {
      await _db.collection(_userCollection).doc(_userId).set(
        {"name": _name, "email": _email, "workspacesIdRef": []},
      );
      await _db
          .collection(_userCollection)
          .doc(_userId)
          .collection(_settingsCollection)
          .doc()
          .set({
        "language": "italiano",
        "showPrice": true,
        "showSelected": true,
        "saveMenuDays": 7,
      });
    } catch (e) {
      throw LoginException("$e");
    }
  }

  Future<UserDataModel> getUserData(String _userID) async {
    var _ref = _db.collection(_userCollection).doc(_userID);
    return await _ref.get().then(
          (_snapshot) => UserDataModel.fromFirestore(_snapshot),
        );
  }

  Stream<List<UserWorkspace>> getUserWorkspace(List<String> _userWs) {
    return _db
        .collection(_workspaceCollection)
        .where(FieldPath.documentId, whereIn: _userWs)
        .snapshots()
        .map(
          (_q) => _q.docs.map(
            (_d) {
              return UserWorkspace.fromFirestore(_d);
            },
          ).toList(),
        );
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
      String? workspaceIdsRef, DateTime? start, DateTime? end) {
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

  Future<List<Product>> getProductsInMenuWhereDate(
      String menuId, DateTime day) async {
    return await _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_productCollection)
        .where("date", isEqualTo: day)
        .get()
        .then((value) =>
            value.docs.map((ds) => Product.fromFirestore(ds)).toList());
  }

  Future<List<Product>> getProductsInMenu(String menuId) async {
    return await _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_productCollection)
        .get()
        .then((value) =>
            value.docs.map((ds) => Product.fromFirestore(ds)).toList());
  }

  Future<List<Ricetta>> getReciptsFromMenuIdWhereDate(
      String menuId, DateTime day) async {
    return await _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_ricettaCollection)
        .where("date", isEqualTo: day)
        .get()
        .then((value) =>
            value.docs.map((ds) => Ricetta.fromFirestore(ds)).toList());
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

  Stream<List<Product>> getProductsFromMenuIdAndDateAndPasto(
      String menuIdRef, DateTime day, String pasto) {
    return _db
        .collection(_menuCollection)
        .doc(menuIdRef)
        .collection(_productCollection)
        .where("date", isEqualTo: day)
        .where("pasto", isEqualTo: pasto)
        .snapshots()
        .map((value) =>
            value.docs.map((ds) => Product.fromFirestore(ds)).toList());
  }

  Stream<List<Ricetta>> getReciptsFromMenuIdAndDateAndPasto(
      String menuIdRef, DateTime day, String pasto) {
    return _db
        .collection(_menuCollection)
        .doc(menuIdRef)
        .collection(_ricettaCollection)
        .where("date", isEqualTo: day)
        .where("pasto", isEqualTo: pasto)
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

  Future<List<Product>> searchProductByName(
      String string, String userId) async {
    //recupero tutti i prodotti in spesa o in ricetta creati dall'utente corrente che matchano la stringa richiesta
    List<Product> products = await _db
        .collectionGroup(_productCollection)
        .where("ownerId", isEqualTo: userId)
        .where("name", isGreaterThanOrEqualTo: string)
        .where("name", isLessThanOrEqualTo: string + '\uf8ff')
        .get()
        .then((_qs) =>
            _qs.docs.map((_ds) => Product.fromFirestore(_ds)).toList());
    //filtro i doppioni
    List<Product> filteredList = [];
    products.forEach((prod) {
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
  Future<List<Ricetta>> searchRicetteByName(
      String string, String userId) async {
    //per ogni menu, aggiungo le ricette che non sono duplicate
    //vado quindi a cercare se una certa ricetta nel menu corrente è presente guardando il nome e la descrizione
    List<Ricetta> ricette = await _db
        .collectionGroup(_ricettaCollection)
        .where("ownerId", isEqualTo: userId)
        .where("name", isGreaterThanOrEqualTo: string)
        .where("name", isLessThanOrEqualTo: string + '\uf8ff')
        .get()
        .then((_qs) =>
            _qs.docs.map((_ds) => Ricetta.fromFirestore(_ds)).toList());
    return ricette;
  }

  Future<void> insertNewProductInMenu(
      ProductInputForDb productInputForDb,
      bool isAddToSpesa,
      DateTime dateStart,
      DateTime dateEnd,
      String userId) async {
    Product _productToBeInserted = productInputForDb.product;
    List<Menu> currentMenuList =
        await getMenuFromDate(productInputForDb.workspaceId, dateStart, dateEnd)
            .elementAt(0);
    Menu? currenMenu =
        currentMenuList.isNotEmpty ? currentMenuList.first : null;
    ;
    String? _menuId;
    if (currenMenu == null) {
      //creo menu nuovo
      DocumentReference docRef = await _db.collection(_menuCollection).add({
        "name": "default",
        "ownerId": _productToBeInserted.ownerId,
        "startWeek": dateStart,
        "endWeek": dateEnd,
        "workspaceIdRef": productInputForDb.workspaceId
      });
      //aggiorno il menu con il suo nuovo id
      _menuId = docRef.id;
    } else {
      _menuId = currenMenu.id;
    }
    String _color = await getUserColor(
      productInputForDb.workspaceId,
      _productToBeInserted.ownerId,
    );
    _db.runTransaction((transaction) async {
      Spesa? currentSpesa = null;
      if (isAddToSpesa) {
        List<Spesa> spesaList = await getSpesaListFromIdAndDate(
            productInputForDb.workspaceId, dateStart, dateEnd);
        if (spesaList.isNotEmpty) {
          currentSpesa = spesaList.first;
        } else {
          currentSpesa = await createNewSpesa(
            new Spesa(
              ownerId: userId,
              startWeek: dateStart,
              endWeek: dateEnd,
              workspaceIdRef: productInputForDb.workspaceId,
              orderBy: CategoryOrder.category.toString(),
              showSelected: true,
              showPrice: true,
            ),
          );
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
        'pasto': _productToBeInserted.pasto,
        'date': _productToBeInserted.date,

        //'productIdSpesa': _productIdSpesa,
      });
      if (isAddToSpesa) {
        //insert on spesa and update CONTINUARE A SALVARE I PRODOTTI IN SPESA SE SONO A TRUE
        CollectionReference dcref = _db
            .collection(_spesaCollection)
            .doc(currentSpesa?.id)
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
          "spesaIdRef": currentSpesa?.id, //c'è per forza
          "currency": _productToBeInserted.price != null ? "€" : null,
          "price": _productToBeInserted.price
        });
        transaction.update(
            _db.collection(_spesaCollection).doc(currentSpesa?.id), {
          "ammount": FieldValue.increment(_productToBeInserted.price as num)
        });
      }
    });
  }

  /**
   * metodo per inserire una ricetta da zero tramite il pulsante di add nella pagina di aggiunta ricetta
   */
  Future<Ricetta> createNewReceiptFromScratch(
      Ricetta ricetta,
      RicettaManagementInput mealDetailModel,
      Map<Product, bool>? products,
      String userId) async {
    String? menuId = mealDetailModel.menuIdRef;
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
    String? _color = await getUserColor(
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
      Spesa? currentSpesa = null;
      if (products != null &&
          products.isNotEmpty &&
          products.values.any((element) => true)) {
        List<Spesa> spesaList = await getSpesaListFromIdAndDate(
            mealDetailModel.workspaceId,
            mealDetailModel.dateStart,
            mealDetailModel.dateEnd);
        if (spesaList.isNotEmpty) {
          currentSpesa = spesaList.first;
        } else {
          currentSpesa = await createNewSpesa(
            new Spesa(
                ownerId: userId,
                startWeek: mealDetailModel.dateStart,
                endWeek: mealDetailModel.dateEnd,
                workspaceIdRef: mealDetailModel.workspaceId,
                orderBy: CategoryOrder.category.toString(),
                showSelected: true,
                showPrice: true),
          );
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
            'spesaIdRef': entry.value ? currentSpesa?.id : null,
            'ricettaIdRef': p.ricettaIdRef,
            //'productIdSpesa': _productIdSpesa,
          });
          if (entry.value) {
            //insert on spesa and update CONTINUARE A SALVARE I PRODOTTI IN SPESA SE SONO A TRUE
            CollectionReference dcref = _db
                .collection(_spesaCollection)
                .doc(currentSpesa?.id)
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
              "spesaIdRef": currentSpesa?.id,
              "currency": entry.key.price != null ? "€" : null,
              "price": entry.key.price
            });
            transaction.update(
                _db.collection(_spesaCollection).doc(currentSpesa?.id),
                {"ammount": FieldValue.increment(entry.key.price as num)});
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
      List<Product> productsToBeDeleted,
      DateTime dateStart,
      DateTime dateEnd,
      String userId) async {
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
          product.ricettaIdRef = ricetta.id;
          await insertProductOnReceipt(ricetta.menuIdRef, workspaceId, product,
              isAddToSpesa, dateStart, dateEnd, userId);
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

  Future<void> insertProductOnReceipt(
      String? menuId,
      String? workspaceId,
      Product? product,
      bool isAddToSpesa,
      DateTime? dateStart,
      DateTime? dateEnd,
      String? userId) async {
    Spesa? currentSpesa = null;
    if (isAddToSpesa) {
      List<Spesa> spesaList =
          await getSpesaListFromIdAndDate(workspaceId, dateStart, dateEnd);
      if (spesaList.isNotEmpty) {
        currentSpesa = spesaList.first;
      } else {
        currentSpesa = await createNewSpesa(
          new Spesa(
              ownerId: userId,
              startWeek: dateStart,
              endWeek: dateEnd,
              workspaceIdRef: workspaceId,
              orderBy: CategoryOrder.category.toString(),
              showSelected: true,
              showPrice: true),
        );
      }
    }
    _db.runTransaction((transaction) async {
      CollectionReference prodRef = _db
          .collection(_menuCollection)
          .doc(menuId)
          .collection(_ricettaCollection)
          .doc(product?.ricettaIdRef)
          .collection(_productCollection);
      transaction.set(prodRef.doc(), {
        'ownerId': product?.ownerId,
        'ownerName': product?.ownerName,
        'color': product?.color,
        'name': product?.name,
        'description': product?.description,
        'measureUnit': product?.measureUnit,
        'quantity': product?.quantity,
        'image': product?.image,
        'spesaIdRef': currentSpesa != null
            ? currentSpesa.id
            : null, //se ad esempio ho deciso di non inserirlo in spesa
        'ricettaIdRef': product?.ricettaIdRef,
        //'productIdSpesa': _productIdSpesa,
      });
      if (isAddToSpesa) {
        //insert on spesa and update CONTINUARE A SALVARE I PRODOTTI IN SPESA SE SONO A TRUE
        CollectionReference dcref = _db
            .collection(_spesaCollection)
            .doc(currentSpesa?.id)
            .collection(_productCollection);
        transaction.set(dcref.doc(), {
          "color": product?.color,
          "description": product?.description,
          "image": "",
          "measureUnit": product?.measureUnit,
          "name": product?.name,
          "ownerId": product?.ownerId,
          "ownerName": product?.ownerName,
          "quantity": product?.quantity,
          "reparto": product?.reparto,
          "spesaIdRef": currentSpesa?.id,
          "currency": product?.currency,
          "price": product?.price
        });
        transaction.update(
            _db.collection(_spesaCollection).doc(currentSpesa?.id),
            {"ammount": FieldValue.increment(product?.price as num)});
      }
    });
  }

  Future<void> deleteProductRecipt(String? menuId, Product product) async {
    await _db
        .collection(_menuCollection)
        .doc(menuId)
        .collection(_ricettaCollection)
        .doc(product.ricettaIdRef)
        .collection(_productCollection)
        .doc(product.id)
        .delete();
  }

  Future<String> getUserColor(String? workspaceId, String? ownerId) async {
    if (workspaceId != null && ownerId != null) {
      String? color;
      UserWorkspace workspaceData = await _db
          .collection(_workspaceCollection)
          .doc(workspaceId)
          .get()
          .then((d) => UserWorkspace.fromFirestore(d));
      color = workspaceData
          .userColors![ownerId]; //recupero il colore può essere nullo

      if (color == null) {
        List<String> colorsUsed = [];
        workspaceData.userColors?.values.forEach((color) {
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
        workspaceData.userColors?.putIfAbsent(ownerId, () => color!);
      }
      return color;
    }
    return "green";
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
    if (pattern.isEmpty) {
      return mergedReparti;
    }
    List<Product> prods = await _db
        .collectionGroup(_productCollection)
        .where("ownerId", isEqualTo: userId)
        .where("reparto", isGreaterThanOrEqualTo: pattern)
        .where("reparto", isLessThanOrEqualTo: pattern + '\uf8ff')
        .get()
        .then((_qs) =>
            _qs.docs.map((_ds) => Product.fromFirestore(_ds)).toList());
    prods.forEach((p) => {
          if (!mergedReparti.contains(p.reparto))
            {mergedReparti.add(p.reparto as String)}
        });
    return mergedReparti;
  }

  Future<void> insertProductOnSpesa(
      String workspaceId,
      String spesaIdRef,
      String ownerId,
      String ownerName,
      String productName,
      String productDescription,
      String productReparto,
      double quantity,
      String measureUnit,
      String? currency,
      double price) async {
    String _color = await getUserColor(workspaceId, ownerId);
    await _db
        .collection(_spesaCollection)
        .doc(spesaIdRef)
        .collection(_productCollection)
        .doc()
        .set({
      "color": _color,
      "description": (productDescription.isEmpty) ? "" : productDescription,
      "image": "",
      "measureUnit": measureUnit,
      "name": productName,
      "ownerId": ownerId,
      "ownerName": ownerName,
      "quantity": quantity,
      "reparto": productReparto,
      "spesaIdRef": spesaIdRef,
      "currency": "€",
      "price": price,
      "date": new DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .subtract(
        Duration(days: DateTime.now().weekday - 1),
      ),
    });
    await _db
        .collection(_spesaCollection)
        .doc(spesaIdRef)
        .update({"ammount": FieldValue.increment(price)});
  }

  Future<void> updateProductOnReceipt(Product product, String? menuId) async {
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

  Future<void> updateProductBoughtOnSpesa(Product _product) async {
    await _db
        .collection(_spesaCollection)
        .doc(_product.spesaIdRef)
        .collection(_productCollection)
        .doc(_product.id)
        .update(
      {
        "bought": _product.bought,
      },
    );
  }

  Future<void> updateShowSelected(Spesa currentSpesa) async {
    await _db.collection(_spesaCollection).doc(currentSpesa.id).update(
      {
        "showSelected": currentSpesa.showSelected,
      },
    );
  }

  Future<void> updateShowPrice(Spesa currentSpesa) async {
    await _db.collection(_spesaCollection).doc(currentSpesa.id).update(
      {
        "showPrice": currentSpesa.showPrice,
      },
    );
  }

  Future<void> updateSpesaOrder(Spesa currentSpesa) async {
    await _db.collection(_spesaCollection).doc(currentSpesa.id).update(
      {
        "orderBy": currentSpesa.orderBy,
      },
    );
  }

  Future<void> updateProductOnSpesa(
      String productId,
      String spesaIdRef,
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
      "description": (productDescription.isEmpty) ? "" : productDescription,
      "image": "",
      "measureUnit": measureUnit,
      "quantity": quantity,
      "reparto": productReparto,
      "currency": "€",
      "price": price
    });
    if (priceDifference != 0)
      await _db
          .collection(_spesaCollection)
          .doc(spesaIdRef)
          .update({"ammount": FieldValue.increment(priceDifference)});
  }

  Future<Spesa> createNewSpesa(Spesa spesa) async {
    List<UserSettings> userSetting =
        await getUserSettings(spesa.ownerId!).first;
    var docRef = await _db.collection(_spesaCollection).add({
      "ownerId": spesa.ownerId,
      "startWeek": spesa.startWeek,
      "endWeek": spesa.endWeek,
      "ammount": 0.0,
      "workspaceIdRef": spesa.workspaceIdRef,
      "orderBy": spesa.orderBy,
      "showSelected": userSetting.first.showSelected,
      "showPrice": userSetting.first.showPrice,
    });

    spesa.id = docRef.id;
    return spesa;
  }

  Future<void> deleteProduct(Product product) async {
    _db.runTransaction((transaction) async {
      // if(product.menuIdRef!=null){
      //   //elimino prima nel prodotto del menu il riferimento alla spesa

      //   if(product.ricettaIdRef!=null){
      //     //in ricetta
      //   }else{
      //     //singolo
      //   _db.collection(_menuCollection).doc(product.menuIdRef).collection(_productCollection).doc(product.id).update({""})

      //   }
      //   }
      await transaction.delete(_db
          .collection(_spesaCollection)
          .doc(product.spesaIdRef)
          .collection(_productCollection)
          .doc(product.id));

      await _db.collection(_spesaCollection).doc(product.spesaIdRef).update({
        "ammount": FieldValue.increment(
            0 - (product.price != null ? product.price as num : 0))
      });
    });
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
    _db.runTransaction((transaction) async {
      //cancello spesa
      await _db
          .collection(_menuCollection)
          .doc(ricetta.menuIdRef)
          .collection(_ricettaCollection)
          .doc(ricetta.id)
          .collection(_productCollection)
          .get()
          .then(
            (qs) => qs.docs.forEach(
              (qd) {
                //cancello prodotti in menu
                //cancello spesa
                transaction.delete(qd.reference);
              },
            ),
          );
      await transaction.delete(_db
          .collection(_menuCollection)
          .doc(ricetta.menuIdRef)
          .collection(_ricettaCollection)
          .doc(ricetta.id));
    });
  }

  Future<void> deleteProductInMenu(Product product) async {
    return await _db
        .collection(_menuCollection)
        .doc(product.menuIdRef)
        .collection(_productCollection)
        .doc(product.id)
        .delete();
  }

  Future<void> updateProductOnMenu(ProductInputForDb productInputForDb) async {
    await _db
        .collection(_menuCollection)
        .doc(productInputForDb.product.menuIdRef)
        .collection(_productCollection)
        .doc(productInputForDb.product.id)
        .update({
      "name": productInputForDb.product.name,
      "description": (productInputForDb.product.description == null ||
              productInputForDb.product.description!.isEmpty)
          ? ""
          : productInputForDb.product.description,
      "image": "",
      "measureUnit": productInputForDb.product.measureUnit,
      "quantity": productInputForDb.product.quantity,
      "reparto": productInputForDb.product.reparto,
      "currency": productInputForDb.product.price != null ? "€" : null,
      "price": productInputForDb.product.price
    });
  }

//recupero tutto per il menu
  Future<ReciptsAndProducts> getReciptsAndProductForMenu(String menuId) async {
    List<Ricetta> ricette = await getReciptsFromMenuId(menuId);
    List<Product> products = await getProductsInMenu(menuId);

    return new ReciptsAndProducts(ricette, products);
  }

  Future<void> deleteAllProductsOnSpesa(String id) async {
    await _db.collection(_spesaCollection).doc(id).delete();
  }

  Future<void> cloneSpesa(Spesa currentSpesa, DateTime dateStart,
      DateTime dateEnd, String userId) async {
    //controllo se per l'intervallo di date esiste gia una spesa
    Spesa existingSpesa;
    List<Spesa> spesaList = await getSpesaListFromIdAndDate(
        currentSpesa.workspaceIdRef, dateStart, dateEnd);
    if (spesaList != null && spesaList.isNotEmpty) {
      existingSpesa = spesaList.first;
    } else {
      existingSpesa = await createNewSpesa(
        new Spesa(
          ownerId: userId,
          startWeek: dateStart,
          endWeek: dateEnd,
          workspaceIdRef: currentSpesa.workspaceIdRef,
          orderBy: CategoryOrder.category.toString(),
          showSelected: true,
          showPrice: true,
        ),
      );
    }
    List<Product> productToBeInsert =
        await getProductsBySpesa(currentSpesa.id!).first;
    //clone prod
    double price = 0.0;
    for (Product product in productToBeInsert) {
      if (product.price != null) {
        price += product.price!;
      }
      _db
          .collection(_spesaCollection)
          .doc(existingSpesa.id)
          .collection(_productCollection)
          .add({
        "color": product.color,
        "description": product.description,
        "image": "",
        "measureUnit": product.measureUnit,
        "name": product.name,
        "ownerId": product.ownerId,
        "ownerName": product.ownerName,
        "quantity": product.quantity,
        "reparto": product.reparto,
        "spesaIdRef": existingSpesa.id,
        "currency": product.currency,
        "price": product.price,
        "bought": false,
      });
    }
    _db.collection(_spesaCollection).doc(existingSpesa.id).update(
      {
        "ammount": FieldValue.increment(price),
      },
    );
  }

  Future<void> cloneMenuInSpecificDay(
      String menuIdRef,
      DateTime dayTimeFrom, //giorno da cui prendo i dati
      DateTime dateStartLoop, //inizio settimana dove travaso i dati
      DateTime dateEndLoop, //fine settimana dove travaso i dati
      DateTime dayTimeTo, //giorni in cui verso i dati
      String userId,
      String userName) async {
    Menu _currentMenuRef = await _db
        .collection(_menuCollection)
        .doc(menuIdRef)
        .get()
        .then((ds) => Menu.fromFirestore(ds));
    List<Menu> _menus = await getMenuFromDate(
            _currentMenuRef.workspaceIdRef!, dateStartLoop, dateEndLoop)
        .first;
    Menu _newMenuRef;
    if (_menus == null || _menus.isEmpty) {
      //creo menu nuovo
      DocumentReference docRef = await _db.collection(_menuCollection).add({
        "name": "default",
        "ownerId": userId,
        "startWeek": dateStartLoop,
        "endWeek": dateEndLoop,
        "workspaceIdRef": _currentMenuRef.workspaceIdRef
      });
      _newMenuRef = await docRef.get().then((ds) => Menu.fromFirestore(ds));
    } else {
      _newMenuRef = _menus.first;
    }
    //recupero prodotti
    List<Product> prods =
        await getProductsInMenuWhereDate(menuIdRef, dayTimeFrom);
    if (prods != null && prods.isNotEmpty) {
      for (Product prod in prods) {
        prod.menuIdRef = _newMenuRef.id;
        prod.ownerId = userId;
        prod.ownerName = userName;
        prod.color = await getUserColor(
          _currentMenuRef.workspaceIdRef,
          userId,
        );
        prod.bought = false;
        prod.checkedOnMenu = false;
        prod.date = dayTimeTo;
        prod.id = null;
        prod.spesaIdRef = null;
        prod.ricettaIdRef = null;

        insertNewProductInMenu(
            new ProductInputForDb(prod, _currentMenuRef.workspaceIdRef!),
            false,
            dateStartLoop,
            dateEndLoop,
            userId);
      }
    }

    //recupero ricette
    List<Ricetta> ricette =
        await getReciptsFromMenuIdWhereDate(menuIdRef, dayTimeFrom);
    if (ricette != null && ricette.isNotEmpty) {
      for (Ricetta ricetta in ricette) {
        List<Product> prodRic =
            await getProductsByRecipt(menuIdRef, ricetta.id!);
        ricetta.id = null;
        ricetta.menuIdRef = _newMenuRef.id;
        ricetta.ownerId = userId;
        ricetta.ownerName = userName;
        ricetta.date = dayTimeTo;
        ricetta.color =
            await getUserColor(_currentMenuRef.workspaceIdRef, userId);
        DocumentReference ricRef = await _db
            .collection(_menuCollection)
            .doc(_newMenuRef.id)
            .collection(_ricettaCollection)
            .add({
          "ownerId": ricetta.ownerId,
          "ownerName": ricetta.ownerName,
          "color": ricetta.color,
          "name": ricetta.name,
          "description": ricetta.description,
          "pasto": ricetta.pasto,
          "date": ricetta.date,
          "image": "",
          "menuIdRef": _newMenuRef.id,
        });
        if (prodRic != null && prodRic.isNotEmpty) {
          for (Product prod in prodRic) {
            prod.menuIdRef = _newMenuRef.id;
            prod.ownerId = userId;
            prod.ownerName = userName;
            prod.color = await getUserColor(
              _currentMenuRef.workspaceIdRef,
              userId,
            );
            prod.bought = false;
            prod.checkedOnMenu = false;
            prod.date = dayTimeTo;
            prod.id = null;
            prod.spesaIdRef = null;
            prod.ricettaIdRef = ricRef.id;

            insertProductOnReceipt(
                _currentMenuRef.id,
                _currentMenuRef.workspaceIdRef,
                prod,
                false,
                dateStartLoop,
                dateEndLoop,
                userId);
          }
        }
      }
    }
  }

  Future<void> cloneEntireMenu(String menuIdRef, DateTime dateStartLoop,
      DateTime dateEndLoop, String userId, String userName) async {
    Menu _currentMenuRef = await _db
        .collection(_menuCollection)
        .doc(menuIdRef)
        .get()
        .then((ds) => Menu.fromFirestore(ds));
    List<Menu> _menus = await getMenuFromDate(
            _currentMenuRef.workspaceIdRef!, dateStartLoop, dateEndLoop)
        .first;
    Menu _newMenuRef;
    if (_menus == null || _menus.isEmpty) {
      //creo menu nuovo
      DocumentReference docRef = await _db.collection(_menuCollection).add({
        "name": "default",
        "ownerId": userId,
        "startWeek": dateStartLoop,
        "endWeek": dateEndLoop,
        "workspaceIdRef": _currentMenuRef.workspaceIdRef
      });
      _newMenuRef = await docRef.get().then((ds) => Menu.fromFirestore(ds));
    } else {
      _newMenuRef = _menus.first;
    }
    //recupero prodotti
    List<Product> prods = await getProductsInMenu(menuIdRef);
    if (prods != null && prods.isNotEmpty) {
      for (Product prod in prods) {
        prod.menuIdRef = _newMenuRef.id;
        prod.ownerId = userId;
        prod.ownerName = userName;
        prod.color = await getUserColor(
          _currentMenuRef.workspaceIdRef,
          userId,
        );
        prod.bought = false;
        prod.checkedOnMenu = false;
        prod.date = prod.date!.add(Duration(
            days: dateStartLoop.difference(_currentMenuRef.startWeek!).inDays));
        prod.id = null;
        prod.spesaIdRef = null;
        prod.ricettaIdRef = null;

        insertNewProductInMenu(
            new ProductInputForDb(prod, _currentMenuRef.workspaceIdRef!),
            false,
            dateStartLoop,
            dateEndLoop,
            userId);
      }
    }

    //recupero ricette
    List<Ricetta> ricette = await getReciptsFromMenuId(menuIdRef);
    if (ricette != null && ricette.isNotEmpty) {
      for (Ricetta ricetta in ricette) {
        List<Product> prodRic =
            await getProductsByRecipt(menuIdRef, ricetta.id!);
        ricetta.id = null;
        ricetta.menuIdRef = _newMenuRef.id;
        ricetta.ownerId = userId;
        ricetta.ownerName = userName;
        ricetta.date = ricetta.date!.add(Duration(
            days: dateStartLoop.difference(_currentMenuRef.startWeek!).inDays));
        ricetta.color = await getUserColor(
          _currentMenuRef.workspaceIdRef,
          userId,
        );
        DocumentReference ricRef = await _db
            .collection(_menuCollection)
            .doc(_newMenuRef.id)
            .collection(_ricettaCollection)
            .add({
          "ownerId": ricetta.ownerId,
          "ownerName": ricetta.ownerName,
          "color": ricetta.color,
          "name": ricetta.name,
          "description": ricetta.description,
          "pasto": ricetta.pasto,
          "date": ricetta.date,
          "image": "",
          "menuIdRef": ricetta.menuIdRef,
        });
        if (prodRic != null && prodRic.isNotEmpty) {
          for (Product prod in prodRic) {
            prod.menuIdRef = _newMenuRef.id;
            prod.ownerId = userId;
            prod.ownerName = userName;
            prod.color = await getUserColor(
              _currentMenuRef.workspaceIdRef,
              userId,
            );
            prod.bought = false;
            prod.checkedOnMenu = false;
            prod.date = prod.date!.add(Duration(
                days: dateStartLoop
                    .difference(_currentMenuRef.startWeek!)
                    .inDays));
            prod.id = null;
            prod.spesaIdRef = null;
            prod.ricettaIdRef = ricRef.id;

            insertProductOnReceipt(
                _currentMenuRef.id,
                _currentMenuRef.workspaceIdRef,
                prod,
                false,
                dateStartLoop,
                dateEndLoop,
                userId);
          }
        }
      }
    }
  }

  Future<void> deleteAllInMenu(String menuId) async {
    await _db.collection(_menuCollection).doc(menuId).delete();
  }

  Future<void> updateWorkspaceFocus(
      AuthProvider provider, String userId, String? wsId) async {
    await _db.collection(_userCollection).doc(userId).update(
      {"favouriteWs": wsId},
    );

    UserDataModel _userData = await getUserData(userId);
    provider.refreshUserData(_userData);
  }

  Future<void> saveWorkspace(UserWorkspace currentWorkspace, bool _isFavourite,
      AuthProvider provider) async {
    late String wsId;
    if (currentWorkspace.id != null) {
      //aggiorna
      wsId = currentWorkspace.id!;
      await _db
          .collection(_workspaceCollection)
          .doc(currentWorkspace.id)
          .update(
        {
          "name": currentWorkspace.name != null ? currentWorkspace.name : "",
        },
      );
    } else {
      //inserisci
      Map<String, String> firstColorWithUser = {
        currentWorkspace.ownerId!: ColorCostant.colorMap.keys.first
      };
      DocumentReference docRef =
          await _db.collection(_workspaceCollection).add({
        "name": currentWorkspace.name,
        "ownerId": currentWorkspace.ownerId,
        "contributorsId": [],
        "userColors": firstColorWithUser
      });
      wsId = docRef.id;
      await _db
          .collection(_userCollection)
          .doc(currentWorkspace.ownerId)
          .update({
        "workspacesIdRef": FieldValue.arrayUnion([docRef.id])
      });
    }
    //update is favourite for user
    DatabaseService.instance.updateWorkspaceFocus(
        provider, provider.userData!.id!, _isFavourite ? wsId : null);
  }

  Future<void> deleteWorkspace(String userId, String workspacesId) async {
    _db.runTransaction(
      (transaction) async {
        //cancello spesa
        await _db
            .collection(_spesaCollection)
            .where("workspaceIdRef", isEqualTo: workspacesId)
            .get()
            .then(
              (qs) => qs.docs.forEach(
                (qd) {
                  //cancello prodotti in spesa
                  qd.reference.collection(_productCollection).get().then(
                        (qs) => qs.docs.forEach(
                          (qd) {
                            transaction.delete(qd.reference);
                          },
                        ),
                      );
                  //cancello spesa
                  transaction.delete(qd.reference);
                },
              ),
            );

        //cancello menu
        await _db
            .collection(_menuCollection)
            .where("workspaceIdRef", isEqualTo: workspacesId)
            .get()
            .then(
              (qs) => qs.docs.forEach(
                (qd) {
                  //cancello prodotti singoli in menu
                  qd.reference.collection(_productCollection).get().then(
                        (qs) => qs.docs.forEach(
                          (qd) {
                            transaction.delete(qd.reference);
                          },
                        ),
                      );
                  //gestisco cancellazione ricette
                  qd.reference.collection(_ricettaCollection).get().then(
                        (qs) => qs.docs.forEach(
                          (qd) {
                            //cancello prodotti in ricetta
                            qd.reference
                                .collection(_productCollection)
                                .get()
                                .then(
                                  (qs) => qs.docs.forEach(
                                    (qd) {
                                      transaction.delete(qd.reference);
                                    },
                                  ),
                                );
                            //cancello la ricetta
                            transaction.delete(qd.reference);
                          },
                        ),
                      );
                  //cancello menu
                  transaction.delete(qd.reference);
                },
              ),
            );

        //cancello workspace
        await transaction
            .delete(_db.collection(_workspaceCollection).doc(workspacesId));

        //rimuovo riferimento in array

        await transaction.update(_db.collection(_userCollection).doc(userId), {
          "workspacesIdRef": FieldValue.arrayRemove([workspacesId])
        });
      },
    );
  }

  Future<void> acceptWorkspaceWork(
      Notifiche notifica, String userId, AuthProvider provider) async {
    try {
      await _db.runTransaction((transaction) async {
//aggiorno notifica
        await transaction.update(
            _db
                .collection(_userCollection)
                .doc(userId)
                .collection(_notificheCollection)
                .doc(notifica.id),
            {"accepted": "1"});

        //aggiorno user collection aggiungendo il nuovo workspace

        await transaction.update(_db.collection(_userCollection).doc(userId), {
          "workspacesIdRef": FieldValue.arrayUnion([notifica.workspaceIdRef])
        });
        //aggiorno invito in workspace
        await _db
            .collection(_workspaceCollection)
            .doc(notifica.workspaceIdRef!)
            .collection(_invitesCollection)
            .where("userId", isEqualTo: userId)
            .get()
            .then((qds) => transaction
                .update(qds.docs.first.reference, {"accepted": "1"}));

        //update color e lista dei contributors nel workspace
        String _color = await getUserColor(
          notifica.workspaceIdRef,
          userId,
        );
        UserWorkspace _workspace =
            await getWorkspaceFromId(notifica.workspaceIdRef!);
        Map<String, String> _wsColors = _workspace.userColors!;
        _wsColors.putIfAbsent(userId, () => _color);

        await transaction.update(
            _db.collection(_workspaceCollection).doc(notifica.workspaceIdRef), {
          "contributorsId": FieldValue.arrayUnion([userId]),
          "userColors": _wsColors
        });
      });
    } catch (e) {
      print("errore durante l'accettazione del workspace, " + e.toString());
    }

    //refresh userdata
    UserDataModel _userData = await getUserData(userId);
    provider.refreshUserData(_userData);
  }

  Future<void> rejectWorkspaceWork(Notifiche notifica, String userId) async {
    try {
      await _db.runTransaction((transaction) async {
        //aggiorno notifica
        await transaction.update(
            _db
                .collection(_userCollection)
                .doc(userId)
                .collection(_notificheCollection)
                .doc(notifica.id),
            {"accepted": -1});
        //aggiorno invito in workspace
        await _db
            .collection(_workspaceCollection)
            .doc(notifica.workspaceIdRef!)
            .collection(_invitesCollection)
            .where("userId", isEqualTo: userId)
            .get()
            .then((qds) => transaction
                .update(qds.docs.first.reference, {"accepted": "0"}));
      });
    } catch (e) {
      print("errore durante il rifiuto del workspace, " + e.toString());
    }
  }

  Future<void> shareWorkspaceToUser(String ownerId, String userId, String email,
      String worksapceId, Future<void> onSuccess()) async {
    //creo invito
    await _db.runTransaction((transaction) async {
      //creo invito
      DocumentReference documentReference = await _db
          .collection(_workspaceCollection)
          .doc(worksapceId)
          .collection(_invitesCollection)
          .doc();
      await transaction.set(documentReference, {
        "email": email,
        "userId": userId,
        "accepted": "",
        "dateInvitation": DateTime.now()
      });
      //creo notifica all'utente
      DocumentReference documentReferenceNotify = await _db
          .collection(_userCollection)
          .doc(userId)
          .collection(_notificheCollection)
          .doc();
      await transaction.set(documentReferenceNotify, {
        "userOwner": ownerId,
        "viewed": false,
        "accepted": "",
        "workspaceIdRef": worksapceId,
        "date": DateTime.now().toUtc()
      });
    });
    await onSuccess();
  }

  Future<List<UserDataModel>> getUserFromEmail(String email) async {
    return await _db
        .collection(_userCollection)
        .where("email", isEqualTo: email)
        .get()
        .then((qs) =>
            qs.docs.map((qd) => UserDataModel.fromFirestore(qd)).toList());
  }

  Stream<List<Invites>> getInvitesForWorkspace(String workspaceId) {
    return _db
        .collection(_workspaceCollection)
        .doc(workspaceId)
        .collection(_invitesCollection)
        .snapshots()
        .map(
          (qs) => qs.docs.map((qd) => Invites.fromFirestore(qd)).toList(),
        );
  }

  Future<void> deleteInvites(
      Invites invites, String wsId, Future<void> onSuccess()) async {
    _db.runTransaction((transaction) async {
      //elimino invito
      await transaction.delete(_db
          .collection(_workspaceCollection)
          .doc(wsId)
          .collection(_invitesCollection)
          .doc(invites.id));
      if (invites.userId != null) {
        //elimino user colors da workspace se presente
        UserWorkspace workspace = await _db
            .collection(_workspaceCollection)
            .doc(wsId)
            .get()
            .then((value) => UserWorkspace.fromFirestore(value));
        Map<String, String> userColors = workspace.userColors!;
        userColors.removeWhere((key, value) => key == invites.userId);

        await transaction
            .update(_db.collection(_workspaceCollection).doc(wsId), {
          "userColors": userColors,
          "contributorsId": FieldValue.arrayRemove([invites.userId])
        });
        //elimino workspaceidref dall'utente a cui tolgo invito

        await transaction
            .update(_db.collection(_userCollection).doc(invites.userId), {
          "workspacesIdRef": FieldValue.arrayRemove([wsId])
        });
        //elimino la notifica dell'utente

        print("cancello notifica");
        await _db
            .collection(_userCollection)
            .doc(invites.userId)
            .collection(_notificheCollection)
            .where("workspaceIdRef", isEqualTo: wsId)
            .get()
            .then((qs) => transaction.delete(qs.docs.first.reference));
      }
    });

    await onSuccess();
  }

  Stream<List<Notifiche>> countNotificheNotViewed(String userId) {
    return _db
        .collection(_userCollection)
        .doc(userId)
        .collection(_notificheCollection)
        .where("viewed", isEqualTo: false)
        .snapshots()
        .map(
          (_q) => _q.docs.map(
            (_d) {
              return Notifiche.fromFirestore(_d);
            },
          ).toList(),
        );
  }

  Future<void> updateUserImage(
    AuthProvider provider,
    File imageFile,
    String fileName,
    String userId,
  ) async {
    //salvo il vecchio url se esiste
    String? oldImage = provider.userData!.image;
    //inserisco immagine in storadge e aggiorno db
    final taskSnap = await _storage
        .ref()
        .child("images/account/$userId/$fileName")
        .putFile(imageFile);
    String url = await taskSnap.ref.getDownloadURL();
    await _db.collection(_userCollection).doc(userId).update({"image": url});
    //se tutto ok rimuovo dallo storadge la vecchia immagine
    if (oldImage != null) {
      await _storage
          .ref()
          .storage
          .refFromURL(provider.userData!.image!)
          .delete();
    }
    //aggiorno provider

    UserDataModel _userData = await getUserData(userId);
    provider.refreshUserData(_userData);
  }

  Stream<List<Product>> getHistoryProducts30days(
      String userId, DateTime dateStart) {
    return _db
        .collectionGroup(_productCollection)
        .where("ownerId", isEqualTo: userId)
        .where("date", isLessThanOrEqualTo: dateStart)
        .where("date",
            isGreaterThanOrEqualTo: dateStart.subtract(Duration(days: 28)))
        .snapshots()
        .map((qs) => qs.docs.map((qd) => Product.fromFirestore(qd)).toList());
  }

  Stream<List<Ricetta>> getHistoryRicetta30days(
      String userId, DateTime dateEnd) {
    return _db
        .collectionGroup(_ricettaCollection)
        .where("ownerId", isEqualTo: userId)
        .where("date", isLessThanOrEqualTo: dateEnd)
        .where("date",
            isGreaterThanOrEqualTo: dateEnd.subtract(Duration(days: 28)))
        .snapshots()
        .map((qs) => qs.docs.map((qd) => Ricetta.fromFirestore(qd)).toList());
  }

  Future<void> deleteUserAccount(
      UserDataModel userDataModel, Future<void> onSuccess()) async {
    _db.runTransaction(
      (transaction) async {
        //recupero workspace associati a utente che siano creati da lui
        await _db
            .collection(_workspaceCollection)
            .where("ownerId", isEqualTo: userDataModel.id)
            .get()
            .then((qs) => qs.docs.forEach((qds) {
                  deleteWorkspace(userDataModel.id!, qds.id);
                }));
        print("elimino");
        //elimino settings
        await _db
            .collection(_userCollection)
            .doc(userDataModel.id)
            .collection(_settingsCollection)
            .get()
            .then((qs) => qs.docs.forEach((qds) {
                  transaction.delete(qds.reference);
                }));
        //elimino user collection
        await transaction
            .delete(_db.collection(_userCollection).doc(userDataModel.id));
      },
    );

    onSuccess();
  }

  Future<void> removeUserFromWorkspace(AuthProvider provider, String userId,
      UserWorkspace workspacesWidget) async {
    await _db.runTransaction((transaction) async {
      //elimino invito

      //elimino user colors da workspace se presente
      UserWorkspace workspace = await _db
          .collection(_workspaceCollection)
          .doc(workspacesWidget.id)
          .get()
          .then((value) => UserWorkspace.fromFirestore(value));
      Map<String, String> userColors = workspace.userColors!;
      userColors.removeWhere((key, value) => key == userId);

      await transaction.update(
          _db.collection(_workspaceCollection).doc(workspacesWidget.id), {
        "userColors": userColors,
        "contributorsId": FieldValue.arrayRemove([userId])
      });
      //elimino workspaceidref dall'utente a cui tolgo invito

      await transaction.update(_db.collection(_userCollection).doc(userId), {
        "workspacesIdRef": FieldValue.arrayRemove([workspacesWidget.id])
      });
      //elimino la notifica dell'utente

      await _db
          .collection(_userCollection)
          .doc(userId)
          .collection(_notificheCollection)
          .where("workspaceIdRef", isEqualTo: workspacesWidget.id)
          .get()
          .then((qs) => transaction.delete(qs.docs.first.reference));

      await _db
          .collection(_workspaceCollection)
          .doc(workspacesWidget.id)
          .collection(_invitesCollection)
          .where("userId", isEqualTo: userId)
          .get()
          .then((qs) => transaction.delete(qs.docs.first.reference));
    });

    UserDataModel _userData = await getUserData(userId);
    _userData.workspacesIdRef!.forEach((element) {
      print(element);
    });
    provider.refreshUserData(_userData);
    NavigationService.instance.navigateToReplacement("home");
  }

  Future<List<UserDataModel>> getContributorsInfo(
      List<String> contributorsId) async {
    List<UserDataModel> data = [];
    contributorsId.forEach((id) async => data.add(await (getUserData(id))));
    return data;
  }
}
