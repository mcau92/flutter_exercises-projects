import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget with PreferredSizeWidget {
  Widget _leftWidget;
  Widget _centerWidget;
  Widget _rightWidget;
  Color _background;
  double _height;

  AppBarWidget(
      leftWidget, centerWidget, rightWidget, this._background, this._height) {
    leftWidget == null ? _leftWidget = Container() : _leftWidget = leftWidget;
    centerWidget == null
        ? _centerWidget = Container()
        : _centerWidget = centerWidget;
    rightWidget == null
        ? _rightWidget = Container()
        : _rightWidget = rightWidget;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _background,
        border: Border.all(width: 0, color: _background),
      ),
      child: Container(
        height: _height,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(50),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 30, right: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_leftWidget, _centerWidget, _rightWidget],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(_height);
}
