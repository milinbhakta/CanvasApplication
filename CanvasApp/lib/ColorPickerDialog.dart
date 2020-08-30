import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:slide_popup_dialog/pill_gesture.dart';

class ColorPickerDialog extends StatefulWidget {
  /// initial selection for the slider
  final Color pickerColor;

  const ColorPickerDialog({Key key, this.pickerColor}) : super(key: key);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  /// current selection of the slider
  Color _color1;
  var _initialPosition = 0.0;
  var _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _color1 = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          EdgeInsets.only(top: deviceHeight / 3.0 + _currentPosition),
      duration: Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: Center(
          child: Container(
            width: deviceWidth,
            height: deviceHeight,
            child: Material(
              color: Theme.of(context).canvasColor,
              elevation: 24.0,
              type: MaterialType.card,
              child: Column(
                children: <Widget>[
                  PillGesture(
                    pillColor: Colors.blueGrey[200],
                    onVerticalDragStart: _onVerticalDragStart,
                    onVerticalDragEnd: _onVerticalDragEnd,
                    onVerticalDragUpdate: _onVerticalDragUpdate,
                  ),
                  ColorPicker(
                    pickerColor: _color1,
                    onColorChanged: (value) {
                      setState(() {
                        _color1 = value;
                      });
                    },
                    enableAlpha: false,
                    displayThumbColor: true,
                    showLabel: false,
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onVerticalDragStart(DragStartDetails drag) {
    setState(() {
      _initialPosition = drag.globalPosition.dy;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails drag) {
    setState(() {
      final temp = _currentPosition;
      _currentPosition = drag.globalPosition.dy - _initialPosition;
      if (_currentPosition < 0) {
        _currentPosition = temp;
      }
    });
  }

  void _onVerticalDragEnd(DragEndDetails drag) {
    if (_currentPosition > 100.0) {
      Navigator.pop(context, _color1);
      return;
    }
    setState(() {
      _currentPosition = 0.0;
    });
  }
}
