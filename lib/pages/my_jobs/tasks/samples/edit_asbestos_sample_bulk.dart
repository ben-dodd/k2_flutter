import 'dart:async';
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
import 'package:k2e/widgets/buttons.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dropdown_menu/dropdown_menu.dart';

class EditAsbestosSampleBulk extends StatefulWidget {
  EditAsbestosSampleBulk({Key key, this.sample}) : super(key: key);
  final String sample;
  @override
  _EditAsbestosSampleBulkState createState() => new _EditAsbestosSampleBulkState();
}

class _EditAsbestosSampleBulkState extends State<EditAsbestosSampleBulk> {
//  bool _isLoading = false;
  String _title = "Edit Sample";
  Stream sampleDoc;
  bool isLoading = true;
  bool isSampled = true;
  String materialText;
  String presumedText = 'Presumed';
  bool stronglyPresumed = false;
  List<String> roomlist = new List();

  // view
  bool showMaterialRisk = true;
  bool showPriorityRisk = false;

  String idKey;

  int accessibilityScore;

  // material risk assessment
  int materialDamageScore;
  int materialSurfaceScore;
  int materialProductScore;
  int materialAsbestosScore;
  final controllerDamageDesc = TextEditingController();
  final controllerSurfaceDesc = TextEditingController();

  String sample;
  String room = '';

  String localPath;
  String remotePath;

  bool localPhoto = false;

  List<String> materials = AutoComplete.materials.split(';');

  final controllerSampleNumber = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerMaterial = TextEditingController();


  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  int _radioSample;

