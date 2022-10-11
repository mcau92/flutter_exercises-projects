import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoSpesaWidget extends StatelessWidget {
  const NoSpesaWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(),
        SizedBox(
          height: 30,
        ),
        _image(),
        SizedBox(
          height: 30,
        ),
        _description(),
      ],
    );
  }

  Widget _header() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: SizedBox(
          child: Text(
            "Ops, non ci sono prodotti in lista",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _description() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: SizedBox(
          width: 250,
          child: Text(
            "Inizia ad aggiungerli!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _image() {
    return Container(
      padding: EdgeInsets.all(30),
      clipBehavior: Clip.hardEdge,
      height: 250,
      width: 250,
      child: SvgPicture.asset(
        'assets/images/empty_spesa.svg',
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(250),
      ),
    );
  }
}
