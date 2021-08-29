import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  String name;
  EmptyWidget(this.name);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text(name),
      ),
    );
  }
}
