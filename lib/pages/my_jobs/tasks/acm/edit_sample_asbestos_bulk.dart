import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/common_widgets.dart';

class EditSampleAsbestosBulk extends StatefulWidget {
  EditSampleAsbestosBulk({Key key, this.sample}) : super(key: key);
  final String sample;
  @override
  _EditSampleAsbestosBulkState createState() =>
      new _EditSampleAsbestosBulkState();
}

class _EditSampleAsbestosBulkState extends State<EditSampleAsbestosBulk> {
  // TITLE
  String _title = "Edit Sample";

  // DOCUMENT IDS
  DocumentReference sample;

  // UI STATE
  bool isLoading = true;
  bool isSampled = true;
  bool stronglyPresumed = false;
  String presumedText = 'Presumed';
  List<String> roomlist = new List();
  bool showMaterialRisk = true;
  bool showPriorityRisk = false;

  String idKey;

  // GENERAL INFO
  final controllerSampleNumber = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerMaterial = TextEditingController();
  final controllerNotes = TextEditingController();

  // IMAGES
  bool localPhoto = false;

  @override
  void initState() {
    // init text controllers
    controllerSampleNumber.addListener(_updateSampleNumber);
    controllerDescription.addListener(_updateDescription);
    controllerMaterial.addListener(_updateMaterial);
    controllerNotes.addListener(_updateNotes);

    // set paths
    if (widget.sample != null)
      sample = Firestore.instance
          .collection('samplesasbestos')
          .document(widget.sample);
    _loadACM();

    super.initState();
  }

  //
  // TEXT CONTROLLERS, FIRESTORE UPLOAD
  //

  _updateSampleNumber() {
    sample.setData({"sampleNumber": int.tryParse(controllerSampleNumber.text)},
        merge: true);
  }

  _updateDescription() {
    sample.setData({"description": controllerDescription.text}, merge: true);
  }

  _updateMaterial() {
    sample.setData({"material": controllerMaterial.text}, merge: true);
  }

  _updateNotes() {
    sample.setData({"notes": controllerNotes.text}, merge: true);
  }

  Widget build(BuildContext context) {
    return new Scaffold(
//        resizeToAvoidBottomPadding: false,
        appBar: new AppBar(title: Text(_title), actions: <Widget>[
          new IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context);
              })
        ]),
        body: isLoading
            ? LoadingPage(loadingText: 'Loading sample info...')
            : new StreamBuilder(
                stream: sample.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return LoadingPage(loadingText: 'Loading sample info...');
                  else {
                    return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        child: Container(
                            padding: new EdgeInsets.all(8.0),
                            child: ListView(children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Container(
                                    width: 150.0,
                                    child: new Column(
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.center,
                                          height: 156.0,
                                          width: 120.0,
                                          decoration: BoxDecoration(
                                              border: new Border.all(
                                                  color: Colors.black)),
                                          child: GestureDetector(
                                              onTap: () {
                                                ImagePicker.pickImage(
                                                        source:
                                                            ImageSource.camera)
                                                    .then((image) {
//                                          _imageFile = image;
                                                  localPhoto = true;
                                                  _handleImageUpload(image);
                                                });
                                              },
//                                    child: (_imageFile != null)
//                                        ? Image.file(_imageFile)
                                              child: localPhoto
                                                  ? new Image.file(new File(
                                                      snapshot
                                                          .data['path_local']))
                                                  : (snapshot.data[
                                                              'path_remote'] !=
                                                          null)
                                                      ? new CachedNetworkImage(
                                                          imageUrl: snapshot
                                                                  .data[
                                                              'path_remote'],
                                                          placeholder: (context,
                                                                  url) =>
                                                              new CircularProgressIndicator(),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              new Icon(
                                                                  Icons.error),
                                                          fadeInDuration:
                                                              new Duration(
                                                                  seconds: 1),
                                                        )
                                                      : new Icon(
                                                          Icons.camera,
                                                          color: CompanyColors
                                                              .accentRippled,
                                                          size: 48.0,
                                                        )),
                                        )
                                      ],
                                    ),
                                  ),

                                  // HEADER INFO

                                  new Expanded(
                                    child: new Container(
                                        child: new Column(
                                      children: <Widget>[
                                        // SAMPLE NUMBER
//                                  new Row(children: <Widget> [
                                        new Container(
                                          alignment: Alignment.topLeft,
                                          child: TextField(
                                            decoration: const InputDecoration(
                                                labelText: "Sample Number"),
                                            autocorrect: false,
                                            controller: controllerSampleNumber,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),

                                        Container(
                                          alignment: Alignment.topLeft,
                                          child: TextField(
                                            decoration: const InputDecoration(
                                                labelText: "Description"),
                                            autocorrect: false,
                                            controller: controllerDescription,
                                            keyboardType: TextInputType.text,
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          child: TextField(
                                            decoration: const InputDecoration(
                                                labelText: "Material"),
                                            autocorrect: false,
                                            controller: controllerMaterial,
                                            keyboardType: TextInputType.text,
                                          ),
                                        ),
                                      ],
                                    )),
                                  )
                                ],
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: "Site Notes"),
                                  autocorrect: false,
                                  controller: controllerNotes,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                ),
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: "Lab Notes"),
                                  autocorrect: false,
                                  controller: controllerNotes,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                ),
                              ),
                            ])));
                  }
                }));
  }

  void _loadACM() async {
    // Load rooms from job
    QuerySnapshot querySnapshot = await Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('rooms')
        .getDocuments();
    querySnapshot.documents
        .forEach((doc) => roomlist.add(doc.data['name'].toString()));
//    print('ROOMLIST ' + roomlist.toString());

    if (widget.sample == null) {
      _title = "Add New Sample";
      Map<String, dynamic> dataMap = new Map();
      dataMap['jobNumber'] = DataManager.get().currentJobNumber;
      //      sample.sampleNumber = DataManager.get().getHighestSampleNumber(DataManager.get().currentJob) + 1;
      dataMap['sampleNumber'] = null;
      dataMap['description'] = null;
      dataMap['material'] = null;
      dataMap['sampleType'] = 'bulk';
      dataMap['path_local'] = null;
      dataMap['path_remote'] = null;
      Firestore.instance.collection('samplesasbestos').add(dataMap).then((ref) {
        sample = Firestore.instance
            .collection('samplesasbestos')
            .document(ref.documentID);
        setState(() {
          isLoading = false;
        });
      });
    } else {
      _title = "Edit Sample";

      sample.get().then((doc) {
        if (doc.data['sampleNumber'].toString() == 'null') {
          controllerSampleNumber.text = '';
        } else
          controllerSampleNumber.text = doc.data['sampleNumber'].toString();

        controllerDescription.text = doc.data['description'];
        controllerMaterial.text = doc.data['material'];
        controllerNotes.text = doc.data['notes'];

        // image
        if (doc.data['path_remote'] == null && doc.data['path_local'] != null) {
          // only local image available (e.g. when taking photos with no internet)
          _handleImageUpload(File(doc.data['path_local']));
          localPhoto = true;
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
    sample.setData({"path_local": image.path}, merge: true).then((_) {
      setState(() {});
    });
    ImageSync(image, 50, "sample" + controllerSampleNumber.text,
            "jobs/" + DataManager.get().currentJobNumber, sample)
        .then((_) {
      setState(() {
        localPhoto = false;
      });
    });
  }
}
