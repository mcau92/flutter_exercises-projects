import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/pages/spesa/singleproduct_widget.dart';
import 'package:market_organizer/models/product_model.dart';

class RepartoWidget extends StatelessWidget {
  final String _workspaceId;
  final String repartoName;
  final List<Product> products;

  RepartoWidget(this._workspaceId,this.repartoName, this.products);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 15, top: 10, right: 15, left: 15),
      
      child: Column(
        children: [_titleReparto(), _productsList()],
      ),
    );
  }

  Widget _titleReparto() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          repartoName,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _productsList() {
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) {
          return Divider(
            height: 20,
            thickness: 0,
          );
        },
        itemCount: products.length,
        itemBuilder: (context, index) {
          return SingleProductWidget(_workspaceId,products[index],index);
        });
  }
}
