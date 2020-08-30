import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:CanvasApp/ColorPickerDialog.dart';
import 'package:CanvasApp/Pick_ImagetoDrawDialog.dart';
import 'package:CanvasApp/slide_dialog.dart';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:save_in_gallery/save_in_gallery.dart';

void main() => runApp(MaterialApp(
      home: CanvasPainting(),
    ));

class CanvasPainting extends StatefulWidget {
  @override
  _CanvasPaintingState createState() => _CanvasPaintingState();
}

class _CanvasPaintingState extends State<CanvasPainting> {
  GlobalKey globalKey = GlobalKey();
  final _imageSaver = ImageSaver();
  IconData isSelected = FontAwesome5.paint_brush;
  List<TouchPoints> points = List();
  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  double brushStrokeWidth = 3.0;
  double eraserStrokeWidth = 3.0;
  Color selectedColor = Colors.black;
  bool eraser = false;
  List<String> imageData;
  int selectedImageIndex = 0;
  bool isloading = true;
  ui.Image _image;

  @override
  void initState() {
    super.initState();
    getImageData().then((value) => stoploading());
    _loadImage();
  }

  _loadImage() async {
    ByteData bd = await rootBundle.load("images/image01.jpg");

    final Uint8List bytes = Uint8List.view(bd.buffer);

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);

    final ui.Image image = (await codec.getNextFrame()).image;
    print(image);

