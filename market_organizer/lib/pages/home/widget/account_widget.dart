import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/settings.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/models/userworkspace.model.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/service/snackbar_service.dart';
import 'package:market_organizer/utils/language_list.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class UserWidget extends StatefulWidget {
  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  List<UserWorkspace> workspaces = [];
  late UserDataModel userDataModel;
  late UserSettings userSettings;
  //
  bool _startLoader = false;
  /** -------------------START FUNCTIONS------------------------- */

  Future<bool> _confirmDismiss(BuildContext context) async {
    return await showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text("Confermi di cancellare il tuo account?"),
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

  Future<void> _updateSettingsForLanguage() async {
    await _updateSettings();
    Navigator.of(context).pop();
  }

  Future<void> _updateSettingsForMenuDays() async {
    await _updateSettings();
    Navigator.of(context).pop();
  }

  Future<void> _updateSettings() async {
    await DatabaseService.instance
        .updateUserSettings(userDataModel.id!, userSettings);
  }

  Future<void> _deleteAccountFunction() async {
    await DatabaseService.instance.deleteUserAccount(userDataModel, (() async {
      SnackBarService.instance
          .showSnackBarSuccesfull("Utente eliminato correttamente");
      AuthProvider.instance.deleteAndlogoutUser();
    }));
  }

  void _logout() async {
    setState(() {
      _startLoader = true;
    });
    AuthProvider.instance.logoutUser();
  }

  /** -------------------END FUNCTIONS------------------------- */

  @override
  Widget build(BuildContext context) {
    SnackBarService.instance.buildContext = context;
    double _heigth = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Consumer<AuthProvider>(
      builder: ((context, authprovider, child) {
        userDataModel = authprovider.userData!;
        return Stack(
          children: [
            _account(),
            if (_startLoader) _loader(_heigth, _width),
          ],
        );
      }),
    );
  }

  Widget _account() {
    return StreamBuilder<List<UserSettings>>(
      stream: DatabaseService.instance.getUserSettings(userDataModel.id!),
      builder: (context, snap) {
        if (snap.hasData) {
          userSettings = snap.data![0];
          return _body();
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.orange,
            ),
          );
        }
      },
    );
  }

  Widget _body() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        _imageUserSection(),
        SizedBox(
          height: 20,
        ),
        _settings(),
      ],
    );
  }

  //user image
  Widget _imageUserSection() {
    return Column(
      children: [
        _imageUser(),
        _nameUser(),
        SizedBox(
          height: 10,
        ),
        _emailUser(),
      ],
    );
  }

//get image functions and widget

  Future<void> _upload(String inputSource) async {
    final picker = ImagePicker();
    XFile? pickedImage;
    try {
      print("start");
      pickedImage = await picker.pickImage(
          source: inputSource == "Fotocamera"
              ? ImageSource.camera
              : ImageSource.gallery,
          maxHeight: 1080,
          maxWidth: 1920);
      if (pickedImage != null) {
        print(pickedImage.name);
        setState(() {
          _startLoader = true;
        });
        final String fileName = path.basename(pickedImage.path);
        File imageFile = File(pickedImage.path);

        try {
          // Uploading the selected image with some custom meta data

          AuthProvider provider =
              Provider.of<AuthProvider>(context, listen: false);
          await DatabaseService.instance.updateUserImage(
            provider,
            imageFile,
            fileName,
            userDataModel.id!,
          );
        } on FirebaseException catch (error) {
          print(error);

          SnackBarService.instance.showSnackBarError(
              "errore nel caricamento della foto, riprovare più tardi");
        }
      }
    } catch (err) {
      print(err);

      SnackBarService.instance.showSnackBarError(
          "errore nel caricamento della foto, riprovare più tardi");
    }
    setState(() {
      _startLoader = false;
    });
  }

  Future<void> _showCupertinoPickerImage() async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text('Seleziona come caricare l\'immagine'),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Fotocamera'),
            onPressed: () {
              Navigator.pop(context);
              _upload("Fotocamera");
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Galleria'),
            onPressed: () {
              Navigator.pop(context);

              _upload("Galleria");
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancella'),
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _imageUser() {
    return GestureDetector(
      onTap: () => _showCupertinoPickerImage(),
      child: Container(
        margin: EdgeInsets.all(20),
        height: 100,
        width: 100,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          // image: DecorationImage(
          //     image: NetworkImage(userDataModel.image!), fit: BoxFit.cover),
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[700]!,
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset(
                1,
                1,
              ),
            ),
          ],
        ),
        child: userDataModel.image == null || userDataModel.image!.isEmpty
            ? Center(
                child: Icon(
                  CupertinoIcons.camera,
                  size: 30,
                ),
              )
            : Image.network(
                userDataModel.image!,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _nameUser() {
    return Text(
      userDataModel.name!,
      style: Theme.of(context)
          .textTheme
          .headline6!
          .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _emailUser() {
    return Text(
      userDataModel.email!,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.withOpacity(0.8),
          fontSize: 13),
    );
  }

  //generic settings
  Widget _settings() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            _generalSettings(),
            SizedBox(
              height: 10,
            ),
            _generalSpesaSettings(),
            SizedBox(
              height: 10,
            ),
            _generalMenuSettings(),
            SizedBox(
              height: 40,
            ),
            _logoutWidget(),
            SizedBox(
              height: 10,
            ),
            _deleteAccount(),
          ],
        ),
      ),
    );
  }

