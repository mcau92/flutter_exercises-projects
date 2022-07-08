import 'package:flutter/material.dart';

class FullPageLoader extends StatelessWidget {
  const FullPageLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
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
