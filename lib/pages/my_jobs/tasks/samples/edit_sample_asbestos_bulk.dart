import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/autocomplete.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class EditSampleAsbestosBulk extends StatefulWidget {
  EditSampleAsbestosBulk({Key key, this.sample}) : super(key: key);
  final String sample;
  @override
  _EditSampleAsbestosBulkState createState() => new _EditSampleAsbestosBulkState();
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
  String localPath;
  String remotePath;

  bool localPhoto = false;


  // MATERIAL AUTOCOMPLETE
  List<String> materials = AutoComplete.materials.split(';');
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  @override
  void initState() {
    // init text controllers
    controllerSampleNumber.addListener(_updateSampleNumber);
    controllerDescription.addListener(_updateDescription);
    controllerMaterial.addListener(_updateMaterial);
    controllerNotes.addListener(_updateNotes);

    // set paths
    if (widget.sample != null) sample =  Firestore.instance.collection('samplesasbestosbulk').document(widget.sample);
    _loadACM();

    super.initState();
  }

  //
  // TEXT CONTROLLERS, FIRESTORE UPLOAD
  //

  _updateSampleNumber() {
    sample.setData({"samplenumber": int.tryParse(controllerSampleNumber.text)}, merge: true);
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
    materials.sort();

    return new Scaffold(
//        resizeToAvoidBottomPadding: false,
        appBar:
        new AppBar(title: Text(_title),
            actions: <Widget>[
              new IconButton(icon: const Icon(Icons.check), onPressed: () {
                Navigator.pop(context);
              })
            ]),
        body:
        isLoading ? loadingPage(loadingText: 'Loading sample info...')
        : new StreamBuilder(stream: sample.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return
                loadingPage(loadingText: 'Loading sample info...');
              else {
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
                                  child: new Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        height: 156.0,
                                        width: 120.0,
                                        decoration: BoxDecoration(border: new Border.all(color: Colors.black)),
                                        child: GestureDetector(
                                            onTap: () {
                                              ImagePicker.pickImage(source: ImageSource.camera).then((image) {
                                                setState(() {
                                                  localPath = image.path;
                                                  localPhoto = true;
                                                });
                                                _handleImageUpload(image);
                                              });
                                            },
//                                    child: (_imageFile != null)
//                                        ? Image.file(_imageFile)
                                            child: (localPhoto) ?
                                            (localPath != null) ?
                                            new Image.file(new File(localPath))
                                                : new Container()
                                                : (remotePath != null) ?
                                            new CachedNetworkImage(
                                              imageUrl: remotePath,
//                                            imageUrl: 'https://www.whaleoil.co.nz/wp-content/uploads/2018/08/Dog.jpg',
                                              placeholder: new CircularProgressIndicator(),
                                              errorWidget: new Icon(Icons.error),
                                              fadeInDuration: new Duration(seconds: 1),
                                            )
                                                : new Icon(
                                              Icons.camera, color: CompanyColors.accent,
                                              size: 48.0,)
                                        ),
                                      )],
                                  ),),

                                // HEADER INFO

                                new Expanded(child: new Container(child:
                                new Column(children: <Widget>[
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
                                )
                                ),)
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
                            // TODO Collate lab notes from all analyses
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
                    ])
                    )
                );
              }
            }
        )
    );
  }

  void _loadACM() async {
    // Load rooms from job
    QuerySnapshot querySnapshot = await Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').getDocuments();
    querySnapshot.documents.forEach((doc) => roomlist.add(doc.data['name'].toString()));
//    print('ROOMLIST ' + roomlist.toString());

    if (widget.sample == null) {
      _title = "Add New Sample";
      Map<String, dynamic> dataMap = new Map();
      dataMap['jobnumber'] = DataManager
          .get()
          .currentJobNumber;
      //      sample.sampleNumber = DataManager.get().getHighestSampleNumber(DataManager.get().currentJob) + 1;
      dataMap['samplenumber'] = null;
      dataMap['description'] = null;
      dataMap['material'] = null;
      dataMap['path_local'] = null;
      dataMap['path_remote'] = null;
      localPath = null;
      Firestore.instance.collection('samplesasbestosbulk').add(
          dataMap).then((ref) {
        sample = Firestore.instance.collection('samplesasbestosbulk').document(ref.documentID);
        setState(() {
          isLoading = false;
        });
      });
    } else {
      _title = "Edit Sample";

      sample.get().then((doc) {
        if (doc.data['samplenumber'].toString() == 'null') {
          controllerSampleNumber.text = '';
        } else controllerSampleNumber.text = doc.data['samplenumber'].toString();

        controllerDescription.text = doc.data['description'];
        controllerMaterial.text = doc.data['material'];
        controllerNotes.text = doc.data['notes'];

        // image
        remotePath = doc.data['path_remote'];
        localPath = doc.data['path_local'];
        if (remotePath == null && localPath != null){
          // only local image available (e.g. when taking photos with no internet)
          localPhoto = true;
        } else if (remotePath != null) {
          localPhoto = false;
        }
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  void _handleImageUpload(File image) async {
    ImageSync(
        image,
        50,
        "sample" + controllerSampleNumber.text + "_" + sample.documentID + ".jpg",
        DataManager.get().currentJobNumber,
        sample
    ).then((path) {
      setState(() {
        remotePath = path;
        localPhoto = false;
      });
    });
  }
}