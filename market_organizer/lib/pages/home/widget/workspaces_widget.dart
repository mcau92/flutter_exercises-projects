import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/pages/home/widget/userShared_widget.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/service/snackbar_service.dart';
import 'package:market_organizer/utils/full_page_loader.dart';
import 'package:provider/provider.dart';

class WorkspacesWidget extends StatefulWidget {
  @override
  State<WorkspacesWidget> createState() => _WorkspacesWidgetState();
}

class _WorkspacesWidgetState extends State<WorkspacesWidget> {
  List<UserWorkspace> workspaces = [];
  bool _isLoadingData = false;
  late AuthProvider provider;

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
    Navigator.pop(context);
    NavigationService.instance
        .navigateToWithParameters("saveWorkspace", workspacesWidget);
  }

//non usato da cancellare
  void _addToPreferred(UserWorkspace workspacesWidget) async {
    AuthProvider provider = Provider.of<AuthProvider>(context, listen: false);
    await DatabaseService.instance.updateWorkspaceFocus(
        provider, provider.userData!.id!, workspacesWidget.id!);
  }

  void _removeFromPreferred(UserWorkspace workspacesWidget) async {
    AuthProvider provider = Provider.of<AuthProvider>(context, listen: false);
    await DatabaseService.instance
        .updateWorkspaceFocus(provider, provider.userData!.id!, "");
  }

  //metodo generico per aggiungere utente al nostro workspace
  void _addUser(String workspaceId) {
    Navigator.pop(context);
    NavigationService.instance
        .navigateToWithParameters("shareToUserPage", workspaceId);
  }

  void _deleteWorkspace(UserWorkspace workspacesWidget) async {
    setState(() {
      _isLoadingData = true;
    });

    await Future.delayed(Duration(seconds: 1));
    if (workspacesWidget.ownerId == provider.userData!.id!) {
      await DatabaseService.instance
          .deleteWorkspace(provider.userData!.id!, workspacesWidget.id!);
    } else {
      await DatabaseService.instance.removeUserFromWorkspace(
          provider, provider.userData!.id!, workspacesWidget);
    }

    setState(() {
      _isLoadingData = false;
    });

    SnackBarService.instance
        .showSnackBarSuccesfull("Workspace eliminato con successo");
  }

  void _dispatchWorkspace(UserWorkspace workspacesWidget) {
    NavigationService.instance
        .navigateToReplacementWithParameters("dispatchPage", workspacesWidget);
  }

  /** -------------------END FUNCTIONS------------------------- */

  @override
  Widget build(BuildContext context) {
    SnackBarService.instance.buildContext = context;
    provider = Provider.of<AuthProvider>(context, listen: false);
    return Stack(
      children: [
        _wsStream(),
        if (_isLoadingData) FullPageLoader(),
      ],
    );
  }

  Widget _wsStream() {
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
              color: Colors.orange,
            ));
          }
        },
      );
    });
  }

  Widget _workspaceList(String name) {
    return ListView.builder(
      itemCount: workspaces.length,
      itemBuilder: ((context, index) {
        return _workspaceCard(workspaces[index], name);
      }),
    );
  }

  List<Widget> getWorkspaceList(String name) {
    if (workspaces.isNotEmpty)
      return workspaces.map((e) => _workspaceCard(e, name)).toList();
    return [];
  }

  Widget _workspaceCard(UserWorkspace workspacesWidget, String name) {
    UserDataModel _userdata =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    bool isOwnerId = workspacesWidget.ownerId == _userdata.id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.heavyImpact();
          _showUpdateActions(workspacesWidget, isOwnerId);
        },
        onTap: () => _dispatchWorkspace(workspacesWidget),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            color: Colors.white,
            margin: EdgeInsets.all(0),
            elevation: 5,
            child: _listTileWorkspace(
                workspacesWidget, name, isOwnerId, _userdata.favouriteWs),
            shadowColor: Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _listTileWorkspace(UserWorkspace workspacesWidget, String name,
      bool isOwnerId, String? favouriteWs) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                child: Text(
                  workspacesWidget.name!,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                  padding: EdgeInsets.only(left: 15),
                  child: Icon(
                    favouriteWs != null && favouriteWs == workspacesWidget.id
                        ? CupertinoIcons.star_fill
                        : CupertinoIcons.star,
                    color: favouriteWs != null &&
                            favouriteWs == workspacesWidget.id
                        ? Colors.orange
                        : Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    favouriteWs != null && favouriteWs == workspacesWidget.id
                        ? _removeFromPreferred(workspacesWidget)
                        : _addToPreferred(workspacesWidget);
                  }),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                  padding: EdgeInsets.only(right: 15),
                  child: Icon(
                    CupertinoIcons.ellipsis_vertical,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () =>
                      _showUpdateActions(workspacesWidget, isOwnerId)),
            )
          ],
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 15.0, right: 15, top: 35, bottom: 15),
          child: UserShared(
            workspacesWidget,
          ),
        )
      ],
    ));
  }

  void _showUpdateActions(UserWorkspace workspacesWidget, bool isOwnerId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        child: actions(workspacesWidget, isOwnerId),
      ),
    );
  }

  Widget actions(UserWorkspace workspacesWidget, bool isOwnerId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Azioni",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Divider(
          thickness: 0.2,
          color: Colors.black,
        ),
        if (isOwnerId)
          ListTile(
            onTap: () => _updateWorkspace(workspacesWidget),
            leading: Icon(CupertinoIcons.pen),
            title: Text("Modifica"),
          ),
        if (isOwnerId)
          ListTile(
            onTap: () => _addUser(workspacesWidget.id!),
            leading: Icon(CupertinoIcons.person),
            title: Text("Condividi"),
          ),
        ListTile(
          onTap: () async {
            bool isToDeleteAfterConfirm = await _confirmDismiss(context);
            if (isToDeleteAfterConfirm) _deleteWorkspace(workspacesWidget);

            Navigator.pop(context);
          },
          leading: Icon(CupertinoIcons.delete),
          title: Text("Cancella"),
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }
}
