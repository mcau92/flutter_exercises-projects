import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:shimmer/shimmer.dart';

class UserShared extends StatefulWidget {
  final UserWorkspace workspacesWidget;

  UserShared(this.workspacesWidget);

  @override
  State<UserShared> createState() => _UserSharedState();
}

class _UserSharedState extends State<UserShared> {
  late Future<UserDataModel> userFuture;
  late Future<List<UserDataModel>> userSharedFuture;

  @override
  void initState() {
    userFuture =
        DatabaseService.instance.getUserData(widget.workspacesWidget.ownerId!);
    userSharedFuture = DatabaseService.instance
        .getContributorsInfo(widget.workspacesWidget.contributorsId!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Creato da: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(
                width: 10,
              ),
              FutureBuilder<UserDataModel>(
                  future: userFuture,
                  builder: (c, s) {
                    if (s.hasData) {
                      return Text(
                        s.data!.name!,
                        style: TextStyle(fontSize: 12),
                      );
                    }
                    return Shimmer(
                      child: Text("....."),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 42, 42, 42),
                          Color.fromARGB(255, 146, 146, 146),
                          Color.fromARGB(255, 218, 218, 220),
                        ],
                        stops: [
                          0.1,
                          0.3,
                          0.4,
                        ],
                        begin: Alignment(-1.0, -0.3),
                        end: Alignment(1.0, 0.3),
                        tileMode: TileMode.clamp,
                      ),
                    );
                  }),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                "Condiviso con: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(
                width: 10,
              ),
              if (widget.workspacesWidget.contributorsId != null &&
                  widget.workspacesWidget.contributorsId!.isNotEmpty)
                FutureBuilder<List<UserDataModel>>(
                    future: userSharedFuture,
                    builder: (c, s) {
                      if (s.hasData) {
                        return Row(
                          children: [
                            ...s.data!.expand(
                              (contributor) => [
                                Text(
                                  contributor.name!,
                                  style: TextStyle(fontSize: 12),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            )
                          ],
                        );
                      } else {
                        return Shimmer(
                          child: Text("....."),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 42, 42, 42),
                              Color.fromARGB(255, 146, 146, 146),
                              Color.fromARGB(255, 218, 218, 220),
                            ],
                            stops: [
                              0.1,
                              0.3,
                              0.4,
                            ],
                            begin: Alignment(-1.0, -0.3),
                            end: Alignment(1.0, 0.3),
                            tileMode: TileMode.clamp,
                          ),
                        );
                      }
                    }),
            ],
          )
        ],
      ),
    );
  }
}
