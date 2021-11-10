import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/pages/spesa/reparto_widget.dart';
import 'package:market_organizer/models/product_model.dart';
import 'package:market_organizer/models/spesa.dart';
import 'package:market_organizer/utils/utils.dart';

class BodyWidget extends StatelessWidget {
  final Spesa _spesa;

  BodyWidget(this._spesa);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: _repartoList());
  }

  Widget _repartoList() {
    return StreamBuilder<List<Product>>(
        stream: DatabaseService.instance.getProductsBySpesa(_spesa.id),
        builder: (context, _snapshot) {
          if (_snapshot.hasData) {
            if (_snapshot.data != null && _snapshot.data.isNotEmpty) {
              List<Product> _products = _snapshot.data;
              List<String> reparti = Utils.instance.getReparti(_products);
              return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 7,
                    );
                  },
                  itemCount: reparti.length,
                  itemBuilder: (context, index) {
                    return RepartoWidget(
                      _spesa.workspaceIdRef,
                      reparti[index],
                      _products
                          .where((p) => p.reparto == reparti[index])
                          .toList(),
                    );
                  });
            } else {
              return Center(
                child: Text("nessuna spesa inserita"),
              );
            }
          } else {
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.red,
            ));
          }
        });
  }
}
