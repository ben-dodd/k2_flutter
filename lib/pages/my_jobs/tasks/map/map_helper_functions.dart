import 'dart:math';

import 'package:flutter/material.dart';

Offset transformPoint(Offset p, Offset o, double scale, double rotation,
    double translateX, double translateY) {
  // Translate to the origin, apply scaling
  Offset t = Offset((p.dx - o.dx) * (1 / scale), (p.dy - o.dy) * (1 / scale));

  // Apply rotation
  t = Offset(cos(-rotation) * (t.dx) - sin(-rotation) * (t.dy),
      sin(-rotation) * (t.dx) + cos(-rotation) * (t.dy));

  // Translate back + take away view translation
  t = Offset(t.dx + o.dx - translateX, t.dy + o.dy - translateY);

  return t;
}

Offset rotatePoint(Offset t, Offset o, double rotation) {
  return Offset(
      cos(rotation) * (t.dx - o.dx) - sin(rotation) * (t.dy - o.dy) + o.dx,
      sin(rotation) * (t.dx - o.dx) + cos(rotation) * (t.dy - o.dy) + o.dy);
}

// Move a point a certain distance in any angle (radians)
Offset movePoint(Offset p, double angle, double distance) {
  double x = p.dx + distance * sin(angle);
  double y = p.dy + distance * cos(angle);
  return Offset(x, y);
}

Offset snapToAngle(Offset p, Offset q, double angle) {
//    return p;
  var dx = p.dx - q.dx;
  var dy = p.dy - q.dy;
//    print (dx.toString());
//    print (dy.toString());
//    var distance = sqrt(dx*dx + dy*dy);
//    print ('Distance; ' + distance.toString());
  return Offset(q.dx + ((sqrt(dx * dx + dy * dy)) * cos(angle)),
      q.dy + ((sqrt(dx * dx + dy * dy)) * sin(angle)));
}

double roundToMultiple(double n, double multiple) {
  var rest = n % multiple;
  if (rest <= multiple / 2) {
    return n - rest;
  } else {
    return n + multiple - rest;
  }
}
