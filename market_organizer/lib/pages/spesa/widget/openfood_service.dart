import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:openfoodfacts/model/parameter/SearchTerms.dart';
import 'package:openfoodfacts/model/parameter/TagFilter.dart';
import 'package:openfoodfacts/openfoodfacts.dart' hide Product;
import 'package:openfoodfacts/utils/CountryHelper.dart';

class OpenfoodService {
  static OpenfoodService instance = OpenfoodService();
  final String username = "me4692";
  final String password = "JRr55tL@xLX6qmq";

  Future<List<Product>> getOpenFoodProductByInputItaly(
      String suggestion, BuildContext context) async {
    List<Parameter> parameters = [
      SearchTerms(terms: [suggestion])
    ];

    ProductSearchQueryConfiguration filter = ProductSearchQueryConfiguration(
        parametersList: parameters,
        fields: [
          ProductField.NAME,
          ProductField.GENERIC_NAME,
          ProductField.BRANDS,
          ProductField.QUANTITY
        ],
        language: OpenFoodFactsLanguage.ITALIAN,
        country: OpenFoodFactsCountry.ITALY);

    // final jsonString =
    //     await DefaultAssetBundle.of(context).loadString('pw.json');
    // final dynamic jsonMap = jsonDecode(jsonString);
    print(username);
    print(password);
    User user = User(userId: username, password: password);
    SearchResult result = await OpenFoodAPIClient.searchProducts(user, filter);
    print(result.count);
    List<Product> prodConverted = [];
    if (result.products != null) {
      result.products!.forEach((prod) {
        print(prod.toJson());
        Product p = new Product();
        p.name = prod.productName ?? "";
        p.description = prod.genericName ?? prod.brands ?? "";
        p.quantity = prod.quantity != null ? getQuantity(prod.quantity!) : 0.0;
        p.measureUnit = prod.nutrimentEnergyUnit ?? "grammi";
        p.reparto = "Altro";
        p.price = 0.0;
        p.currency = "€";
        p.date = DateTime.now();

        prodConverted.add(p);
      });
    }
    return prodConverted;
  }

  double getQuantity(String quantity) {
    print(quantity);

    bool parseIntero = true;
    List<int> interi = [];
    List<int> decimali = [];
    double finalValue = 0.0;

    for (int i = 0; i < quantity.length; i++) {
      if (parseIntero) {
        if (quantity[i] == ".") {
          parseIntero = false;
        }
        if (int.tryParse(quantity[i]) != null) {
          print("intero" + i.toString() + int.parse(quantity[i]).toString());
          interi.add(int.parse(quantity[i]));
        }
      } else {
        if (int.tryParse(quantity[i]) != null) {
          print("decimale" + i.toString() + int.parse(quantity[i]).toString());
          decimali.add(int.parse(quantity[i]));
        }
      }
    }
    //interi
    int i = interi.length;
    interi.forEach((intero) {
      print(intero);
      print(intero * pow(10, i - 1));
      finalValue = finalValue + (intero * pow(10, i - 1));
    });
    //decimali
    int d = decimali.length;
    decimali.forEach((decimale) {
      finalValue = finalValue + (decimale * (1 / (pow(10, d - 1))));
    });
    print(finalValue);
    return finalValue;
  }
}
