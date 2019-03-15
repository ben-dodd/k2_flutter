import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:k2e/pages/my_jobs/tasks/map/map_helper_functions.dart';
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
  List<Offset> points =
      new List(2); //List of points in one Tap or ery point or path is kept here
  bool lineInProgress = false;
  bool pathInProgress = false;
  Offset stackOffset = null;
  bool dragging = false;
  int dragFingerCount = 0;

  // DEFAULT MODE
  // Modes can be:
  //  edit: Allows for drawing of walls + moving & deleting
  //  nav: Allows for panning, scrolling
  String mode = 'edit';

  // DEFAULT LAYER
  // Layers can be:
  // image: Add image from photo or file, or add other map to be displayed below (semi-transparent)
  int layer = 1;

  double scale = 1.0;
  double rotation = 0.0;
  double translateX = 0.0;
  double translateY = 0.0;

  double startScale = 1.0;
  double startRotation = 0.0;
  double startTranslateX = 0.0;
  double startTranslateY = 0.0;

  // Settings
  bool gestureRotationEnabled = false;
  bool gestureTranslationEnabled = true;
  bool gestureScaleEnabled = true;

  int intervals = 10;
  int divisions = 4;
  int subdivisions = 2;
  double angleLimit = 15;

  Offset snapPoint(Offset p, Offset q) {
    var object = this.contexto.findRenderObject();
    var translation = object?.getTransformTo(null)?.getTranslation();

    transformPoint(
      Offset(p.dx - translation.x, p.dy - translation.y),
      Offset(_w / 2, _h / 2),
      scale,
      rotation,
      translateX,
      translateY,
    );

    int increments = intervals * divisions * subdivisions;
    double interval = _w * scale / increments;
    Offset t = new Offset(
        roundToMultiple(p.dx, interval), roundToMultiple(p.dy, interval));
    if (q != null) {
      // Limit angle to be multiple of the angleLimit

      print(p.toString());
      print(q.toString());
//    return point;
      double angle = atan2(q.dy - t.dy, q.dx - t.dx) * 180 / pi;
//    double snapAngle = angleLimit * (angle ~/ angleLimit);
      double snapAngle = roundToMultiple(angle, angleLimit);
      double snapAngleRad = (snapAngle * pi / 180) - pi;

//      print('Angle: ' + angle.toString() + ', SnapAngle: ' +
//          snapAngle.toString() + ', angleDifference: ' +
//          angleDifference.toString());

      double distance =
          sqrt((t.dx - q.dx) * (t.dx - q.dx) + (t.dy - q.dy) * (t.dy - q.dy));
      print('Distance between points: ' + distance.toString());
      print('Angle in degrees: ' + snapAngle.toString());
      print('Angle in radians; ' + snapAngleRad.toString());

//      print (movePoint(p, snapAngleRad, distance).toString());
//      return movePoint(p, snapAngleRad, distance);

      print(snapToAngle(t, q, snapAngleRad).toString());
      return snapToAngle(t, q, snapAngleRad);
//      return p;
    } else {
      return t;
    }
  }

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
      Offset newPoint = snapPoint(details.globalPosition, points[0]);

      if (pathInProgress) {
        if (lineInProgress) {
          print('new point finished');
          points[1] = newPoint;
          lineInProgress = false;
          widget.updatePoints(points);
          points = [newPoint, newPoint];
          print('NEW POINT IN TAPUP - LINEINPROGRESS');
          widget.updatePaths(points);
        } else {
          print('new point started');
          points = [points[1] != null ? points[1] : newPoint, newPoint];
//          lineInProgress = false;
          print('NEW POINT IN TAPUP - LINEINPROGRESS FALSE');
          widget.updatePaths(points);
        }
      } else {
        print('new point + path started');
        points = [newPoint, newPoint];
        widget.updatePaths(points);
        print('NEW POINT IN TAPUP - PATH AND LINE FALSE');
        lineInProgress = true;
        pathInProgress = true;
      }
    });
  }

  // Not used - when tap becomes scale or pan
  void _tapCancel() {
    print('tapCancel');
  }

  void loadStackOffset() {
    print('Loading stack offset!');
    if (lineInProgress) {
      points[1] = stackOffset;
//      lineInProgress = false;
      widget.updatePoints(points);
      points = [stackOffset, stackOffset];
    } else {
      points = [points[1] != null ? points[1] : stackOffset, stackOffset];
    }
    widget.updatePaths(points);
    print('NEW POINT IN LOADSTACKOFFSET ' +
        lineInProgress.toString() +
        ' line, ' +
        pathInProgress.toString() +
        ' path');

    lineInProgress = true;
    pathInProgress = true;
    stackOffset = null;
  }

  // Pinch zoom
  void _scaleStart(ScaleStartDetails details) {
    print('scale start');
    print(details.toString());
    setState(() {
//     lineInProgress = false;
      var object = this.contexto.findRenderObject();
      var translation = object?.getTransformTo(null)?.getTranslation();
      if (pathInProgress) {
        Offset newOffset = snapPoint(details.focalPoint, points[0]);
        if (lineInProgress) {
          print('new point finished');
          // set up new point to be added if scale is not a zoom/rotation
          stackOffset = newOffset;
        } else {
          print('new point started');
          stackOffset = newOffset;
        }
      } else {
        print('new point + path started');
        lineInProgress = true;
        pathInProgress = true;
        Offset newOffset = snapPoint(details.focalPoint, null);
        points = [newOffset, newOffset];
        widget.updatePaths(points);
        print('NEW POINT IN SCALE START - pathINPROGRESES FALSE');
      }
    });
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
//    print('scale update ' + details.toString());
    if (startScale / details.scale == scale &&
        details.rotation + startRotation == rotation) {
      // No pinching, draw line
      if (stackOffset != null) {
        loadStackOffset();
      }
      setState(() {
        var object = this.contexto.findRenderObject();
        var translation = object?.getTransformTo(null)?.getTranslation();
        points[1] = snapPoint(details.focalPoint, points[0]);
      });
    } else {
      setState(() {
        if (gestureRotationEnabled) rotation = startRotation + details.rotation;
        if (gestureScaleEnabled) scale = startScale * details.scale;
      });
    }
    widget.updatePoints(points);
  }

  void _scaleEnd(ScaleEndDetails details) {
    startRotation = rotation;
    startScale = scale;
  }

  void _panUpdate(DragUpdateDetails details) {
    if (dragFingerCount > 1 && gestureTranslationEnabled) {
//      print('pan view: ' + details.toString());
      setState(() {
        translateX = translateX + details.delta.dx;
        translateY = translateY + details.delta.dy;
      });
    } else {
      if (dragging && pathInProgress) {
        _scaleUpdate(ScaleUpdateDetails(
          focalPoint: details.globalPosition,
          rotation: 0.0,
          scale: 1.0,
        ));
      } else {
        dragging = true;
        print(points.toString() + ' ' + details.globalPosition.toString());
        _scaleStart(ScaleStartDetails(
          focalPoint: details.globalPosition,
        ));
      }
    }
  }

  void _panEnd(DragEndDetails details) {
    print('pan end: ' + details.toString());
    dragFingerCount = 0;
    if (dragging) {
      // Finish path
      print('new point finished');

      lineInProgress = false;
      widget.updatePoints(points);
      points = [points[1], points[1]];
      print('NEW POINT IN PAN END');
      widget.updatePaths(points);
    }
    dragging = false;
  }

  void _doubleTap() {
    print(
        'double tap TAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP');
    setState(() {
      lineInProgress = false;
      pathInProgress = false;
      dragging = false;
    });
  }

  double _w, _h;
  BuildContext contexto;

  @override
  Widget build(BuildContext context) {
    contexto = context;
    _w = MediaQuery.of(context).size.width;
    _h = MediaQuery.of(context).size.height;

//    print('Scale is: ' + scale.toString());
//    print('Height is: ' + _h.toString());
//    print('Width is: ' + _w.toString());
//    if (widget.arrowPaths.length == 0) paths.clear();
//    print('Paths in MapPainter: ' + widget.paths.toString());
    return Transform(
      transform: Matrix4.rotationZ(rotation)
        ..scale(scale)
        ..translate(translateX, translateY),
      origin: Offset(_w / 2 + translateX, _h / 2 + translateY),
      child: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                  () => TapGestureRecognizer(),
                  (TapGestureRecognizer instance) {
            instance
              ..onTap = () {
                print('tap');
              }
              ..onTapDown = _tapDown
              ..onTapUp = _tapUp
              ..onTapCancel = _tapCancel;
          }),
          ScaleGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
                  () => ScaleGestureRecognizer(),
                  (ScaleGestureRecognizer instance) {
            instance
              ..onStart = _scaleStart
              ..onUpdate = _scaleUpdate
              ..onEnd = _scaleEnd;
          }),
          DoubleTapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
                  () => DoubleTapGestureRecognizer(),
                  (DoubleTapGestureRecognizer instance) {
            instance..onDoubleTap = _doubleTap;
          }),
          ImmediateMultiDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                      ImmediateMultiDragGestureRecognizer>(
                  () => ImmediateMultiDragGestureRecognizer(),
                  (MultiDragGestureRecognizer instance) {
            instance
              ..onStart = (Offset offset) {
                dragFingerCount = dragFingerCount + 1;
                print('on start drag ' + dragFingerCount.toString());
                return new PanView(_panUpdate, _panEnd);
              };
          })
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          height: _h,
          width: _w,
          child: new Container(
            alignment: Alignment.center,
            child: Stack(children: <Widget>[
              widget.photo != null
                  ? widget.photo
                  : new Container(
                      height: _h,
                      width: _w,
                      child: GridPaper(
                        interval: _w / intervals,
                        divisions: divisions,
                        subdivisions: subdivisions,
//            color: Color(0x7FC3E8F3),
                        color: Color(0x7F003080),
                      ),
                    ),
              new CustomPaint(
                foregroundPainter: new MyPainter(
                  lineColor: widget.pathColour,
                  aImg: widget.image,
                  width: 1.0,
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

  MyPainter({
    this.lineColor,
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
              ..strokeMiterLimit = 3.0);
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
              ..strokeMiterLimit = 3.0);
      }
    }
    // Storing image
    ui.Picture picture = recorder.endRecording();
    ui.Image imagen;
    picture.toImage(canvasWidth, canvasWidth).then((image) => {
      imagen = image
    });
    _capturePng(imagen);
    canvasFinal.drawPicture(picture);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

Offset rotate_point(Offset o, Offset p, double angle) {
  return p;
//  return Offset(cos(angle) * (p.dx - o.dx) - sin(angle) * (p.dy - o.dy) + o.dx,
//      sin(angle) * (p.dx - o.dx) + cos(angle) * (p.dy - o.dy) + o.dy);
}

Offset scale_point(Offset o, double scale) {
  return o;
//  return Offset(o.dx * scale, o.dy * scale);
}

class PanView extends Drag {
  final GestureDragUpdateCallback onUpdate;
  final GestureDragEndCallback onEnd;

  PanView(this.onUpdate, this.onEnd);

  @override
  void update(DragUpdateDetails details) {
    super.update(details);
    onUpdate(details);
  }

  @override
  void end(DragEndDetails details) {
    super.end(details);
    onEnd(details);
  }
}
