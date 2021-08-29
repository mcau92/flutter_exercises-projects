import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:market_organizer/models/men%C3%B9.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/ricette.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/homepage/widget/menu/singleDay/meal/meal_detail_model.dart';
import 'package:market_organizer/utils/color_costant.dart';
import 'package:market_organizer/utils/datas.dart';
import 'package:market_organizer/utils/utils.dart';

class DatabaseService {
  static DatabaseService instance = DatabaseService();

  String _spesaCollection = "spesa";
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

  Stream<List<Menu>> getMenuFromDate(DateTime start, DateTime end) {
    return Stream.value(
      Utils.instance
          .getCurrentMenuListByWeek(Datas.instance.exampleMenu, start, end),
    );
  }

  List<Ricette> searchRicetteByName(String string) {
    List<Ricette> ricette = [];
    //per ogni menu, aggiungo le ricette che non sono duplicate
    //vado quindi a cercare se una certa ricetta nel menu corrente è presente guardando il nome e la descrizione
    Datas.instance.exampleMenu.forEach(
      (menu) {
        ricette.addAll(
          menu.recipts.where(
            (recipt) =>
                ricette.indexWhere((ricetta) => (ricetta.name == recipt.name &&
                    ricetta.description == recipt.description)) ==
                -1,
          ),
        );
      },
    );
    return ricette
        .where((r) => r.name.toUpperCase().startsWith(string.toUpperCase()))
        .toList();
  }

  void updateMealRicette(Ricette ricetta, MealDetailModel mealInput) {
    Ricette _newRicetta = new Ricette(
        color: ricetta.color,
        date: mealInput.singleDayPageInput.dateTimeDay,
        description: ricetta.description,
        name: ricetta.name,
        image: ricetta.image,
        ownerId: ricetta.ownerId,
        ownerName: ricetta.ownerName,
        pasto: mealInput.pasto,
        products: ricetta.products);
    Datas.instance.exampleMenu
        .where((menu) =>
            (menu.startWeek.isBefore(ricetta.date) ||
                menu.startWeek.isAtSameMomentAs(ricetta.date)) &&
            (menu.endWeek.isAfter(ricetta.date) ||
                menu.startWeek.isAtSameMomentAs(ricetta.date)))
        .first
        .recipts
        .add(_newRicetta);
  }

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
      String measureUnit) async {
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
      "spesaIdRef": spesaIdRef
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
      String measureUnit) async {
    await _db
        .collection(_spesaCollection)
        .doc(spesaIdRef)
        .collection(_productCollection)
        .doc(productId)
        .update({
      "description": (productDescription == null || productDescription.isEmpty)
          ? "nessuna descrizione"
          : productDescription,
      "image": "",
      "measureUnit": measureUnit,
      "quantity": quantity,
      "reparto": productReparto,
    });
  }

  Future<Spesa> createNewSpesa(Spesa spesa) async {
    var docRef = await _db.collection(_spesaCollection).add({
      "ownerId": spesa.ownerId,
      "startWeek": spesa.startWeek,
      "endWeek": spesa.endWeek,
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
  }

  Future<int> getSpesaProductsSize(String spesaIdRef) async {
    int prods = await _db
        .collection(_spesaCollection)
        .doc(spesaIdRef)
        .collection(_productCollection)
        .get().then((value) => value.size);
    return prods;
  }

  Future<void> deleteSpesa(String spesaIdRef) async {
    return await _db.collection(_spesaCollection).doc(spesaIdRef).delete();
  }
}
