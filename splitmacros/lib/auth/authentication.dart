import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:splitmacros/auth/authentication.dart';
import 'package:splitmacros/auth/widget/signin_widget.dart';
import 'package:splitmacros/home/homepage.dart';
import 'package:splitmacros/service/navigator_service.dart';
import 'package:splitmacros/utils/constant.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  void userAuth(BuildContext _context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: "michael.cauduro.dev@gmail.com", password: "testtest");
      ScaffoldMessenger.of(_context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            "welcome" + userCredential.user.email,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
      NavigationService.instance.navigateToReplacement("home");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    /* return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Center(
            child: ElevatedButton(
              child: Text("auth"),
              onPressed: () => userAuth(context),
            ),
          );
        }
        return SpinKitRotatingCircle(
          color: Colors.white,
          size: 50.0,
        );
      },
    ); */
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          height: _height,
          width: _width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(250),
              bottomRight: Radius.circular(100),
            ),
            color: Theme.of(context).primaryColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Constant().title,
                style: Theme.of(context).textTheme.headline1,
              ),
              SignInWidget(_height, _width),
            ],
          )),
    );
  }
}