    setState(() => _image = image);
  }

  Future<void> getImageData() async {
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final images = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('images/'));
    imageData = new List<String>.from(images);
  }

  void stoploading() {
    setState(() {
      isloading = false;
    });
  }

  Future<void> _pickStroke(BuildContext context) async {
    final selectedSize = await showGeneralDialog(
      context: context,
      pageBuilder: (context, animation1, animation2) {},
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation1, animation2, widget) {
        final curvedValue = Curves.easeInOut.transform(animation1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * -300, 0.0),
          child: Opacity(
            opacity: animation1.value,
            child: CustomSizeDialog(
              initialize: brushStrokeWidth,
              toolName: "Brush Size",
              min: 1.0,
              max: 30.0,
            ),
          ),
        );
      },
    );

    if (selectedSize != null) {
      setState(() {
        brushStrokeWidth = selectedSize;
        print('brush size $brushStrokeWidth');
      });
    }
  }

  Future<void> _pickEraserStroke(BuildContext context) async {
    final selectedSize = await showGeneralDialog(
      context: context,
      pageBuilder: (context, animation1, animation2) {},
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation1, animation2, widget) {
        final curvedValue = Curves.easeInOut.transform(animation1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * -300, 0.0),
          child: Opacity(
            opacity: animation1.value,
            child: CustomSizeDialog(
              initialize: eraserStrokeWidth,
              toolName: "Eraser Size",
              min: 1.0,
              max: 30.0,
            ),
          ),
        );
      },
    );

    if (selectedSize != null) {
      setState(() {
        eraserStrokeWidth = selectedSize;
        print('Eraser size $eraserStrokeWidth');
      });
    }
  }

  Future<void> _pickImagetoDraw(BuildContext context) async {
    setState(() {});
    final selectedIndex = await showGeneralDialog(
      context: context,
      pageBuilder: (context, animation1, animation2) {},
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation1, animation2, widget) {
        final curvedValue = Curves.easeInOut.transform(animation1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * -300, 0.0),
          child: Opacity(
            opacity: animation1.value,
            child: PickImageToDrawDialog(
              imgData: imageData,
              selectedIndex: selectedImageIndex,
            ),
          ),
        );
      },
    );

    if (selectedIndex != null) {
      setState(() {
        selectedImageIndex = selectedIndex;
        print('selectedImageIndex $selectedImageIndex');
      });
    }
  }

  Future<void> _colorPlatte(BuildContext context) async {
    final selectedColorchanged = await showGeneralDialog(
      context: context,
      pageBuilder: (context, animation1, animation2) {},
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation1, animation2, widget) {
        final curvedValue = Curves.easeInOut.transform(animation1.value) - 1.0;
        return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * -300, 0.0),
            child: Opacity(
              opacity: animation1.value,
              child: ColorPickerDialog(
                pickerColor: selectedColor,
              ),
            ));
      },
    );

    if (selectedColorchanged != null) {
      setState(() {
        selectedColor = selectedColorchanged;
        print('$selectedColor');
      });
    }
  }

  Future<void> _save(BuildContext context) async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    final res = await _imageSaver.saveImages(imageBytes: [pngBytes]);
    if (res) {
      final snackBar = SnackBar(
        content: Text('Yay! A SnackBar!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );

      // Find the Scaffold in the widget tree and use
      // it to show a SnackBar.
      Scaffold.of(context).showSnackBar(snackBar);
    }
    print(res);
  }

  List<Widget> fabOption(BuildContext context) {
    return <Widget>[
      FloatingActionButton(
        heroTag: "paint_save",
        child: Icon(
          FontAwesome5.save,
          color: Colors.white,
        ),
        tooltip: 'Save',
        onPressed: () {
          //min: 0, max: 50
          setState(() {
            _save(context);
          });
        },
      ),
      FloatingActionButton(
        heroTag: "paint_stroke",
        child: Icon(
          FontAwesome5.paint_brush,
          color: Colors.white,
        ),
        backgroundColor: !eraser ? Colors.redAccent : Color(0xFFAA96DA),
        tooltip: 'Stroke',
        onPressed: () {
          setState(() {
            eraser = false;
          });
        },
      ),
      FloatingActionButton(
          heroTag: "erase",
          child: Icon(
            FontAwesome5.eraser,
            color: Colors.white,
          ),
          backgroundColor: eraser ? Colors.redAccent : Color(0xFFAA96DA),
          tooltip: "Erase",
          onPressed: () {
            setState(() {
              eraser = true;
            });
          }),
      FloatingActionButton(
          heroTag: "New",
          child: Icon(
            Icons.fiber_new,
            color: Colors.white,
          ),
          tooltip: "New",
          onPressed: () {
            setState(() {
              points.clear();
            });
          }),
      FloatingActionButton(
          heroTag: "Select Image!",
          child: Icon(
            FontAwesome5.images,
            color: Colors.white,
          ),
          tooltip: "Select Image!",
          onPressed: () {
            setState(() {
              _pickImagetoDraw(context);
            });
          }),
      FloatingActionButton(
        heroTag: "color",
        backgroundColor: selectedColor,
        child: Icon(
          FontAwesome5.palette,
          color: Colors.white,
        ),
        tooltip: 'Color',
        onPressed: () {
          _colorPlatte(context);
        },
      ),
      FloatingActionButton(
        heroTag: "Size",
        child: Icon(
          FontAwesome5.sort,
          color: Colors.white,
        ),
        tooltip: 'Color',
        onPressed: () {
          if (eraser) {
            _pickEraserStroke(context);
          } else {
            _pickStroke(context);
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define the default brightness and colors.
        primaryColor: Color(0xFFA8D8EA),
        accentColor: Color(0xFFAA96DA),

        // Define the default font family.
        fontFamily: 'Georgia',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(),
      ),
      home: Scaffold(
        body: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              RenderBox renderBox = context.findRenderObject();
              var add = TouchPoints(
                  points: renderBox.globalToLocal(details.globalPosition),
                  paint: Paint()
                    ..strokeCap = strokeType
                    ..isAntiAlias = true
                    ..color = eraser
                        ? Colors.transparent
                        : selectedColor.withOpacity(opacity)
                    ..strokeWidth =
                        eraser ? eraserStrokeWidth : brushStrokeWidth
                    ..blendMode = eraser ? BlendMode.clear : BlendMode.color);
              points.add(add);
            });
          },
          onPanStart: (details) {
            setState(() {
              RenderBox renderBox = context.findRenderObject();
              var add = TouchPoints(
                  points: renderBox.globalToLocal(details.globalPosition),
                  paint: Paint()
                    ..strokeCap = strokeType
                    ..isAntiAlias = true
                    ..color = eraser
                        ? Colors.transparent
                        : selectedColor.withOpacity(opacity)
                    ..strokeWidth =
                        eraser ? eraserStrokeWidth : brushStrokeWidth
                    ..blendMode = eraser ? BlendMode.clear : BlendMode.color);

              points.add(add);
            });
          },
          onPanEnd: (details) {
            setState(() {
              points.add(null);
            });
          },
          child: RepaintBoundary(
            key: globalKey,
            child: Stack(
              children: <Widget>[
                Center(
                  child: isloading
                      ? CircularProgressIndicator()
                      : Image.asset(imageData[selectedImageIndex]),
                ),
                CustomPaint(
                  size: Size.infinite,
                  painter: MyPainter(
                    pointsList: points,
                    image: _image,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: AnimatedFloatingActionButton(
          fabButtons: fabOption(context),
          colorStartAnimation: Colors.blue,
          colorEndAnimation: Colors.cyan,
          animatedIconData: AnimatedIcons.menu_home,
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter({this.pointsList, this.image});

  //Keep track of the points tapped on the screen
  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = List();

  ui.Image image;

  //This is where we can draw on canvas.
  @override
  void paint(Canvas canvas, Size size) {
    var imagePaint = new Paint();
    imagePaint.color = Colors.black;
    imagePaint.style = PaintingStyle.stroke;
    imagePaint.strokeWidth = 10;

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawImage(image, Offset.zero, imagePaint);
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        //Drawing line when two consecutive points are available
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));

        //Draw points when two points are not next to each other
        canvas.drawPoints(
            ui.PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
    canvas.restore();
  }

  //Called when CustomPainter is rebuilt.
  //Returning true because we want canvas to be rebuilt to reflect new changes.
  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}

//Class to define a point touched at canvas
class TouchPoints {
  Paint paint;
  Offset points;
  TouchPoints({this.points, this.paint});
}

class ButtonList {
  String name;
  IconData icon;
  Function onPressed;
  ButtonList({this.name, this.icon, this.onPressed});
}
