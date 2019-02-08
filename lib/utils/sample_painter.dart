import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:k2e/theme.dart';
import 'package:vector_math/vector_math_64.dart';

// Class to get an image from other object
// Used like a reference parameter
class ImageAccess {
  Image image;
}

class SamplePainter extends StatefulWidget {
  SamplePainter({
    @required
    this.photo,
    @required
    this.shadeOn,
    @required
    this.arrowOn,
    @required
    this.arrowPaths,
    @required
    this.shadePaths,
    @required
    this.pathColour,
    @required
    this.updatePaths,
    @required
    this.updatePoints,
//    @required
//    this.clearAll,
  });

  Widget photo;
  bool shadeOn;
  bool arrowOn;
  Color pathColour;
  List<List<Offset>> arrowPaths;
  List<List<Offset>> shadePaths;
  Function updatePaths;
  Function updatePoints;

  // The image can be accessed by this property
  ImageAccess image = new ImageAccess();

  @override
  _SamplePainterState createState() => new _SamplePainterState();
}

class _SamplePainterState extends State<SamplePainter> {
  List<Offset> points; //List of points in one Tap or ery point or path is kept here
  bool arrowInProgress = false;
//  VoidCallback clearAll;

  /*
  *  Tap and Pan behaviour:
  *
  *  Touch the screen throws tapDown.
  *  If up the finger tapUp and then onTap,
  *   if not and begin drag throws tapCancel, panStart and panUpdate
  *    and when stop drag and up the finger throws panEnd
  *
  * */

  // Not used
  void _tapDown(TapDownDetails details) {
    print('tapDown');
  }

  // User tap one point
  void _tapUp(TapUpDetails details) {
    print('tapUp');
    setState(() {
      var object = this.contexto.findRenderObject();
      var translation = object?.getTransformTo(null)?.getTranslation();
      // translation.y have the offset from the top of the screen to the "canvas".

      if (arrowInProgress) {
        points[1] = new Offset(details.globalPosition.dx - translation.x,
            details.globalPosition.dy - translation.y);
        arrowInProgress = false;
      } else {
        points = [
          new Offset(details.globalPosition.dx - translation.x,
              details.globalPosition.dy
                  - translation.y
          ),
          new Offset(details.globalPosition.dx - translation.x,
              details.globalPosition.dy
                  - translation.y
          )
          ];
          arrowInProgress = true;
      }
      widget.updatePoints(points);
    });
  }

  // Not used
  void _tapCancel() {
    print('tapCancel');
  }

  // User touch and drag over the screen
  void _panStart(DragStartDetails details) {
    print('panStart');
    setState(() {
      var object = this.contexto.findRenderObject();
      var translation = object?.getTransformTo(null)?.getTranslation();
      points = [
        new Offset(details.globalPosition.dx - translation.x,
            details.globalPosition.dy
                - translation.y
        ),
        new Offset(details.globalPosition.dx - translation.x,
            details.globalPosition.dy
                - translation.y
        )
      ];
      widget.updatePaths(points);
      // Add here to refresh the screen. If paths.add is only in panEnd
      // only update the screen when finger is up
    });
  }

  // User drag over screen
  void _panUpdate(DragUpdateDetails details) {
    // print('panUpdate'); //Lot of prints :-/
    setState(() {
      var object = this.contexto.findRenderObject();
      var translation = object?.getTransformTo(null)?.getTranslation();
      points[1] = (new Offset(details.globalPosition.dx - translation.x,
          details.globalPosition.dy
              - translation.y
      ));
      widget.updatePoints(points);
    });
  }

  // Not use because in panStart and tapUp initialize a new path of points
  void _panEnd(DragEndDetails details) {
    print('panEnd');
  }

  double _w, _h;
  BuildContext contexto;

  @override
  Widget build(BuildContext context) {
    contexto = context;
    _w = MediaQuery.of(context).size.width;
    _h = MediaQuery.of(context).size.height;
//    if (widget.arrowPaths.length == 0) paths.clear();
    print('Paths in SamplePainter: ' + widget.arrowPaths.toString());
    return GestureDetector(
      //  behavior: HitTestBehavior.translucent,
      onTap: () {
        print('tap');
      },
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      onTapCancel: _tapCancel,
      onPanStart: _panStart,
      onPanEnd: _panEnd,
      onPanUpdate: _panUpdate,
      child: Container(
        height: _h,
        width: _w,
        child: new Container(alignment: Alignment.center, child: Stack(children: <Widget> [
          widget.photo,
          new CustomPaint(
            foregroundPainter: new MyPainter(
              lineColor: widget.pathColour,
              aImg: widget.image,
              width: 8.0,
              canvasWidth: _w.toInt(),
              canvasHeight: _h.toInt(),
              paths: widget.arrowPaths,
              shape: 'arrow',
            ),
          ),
      ]),
      ),
    ),
    );
  }
}

class MyPainter extends CustomPainter {
  Color lineColor; //Line color

  ImageAccess aImg; // Image in png
  double width; // Pen thickness
  int canvasWidth;
  int canvasHeight;
  List<List<Offset>> paths; // paths to draw
  String shape;

  MyPainter(
      {this.lineColor,
        this.aImg,
        this.width,
        this.paths,
        this.shape,
        this.canvasWidth,
        this.canvasHeight});

  Future<void> _capturePng(ui.Image img) async {
    ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    aImg.image = new Image.memory(new Uint8List.view(pngBytes.buffer));

  }

  @override
  void paint(Canvas canvasFinal, Size size) {
    final recorder = new ui.PictureRecorder(); // dart:ui
    final canvas = new Canvas(recorder);
    if (paths == null || paths.isEmpty) return;
    for (List<Offset> points in paths) {
      if (points.length > 1) {
        if (shape == 'arrow') {
          Path path = Path();
          Offset origin = points[0];
          path.moveTo(origin.dx, origin.dy);
          Offset dest = points[1];
          path.lineTo(dest.dx, dest.dy);
          canvas.drawPath(
            path,
            Paint()
              ..color = lineColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = this.width,
          );
          path.moveTo(dest.dx, dest.dy + 10.0);
          double angle = degrees(atan2(origin.dy - dest.dy, dest.dx - origin.dx));
//          Vector3 axis = new Vector3(origin.dx, origin.dy, 0.0);
//          Quaternion q = new Quaternion.axisAngle(axis, angle);
          if (angle < 0) angle = angle + 360.0;
          print (angle.toString());
          path.addPolygon([Offset(dest.dx, dest.dy + 10.0),Offset(dest.dx + 10.0, dest.dy - 20.0),Offset(dest.dx - 10.0, dest.dy - 20.0)], true);
          canvas.drawPath(
            path,
            Paint()
              ..color = lineColor
              ..style = PaintingStyle.fill
              ..strokeWidth = 1.0,
          );
        } else {
          Path path = Path();
          Offset origin = points[0];
          path.moveTo(origin.dx, origin.dy);
          for (Offset o in points) {
            path.lineTo(o.dx, o.dy);
          }
          canvas.drawPath(
            path,
            Paint()
              ..color = lineColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = this.width,
          );
        }
      } else {
        canvas.drawPoints(
          ui.PointMode.points,
          points,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = this.width,
        );
      }
    }
    // Storing image
    ui.Picture picture = recorder.endRecording();
    ui.Image imagen = picture.toImage(canvasWidth, canvasWidth);
    _capturePng(imagen);
    canvasFinal.drawPicture(picture);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}