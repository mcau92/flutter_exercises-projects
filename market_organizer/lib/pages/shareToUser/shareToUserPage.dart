import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market_organizer/database/database_service.dart';
import 'package:market_organizer/models/userdata_model.dart';
import 'package:market_organizer/pages/shareToUser/contactListWidget.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:market_organizer/service/navigation_service.dart';
import 'package:market_organizer/service/snackbar_service.dart';
import 'package:provider/provider.dart';

class ShareToUserPage extends StatefulWidget {
  @override
  _ShareToUserPageState createState() => _ShareToUserPageState();
}

class _ShareToUserPageState extends State<ShareToUserPage> {
  late String worksapceId;

  @override
  Widget build(BuildContext context) {
    SnackBarService.instance.buildContext = context;
    worksapceId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
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
        title: Text(
          "Condividi questo workspace",
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      body: ContactListWidget(worksapceId),
    );
  }
}