  void _handleSampleChange(int value) {
    setState(() {
      _radioSample = value;
      switch (_radioSample) {
        case 0:
          isSampled = true;
          idKey = 'i';
          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
              {"idkey": 'i'}, merge: true);
        // Add to samplesasbestosbulk
        // Sample number input pops up
        break;
      case 1:
        isSampled = false;
        if (stronglyPresumed) {
          Firestore.instance.collection('samplesasbestosbulk')
              .document(sample)
              .setData(
              {"idkey": 's'}, merge: true);
        } else {
          Firestore.instance.collection('samplesasbestosbulk')
              .document(sample)
              .setData(
              {"idkey": 'p'}, merge: true);
        }
// Presumed inputs pop up
        break;
    }
    });
  }


  @override
  void initState() {
    controllerSampleNumber.addListener(_updateSampleNumber);
    controllerDescription.addListener(_updateDescription);
    controllerMaterial.addListener(_updateMaterial);

    controllerDamageDesc.addListener(_updateDamageDesc);
    controllerSurfaceDesc.addListener(_updateSurfaceDesc);
    sample = widget.sample;
    _loadSample();
    super.initState();
  }

  _updateSampleNumber() {
    Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
        {"sampleNumber": int.tryParse(controllerSampleNumber.text)}, merge: true);
  }

  _updateDescription() {
    Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
        {"description": controllerDescription.text}, merge: true);
  }

  _updateMaterial() {
    Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
        {"material": controllerMaterial.text}, merge: true);
  }

  _updateDamageDesc() {
    Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
        {"materialrisk_damagedesc": controllerDamageDesc.text}, merge: true);
  }

  _updateSurfaceDesc() {
    Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
        {"materialrisk_surfacedesc": controllerSurfaceDesc.text}, merge: true);
  }


  Widget build(BuildContext context) {
//    final DateTime today = new DateTime.now();

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
        body: new StreamBuilder(stream: Firestore.instance.collection('samplesasbestosbulk').document(sample).snapshots(),
            builder: (context, snapshot) {
                if (isLoading || !snapshot.hasData) return
                  loadingPage(loadingText: 'Loading sample info...');
                if (!isLoading && snapshot.hasData) {
                  return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Container(
                          padding: new EdgeInsets.all(8.0),
                          child: ListView(
                            children: <Widget>[
                              new Row(children: <Widget>[
                                new Container(
                                    child: new Row(children: <Widget>[
                                      new Radio(
                                        value: 0,
                                        groupValue: _radioSample,
                                        onChanged: _handleSampleChange,
                                      ),
                                      new Text("Sampled"),
                                    ],)
                                ),
                                new Container(
                                    child: new Row(children: <Widget>[
                                      new Radio(
                                        value: 1,
                                        groupValue: _radioSample,
                                        onChanged: _handleSampleChange,
                                      ),
                                      new Text(presumedText),
                                    ],
                                    )
                                  ),
                              ],),
                        Row(children: <Widget>[
                          new Container(width: 150.0,
                          child: new Column(children: <Widget>[
//                            new Container(
//                                height: 40.0,
//                                alignment: Alignment.center,
//                                child: Text("Sample Photo", style: Styles.h2,)
//                            ),
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
                          new Expanded(child: new Container(child:
                          new Column(children: <Widget>[
                                isSampled ?
                                new Container(
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: "Sample Number"),
                                  autocorrect: false,
                                  controller: controllerSampleNumber,
                                  keyboardType: TextInputType.number,
                                ),
                              )
                              :
                                  new Container(
                                    child: new Row(children: <Widget>[
                                      new Switch(
                                        value: stronglyPresumed,
                                        onChanged: (bool strong) {
                                          setState(() {
                                            if (strong) {
                                              presumedText = 'Strongly presumed';
                                              stronglyPresumed = true;
                                            } else {
                                              presumedText = 'Presumed';
                                              stronglyPresumed = false;
                                            }
                                          });
                                        },
                                      ),
                                      new Text("Strongly presume"),
                                    ],)
                                  ),
                              //todo: fix this
//                              new Text(room),
                              new Row(
                                children: <Widget>[
                                  new Text(room),
                                  new DropdownButton<String>(
                                    items: roomlist.map((String value) {
                                      return new DropdownMenuItem<String>(
                                        value: value,
                                        child: new Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                    room = value;
                                      });
                                    },
                                  )
                                ],),
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
                                child: AutoCompleteTextField<String>(
                                    decoration: new InputDecoration(
                                        hintText: materialText,
                                        labelText: "Material"

//                                        border: new OutlineInputBorder(
//                                            gapPadding: 0.0, borderRadius: new BorderRadius.circular(16.0)),
//                                        suffixIcon: new Icon(Icons.search)
                                    ),
                                    key: key,
                                    suggestions: materials,
                                    textChanged: (item) {
                                      controllerMaterial.text = item;
                                    },
                                    itemBuilder: (context, item) {
                                      return new Padding(
                                          padding: EdgeInsets.all(8.0), child: new Text(item));
                                    },
                                    itemSorter: (a, b) {
                                      return a.compareTo(b);
                                    },
                                    itemFilter: (item, query) {
                                      return item.toLowerCase().contains(query.toLowerCase());
                                    }),
                              ),
                            ],
                          )
                          ),)
                        ],
                        ),

                              new Container(
                                  child: new Row(children: <Widget>[
                                    new Switch(
                                      value: showMaterialRisk,
                                      onChanged: (bool show) {
                                        setState(() {
                                          showMaterialRisk = show;
                                        });
                                      },
                                    ),
                                    new Text("Material Risk"),
                                  ],)
                              ),
                              showMaterialRisk ?
                              new Container(
                                  child: new Column(children: <Widget>[
                                    // ACCESSIBILITY

                                    new Container(alignment: Alignment.bottomLeft, child:
                                    new Text('Accessibility'),),
                                    new Row(children: <Widget>[
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (accessibilityScore == 1) { accessibilityScore = null; }
                                            else { accessibilityScore = 1; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"accessibility": accessibilityScore}, merge: true);
                                          });
                                        },
                                        selected: accessibilityScore == 1,
                                        score: 1,
                                        text: 'Easy',
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (accessibilityScore == 2) { accessibilityScore = null; }
                                            else { accessibilityScore = 2; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"accessibility": accessibilityScore}, merge: true);
                                          });
                                        },
                                        selected: accessibilityScore == 2,
                                        score: 2,
                                        text: 'Medium',
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (accessibilityScore == 3) { accessibilityScore = null; }
                                            else { accessibilityScore = 3; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"accessibility": accessibilityScore}, merge: true);
                                          });
                                        },
                                        selected: accessibilityScore == 3,
                                        score: 3,
                                        text: 'Difficult',
                                      ),),


                                    ],
                                    ),

                                    // PRODUCT SCORE

                                    new Container(alignment: Alignment.bottomLeft, child:
                                    new Text('Product'),),
                                    new Row(children: <Widget>[
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialProductScore == 0) { materialProductScore = null; }
                                            else { materialProductScore = 0; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_productscore": materialProductScore}, merge: true);
                                          });
                                        },
                                        selected: materialProductScore == 0,
                                        score: 0,
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialProductScore == 1) { materialProductScore = null; }
                                            else { materialProductScore = 1; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_productscore": materialProductScore}, merge: true);
                                          });
                                        },
                                        selected: materialProductScore == 1,
                                        score: 1,
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialProductScore == 2) { materialProductScore = null; }
                                            else { materialProductScore = 2; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_productscore": materialProductScore}, merge: true);
                                          });
                                        },
                                        selected: materialProductScore == 2,
                                        score: 2,
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialProductScore == 3) { materialProductScore = null; }
                                            else { materialProductScore = 3; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_productscore": materialProductScore}, merge: true);
                                          });
                                        },
                                        selected: materialProductScore == 3,
                                        score: 3,
                                      ),),

                                    ],
                                    ),

                                    // DAMAGE SCORE

                                    new Container(alignment: Alignment.bottomLeft, child:
                                    new Text('Damage'),),
                                    new Row(children: <Widget>[
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change
                                          setState(() {
                                            if (materialDamageScore == 0) { materialDamageScore = null; }
                                            else { materialDamageScore = 0; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_damagescore": materialDamageScore}, merge: true);
                                          });
                                        },
                                        selected: materialDamageScore == 0,
                                        score: 0,
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialDamageScore == 1) { materialDamageScore = null; }
                                            else { materialDamageScore = 1; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_damagescore": materialDamageScore}, merge: true);
                                          });
                                        },
                                        selected: materialDamageScore == 1,
                                        score: 1,
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialDamageScore == 2) { materialDamageScore = null; }
                                            else { materialDamageScore = 2; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_damagescore": materialDamageScore}, merge: true);
                                          });
                                        },
                                        selected: materialDamageScore == 2,
                                        score: 2,
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialDamageScore == 3) { materialDamageScore = null; }
                                            else { materialDamageScore = 3; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_damagescore": materialDamageScore}, merge: true);
                                          });
                                        },
                                        selected: materialDamageScore == 3,
                                        score: 3,
                                      ),),

                                    ],
                                    ),

                                    // SURFACE SCORE

                                    new Container(alignment: Alignment.bottomLeft, child:
                                    new Text('Surface'),),
                                    new Row(children: <Widget>[
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialSurfaceScore == 0) { materialSurfaceScore = null; }
                                            else { materialSurfaceScore = 0; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_surfacescore": materialSurfaceScore}, merge: true);
                                          });
                                        },
                                        selected: materialSurfaceScore == 0,
                                        score: 0,
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialSurfaceScore == 1) { materialSurfaceScore = null; }
                                            else { materialSurfaceScore = 1; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_surfacescore": materialSurfaceScore}, merge: true);
                                          });
                                        },
                                        selected: materialSurfaceScore == 1,
                                        score: 1,
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialSurfaceScore == 2) { materialSurfaceScore = null; }
                                            else { materialSurfaceScore = 2; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_surfacescore": materialSurfaceScore}, merge: true);
                                          });
                                        },
                                        selected: materialSurfaceScore == 2,
                                        score: 2,
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialSurfaceScore == 3) { materialSurfaceScore = null; }
                                            else { materialSurfaceScore = 3; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_surfacescore": materialSurfaceScore}, merge: true);
                                          });
                                        },
                                        selected: materialSurfaceScore == 3,
                                        score: 3,
                                      ),),

                                    ],
                                    ),

                                    // ASBESTOS SCORE

                                    new Container(alignment: Alignment.bottomLeft, child:
                                    new Text('Asbestos Type'),),
                                    new Row(children: <Widget>[
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {

                                        },
                                        selected: false,
                                        // -1 = disabled button
                                        score: -1,
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialAsbestosScore == 1) { materialAsbestosScore = null; }
                                            else { materialAsbestosScore = 1; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_asbestosscore": materialAsbestosScore}, merge: true);
                                          });
                                        },
                                        selected: materialAsbestosScore == 1,
                                        score: 1,
