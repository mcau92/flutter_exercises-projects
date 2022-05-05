import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/utils/color_costant.dart';
import 'package:market_organizer/utils/utils.dart';
import 'package:provider/provider.dart';

class WorkspacesWidget extends StatefulWidget {
  @override
  State<WorkspacesWidget> createState() => _WorkspacesWidgetState();
}

class _WorkspacesWidgetState extends State<WorkspacesWidget> {
  List<UserWorkspace> workspaces = [];

  /** -------------------START FUNCTIONS------------------------- */

  Future<bool> _confirmDismiss(BuildContext context) async {
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text("Confermi di cancellare questo Workspace?"),
            actions: [
              CupertinoDialogAction(
                child: Text("si"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                    // rootNavigator: true,
                  ).pop(true);
                },
              ),
              CupertinoDialogAction(
                child: Text("no"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                  ).pop(false);
                },
              )
            ],
          );
        });
  }

  void _updateWorkspace(UserWorkspace workspacesWidget) {
    NavigationService.instance
        .navigateToWithParameters("saveWorkspace", workspacesWidget);
  }

//non usato da cancellare
  void _addToPreferred(UserWorkspace workspacesWidget) async {
    Iterable<UserWorkspace> currentFocused =
        workspaces.where((w) => w.focused! && w.id != workspacesWidget.id);
    if (currentFocused != null && currentFocused.isNotEmpty) {
      await DatabaseService.instance.updateWorkspaceFocus(
          currentFocused.first.id!, !currentFocused.first.focused!);
    }
  }

  Future<void> _deleteWorkspace(UserWorkspace workspacesWidget) async {
    bool isToDeleteAfterConfirm = await _confirmDismiss(context);
    if (isToDeleteAfterConfirm) {
      await DatabaseService.instance.deleteWorkspace(workspacesWidget);
    }
  }

  void _dispatchWorkspace(UserWorkspace workspacesWidget) {
    NavigationService.instance
        .navigateToReplacementWithParameters("dispatchPage", workspacesWidget);
  }

  /** -------------------END FUNCTIONS------------------------- */

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, autProv, child) {
      if (autProv.userData!.workspacesIdRef!.isEmpty) {
        return Container();
      }
      return StreamBuilder<List<UserWorkspace>>(
        stream: DatabaseService.instance
            .getUserWorkspace(autProv.userData!.workspacesIdRef!),
        builder: (ctx, _snap) {
          if (_snap.hasData) {
            workspaces = _snap.data!;
            return _workspaceList(autProv.userData!.name!);
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: Colors.red,
            ));
          }
        },
      );
    });
  }

  Widget _workspaceList(String name) {
    return ListView.separated(
        separatorBuilder: (context, index) {
          return SizedBox(
            height: 2,
          );
        },
        itemCount: workspaces.length,
        itemBuilder: (context, index) {
          return _workspaceCard(workspaces[index], name);
        });
  }

  Widget _workspaceCard(UserWorkspace workspacesWidget, String name) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => _dispatchWorkspace(workspacesWidget),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Slidable(
            key: UniqueKey(),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0)),
              color: Colors.white,
              margin: EdgeInsets.all(0),
              elevation: 5,
              child: _listTileWorkspace(workspacesWidget, name),
              shadowColor: Colors.red,
            ),
            direction: Axis.horizontal,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                    label: "Modifica",
                    backgroundColor: Colors.green,
                    icon: CupertinoIcons.pen,
                    onPressed: (bc) => _updateWorkspace(workspacesWidget),
                    autoClose: true),
                SlidableAction(
                  label: "Elimina",
                  backgroundColor: Colors.red,
                  icon: CupertinoIcons.delete,
                  onPressed: (bc) => _deleteWorkspace(workspacesWidget),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listTileWorkspace(UserWorkspace workspacesWidget, String name) {
    return Container(
        color: ColorCostant
            .colorMap[workspacesWidget.userColors![workspacesWidget.ownerId]]!
            .withOpacity(0.2),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 10, bottom: 10),
              child: Text(
                workspacesWidget.name!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_userShared(workspacesWidget)],
            )
          ],
        ));
  }

  Widget _userShared(UserWorkspace workspacesWidget) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<UserDataModel>(
                future: DatabaseService.instance
                    .getUserData(workspacesWidget.ownerId!),
                builder: (c, s) {
                  if (s.hasData) {
                    return _userBox(
                      workspacesWidget.userColors![workspacesWidget.ownerId]!,
                      s.data!.name!,
                    );
                  } else {
                    return Container();
                  }
                }),
            if (workspacesWidget.contributorsId!.isNotEmpty)
              VerticalDivider(
                indent: 10,
                endIndent: 10,
                thickness: 0.5,
                color: Colors.black,
              ),
            for (var contributorId in workspacesWidget.contributorsId!)
              FutureBuilder<UserDataModel>(
                  future: DatabaseService.instance.getUserData(contributorId),
                  builder: (c, s) {
                    if (s.hasData) {
                      return _userBox(
                        workspacesWidget.userColors![contributorId]!,
                        s.data!.name!,
                      );
                    } else {
                      return Container();
                    }
                  })
          ],
        ),
      ),
    );
  }

  Widget _userBox(String color, String name) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 2),
      height: 25,
      width: 25,
      decoration: BoxDecoration(
        color: ColorCostant.colorMap[color],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }
}
