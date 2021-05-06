import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:highlights_learning/models/highlight.dart';

class HighlightContainer extends StatelessWidget {
  final Highlight highlightsDetails;
  HighlightContainer({this.highlightsDetails});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 20,
      child: ListTile(
        title: Text(
          "highlight description",
        ),
        subtitle: Text(highlightsDetails.highlightText),
      ),
    );
  }
}
