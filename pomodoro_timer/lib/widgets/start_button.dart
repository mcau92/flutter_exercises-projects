import 'package:flutter/material.dart';

class StartButton extends StatelessWidget {
  const StartButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 50,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushReplacementNamed("studio"),
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(50)),
          child: const Center(
              child: Icon(
            Icons.play_arrow_rounded,
            size: 50,
          )),
        ),
      ),
    );
  }
}
