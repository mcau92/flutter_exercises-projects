import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/notifiche.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/service/snackbar_service.dart';
import 'package:provider/provider.dart';

class NotifyPage extends StatefulWidget {
  const NotifyPage() : super();

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  void _acceptWorkspaceWork(Notifiche notifica, String userId) async {
    AuthProvider _auth = Provider.of<AuthProvider>(context, listen: false);
    await DatabaseService.instance.acceptWorkspaceWork(notifica, userId, _auth);

    SnackBarService.instance
        .showSnackBarSuccesfull("Ora puoi iniziare a contribuire!");

    NavigationService.instance.goBack();
  }

  void _rejectWorkspaceWork(Notifiche notifica, String userId) async {
    await DatabaseService.instance.rejectWorkspaceWork(notifica, userId);

    SnackBarService.instance
        .showSnackBarSuccesfull("Workspace rifiutato con successo");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SnackBarService.instance.buildContext = context;
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 1,
        leading: CupertinoButton(
          child: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
          onPressed: () => NavigationService.instance.goBack(),
        ),
        title: Text("Le tue notifiche"),
      ),
      body: _bodySelection(),
    );
  }

  void _resetViewFlag(String userId) async {
    await DatabaseService.instance.updateViewNotifications(userId);
  }

  Widget _bodySelection() {
    AuthProvider _autProv = Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder<List<Notifiche>>(
      future: DatabaseService.instance.getUserNotifies(_autProv.userData!.id!),
      builder: (ctx, _snap) {
        if (_snap.hasData) {
          _resetViewFlag(_autProv.userData!.id!);
          return ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 2,
              );
            },
            itemCount: _snap.data!.length,
            itemBuilder: (context, index) {
              return _notifyCard(_snap.data![index], _autProv);
            },
          );
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.red,
          ));
        }
      },
    );
  }

  Widget _notifyCard(Notifiche notifica, AuthProvider _autProv) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        clipBehavior: Clip.hardEdge,
        child: Slidable(
          key: UniqueKey(),
          child: Card(
            color: Colors.white,
            margin: EdgeInsets.all(0),
            elevation: 5,
            child: _listTileNotifiche(notifica),
            shadowColor: Colors.red,
          ),
          direction: Axis.horizontal,
          startActionPane: ActionPane(
            extentRatio: 1 / 2,
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                  label: "Accetta",
                  backgroundColor: Colors.green,
                  icon: CupertinoIcons.checkmark,
                  onPressed: (bc) =>
                      _acceptWorkspaceWork(notifica, _autProv.userData!.id!),
                  autoClose: true),
              SlidableAction(
                label: "Rifiuta",
                backgroundColor: Colors.red,
                icon: CupertinoIcons.delete,
                onPressed: (bc) =>
                    _rejectWorkspaceWork(notifica, _autProv.userData!.id!),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _listTileNotifiche(Notifiche notifiche) {
    return FutureBuilder<UserDataModel>(
      future: DatabaseService.instance.getUserData(notifiche.userOwner!),
      builder: (ctx, _snap) {
        if (_snap.hasData) {
          return Container(
            color: Colors.blue.withOpacity(0.2),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _snap.data!.name!,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        _manageInfo(notifiche)
                      ],
                    ),
                    Text(
                      _snap.data!.email!,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Ti ha invitato a partecipare al suo workspace!",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                )),
          );
        }
        return Center(
          child: LinearProgressIndicator(
            color: Colors.red,
          ),
        );
      },
    );
  }

  Widget _manageInfo(Notifiche notifiche) {
    return Row(
      children: [
        if (!notifiche.viewed!)
          Container(
            decoration: BoxDecoration(
                color: Colors.orange, borderRadius: BorderRadius.circular(5)),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                "NEW",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (!notifiche.viewed!)
          SizedBox(
            width: 10,
          ),
        Container(
          decoration: BoxDecoration(
              color:
                  notifiche.accepted != null && notifiche.accepted!.isNotEmpty
                      ? (notifiche.accepted == 1 ? Colors.green : Colors.red)
                      : Colors.lightBlue,
              borderRadius: BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text(
              notifiche.accepted != null && notifiche.accepted!.isNotEmpty
                  ? (notifiche.accepted == 1 ? "ACCETTATO" : "RIFIUTATO")
                  : "IN ATTESA",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }
}
