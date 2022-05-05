import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
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

class UserWidget extends StatefulWidget {
  @override
  State<UserWidget> createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  List<UserWorkspace> workspaces = [];
  late UserDataModel userDataModel;
  late UserSettings userSettings;
  //
  late String _newLanguage;

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

  Future<void> _updateSettings() async {
    await DatabaseService.instance
        .updateUserSettings(userDataModel.id!, userSettings);

    Navigator.of(context).pop();
  }

  void _logout() async {
    AuthProvider.instance.logoutUser();
  }

  /** -------------------END FUNCTIONS------------------------- */

  @override
  Widget build(BuildContext context) {
    SnackBarService.instance.buildContext = context;
    userDataModel = Provider.of<AuthProvider>(context, listen: false).userData!;
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
        _imageUserSection(),
        SizedBox(
          height: 30,
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
    // final picker = ImagePicker();
    // XFile? pickedImage;
    // try {
    //   pickedImage = await picker.pickImage(
    //       source: inputSource == 'camera'
    //           ? ImageSource.camera
    //           : ImageSource.gallery,
    //       maxWidth: 1920);

    //   final String fileName = path.basename(pickedImage!.path);
    //   File imageFile = File(pickedImage.path);

    //   try {
    //     // Uploading the selected image with some custom meta data
    //     await storage.ref(fileName).putFile(
    //         imageFile,
    //         SettableMetadata(customMetadata: {
    //           'uploaded_by': 'A bad guy',
    //           'description': 'Some description...'
    //         }));

    //     // Refresh the UI
    //     setState(() {});
    //   } on FirebaseException catch (error) {
    //     if (kDebugMode) {
    //       print(error);
    //     }
    //   }
    // } catch (err) {
    //   if (kDebugMode) {
    //     print(err);
    //   }
    // }
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
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(150),
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
                    size: 40,
                  ),
                )
              : null),
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
    return Column(
      children: [
        _generalSettings(),
        SizedBox(
          height: 30,
        ),
        _accountSettings(),
      ],
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
                          onPressed: () async => _updateSettings()),
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Text(
            "Generale",
            style: TextStyle(color: Colors.orange, fontSize: 16),
          ),
        ),
        _lingua(),
      ],
    );
  }

  Widget _lingua() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
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
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _showCupertinoPicker(),
              child: Text(
                userSettings == null || userSettings.language == null
                    ? ""
                    : userSettings.language!,
                style: TextStyle(
                    color: Colors.orange.withOpacity(0.8), fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _accountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Text(
            "Account",
            style: TextStyle(color: Colors.orange, fontSize: 16),
          ),
        ),
        _logoutWidget(),
        SizedBox(
          height: 5,
        ),
        _deleteAccount(),
      ],
    );
  }

  Widget _logoutWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () => _logout(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Text(
            "Logout",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _deleteAccount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () => {}, //TODO
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Text(
            "Elimina Account",
            style: TextStyle(color: Colors.red[900], fontSize: 16),
          ),
        ),
      ),
    );
  }
}
