import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highlights_learning/highlight_container.dart';
import 'package:highlights_learning/models/highlight.dart';
import 'package:highlights_learning/provider/highlights_provider.dart';
import 'package:provider/provider.dart';

class HighlightsSection extends StatefulWidget {
  @override
  _HighlightsSectionState createState() => _HighlightsSectionState();
}

class _HighlightsSectionState extends State<HighlightsSection> {
  List<Highlight> highlights;
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    final highlightProvider = Provider.of<HighlightsProvider>(context);
    return Container(
      height: _height,
      child: StreamBuilder(
          stream: highlightProvider.fetchProductsAsStream(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              highlights = snapshot.data.docs
                  .map((doc) => Highlight.fromMap(doc.data(), doc.id))
                  .toList();
              return ListView.builder(
                itemCount: highlights.length,
                itemBuilder: (buildContext, index) =>
                    HighlightContainer(highlightsDetails: highlights[index]),
              );
            } else {
              return Text('fetching');
            }
          }),
    );
  }
}
