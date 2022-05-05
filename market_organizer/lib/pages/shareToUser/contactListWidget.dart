import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactListWidget extends StatefulWidget {
  final Function _shareToSelectedUser;
  ContactListWidget(this._shareToSelectedUser);
  @override
  _ContactListWidgetState createState() => _ContactListWidgetState();
}

class _ContactListWidgetState extends State<ContactListWidget> {
  Iterable<Contact> _contacts = [];
  late TextEditingController _textController;
  String searchBarText = "";

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
        searchBarText = string;
        _contacts = contacts;
      });
    } else {
      final Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        searchBarText = "";
        _contacts = contacts.where((element) => element.emails!.isNotEmpty);
      });
    }
  }

  Future<void> _getContacts() async {
    //Make sure we already have permissions for contacts when we get to this
    //page, so we can just retrieve it

    //avoid refresh
    if (_contacts.isNotEmpty || searchBarText.isNotEmpty) {
      return;
    }
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.where((element) => element.emails!.isNotEmpty);
    });
  }

  Future<PermissionStatus> _getPermission() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      print('Permission granted');
    } else if (status.isDenied) {
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PermissionStatus>(
      future: _getPermission(),
      builder: (cont, snap) {
        print(snap.hasData);
        if (snap.hasData && snap.data!.isGranted) {
          return _showContactsBody();
        } else if (snap.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.red));
        } else {
          return Container();
        }
      },
    );
  }

  Widget _showContactsBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _showSearchBar(),
        if (searchBarText.isEmpty) _showTip(),
        if (searchBarText.isNotEmpty) _customDivider("Invita"),
        if (searchBarText.isNotEmpty)
          _showEmailBuilder(), //per mostrare il contatto con la mail che sto inserendo e voglio crearlo da zero

        _customDivider("Contatti"),
        Expanded(child: _showContacts()),
      ],
    );
  }

  Widget _customDivider(String text) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 5),
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
          child: Text("?"),
          backgroundColor: Theme.of(context).accentColor,
        ),
        title: Text(searchBarText),
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
                ),
                onPressed: () {})
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
        .hasMatch(searchBarText);
  }

  Widget _showTip() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8.0),
      child: Center(
        child: Text(
          "Per condividere, inserisci l'indirizzo email e tocca +",
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
        controller: _textController,
        itemColor: Colors.white38,
        placeholder: "Inserisci persona o email..",
        style: TextStyle(color: Colors.white),
        onChanged: (string) => _updateResearch(string),
      ),
    );
  }

  Widget _showContacts() {
    return FutureBuilder(
      future: _getContacts(),
      builder: (cont, snap) {
        return ListView.builder(
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
              )
            : CircleAvatar(
                child: Text(contact.initials()),
                backgroundColor: Theme.of(context).accentColor,
              ),
        title: Text(contact.displayName ?? ''),
        subtitle: Text(contact.emails != null && contact.emails!.isNotEmpty
            ? contact.emails!.first.value!
            : ""),
        trailing: CupertinoButton(
            padding: EdgeInsets.all(0),
            child: Icon(
              CupertinoIcons.add_circled,
              size: 30,
            ),
            onPressed: () {})
        //This can be further expanded to showing contacts detail
        // onPressed().
        );
  }
}
