import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_timer/utils/decoder.dart';
import 'package:pomodoro_timer/utils/settings_type.dart';

class SettingsPickerWidget extends StatefulWidget {
  final SettingsType settingsType;
  final String title;
  final int currentSelectedOption;
  final List<int> options;
  final Function(int selectedOption) updateOption;

  const SettingsPickerWidget(
      {Key? key,
      required this.settingsType,
      required this.title,
      required this.currentSelectedOption,
      required this.options,
      required this.updateOption})
      : super(key: key);

  @override
  State<SettingsPickerWidget> createState() => _SettingsPickerWidgetState();
}

class _SettingsPickerWidgetState extends State<SettingsPickerWidget> {
  int? _currentSelectedOptionAfterConfirm;

  void _updateCurrentSelectedOption() {
    if (_currentSelectedOptionAfterConfirm != null &&
        _currentSelectedOptionAfterConfirm != widget.currentSelectedOption) {
      widget.updateOption(_currentSelectedOptionAfterConfirm!);
    }
    Navigator.pop(context);
  }

  void _showCupertinoPicker(BuildContext context) {
    showCupertinoModalPopup(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Container(
              height: 200,
              color: Colors.white,
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.grey, width: 0.2))),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.zero),
                              child: const Text(
                                "Annulla",
                                style: TextStyle(fontSize: 16),
                              ),
                              onPressed: () => Navigator.of(context).pop()),
                          Center(
                            child: Material(
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero),
                            child: const Text("Conferma",
                                style: TextStyle(
                                  fontSize: 16,
                                )),
                            onPressed: () => _updateCurrentSelectedOption(),
                          ),
                        ],
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: widget.options
                              .indexOf(widget.currentSelectedOption),
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          _currentSelectedOptionAfterConfirm =
                              widget.options[index];
                        },
                        children: widget.options.map(
                          (v) {
                            return Center(
                              child: Text(
                                v.toString() +
                                    " " +
                                    Decoder.getLabel(widget.settingsType,
                                        widget.currentSelectedOption),
                              ),
                            );
                          },
                        ).toList()),
                  ),
                ],
              ));
        });
  }

  String _createString() {
    return widget.currentSelectedOption.toString() +
        " " +
        Decoder.getLabel(widget.settingsType, widget.currentSelectedOption);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCupertinoPicker(context),
      child:
          Text(_createString(), style: Theme.of(context).textTheme.headline2),
    );
  }
}
