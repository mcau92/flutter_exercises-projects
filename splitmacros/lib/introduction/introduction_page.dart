import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:splitmacros/introduction/widget/kcal_form_widget.dart';
import 'package:splitmacros/utils/constant.dart';

class IntroductionPage extends StatefulWidget {
  @override
  _IntroductionPageState createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  int _kcal;

  void updateKcal(int _kcalInput) {
    setState(() {
      _kcal = _kcalInput;
    });
  }

  static final List<PageViewModel> _introductionPages = [
    new PageViewModel(
      titleWidget: RichText(
        text: TextSpan(
          text: "Welcome to ",
          style: TextStyle(
            fontFamily: GoogleFonts.satisfy.toString(),
            fontSize: 22,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: "SplitMacros",
              style: TextStyle(
                fontFamily: GoogleFonts.satisfy.toString(),
                fontSize: 25,
                color: Color.fromRGBO(234, 142, 35, 1),
              ),
            ),
          ],
        ),
      ),
      body:
          "Here you can set some default parameters to ensure a better user experience.. You can for sure change those later",
      footer: Text(
        "let's start!",
        style: TextStyle(
            fontFamily: GoogleFonts.satisfy.toString(),
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
      image: const Center(child: Icon(Icons.android)),
    ),
    new PageViewModel(
      title: "What is your b",
      bodyWidget: KcalFormWidget(updateKcal),
      image: const Center(child: Icon(Icons.ac_unit)),
      footer: RaisedButton(
        color: Color.fromRGBO(234, 142, 35, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onPressed: () {
          // On button presed
        },
        child: const Text("Let's Go !"),
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: _introductionPages,
      onDone: () {},
      done: Container(),
      next: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(234, 142, 35, 1),
              borderRadius: BorderRadius.circular(20)),
          child: Icon(Icons.navigate_next, size: 40)),
      dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Theme.of(context).primaryColor,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0))),
    );
  }
}
