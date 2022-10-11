import 'package:flutter/material.dart';

class ResumeButton extends StatelessWidget {
  final Function resume;
  const ResumeButton({Key? key, required this.resume}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 50,
      child: GestureDetector(
        onTap: () => resume(),
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