//
  void _showCupertinoPicker() {
    FocusScope.of(context).requestFocus(new FocusNode());

    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              // if(...) return true;
              return false;
            },
            child: Container(
              height: 200.0,
              color: Colors.white,
              padding: EdgeInsets.only(bottom: 50),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CupertinoButton(
                        child: Text(
                          "Annulla",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Material(
                            child: Text(
                              "Seleziona la lingua",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      CupertinoButton(
                          child: Text(
                            "Conferma",
                            style: TextStyle(fontSize: 15),
                          ),
                          onPressed: () async => _updateSettingsForLanguage()),
                    ],
                  ),
                  Expanded(
                    child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: LanguageList.units
                                .indexOf(userSettings.language!)),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          String key = LanguageList.units[index];

                          userSettings.language = key;
                        },
                        children: LanguageList.units.map((v) {
                          return Center(child: Text(v));
                        }).toList()),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _generalSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Text(
            "Generale",
            style: TextStyle(color: Colors.orange, fontSize: 16),
          ),
        ),
        _lingua(),
      ],
    );
  }

  Widget _generalSpesaSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Text(
            "Spesa",
            style: TextStyle(color: Colors.orange, fontSize: 16),
          ),
        ),
        _showDefaultPricing(),
        SizedBox(
          height: 10,
        ),
        _showDefaultSelectedInSpesa(),
      ],
    );
  }

  Widget _generalMenuSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Text(
            "Menu",
            style: TextStyle(color: Colors.orange, fontSize: 16),
          ),
        ),
        _showDeleteMenuAfterNdays(),
      ],
    );
  }

  void _showCupertinoPickerDays() {
    FocusScope.of(context).requestFocus(new FocusNode());

    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              // if(...) return true;
              return false;
            },
            child: Container(
              height: 200.0,
              color: Colors.white,
              padding: EdgeInsets.only(bottom: 50),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CupertinoButton(
                        child: Text(
                          "Annulla",
                          style: TextStyle(fontSize: 15),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Material(
                            child: Text(
                              "Seleziona i giorni",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      CupertinoButton(
                          child: Text(
                            "Conferma",
                            style: TextStyle(fontSize: 15),
                          ),
                          onPressed: () async => _updateSettingsForMenuDays()),
                    ],
                  ),
                  Expanded(
                    child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                            initialItem: (userSettings.saveMenuDays ~/ 7) - 1),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          print(userSettings.saveMenuDays % 7);
                          int days = (index + 1) * 7;
                          userSettings.saveMenuDays = days;
                        },
                        children: [
                          for (var i = 1; i < 9; i++)
                            Center(child: Text((i * 7).toString()))
                        ]),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _showDeleteMenuAfterNdays() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Mantieni dati per",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _showCupertinoPickerDays(),
              child: Text(
                userSettings.saveMenuDays.toString() + " giorni",
                style: TextStyle(
                    color: Colors.orange.withOpacity(0.8), fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _showDefaultPricing() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Mostra prezzi in spesa",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            CupertinoSwitch(
                value: userSettings.showPrice,
                onChanged: (value) {
                  userSettings.showPrice = value;
                  _updateSettings();
                }),
          ],
        ),
      ),
    );
  }

  Widget _showDefaultSelectedInSpesa() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Mostra selezionati",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            CupertinoSwitch(
                value: userSettings.showSelected,
                onChanged: (value) {
                  userSettings.showSelected = value;
                  _updateSettings();
                }),
          ],
        ),
      ),
    );
  }

  Widget _lingua() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lingua",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _showCupertinoPicker(),
              child: Text(
                userSettings.language == null ? "" : userSettings.language!,
                style: TextStyle(
                    color: Colors.orange.withOpacity(0.8), fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _logoutWidget() {
    return Center(
      child: CupertinoButton(
          color: Colors.orange,
          child: Text(
            "Logout",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () => _logout()),
    );
  }

  Widget _deleteAccount() {
    return Center(
      child: CupertinoButton(
          color: Colors.red,
          child: Text(
            "Elimina Account",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () async =>
              await _confirmDismiss(context) ? _deleteAccountFunction() : {}),
    );
  }

  Widget _loader(double _height, double _width) {
    return Container(
      width: _width,
      height: _height,
      color: Color.fromRGBO(43, 43, 43, 1).withOpacity(0.5),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      ),
    );
  }
}
