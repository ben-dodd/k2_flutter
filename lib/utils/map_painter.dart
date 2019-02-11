import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
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

class MapPainter extends StatefulWidget {
  MapPainter({
    @required this.photo,
    @required this.paths,
    @required this.pathColour,
    @required this.updatePaths,
    @required this.updatePoints,
//    @required
//    this.clearAll,
  });

  Widget photo;
  bool shadeOn;
  bool arrowOn;
  Color pathColour;
  List<List<Offset>> paths;
  Function updatePaths;
  Function updatePoints;

  // The image can be accessed by this property
  ImageAccess image = new ImageAccess();

  @override
  _MapPainterState createState() => new _MapPainterState();
}

class _MapPainterState extends State<MapPainter> {
  List<Offset> points; //List of points in one Tap or ery point or path is kept here
  bool lineInProgress = false;
  double scale = 0.2;
  double rotation = 0.0;
  double startScale = 0.2;
  double startRotation = 0.0;
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

      if (lineInProgress) {
        print('new point finished');
        points[1] =
        new Offset(snapPoint(details.globalPosition.dx) - translation.x,
            snapPoint(details.globalPosition.dy)
                - translation.y
        );
//        lineInProgress = false;
        widget.updatePoints(points);
        points = [
          new Offset(snapPoint(details.globalPosition.dx) - translation.x,
              snapPoint(details.globalPosition.dy)
                  - translation.y
          ),
          new Offset(snapPoint(details.globalPosition.dx) - translation.x,
              snapPoint(details.globalPosition.dy)
                  - translation.y
          ),
        ];
        widget.updatePaths(points);
      } else {
        print ('new point started');
        points = [
          new Offset(snapPoint(details.globalPosition.dx) - translation.x,
              snapPoint(details.globalPosition.dy)
                  - translation.y
          ),
          new Offset(snapPoint(details.globalPosition.dx) - translation.x,
              snapPoint(details.globalPosition.dy)
                  - translation.y
          ),
        ];
        lineInProgress = true;
        widget.updatePaths(points);
      }
    });
  }

  // Not used
  void _tapCancel() {
    print('tapCancel');
  }

