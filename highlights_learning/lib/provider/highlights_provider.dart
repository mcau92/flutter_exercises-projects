import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:highlights_learning/api/api.dart';
import 'package:highlights_learning/locator.dart';
import 'package:highlights_learning/models/highlight.dart';

class HighlightsProvider with ChangeNotifier {
  Api _api = locator<Api>();
  List<Highlight> highlights;

  Future<List<Highlight>> fetchHighlights() async {
    var result = await _api.getDataCollection();
    highlights = result.docs
        .map((doc) => Highlight.fromMap(doc.data(), doc.id))
        .toList();
    return highlights;
  }

  Stream<QuerySnapshot> fetchProductsAsStream() {
    return _api.streamDataCollection();
  }
  /* 

  Future<Highlight> getProductById(String id) async {
    var doc = await _api.getDocumentById(id);
    return  Highlight.fromMap(doc.data, doc.documentID) ;
  }


  Future removeProduct(String id) async{
     await _api.removeDocument(id) ;
     return ;
  }
  Future updateProduct(Highlight data,String id) async{
    await _api.updateDocument(data.toJson(), id) ;
    return ;
  }

  Future addProduct(Highlight data) async{
    var result  = await _api.addDocument(data.toJson()) ;

    return ;

  } */
}
