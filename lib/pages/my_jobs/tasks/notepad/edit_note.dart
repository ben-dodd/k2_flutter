import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/autocomplete.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class EditNote extends StatefulWidget {
  EditNote({Key key, this.note}) : super(key: key);
  final String note;
  @override
  _EditNoteState createState() => new _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  String _title;
  bool isLoading = true;

  // images
  bool localPhoto = false;

  DocumentReference note;

  final controllerTitle = TextEditingController();
  final controllerNote = TextEditingController();

  @override
  void initState() {
    controllerTitle.addListener(_updateTitle);
    controllerNote.addListener(_updateNote);
    if (widget.note != null) note = Firestore.instance.document(DataManager.get().currentJobPath).collection('notes').document(widget.note);
    _loadNote();
    super.initState();
  }

  _updateTitle() {
    note.setData({"title": controllerTitle.text}, merge: true);
  }

  _updateNote() {
    note.setData({"note": controllerNote.text}, merge: true);
  }



  Widget build(BuildContext context) {
    return new Scaffold(
//        resizeToAvoidBottomPadding: false,
        appBar:
        new AppBar(title: Text(_title),
            actions: <Widget>[
              new IconButton(icon: const Icon(Icons.check), onPressed: () {
                Navigator.pop(context);
              })
            ]),
        body: isLoading ?
          loadingPage(loadingText: 'Loading note...')
        : new StreamBuilder(stream: note.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return
                loadingPage(loadingText: 'Loading note...');
              if (snapshot.hasData) {
                return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Container(
                        padding: new EdgeInsets.all(8.0),
                        child: ListView(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                              new Container(width: 150.0,
                                child: new Column(children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    height: 156.0,
                                    width: 120.0,
                                    decoration: BoxDecoration(border: new Border.all(color: Colors.black)),
                                    child: GestureDetector(
                                        onTap: () {
                                          ImagePicker.pickImage(source: ImageSource.camera).then((image) {
//                                          _imageFile = image;
                                            localPhoto = true;
                                            _handleImageUpload(image);
                                          });
                                        },
//                                    child: (_imageFile != null)
//                                        ? Image.file(_imageFile)
                                        child: localPhoto ?
                                        new Image.file(new File(snapshot.data['path_local']))
                                            : (snapshot.data['path_remote'] != null) ?
                                        new CachedNetworkImage(
                                          imageUrl: snapshot.data['path_remote'],
                                          placeholder: new CircularProgressIndicator(),
                                          errorWidget: new Icon(Icons.error),
                                          fadeInDuration: new Duration(seconds: 1),
                                        )
                                            :  new Icon(
                                          Icons.camera, color: CompanyColors.accent,
                                          size: 48.0,)
                                    ),
                                  )],
                                ),),
                              new Expanded(child: new Container(
                                  child: new Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: TextField(
                                            decoration: const InputDecoration(
                                                labelText: "Title"),
                                            autocorrect: false,
                                            controller: controllerTitle,
                                            keyboardType: TextInputType.multiline,
                                            maxLines: null
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: TextField(
                                            decoration: const InputDecoration(
                                                labelText: "Note"),
                                            autocorrect: false,
                                            controller: controllerNote,
                                            keyboardType: TextInputType.multiline,
                                            maxLines: null
                                        ),
                                      ),
                                    ],
                                  )
                              ),)
                            ],
                            ),
                          ],
                        )
                    )
                );
              }
            }
        )
    );
  }

  void _loadNote() async {
    if (widget.note == null) {
      _title = "Add Note";
      Map<String, dynamic> dataMap = new Map();

      dataMap['title'] = null;
      dataMap['note'] = null;
      dataMap['path_local'] = null;
      dataMap['path_remote'] = null;

      Firestore.instance.document(DataManager.get().currentJobPath).collection('notes').add(dataMap).then((ref) {
        note = Firestore.instance.document(DataManager.get().currentJobPath).collection('notes').document(ref.documentID);
        setState(() {
          isLoading = false;
        });
      });
    } else {
      _title = "Edit Note";
      note.get().then((doc) {
        controllerTitle.text = doc.data['title'];
        controllerNote.text = doc.data['note'];
        // image
        if (doc.data['path_local'] != null && doc.data['path_remote'] == null){
          // only local image available (e.g. when taking photos with no internet)
          localPhoto = true;
          _handleImageUpload(File(doc.data['path_local']));
        } else if (doc.data['path_remote'] != null) {
          localPhoto = false;
        }
        setState(() {
          isLoading = false;
        });
      });
    }
  }
  void _handleImageUpload(File image) async {
    note.setData({"path_local": image.path},merge: true).then((_) {
      setState((){});
    });
    ImageSync(
        image,
        50,
        "note" + "_" + note.documentID + ".jpg",
        DataManager.get().currentJobNumber,
        note
    ).then((_) {
      setState((){
        localPhoto = false;
      });
    });
  }
}