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
  double scale = 1.0;
  double rotation = 0.0;
  double translateX = 0.0;
  double translateY = 0.0;
  double startScale = 1.0;
  double startRotation = 0.0;
  int intervals = 10;
  int divisions = 4;
  int subdivisions = 2;
  double angleLimit = 22.5;
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
    print(details.globalPosition.toString());
    setState(() {
      var object = this.contexto.findRenderObject();
      var translation = object?.getTransformTo(null)?.getTranslation();
      // translation.y have the offset from the top of the screen to the "canvas".

      if (lineInProgress) {
        print('new point finished');
        points[1] =
        snapPoint(transformPoint(new Offset(details.globalPosition.dx - translation.x,
            details.globalPosition.dy
                - translation.y)), points[0]
        );
//        lineInProgress = false;
        widget.updatePoints(points);
        points = [
          transformPoint(new Offset(details.globalPosition.dx - translation.x,
              details.globalPosition.dy
                  - translation.y)
          ),
          transformPoint(new Offset(details.globalPosition.dx - translation.x,
              details.globalPosition.dy
                  - translation.y)
          ),
        ];
        widget.updatePaths(points);
      } else {
        print ('new point started');
        points = [
          transformPoint(new Offset(details.globalPosition.dx - translation.x,
              details.globalPosition.dy
                  - translation.y)
          ),
          transformPoint(new Offset(details.globalPosition.dx - translation.x,
              details.globalPosition.dy
                  - translation.y)
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

  // Pinch zoom
  void _scaleStart(ScaleStartDetails details) {
   print('scale start');
   print (details.toString());
   setState(() {
//     lineInProgress = false;
     var object = this.contexto.findRenderObject();
     var translation = object?.getTransformTo(null)?.getTranslation();
     points = [
       transformPoint(new Offset(details.focalPoint.dx - translation.x,
           details.focalPoint.dy
               - translation.y)
       ),
       transformPoint(new Offset(details.focalPoint.dx - translation.x,
           details.focalPoint.dy
               - translation.y)
       )
     ];
     print(points.toString());
     if (lineInProgress) widget.updatePoints(points);
      else widget.updatePaths(points);
    lineInProgress = false;
     // Add here to refresh the screen. If paths.add is only in panEnd
     // only update the screen when finger is up
   });
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
    print('scale update');
//    print (details.toString());
//    print (rotation.toString());
//    print (startRotation.toString());
//    print (details.rotation.toString());
    if (startScale / details.scale == scale && details.rotation + startRotation == rotation) {
      // No pinching, draw line
      setState(() {
        var object = this.contexto.findRenderObject();
        var translation = object?.getTransformTo(null)?.getTranslation();
        points[1] = snapPoint(transformPoint(new Offset(details.focalPoint.dx - translation.x,
            details.focalPoint.dy
                - translation.y)), points[0]);
        print(points.toString());
      });
    } else {
      setState(() {
        //Delete point
        rotation = startRotation + details.rotation;
        scale = startScale * details.scale;
      });
    }
    widget.updatePoints(points);
  }

  void _scaleEnd(ScaleEndDetails details) {
    startRotation = rotation;
    startScale = scale;
  }

  Offset snapPoint(Offset p, Offset q) {
//    return point;
    double angle = atan2(q.dy - p.dy, q.dx - p.dx) * 180 / pi;
    double snapAngle = angleLimit * (angle ~/ angleLimit);
    double angleDifference = (angle - snapAngle) * pi / 180;

    print ('Angle: ' + angle.toString() + ', SnapAngle: ' + snapAngle.toString() + ', angleDifference: ' + angleDifference.toString());
    double interval = _w * scale/(intervals * divisions * subdivisions);
    return Offset(interval * (p.dx ~/ interval), interval * (p.dy ~/ interval));
//    return rotatePoint(Offset(interval * (p.dx ~/ interval), interval * (p.dy ~/ interval)), q, angleDifference);
  }

  Offset transformPoint(Offset p) {
    // Get origin to rotate around
    Offset o = Offset(_w/2, _h/2);

    // Translate to the origin, apply scaling
    Offset t = Offset((p.dx - o.dx) * (1/scale), (p.dy - o.dy) * (1/scale));

    // Apply rotation
    t = Offset(cos(-rotation) * (t.dx) - sin(-rotation) * (t.dy),
        sin(-rotation) * (t.dx) + cos(-rotation) * (t.dy));

    // Translate back
    t = Offset(t.dx + o.dx, t.dy + o.dy);

    // Snap
    return t;
//    return Offset(cos(-rotation) * (p.dx - o.dx) - sin(-rotation) * (p.dy - o.dy) + o.dx,
//        sin(-rotation) * (p.dx - o.dx) + cos(-rotation) * (p.dy - o.dy) + o.dy);
  }

  Offset rotatePoint(Offset t, Offset o, double rotation){
    return Offset(cos(rotation) * (t.dx - o.dx) - sin(rotation) * (t.dy - o.dy) + o.dx,
        sin(rotation) * (t.dx - o.dx) + cos(rotation) * (t.dy - o.dy) + o.dy);
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
    return Transform(transform: Matrix4.rotationZ(rotation)..scale(scale), origin: Offset(_w/2, _h/2), child: RawGestureDetector(
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
        child: new Container(alignment: Alignment.center, child: Stack(
        children: <Widget> [
          widget.photo !=null ? widget.photo : new Container(height: _h, width: _w, child: GridPaper(
            interval: _w/intervals,
            divisions: divisions,
            subdivisions: subdivisions,
//            color: Color(0x7FC3E8F3),
            color: Color(0x7F003080),
          ),),
          new CustomPaint(
            foregroundPainter: new MyPainter(
              lineColor: widget.pathColour,
              aImg: widget.image,
              width: 2.0,
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
    if (paths == null || paths.isEmpty) return;
    for (List<Offset> points in paths) {
      if (points.length > 1) {
        Path path = Path();
        // Translate by rotation
        Offset origin = points[0];
        // Translate by scale
        path.moveTo(origin.dx, origin.dy);
        for (Offset o in points) {
          path.lineTo(o.dx, o.dy);
        }
        canvas.drawPath(
          path,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = this.width
            ..strokeCap = StrokeCap.butt
            ..strokeJoin = StrokeJoin.miter
            ..strokeMiterLimit = 3.0
        );
      } else {
        canvas.drawPoints(
          ui.PointMode.points,
          points,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = this.width
            ..strokeCap = StrokeCap.butt
            ..strokeJoin = StrokeJoin.miter
            ..strokeMiterLimit = 3.0
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