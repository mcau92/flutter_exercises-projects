import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:provider/provider.dart';

class SaveWorkspacePage extends StatefulWidget {
  @override
  _SaveWorkspacePageState createState() => _SaveWorkspacePageState();
}

class _SaveWorkspacePageState extends State<SaveWorkspacePage> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _controller;
  UserWorkspace? _currentWorkspace; //nullo se inserimento
  String _workspaceName = "";
  bool _isInsertSelected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _controller = TextEditingController();
    super.initState();
  }

  void _saveWorkspace() async {
    AuthProvider provider = Provider.of<AuthProvider>(context, listen: false);
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      if (_currentWorkspace == null) {
        //create new workspace
        _currentWorkspace = new UserWorkspace();
        _currentWorkspace!.ownerId = provider.userData!.id;
      }
      _currentWorkspace!.name = _workspaceName;
      await DatabaseService.instance
          .saveWorkspace(_currentWorkspace!, provider);

      NavigationService.instance.goBack();
    } else {
      return await showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text("Inserisci un nome per poter creare il Workspace"),
              actions: [
                CupertinoDialogAction(
                  child: Text("Ho Capito"),
                  onPressed: () {
                    setState(() {
                      _isInsertSelected = true;
                    });
                    Navigator.of(
                      ctx,
                      // rootNavigator: true,
                    ).pop(true);
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = ModalRoute.of(context)!.settings.arguments;
    if (data != null) {
      _currentWorkspace = data as UserWorkspace;
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(43, 43, 43, 1),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
            onPressed: () => NavigationService.instance.goBack(),
          ),
          actions: [
            CupertinoButton(
              child: Text(_currentWorkspace == null ? "Inserisci" : "Aggiorna"),
              onPressed: () => _workspaceName == null || _workspaceName.isEmpty
                  ? Navigator.of(
                      context,
                    ).pop(true)
                  : _saveWorkspace(),
            )
          ],
          title: Text(
            _currentWorkspace == null
                ? "Crea il Workspace"
                : "Aggiorna il Workspace",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: _body(),
        backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      ),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 20.0, right: 20),
      child: Form(
        key: _formKey,
        child: _descriptionContainer(),
      ),
    );
  }

//description
  Widget _descriptionContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(52, 52, 52, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: _productNameWidget(),
    );
  }

  Widget _productNameWidget() {
    return TextFormField(
      initialValue: _currentWorkspace != null ? _currentWorkspace!.name : "",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Inserisci il nome del Workspace";
        } else {
          return null;
        }
      },
      style: TextStyle(color: Colors.white),
      onChanged: (text) {
        if (text != null && text.isNotEmpty) {
          setState(() {
            _workspaceName = text;
          });
          if (_isInsertSelected) _formKey.currentState!.validate();
        }
      },
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        fillColor: Colors.white,
        hintText: "Nome",
        hintStyle: TextStyle(color: Colors.white24),
        errorStyle: TextStyle(
          height: 1.5,
        ),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}
