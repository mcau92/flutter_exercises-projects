import 'package:flutter/material.dart';
import 'package:money_saver/ui/section/accounting_section.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: AccountingSection()),
    );
  }
}