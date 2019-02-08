import 'dart:ui';

List<Map<String, List<Map<String, double>>>> convertListListOffsetToFirestore(List<List<Offset>> offsets) {
  int i = -1;
  return offsets.map((points) {
    print('Points: ' + points.toString());
    i = i + 1;
    return {i.toString(): points.map((Offset offset) {
      print('Offset: ' + offset.toString());
      return {
        'x': offset.dx,
        'y': offset.dy,
      };
    }).toList()};
  }).toList();
}

List<List<Offset>> convertFirestoreToListListOffset(List<dynamic> offsets) {
  print(offsets.toString());
  List<List<Offset>> pathsList = new List<List<Offset>>();
  List<Offset> pointsList = new List<Offset>();

  offsets.forEach((path) {
    path.forEach((k,v) {
      pointsList = new List<Offset>();
      v.forEach((offset) {
        print('Offset: ' + offset.toString());
        pointsList.add(new Offset(offset['x'], offset['y']));
      });
      pathsList.add(pointsList);
    });
    print ('Path List: ' + pathsList.toString());
  });
  print(pathsList.length.toString());
  if(pathsList.length == 0) return new List<List<Offset>>();
    else return pathsList;
}