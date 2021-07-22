import 'package:flutter/material.dart';
import 'package:market_organizer/homepage/widget/reparto_widget.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/utils/utils.dart';

class BodyWidget extends StatelessWidget {
  final UserWorkspace _workspace;

  BodyWidget(this._workspace);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
          children: [_repartoList()],
        ),
      
    );
  }

  Widget _repartoList() {
    List<String> reparti = Utils.instance.getReparti(_workspace);
    print(reparti.length);
    return Expanded(
      child: ListView.separated(
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
              reparti[index],
              _workspace.products
                  .where((p) => p.reparto == reparti[index])
                  .toList(),
            );
          }),
    );
  }
}