//  // User touch and drag over the screen
//  void _panStart(DragStartDetails details) {
//    print('panStart');
//    setState(() {
//      var object = this.contexto.findRenderObject();
//      var translation = object?.getTransformTo(null)?.getTranslation();
//      points = [
//        new Offset(details.globalPosition.dx - translation.x,
//            details.globalPosition.dy
//                - translation.y
//        ),
//        new Offset(details.globalPosition.dx - translation.x,
//            details.globalPosition.dy
//                - translation.y
//        )
//      ];
//      widget.updatePaths(points);
//      // Add here to refresh the screen. If paths.add is only in panEnd
//      // only update the screen when finger is up
//    });
//  }
//
//  // User drag over screen
//  void _panUpdate(DragUpdateDetails details) {
//    // print('panUpdate'); //Lot of prints :-/
//
//    setState(() {
//      var object = this.contexto.findRenderObject();
//      var translation = object?.getTransformTo(null)?.getTranslation();
//      points[1] = (new Offset(details.globalPosition.dx - translation.x,
//          details.globalPosition.dy
//              - translation.y
//      ));
//      widget.updatePoints(points);
//    });
//  }

  // Pinch zoom
  void _scaleStart(ScaleStartDetails details) {
   print('scale start');
//   print (details.toString());
   setState(() {
     var object = this.contexto.findRenderObject();
     var translation = object?.getTransformTo(null)?.getTranslation();
     points = [
       new Offset(snapPoint(details.focalPoint.dx) - translation.x,
           snapPoint(details.focalPoint.dy)
               - translation.y
       ),
       new Offset(snapPoint(details.focalPoint.dx) - translation.x,
           snapPoint(details.focalPoint.dy)
               - translation.y
       )
     ];
     widget.updatePaths(points);
     // Add here to refresh the screen. If paths.add is only in panEnd
     // only update the screen when finger is up
   });
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
    print('scale update');
    print (details.toString());
    if (details.scale == scale && details.rotation == rotation) {
      // No pinching, draw line
      setState(() {
        var object = this.contexto.findRenderObject();
        var translation = object?.getTransformTo(null)?.getTranslation();
        points[1] = (new Offset(snapPoint(details.focalPoint.dx) - translation.x,
            snapPoint(details.focalPoint.dy)
                - translation.y
        ));
        widget.updatePoints(points);
      });
    } else {
      setState(() {
        //Delete point
        rotation = startRotation + details.rotation;
        scale = startScale * details.scale;
      });
    }
  }

  void _scaleEnd(ScaleEndDetails details) {
    startRotation = rotation;
    startScale = scale;
  }

  double snapPoint(double point) {
    double interval = _w/(4 * 2);
//    print('Interval: ' + interval.toString());
//    print('Point: ' + point.toString());
//    print('Divide: ' + (point ~/ interval).toString());
//    print('Interval * divide: ' + (interval * (point ~/ interval)).toString());
//    print ((interval * (point ~/ interval)).toString());
    return interval * (point ~/ interval);
  }

  double _w, _h;
  BuildContext contexto;

  @override
  Widget build(BuildContext context) {
    contexto = context;
    _w = MediaQuery.of(context).size.width;
    _h = MediaQuery.of(context).size.height;

    print('Scale is: ' + scale.toString());
    print('Height is: ' + _h.toString());
    print('Width is: ' + _w.toString());
//    if (widget.arrowPaths.length == 0) paths.clear();
    print('Paths in MapPainter: ' + widget.paths.toString());
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            () => TapGestureRecognizer(),
            (TapGestureRecognizer instance) {
              instance
                ..onTap = () { print('tap'); }
                ..onTapDown = _tapDown
                ..onTapUp = _tapUp
                ..onTapCancel = _tapCancel;
            }
        ),
        ScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer(),
            (ScaleGestureRecognizer instance) {
              instance
                ..onStart = _scaleStart
                ..onUpdate = _scaleUpdate
                ..onEnd = _scaleEnd;
            }
        )
      },
      behavior: HitTestBehavior.translucent,
      child:
      Container(
        height: _h,
        width: _w,
        child: new Container(alignment: Alignment.center, child: Transform(transform: Matrix4.rotationZ(rotation)..scale(scale), origin: Offset(_w/2, _h/2), child: Stack(
        children: <Widget> [
          widget.photo !=null ? widget.photo : new Container(height: _h, width: _w, child: GridPaper(
            interval: _w/4,
            divisions: 2,
            subdivisions: 4,
//            color: Color(0x7FC3E8F3),
            color: Color(0xFF000000),
          ),),
          new CustomPaint(
            foregroundPainter: new MyPainter(
              lineColor: widget.pathColour,
              aImg: widget.image,
              width: 4.0,
              canvasWidth: _w.toInt(),
              canvasHeight: _h.toInt(),
              paths: widget.paths,
              rotation: rotation,
              scale: scale,
            ),
          ),
      ]),
      ),
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
  double scale;
  double rotation;

  MyPainter(
      {this.lineColor,
        this.aImg,
        this.width,
        this.paths,
        this.shape,
        this.canvasWidth,
        this.canvasHeight,
        this.scale,
        this.rotation,
      });

  Future<void> _capturePng(ui.Image img) async {
    ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    aImg.image = new Image.memory(new Uint8List.view(pngBytes.buffer));

  }

  @override
  void paint(Canvas canvasFinal, Size size) {
    final recorder = new ui.PictureRecorder(); // dart:ui
    final canvas = new Canvas(recorder);
    final Offset center = Offset(canvasWidth.toDouble() / 2, canvasHeight.toDouble() / 2);
    if (paths == null || paths.isEmpty) return;
    for (List<Offset> points in paths) {
      if (points.length > 1) {
        Path path = Path();
        // Translate by rotation
        Offset origin = rotate_point(center, scale_point(points[0], scale), rotation);
        // Translate by scale
        path.moveTo(origin.dx, origin.dy);
        for (Offset o in points) {
          Offset to = rotate_point(center, scale_point(o, scale), rotation);
          path.lineTo(to.dx, to.dy);
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = this.width,
        );
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

Offset rotate_point(Offset o, Offset p, double angle){
  return p;
//  return Offset(cos(angle) * (p.dx - o.dx) - sin(angle) * (p.dy - o.dy) + o.dx,
//      sin(angle) * (p.dx - o.dx) + cos(angle) * (p.dy - o.dy) + o.dy);
}

Offset scale_point(Offset o, double scale) {
  return o;
//  return Offset(o.dx * scale, o.dy * scale);
}