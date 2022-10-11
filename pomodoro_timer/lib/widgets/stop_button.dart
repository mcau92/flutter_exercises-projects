import 'package:flutter/material.dart';

class StopButton extends StatelessWidget {
  final Function resetCounters;
  const StopButton({Key? key, required this.resetCounters}) : super(key: key);

  void _stop(BuildContext context) {
    resetCounters();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 50,
      child: GestureDetector(
        onTap: () => _stop(context),
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(50)),
          child: const Center(
            child: Icon(
              Icons.stop_rounded,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}
