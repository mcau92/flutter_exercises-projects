import 'package:flutter/material.dart';
import 'package:market_organizer/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class LoaderPage extends StatefulWidget {
  const LoaderPage({Key? key}) : super(key: key);

  @override
  State<LoaderPage> createState() => _LoaderPageState();
}

class _LoaderPageState extends State<LoaderPage> {
  @override
  Widget build(BuildContext context) {
//init provider and dispatch to the right page
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 43, 43, 1),
      body: Center(child: _loader()),
    );
  }

  Widget _loader() {
    return Consumer<AuthProvider>(
      builder: (context, value, child) {
        return CircularProgressIndicator(
          color: Colors.orange,
        );
      },
    );
  }
}
