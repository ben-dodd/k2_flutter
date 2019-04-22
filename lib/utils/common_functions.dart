import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:k2e/utils/camera.dart';

void deleteDialog({BuildContext context, String title, String query, DocumentReference docPath, StorageReference imagePath, VoidCallback actions}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(query),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Cancel',
                  style: new TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
                child: new Text('Delete'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Remove references
                  if (actions != null)
                    actions();

                  // Remove images
                  if (imagePath != null)
                    imagePath.delete();

                  // Remove document
                  docPath.delete();

                  // Pop
                  Navigator.pop(context);
                }),
          ],
        );
      });
}

//void handleImageUpload(File image, String filePath) async {
//  String path = widget.map;
//  String mapgrouppath = mapObj['mapgrouppath'];
//  String storageRef = mapObj['storage_ref'];
//
//  updateMapCard(
//      mapgrouppath, {'path_local': image.path, 'path': mapObj['path']});
//  setState(() {
//    mapObj["path_local"] = image.path;
//  });
//
//  ImageSync(
//      image,
//      50,
//      "map_" + mapObj['path'],
//      "jobs/" + DataManager.get().currentJobNumber,
//      Firestore.instance
//          .document(DataManager.get().currentJobPath)
//          .collection('maps')
//          .document(map))
//      .then((refs) {
//    // Delete old photo
//    if (storageRef != null)
//      FirebaseStorage.instance.ref().child(storageRef).delete();
//
//    updateMapCard(mapgrouppath, {
//      'path_remote': refs['downloadURL'],
//      'storage_ref': refs['storageRef'],
//      'path': mapObj['path']
//    });
//    if (this.mounted) {
//      setState(() {
//        mapObj["path_remote"] = refs['downloadURL'];
//        mapObj['storage_ref'] = refs['storageRef'];
//        localPhoto = false;
//      });
//    } else {
//      // User has left the page, upload url straight to firestore
//      Firestore.instance
//          .document(DataManager.get().currentJobPath)
//          .collection('maps')
//          .document(path)
//          .setData({
//        "path_remote": refs['downloadURL'],
//        "storage_ref": refs['storageRef'],
//      }, merge: true);
//    }
//  });
//}
//}