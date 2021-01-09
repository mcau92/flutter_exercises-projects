import 'package:flutter/material.dart';
import 'package:money_saver/ui/widget/accounting_details.dart';

class AccountingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(
        3,
      ),
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.red,
      ),
      child: AccountingDetails(),
    );
  }
}
