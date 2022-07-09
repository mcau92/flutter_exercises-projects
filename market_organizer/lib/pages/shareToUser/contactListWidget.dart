import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/invites.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/snackbar_service.dart';
import 'package:market_organizer/utils/full_page_loader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class ContactListWidget extends StatefulWidget {
  final String workspaceId;
  ContactListWidget(this.workspaceId);
  @override
  _ContactListWidgetState createState() => _ContactListWidgetState();
}

class _ContactListWidgetState extends State<ContactListWidget> {
  Iterable<Contact> _contacts = [];
  late TextEditingController _textController;
  String emailSearchBarText = "";
  bool _isLoadingData = false;

  @override
  void initState() {
    _textController = new TextEditingController();
    super.initState();
  }

  void _updateResearch(String string) async {
    if (string != "") {
      Iterable<Contact> contacts = await ContactsService.getContacts();

      contacts = contacts.where((element) => element.emails!.isNotEmpty);

      contacts = contacts.where((c) =>
          (c.displayName != null && c.displayName!.startsWith(string)) ||
          (c.emails!.first.value!.startsWith(string)));

      setState(() {
        emailSearchBarText = string;
        _contacts = contacts;
      });
    } else {
      final Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        emailSearchBarText = "";
        _contacts = contacts.where((element) => element.emails!.isNotEmpty);
      });
    }
  }

  Future<void> _getContacts() async {
    //Make sure we already have permissions for contacts when we get to this
    //page, so we can just retrieve it

    //avoid refresh
    if (_contacts.isNotEmpty || emailSearchBarText.isNotEmpty) {
      return;
    }
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts =
          contacts.where((element) => element.emails!.isNotEmpty).toList();
    });
  }

  Future<PermissionStatus> _getPermission() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
    } else if (status.isDenied) {
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return status;
  }

  Future<void> _removeSelectedUser(Invites invites) async {
    try {
      await DatabaseService.instance.deleteInvites(invites, widget.workspaceId,
          () async {
        SnackBarService.instance
            .showSnackBarSuccesfull("Utente rimosso dal workspace");
      });
    } catch (e) {
      print(e);
      SnackBarService.instance
          .showSnackBarError("impossibile rimuovere utente, riprova più tardi");
    }
  }

  Future<void> _shareToSelectedUser(String email) async {
    UserDataModel ownerId =
        Provider.of<AuthProvider>(context, listen: false).userData!;
    //check if user exist manage invites and notify
    List<UserDataModel> userSingletonList =
        await DatabaseService.instance.getUserFromEmail(email);

    if (userSingletonList.isNotEmpty) {
      setState(() {
        _isLoadingData = true;
      });
      await Future.delayed(Duration(seconds: 1));
      try {
        await DatabaseService.instance.shareWorkspaceToUser(
            ownerId.id!, userSingletonList.first.id!, email, widget.workspaceId,
            () async {
          SnackBarService.instance.showSnackBarSuccesfull(
              "L'invito è stato inoltrato correttamente");
        });
      } catch (e) {
        print(e);
        SnackBarService.instance
            .showSnackBarError("impossibile condividere, riprova più tardi");
      }
      setState(() {
        _isLoadingData = false;
        _textController.text = "";
        emailSearchBarText = "";
      });
    } else {
      //if not present send invitation, actualy print user not exist
      print("non esiste");
      SnackBarService.instance.showSnackBarError("utente non registrato");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _body(),
        if (_isLoadingData) FullPageLoader(),
      ],
    );
  }

  Widget _body() {
    if (emailSearchBarText.isNotEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            _showSearchBar(),
            SingleChildScrollView(
              child: Column(
                children: [
                  _customDivider("Invita"),
                  _showEmailBuilder(),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          _showSearchBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _showTip(),
                  _showSharedUser(),
                  _contactList(),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _showSharedUser() {
    return StreamBuilder<List<Invites>>(
      stream:
          DatabaseService.instance.getInvitesForWorkspace(widget.workspaceId),
      builder: (context, snap) {
        if (snap.hasData) {
          List<Invites> accepted =
              snap.data!.where((invite) => invite.accepted == "1").toList();
          List<Invites> notYetProcessed =
              snap.data!.where((invite) => invite.accepted == "").toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (accepted.isNotEmpty)
                StickyHeader(
                  header: _customDivider("Condiviso con"),
                  content: ListView.builder(
                    padding: EdgeInsets.all(0),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: accepted.length,
                    itemBuilder: (BuildContext context, int index) {
                      Invites invites = accepted.elementAt(index);
                      return Container(
                        margin: EdgeInsets.all(10),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: _invitesCardProcessed(invites),
                      );
                    },
                  ),
                ),
              if (notYetProcessed.isNotEmpty)
                StickyHeader(
                  header: _customDivider("In attesa"),
                  content: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: notYetProcessed.length,
                    itemBuilder: (BuildContext context, int index) {
                      Invites invites = notYetProcessed.elementAt(index);
                      return Container(
                        margin: EdgeInsets.all(10),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: _invitesCardWaiting(invites),
                      );
                    },
                  ),
                ),
              if (notYetProcessed.isEmpty && accepted.isEmpty)
                //default
                Container(),
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _contactList() {
    return FutureBuilder<PermissionStatus>(
      future: _getPermission(),
      builder: (cont, snap) {
        if (snap.hasData && snap.data!.isGranted) {
          return _showContacts();
        } else if (snap.hasData && snap.data!.isDenied) {
          return Center(
            child: Text(
              "Accesso ai contatti negato",
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _customDivider(String text) {
    return Container(
      color: Color.fromRGBO(43, 43, 43, 1),
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 7),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 0.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showEmailBuilder() {
    bool isEmailValid = checkMailIsValid();
    return Container(
      margin: EdgeInsets.all(10),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
        dense: true,
        leading: CircleAvatar(
          child: Text(
            "?",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromRGBO(43, 43, 43, 1),
        ),
        title: Text(
          emailSearchBarText,
        ),
        subtitle: Text(
          isEmailValid ? "" : "inserire una mail valida",
          style: TextStyle(color: Colors.red),
        ),

        trailing: isEmailValid
            ? CupertinoButton(
                padding: EdgeInsets.all(0),
                child: Icon(
                  CupertinoIcons.add_circled,
                  size: 30,
                  color: Colors.orange,
                ),
                onPressed: () => _shareToSelectedUser(emailSearchBarText))
            : CupertinoButton(
                padding: EdgeInsets.all(0),
                child: Icon(
                  CupertinoIcons.exclamationmark_circle,
                  color: Colors.red,
                  size: 30,
                ),
                onPressed: () {}),
        //This can be further expanded to showing contacts detail
        // onPressed().
      ),
    );
  }

  //check if email is a valid one
  bool checkMailIsValid() {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailSearchBarText);
  }

  Widget _showTip() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8.0),
      child: Center(
        child: Text(
          "Ricerca per nome contatto o email e tocca +",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _showSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSearchTextField(
        autofocus: true,
        controller: _textController,
        itemColor: Colors.white38,
        placeholder: "Contatto o email..",
        style: TextStyle(color: Colors.white),
        onChanged: (string) => _updateResearch(string),
      ),
    );
  }

  Widget _showContacts() {
    return FutureBuilder(
      future: _getContacts(),
      builder: (cont, snap) {
        return StickyHeader(
          header: _customDivider("Contatti"),
          content: ListView.builder(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _contacts.length,
            itemBuilder: (BuildContext context, int index) {
              Contact contact = _contacts.elementAt(index);
              return Container(
                  margin: EdgeInsets.all(10),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: _contactCard(contact));
            },
          ),
        );
      },
    );
  }

  Widget _contactCard(Contact contact) {
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
        dense: true,
        leading: (contact.avatar != null && contact.avatar!.isNotEmpty)
            ? CircleAvatar(
                backgroundImage: MemoryImage(contact.avatar!),
                backgroundColor: Color.fromRGBO(43, 43, 43, 1),
              )
            : CircleAvatar(
                child: Text(contact.initials(),
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Color.fromRGBO(43, 43, 43, 1),
              ),
        title: Text(contact.displayName ?? ''),
        subtitle: Text(
          contact.emails != null && contact.emails!.isNotEmpty
              ? contact.emails!.first.value!
              : "",
        ),
        trailing: CupertinoButton(
            padding: EdgeInsets.all(0),
            child: Icon(
              CupertinoIcons.add_circled,
              color: Colors.orange,
              size: 30,
            ),
            onPressed: () => _shareToSelectedUser(contact.emails!.first.value!))
        //This can be further expanded to showing contacts detail
        // onPressed().
        );
  }

  Future<bool> _confirmRemoveUser(
      bool isAcceptedAlready, BuildContext context) async {
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(isAcceptedAlready
                ? "Confermi di rimuovere l'utente?"
                : "Confermi di rimuovere l'invito?"),
            actions: [
              CupertinoDialogAction(
                child: Text("Si"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                    // rootNavigator: true,
                  ).pop(true);
                },
              ),
              CupertinoDialogAction(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(
                    ctx,
                    // rootNavigator: true,
                  ).pop(false);
                },
              ),
            ],
          );
        });
  }

  Widget _invitesCardProcessed(Invites invites) {
    return FutureBuilder<UserDataModel>(
        future: DatabaseService.instance.getUserData(invites.userId!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserDataModel userinfo = snapshot.data!;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
              dense: true,
              leading: (userinfo.image != null && userinfo.image!.isNotEmpty)
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(userinfo.image!),
                      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
                    )
                  : CircleAvatar(
                      child: Text(userinfo.name!.substring(0, 1)),
                      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
                    ),
              title: Text(userinfo.name ?? '',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                  userinfo.email != null && userinfo.email!.isNotEmpty
                      ? userinfo.email!
                      : ""),
              trailing: CupertinoButton(
                onPressed: () async => await _confirmRemoveUser(true, context)
                    ? _removeSelectedUser(invites)
                    : null,
                padding: EdgeInsets.all(0),
                child: Icon(
                  invites.accepted == "1"
                      ? CupertinoIcons.checkmark_alt_circle_fill
                      : CupertinoIcons.clear_thick_circled,
                  color: invites.accepted == "1" ? Colors.green : Colors.red,
                  size: 30,
                ),
              ), //This can be further expanded to showing contacts detail
              // onPressed().
            );
          } else {
            return Container();
          }
        });
  }

  Widget _invitesCardWaiting(Invites invites) {
    if (invites.userId == null) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
        dense: true,
        leading: CircleAvatar(
          child: Text("?", style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(43, 43, 43, 1),
        ),
        title: Text(invites.email!),

        trailing: CupertinoButton(
          onPressed: () async => await _confirmRemoveUser(false, context)
              ? _removeSelectedUser(invites)
              : null,
          padding: EdgeInsets.all(0),
          child: Icon(
            CupertinoIcons.envelope,
            color: Colors.orange,
            size: 30,
          ),
        ), //This can be further expanded to showing contacts detail
        // onPressed().
      );
      //else use userinfo
    } else {
      return FutureBuilder<UserDataModel>(
          future: DatabaseService.instance.getUserData(invites.userId!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserDataModel userinfo = snapshot.data!;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                dense: true,
                leading: (userinfo.image != null && userinfo.image!.isNotEmpty)
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(userinfo.image!),
                        backgroundColor: Color.fromRGBO(43, 43, 43, 1),
                      )
                    : CircleAvatar(
                        child: Text(userinfo.name!.substring(0, 1),
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Color.fromRGBO(43, 43, 43, 1),
                      ),
                title: Text(
                  userinfo.name ?? '',
                ),
                subtitle: Text(
                    userinfo.email != null && userinfo.email!.isNotEmpty
                        ? userinfo.email!
                        : ""),
                trailing: CupertinoButton(
                  onPressed: () async =>
                      await _confirmRemoveUser(false, context)
                          ? _removeSelectedUser(invites)
                          : null,
                  padding: EdgeInsets.all(0),
                  child: Icon(
                    CupertinoIcons.envelope_badge,
                    color: Colors.orange,
                    size: 30,
                  ),
                ),
              );
            } else {
              return Container();
            }
          });
    }
  }
}
