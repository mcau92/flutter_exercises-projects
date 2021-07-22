import 'package:flutter/material.dart';
import 'package:market_organizer/homepage/widget/singleproduct_widget.dart';
import 'package:market_organizer/models/product_model.dart';

class RepartoWidget extends StatelessWidget {
  final String repartoName;
  final List<Product> products;

  RepartoWidget(this.repartoName, this.products);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15,top: 10),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [_titleReparto(), _productsList()],
      ),
    );
  }

  Widget _titleReparto() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 8.0),
        child: Text(
          repartoName,
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _productsList() {
    return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return Divider(
            height: 20,
          );
        },
        itemCount: products.length,
        itemBuilder: (context, index) {
          return SingleProductWidget(products[index]);
        });
  }
}
