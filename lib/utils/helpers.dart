import 'dart:async';
import 'dart:io';
import 'dart:math' as Math;

import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';

Future<File> compressImage(imageFile, compression) async {
//    File imageFile = await ImagePicker.pickImage();
  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;
  int rand = new Math.Random().nextInt(10000);

  Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
  Im.Image smallerImage = Im.copyResize(
      image, 500); // choose the size here, it will maintain aspect ratio

  var compressedImage = new File('$path/img_$rand.jpg')
    ..writeAsBytesSync(Im.encodeJpg(image, quality: compression));
  print('comprsesed image made.');
  return compressedImage;
}