//                                        text: 'ch'
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialAsbestosScore == 2) { materialAsbestosScore = null; }
                                            else { materialAsbestosScore = 2; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_asbestosscore": materialAsbestosScore}, merge: true);
                                          });
                                        },
                                        selected: materialAsbestosScore == 2,
                                        score: 2,
//                                        text: 'am'
                                      ),),
                                      new Expanded(child:
                                      new ScoreButton(
                                        onClick: () {
                                          // firestore change score
                                          setState(() {
                                            if (materialAsbestosScore == 3) { materialAsbestosScore = null; }
                                            else { materialAsbestosScore = 3; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_asbestosscore": materialAsbestosScore}, merge: true);
                                          });
                                        },
                                        selected: materialAsbestosScore == 3,
                                        score: 3,
//                                        text: 'cr'
                                      ),),

                                    ],
                                    ),

                                    new Container(
                                      alignment: Alignment.topLeft,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                            labelText: "Damage Description"),
                                        autocorrect: false,
                                        controller: controllerDamageDesc,
                                        keyboardType: TextInputType.text,
                                      ),
                                    ),
                                    new Container(
                                      alignment: Alignment.topLeft,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                            labelText: "Surface Treatment"),
                                        autocorrect: false,
                                        controller: controllerSurfaceDesc,
                                        keyboardType: TextInputType.text,
                                      ),
                                    ),
                                    // Damage
                                  ],
                                  )
                              )
                              : Container(),
                              new Container(
                                  width: 140.0,
                                  child: new Row(children: <Widget>[
                                    new Switch(
                                      value: showPriorityRisk,
                                      onChanged: (bool show) {
                                        setState(() {
                                          showPriorityRisk = show;
                                        });
                                      },
                                    ),
                                    new Text("Priority Risk"),
                                  ],)
                              ),
                              showPriorityRisk ?
                                  new Container()
                                  : new Container(),
                              ],
                          )
                      )
                  );
                }
            }
        )
    );
  }

  void _loadSample() async {
    QuerySnapshot querySnapshot = await Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').getDocuments();
    querySnapshot.documents.forEach((doc) => roomlist.add(doc.data['name'].toString()));
    print('ROOMLIST ' + roomlist.toString());
    if (sample == null) {
      _title = "Add New Sample";
      Map<String, dynamic> dataMap = new Map();
      dataMap['jobNumber'] = DataManager
          .get()
          .currentJobNumber;
      //      sample.sampleNumber = DataManager.get().getHighestSampleNumber(DataManager.get().currentJob) + 1;
      dataMap['sampleNumber'] = 1;
      dataMap['idkey'] = 'i';
      idKey = 'i';
      dataMap['description'] = null;
      dataMap['material'] = null;
      dataMap['localPath'] = null;
      dataMap['remotePath'] = null;
      dataMap['materialrisk_asbestosscore'] = 3;
      materialAsbestosScore = 3;
      localPath = null;
      Firestore.instance.collection('samplesasbestosbulk').add(
          dataMap).then((ref) {
        sample = ref.documentID;
        setState(() {
          isLoading = false;
        });
      });
    } else {
      _title = "Edit Sample";
      Firestore.instance.collection('samplesasbestosbulk').document(sample).get().then((doc) {
        if (doc.data['sampleNumber'].toString() == 'null') {
          controllerSampleNumber.text = '';
        } else controllerSampleNumber.text = doc.data['sampleNumber'].toString();
        idKey = doc.data['idkey'];
        if (idKey == 'i') {
          isSampled = true;
          stronglyPresumed = false;
          _radioSample = 0;
        } else {
          isSampled = false;
          _radioSample = 1;
          if (idKey == 's') {
            stronglyPresumed = true;
          } else {
            stronglyPresumed = false;
          }
        }
        controllerDescription.text = doc.data['description'];
        materialText = doc.data['material'];

        accessibilityScore = doc.data['accessibility'];

        // Material Risk assessment
        materialProductScore = doc.data['materialrisk_productscore'];
        materialDamageScore = doc.data['materialrisk_damagescore'];
        materialSurfaceScore = doc.data['materialrisk_surfacescore'];
        materialAsbestosScore = doc.data['materialrisk_asbestosscore'];
        controllerDamageDesc.text = doc.data['materialrisk_damagedesc'];
        controllerSurfaceDesc.text = doc.data['materialrisk_surfacedesc'];

        // image
        remotePath = doc.data['remotePath'];
        localPath = doc.data['localPath'];
        if (remotePath == null && localPath != null){
          // only local image available (e.g. when taking photos with no internet)
          localPhoto = true;
        } else if (remotePath != null) {
          localPhoto = false;
        }
        setState(() {
          print('Rooms: ' + roomlist.toString());
          isLoading = false;
        });
      });
    }
  }

  void _handleImageUpload(File image) async {
    ImageSync(
        image,
        50,
        "sample" + controllerSampleNumber.text + "_" + sample + ".jpg",
        DataManager.get().currentJobNumber,
        Firestore.instance.collection('samplesasbestosbulk').document(sample)
    ).then((path) {
      setState(() {
        remotePath = path;
        localPhoto = false;
      });
    });
  }
}