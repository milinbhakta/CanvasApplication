import 'package:flutter/material.dart';
import 'package:slide_popup_dialog/pill_gesture.dart';

class CustomSizeDialog extends StatefulWidget {
  /// initial selection for the slider
  final double initialize;
  final String toolName;
  final double min;
  final double max;

  const CustomSizeDialog({
    Key key,
    @required this.initialize,
    @required this.toolName,
    @required this.min,
    @required this.max,
  }) : super(key: key);

  @override
  _CustomSizeDialogState createState() => _CustomSizeDialogState();
}

class _CustomSizeDialogState extends State<CustomSizeDialog> {
  /// current selection of the slider
  double _size;
  var _initialPosition = 0.0;
  var _currentPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _size = widget.initialize;
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          EdgeInsets.only(top: deviceHeight / 1.5 + _currentPosition),
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "${widget.toolName}:",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            Container(
                              child: Text(
                                '${_size.toStringAsFixed(1)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Slider(
                        value: _size,
                        min: widget.min,
                        max: widget.max,
                        onChanged: (value) {
                          setState(() {
                            _size = value;
                          });
                        },
                      ),
                    ],
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
      Navigator.pop(context, _size);
      print('${widget.toolName}' '$_size');
      return;
    }
    setState(() {
      _currentPosition = 0.0;
    });
  }
}
