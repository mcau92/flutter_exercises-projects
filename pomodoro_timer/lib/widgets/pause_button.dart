import 'package:flutter/material.dart';

class PauseButton extends StatelessWidget {
  final Function pause;
  const PauseButton({Key? key, required this.pause}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 50,
      child: GestureDetector(
        onTap: () => pause(),
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(50)),
          child: const Center(
              child: Icon(
            Icons.pause_rounded,
            size: 50,
          )),
        ),
      ),
    );
  }
}
