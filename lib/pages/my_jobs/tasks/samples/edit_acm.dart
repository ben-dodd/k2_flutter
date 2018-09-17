import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/autocomplete.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/tooltips.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/buttons.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class EditACM extends StatefulWidget {
  EditACM({Key key, this.sample, this.acm}) : super(key: key);
  final String sample;
  final String acm;
  @override
  _EditACMState createState() => new _EditACMState();
}

class _EditACMState extends State<EditACM> {
//  bool _isLoading = false;
  String _title = "Edit Sample";
//  Stream sampleDoc;

  String sample;
  String acm;
  String _room;

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

  final controllerSampleNumber = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerMaterial = TextEditingController();
  final controllerNotes = TextEditingController();

  int accessibilityScore;

  // material risk assessment
  int materialDamageScore;
  int materialSurfaceScore;
  int materialProductScore;
  int materialAsbestosScore;
  final controllerDamageDesc = TextEditingController();
  final controllerSurfaceDesc = TextEditingController();

  int materialRiskScore;
  String materialRiskText;
  int materialRiskLevel;

  // priority risk assessment
  int priorityActivityMain;
  int priorityActivitySecond;
  int priorityDisturbanceLocation;
  int priorityDisturbanceAccessibility;
  int priorityDisturbanceExtent;
  int priorityExposureOccupants;
  int priorityExposureUseFreq;
  int priorityExposureAvgTime;
  int priorityMaintType;
  int priorityMaintFreq;

  int priorityRiskScore;
  String priorityRiskText;
  int priorityRiskLevel;

  String localPath;
  String remotePath;

  bool localPhoto = false;

  List<String> materials = AutoComplete.materials.split(';');


  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  int _radioSample;

  // WORKS OUT IDKEY ETC.
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
    controllerNotes.addListener(_updateNotes);

    controllerDamageDesc.addListener(_updateDamageDesc);
    controllerSurfaceDesc.addListener(_updateSurfaceDesc);
    sample = widget.sample;
    _loadACM();
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

  _updateNotes() {
    Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
        {"notes": controllerNotes.text}, merge: true);
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
    // Calculate material totals
    bool materialRiskSet = true;
    materialRiskScore = 0;
    if (materialProductScore != null)
      materialRiskScore = materialRiskScore + materialProductScore;
    else materialRiskSet = false;
    if (materialDamageScore != null)
      materialRiskScore = materialRiskScore + materialDamageScore;
    else materialRiskSet = false;
    if (materialSurfaceScore != null)
      materialRiskScore = materialRiskScore + materialSurfaceScore;
    else materialRiskSet = false;
    if (materialAsbestosScore != null)
      materialRiskScore = materialRiskScore + materialAsbestosScore;
    else materialRiskSet = false;

    if (materialRiskScore > 9) {
      materialRiskLevel = 3;
      materialRiskText = 'High (' + materialRiskScore.toString() + ')';
    } else if (materialRiskScore > 6) {
      materialRiskLevel = 2;
      materialRiskText = 'Medium (' + materialRiskScore.toString() + ')';
    } else if (materialRiskScore > 3) {
      materialRiskLevel = 1;
      materialRiskText = 'Low (' + materialRiskScore.toString() + ')';
    } else {
      materialRiskLevel = 0;
      materialRiskText = 'Very low (' + materialRiskScore.toString() + ')';
    }
  // Calculate priority risk
    bool priorityRiskSet = true;
  // Calculate priority totals
    priorityRiskScore = 0;
    int i = 0;
    int priorityActivity = 0;
    int priorityDisturbance = 0;
    int priorityExposure = 0;
    int priorityMaint = 0;

    // Activity
    if (priorityActivityMain != null) {
      priorityActivity = priorityActivity + priorityActivityMain;
      i = i + 1;
    }
    if (priorityActivitySecond != null) {
      priorityActivity = priorityActivity + priorityActivitySecond;
      i = i + 1;
    }
    if (i == 0) {
      i = 1;
      priorityRiskSet = false;
    }
    (i > 1) ? priorityRiskScore = priorityRiskScore + ((priorityActivity + 0.9) / i).round() : priorityRiskScore = priorityRiskScore + priorityActivity;
      print ('Average: ' + ((priorityActivity + 0.9) / i).round().toString() + 'Activity: ' + priorityActivity.toString() + ', Counter: ' + i.toString() + ' PriorityRisk ' + priorityRiskScore.toString());
      i = 0;


      // Disturbance
      if (priorityDisturbanceLocation != null) {
        priorityDisturbance = priorityDisturbance + priorityDisturbanceLocation;
        i = i + 1;
      }
      if (priorityDisturbanceAccessibility != null) {
        priorityDisturbance = priorityDisturbance + priorityDisturbanceAccessibility;
        i = i + 1;
      }
      if (priorityDisturbanceExtent != null) {
        priorityDisturbance = priorityDisturbance + priorityDisturbanceExtent;
        i = i + 1;
      }
      if (i == 0) {
        i = 1;
        priorityRiskSet = false;
      }
    (i > 1) ? priorityRiskScore = priorityRiskScore + ((priorityDisturbance + 0.9) / i).round() : priorityRiskScore = priorityRiskScore + priorityDisturbance;
      print ('Average: ' + ((priorityDisturbance + 0.9) / i).round().toString() + 'Disturbance: ' + priorityDisturbance.toString() + ', Counter: ' + i.toString() + ' PriorityRisk ' + priorityRiskScore.toString());
      i = 0;

      // Exposure
      if (priorityExposureOccupants != null) {
        priorityExposure = priorityExposure + priorityExposureOccupants;
        i = i + 1;
      }
      if (priorityExposureUseFreq != null) {
        priorityExposure = priorityExposure + priorityExposureUseFreq;
        i = i + 1;
      }
      if (priorityExposureAvgTime != null) {
        priorityExposure = priorityExposure + priorityExposureAvgTime;
        i = i + 1;
      }
      if (i == 0) {
        i = 1;
        priorityRiskSet = false;
      }
    (i > 1) ? priorityRiskScore = priorityRiskScore + ((priorityExposure + 0.9) / i).round() : priorityRiskScore = priorityRiskScore + priorityExposure;
      print ('Average: ' + ((priorityExposure + 0.9) / i).round().toString() + 'Exposure: ' + priorityExposure.toString() + ', Counter: ' + i.toString() + ' PriorityRisk ' + priorityRiskScore.toString());
      i = 0;

      // Maint
      if (priorityMaintType != null) {
        priorityMaint = priorityMaint + priorityMaintType;
        i = i + 1;
      }
      if (priorityMaintFreq != null) {
        priorityMaint = priorityMaint + priorityMaintFreq;
        i = i + 1;
      }
      if (i == 0) {
        i = 1;
        priorityRiskSet = false;
      }
    (i > 1) ? priorityRiskScore = priorityRiskScore + ((priorityMaint + 0.9) / i).round() : priorityRiskScore = priorityRiskScore + priorityMaint;
      print ('Average: ' + ((priorityMaint + 0.9) / i).round().toString() + 'Maint: ' + priorityMaint.toString() + ', Counter: ' + i.toString() + ' PriorityRisk ' + priorityRiskScore.toString());
      i = 0;

      if (priorityRiskScore > 9) {
        priorityRiskLevel = 3;
        priorityRiskText = 'High (' + priorityRiskScore.toString() + ')';
      } else if (priorityRiskScore > 6) {
        priorityRiskLevel = 2;
        priorityRiskText = 'Medium (' + priorityRiskScore.toString() + ')';
      } else if (priorityRiskScore > 3) {
        priorityRiskLevel = 1;
        priorityRiskText = 'Low (' + priorityRiskScore.toString() + ')';
      } else {
        priorityRiskLevel = 0;
        priorityRiskText = 'Very low (' + priorityRiskScore.toString() + ')';
      }

    int totalRiskScore;
    int totalRiskLevel;
    String totalRiskText;
    bool totalRiskSet;
    // Calculate total
    if (priorityRiskSet && materialRiskSet){
      totalRiskSet = true;
      totalRiskScore = priorityRiskScore + materialRiskScore;
      if (totalRiskScore > 18) {
        totalRiskLevel = 3;
        totalRiskText = 'High (' + totalRiskScore.toString() + ')';
      } else if (totalRiskScore > 12) {
        totalRiskLevel = 2;
        totalRiskText = 'Medium (' + totalRiskScore.toString() + ')';
      } else if (totalRiskScore > 6) {
        totalRiskLevel = 1;
        totalRiskText = 'Low (' + totalRiskScore.toString() + ')';
      } else {
        totalRiskLevel = 0;
        totalRiskText = 'Very low (' + totalRiskScore.toString() + ')';
      }
    } else totalRiskSet = false;

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

                              // SAMPLED/PRESUMED
                              new Row(
                                children: <Widget>[
                                new Expanded(child:
                                new SelectButton(
                                    onClick: () {
                                      // firestore change score
                                      setState(() {
                                        idKey = 'i';
                                        isSampled = true;
                                        Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                            {"idkey": 'i'}, merge: true);
                                      });
                                    },
                                    selected: idKey == 'i',
                                    text: 'Sampled',
//                                    tooltip: Tip.accessibility_easy
                                ),),
                                new Expanded(child:
                                new SelectButton(
                                  onClick: () {
                                    // firestore change score
                                    setState(() {
                                      idKey = stronglyPresumed ? 's' : 'p';
                                      isSampled = false;
                                      Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                          {"idkey": idKey}, merge: true);
                                    });
                                  },
                                  selected: idKey != 'i',
                                  text: presumedText,
//                                    tooltip: Tip.accessibility_easy
                                ),),
                              ],
                              ),

                              new Divider(),

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
                                  isSampled ?
                                  // SAMPLE NUMBER
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
                                  // PRESUMED/STRONGLY
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
//                             // DROPDOWN ROOM
                                  new Container(
                                    alignment: Alignment.topLeft,
                                    child: new DropdownButton<String>(
                                      // TODO change value to be room text and _room to be doc ID (e.g. map rooms)
                                      value: _room,
                                      items: roomlist.map((String value) {
                                        return new DropdownMenuItem<String>(
                                          value: value,
                                          child: new Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _room = value;
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"room": value}, merge: true);
                                        });
                                      },
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
//                                  Container(
//                                    alignment: Alignment.topLeft,
//                                    child: AutoCompleteTextField<String>(
//                                        decoration: new InputDecoration(
//                                            hintText: materialText,
//                                            labelText: "Material"
//
////                                        border: new OutlineInputBorder(
////                                            gapPadding: 0.0, borderRadius: new BorderRadius.circular(16.0)),
////                                        suffixIcon: new Icon(Icons.search)
//                                        ),
//                                        key: key,
//                                        suggestions: materials,
//                                        textChanged: (item) {
//                                          controllerMaterial.text = item;
//                                        },
//                                        itemBuilder: (context, item) {
//                                          return new Padding(
//                                              padding: EdgeInsets.all(8.0), child: new Text(item));
//                                        },
//                                        itemSorter: (a, b) {
//                                          return a.compareTo(b);
//                                        },
//                                        itemFilter: (item, query) {
//                                          return item.toLowerCase().contains(query.toLowerCase());
//                                        }),
//                                  ),
                                ],
                                )
                                ),)
                              ],
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: "Notes"),
                                  autocorrect: false,
                                  controller: controllerNotes,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                ),
                              ),

                              // Accessibility Section
                              new Container(alignment: Alignment.bottomLeft,
                                  height: 25.0,
                                  margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                  child: new Text('Accessibility', style: Styles.h3,)
                              ),
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
                                    tooltip: Tip.accessibility_easy
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
                                    tooltip: Tip.accessibility_medium
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
                                    tooltip: Tip.accessibility_difficult
                                ),),
                              ],
                              ),

                              // Material Section
                              new Divider(),
                              new Container(
                                  child: new Row(children: <Widget>[
                                    new Container(
                                        width: 200.0,
                                      child: Row(children: <Widget>[
                                    new Switch(
                                      value: showMaterialRisk,
                                      onChanged: (bool show) {
                                        setState(() {
                                          showMaterialRisk = show;
                                        });
                                      },
                                    ),
                                    new Text("Material Risk"),])
                                    ),
                                    new Container(
                                        width: 120.0,
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: ScoreButton(
                                          bordercolor: materialRiskSet ? Colors.black26 : Colors.white,
                                          onClick: () {},
                                          selected: true,
                                          score: materialRiskSet ? materialRiskLevel : -1,
                                          textcolor: Colors.black54,
                                          text: materialRiskSet? materialRiskText : 'Incomplete',
                                          radius: 0.0,
                                        )
                                    ),
                                  ],)
                              ),
                              showMaterialRisk ?
                              new Container(
                                  child: new Column(children: <Widget>[

                                    // PRODUCT SCORE

                                    new Container(alignment: Alignment.bottomLeft,
                                        height: 25.0,
                                        margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                        child: new Text('Product', style: Styles.h3,)
                                    ),
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
                                            if (materialProductScore == 1) { materialProductScore = null; }
                                            else { materialProductScore = 1; }
                                            Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                                {"materialrisk_productscore": materialProductScore}, merge: true);
                                          });
                                        },
                                        selected: materialProductScore == 1,
                                        score: 1,
                                        tooltip: Tip.material_product_1,
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
                                        tooltip: Tip.material_product_2,
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
                                        tooltip: Tip.material_product_3,
                                      ),),

                                    ],
                                    ),

                                    // DAMAGE SCORE

                                    new Container(alignment: Alignment.bottomLeft,
                                        height: 25.0,
                                        margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                        child: new Text('Damage', style: Styles.h3,)
                                    ),
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
                                        tooltip: Tip.material_damage_0,
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
                                        tooltip: Tip.material_damage_1,
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
                                        tooltip: Tip.material_damage_2,
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
                                        tooltip: Tip.material_damage_3,
                                      ),),

                                    ],
                                    ),

                                    // SURFACE SCORE

                                    new Container(alignment: Alignment.bottomLeft,
                                        height: 25.0,
                                        margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                        child: new Text('Surface', style: Styles.h3,)
                                    ),
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
                                        tooltip: Tip.material_surface_0,
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
                                        tooltip: Tip.material_surface_1,
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
                                        tooltip: Tip.material_surface_2,
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
                                        tooltip: Tip.material_surface_3,
                                      ),),

                                    ],
                                    ),

                                    // ASBESTOS SCORE

                                    new Container(alignment: Alignment.bottomLeft,
                                        height: 25.0,
                                        margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                        child: new Text('Asbestos Type', style: Styles.h3,)
                                    ),
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
                                        tooltip: Tip.material_asbestos_1,
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
                                        tooltip: Tip.material_asbestos_2,
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
                                        tooltip: Tip.material_asbestos_3,
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

                              // Priority Section
                              new Divider(),
                              new Container(
                                  child: new Row(children: <Widget>[
                                    new Container(
                                        width: 200.0,
                                        child: Row(children: <Widget>[
                                          new Switch(
                                            value: showPriorityRisk,
                                            onChanged: (bool show) {
                                              setState(() {
                                                showPriorityRisk = show;
                                              });
                                            },
                                          ),
                                          new Text("Priority Risk"),])
                                    ),
                                    new Container(
                                        width: 120.0,
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                                        child: ScoreButton(
                                          bordercolor: priorityRiskSet ? Colors.black26 : Colors.white,
                                          onClick: () {},
                                          selected: true,
                                          score: priorityRiskSet ? priorityRiskLevel : -1,
                                          textcolor: Colors.black54,
                                          text: priorityRiskSet ? priorityRiskText : 'Incomplete',
                                          radius: 0.0,
                                        )
                                    ),
                                  ],)
                              ),

                              showPriorityRisk ?
                              new Container(
                                child: new Column(children: <Widget>[
                                  // ACTIVITY

                                  // MAIN ACTIVITY
                                  new Container(alignment: Alignment.bottomLeft,
                                      height: 25.0,
                                      margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                      child: new Text('Main Activity', style: Styles.h3,)
                                  ),
                                  new Row(children: <Widget>[
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityActivityMain == 0) { priorityActivityMain = null; }
                                          else { priorityActivityMain = 0; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_activity_main": priorityActivityMain}, merge: true);
                                        });
                                      },
                                      selected: priorityActivityMain == 0,
                                      score: 0,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityActivityMain == 1) { priorityActivityMain = null; }
                                          else { priorityActivityMain = 1; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_activity_main": priorityActivityMain}, merge: true);
                                        });
                                      },
                                      selected: priorityActivityMain == 1,
                                      score: 1,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityActivityMain == 2) { priorityActivityMain = null; }
                                          else { priorityActivityMain = 2; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_activity_main": priorityActivityMain}, merge: true);
                                        });
                                      },
                                      selected: priorityActivityMain == 2,
                                      score: 2,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityActivityMain == 3) { priorityActivityMain = null; }
                                          else { priorityActivityMain = 3; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_activity_main": priorityActivityMain}, merge: true);
                                        });
                                      },
                                      selected: priorityActivityMain == 3,
                                      score: 3,
                                    ),),

                                  ],
                                  ),

                                  // SECOND ACTIVITY
                                  new Container(alignment: Alignment.bottomLeft,
                                      height: 25.0,
                                      margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                      child: new Text('Secondary Activity', style: Styles.h3,)
                                  ),
                                  new Row(children: <Widget>[
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityActivitySecond == 0) { priorityActivitySecond = null; }
                                          else { priorityActivitySecond = 0; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_activity_second": priorityActivitySecond}, merge: true);
                                        });
                                      },
                                      selected: priorityActivitySecond == 0,
                                      score: 0,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityActivitySecond == 1) { priorityActivitySecond = null; }
                                          else { priorityActivitySecond = 1; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_activity_second": priorityActivitySecond}, merge: true);
                                        });
                                      },
                                      selected: priorityActivitySecond == 1,
                                      score: 1,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityActivitySecond == 2) { priorityActivitySecond = null; }
                                          else { priorityActivitySecond = 2; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_activity_second": priorityActivitySecond}, merge: true);
                                        });
                                      },
                                      selected: priorityActivitySecond == 2,
                                      score: 2,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityActivitySecond == 3) { priorityActivitySecond = null; }
                                          else { priorityActivitySecond = 3; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_activity_second": priorityActivitySecond}, merge: true);
                                        });
                                      },
                                      selected: priorityActivitySecond == 3,
                                      score: 3,
                                    ),),

                                  ],
                                  ),

                                  new Divider(),

                                  // LOCATION
                                  new Container(alignment: Alignment.bottomLeft,
                                      height: 25.0,
                                      margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                      child: new Text('Location', style: Styles.h3,)
                                  ),
                                  new Row(children: <Widget>[
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceLocation == 0) { priorityDisturbanceLocation = null; }
                                          else { priorityDisturbanceLocation = 0; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_location": priorityDisturbanceLocation}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceLocation == 0,
                                      score: 0,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceLocation == 1) { priorityDisturbanceLocation = null; }
                                          else { priorityDisturbanceLocation = 1; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_location": priorityDisturbanceLocation}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceLocation == 1,
                                      score: 1,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceLocation == 2) { priorityDisturbanceLocation = null; }
                                          else { priorityDisturbanceLocation = 2; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_location": priorityDisturbanceLocation}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceLocation == 2,
                                      score: 2,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceLocation == 3) { priorityDisturbanceLocation = null; }
                                          else { priorityDisturbanceLocation = 3; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_location": priorityDisturbanceLocation}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceLocation == 3,
                                      score: 3,
                                    ),),

                                  ],
                                  ),

                                  // ACCESS
                                  new Container(alignment: Alignment.bottomLeft,
                                      height: 25.0,
                                      margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                      child: new Text('Accessibility', style: Styles.h3,)
                                  ),
                                  new Row(children: <Widget>[
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceAccessibility == 0) { priorityDisturbanceAccessibility = null; }
                                          else { priorityDisturbanceAccessibility = 0; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_accessibility": priorityDisturbanceAccessibility}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceAccessibility == 0,
                                      score: 0,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceAccessibility == 1) { priorityDisturbanceAccessibility = null; }
                                          else { priorityDisturbanceAccessibility = 1; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_accessibility": priorityDisturbanceAccessibility}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceAccessibility == 1,
                                      score: 1,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceAccessibility == 2) { priorityDisturbanceAccessibility = null; }
                                          else { priorityDisturbanceAccessibility = 2; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_accessibility": priorityDisturbanceAccessibility}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceAccessibility == 2,
                                      score: 2,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceAccessibility == 3) { priorityDisturbanceAccessibility = null; }
                                          else { priorityDisturbanceAccessibility = 3; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_accessibility": priorityDisturbanceAccessibility}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceAccessibility == 3,
                                      score: 3,
                                    ),),

                                  ],
                                  ),

                                  //EXTENT
                                  new Container(alignment: Alignment.bottomLeft,
                                      height: 25.0,
                                      margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                      child: new Text('Extent', style: Styles.h3,)
                                  ),
                                  new Row(children: <Widget>[
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceExtent == 0) { priorityDisturbanceExtent = null; }
                                          else { priorityDisturbanceExtent = 0; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_extent": priorityDisturbanceExtent}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceExtent == 0,
                                      score: 0,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceExtent == 1) { priorityDisturbanceExtent = null; }
                                          else { priorityDisturbanceExtent = 1; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_extent": priorityDisturbanceExtent}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceExtent == 1,
                                      score: 1,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceExtent == 2) { priorityDisturbanceExtent = null; }
                                          else { priorityDisturbanceExtent = 2; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_extent": priorityDisturbanceExtent}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceExtent == 2,
                                      score: 2,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityDisturbanceExtent == 3) { priorityDisturbanceExtent = null; }
                                          else { priorityDisturbanceExtent = 3; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_disturbance_extent": priorityDisturbanceExtent}, merge: true);
                                        });
                                      },
                                      selected: priorityDisturbanceExtent == 3,
                                      score: 3,
                                    ),),

                                  ],
                                  ),

                                  new Divider(),

                                  //OCCUPANTS
                                  new Container(alignment: Alignment.bottomLeft,
                                      height: 25.0,
                                      margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                      child: new Text('Occupants', style: Styles.h3,)
                                  ),
                                  new Row(children: <Widget>[
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureOccupants == 0) { priorityExposureOccupants = null; }
                                          else { priorityExposureOccupants = 0; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_occupants": priorityExposureOccupants}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureOccupants == 0,
                                      score: 0,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureOccupants == 1) { priorityExposureOccupants = null; }
                                          else { priorityExposureOccupants = 1; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_occupants": priorityExposureOccupants}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureOccupants == 1,
                                      score: 1,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureOccupants == 2) { priorityExposureOccupants = null; }
                                          else { priorityExposureOccupants = 2; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_occupants": priorityExposureOccupants}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureOccupants == 2,
                                      score: 2,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureOccupants == 3) { priorityExposureOccupants = null; }
                                          else { priorityExposureOccupants = 3; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_occupants": priorityExposureOccupants}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureOccupants == 3,
                                      score: 3,
                                    ),),

                                  ],
                                  ),

                                  //USEFREQ
                                  new Container(alignment: Alignment.bottomLeft,
                                      height: 25.0,
                                      margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                      child: new Text('Use Frequency', style: Styles.h3,)
                                  ),
                                  new Row(children: <Widget>[
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureUseFreq == 0) { priorityExposureUseFreq = null; }
                                          else { priorityExposureUseFreq = 0; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_usefreq": priorityExposureUseFreq}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureUseFreq == 0,
                                      score: 0,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureUseFreq == 1) { priorityExposureUseFreq = null; }
                                          else { priorityExposureUseFreq = 1; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_usefreq": priorityExposureUseFreq}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureUseFreq == 1,
                                      score: 1,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureUseFreq == 2) { priorityExposureUseFreq = null; }
                                          else { priorityExposureUseFreq = 2; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_usefreq": priorityExposureUseFreq}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureUseFreq == 2,
                                      score: 2,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureUseFreq == 3) { priorityExposureUseFreq = null; }
                                          else { priorityExposureUseFreq = 3; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_usefreq": priorityExposureUseFreq}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureUseFreq == 3,
                                      score: 3,
                                    ),),

                                  ],
                                  ),

                                  //AVG TIME
                                  new Container(alignment: Alignment.bottomLeft,
                                      height: 25.0,
                                      margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                      child: new Text('Average Time', style: Styles.h3,)
                                  ),
                                  new Row(children: <Widget>[
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureAvgTime == 0) { priorityExposureAvgTime = null; }
                                          else { priorityExposureAvgTime = 0; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_avgtime": priorityExposureAvgTime}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureAvgTime == 0,
                                      score: 0,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureAvgTime == 1) { priorityExposureAvgTime = null; }
                                          else { priorityExposureAvgTime = 1; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_avgtime": priorityExposureAvgTime}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureAvgTime == 1,
                                      score: 1,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureAvgTime == 2) { priorityExposureAvgTime = null; }
                                          else { priorityExposureAvgTime = 2; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_avgtime": priorityExposureAvgTime}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureAvgTime == 2,
                                      score: 2,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityExposureAvgTime == 3) { priorityExposureAvgTime = null; }
                                          else { priorityExposureAvgTime = 3; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_exposure_avgtime": priorityExposureAvgTime}, merge: true);
                                        });
                                      },
                                      selected: priorityExposureAvgTime == 3,
                                      score: 3,
                                    ),),

                                  ],
                                  ),

                                  new Divider(),

                                  //MAINT TYPE
                                  new Container(alignment: Alignment.bottomLeft,
                                      height: 25.0,
                                      margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                      child: new Text('Maintenance Type', style: Styles.h3,)
                                  ),
                                  new Row(children: <Widget>[
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityMaintType == 0) { priorityMaintType = null; }
                                          else { priorityMaintType = 0; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_maint_type": priorityMaintType}, merge: true);
                                        });
                                      },
                                      selected: priorityMaintType == 0,
                                      score: 0,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityMaintType == 1) { priorityMaintType = null; }
                                          else { priorityMaintType = 1; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_maint_type": priorityMaintType}, merge: true);
                                        });
                                      },
                                      selected: priorityMaintType == 1,
                                      score: 1,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityMaintType == 2) { priorityMaintType = null; }
                                          else { priorityMaintType = 2; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_maint_type": priorityMaintType}, merge: true);
                                        });
                                      },
                                      selected: priorityMaintType == 2,
                                      score: 2,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityMaintType == 3) { priorityMaintType = null; }
                                          else { priorityMaintType = 3; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_maint_type": priorityMaintType}, merge: true);
                                        });
                                      },
                                      selected: priorityMaintType == 3,
                                      score: 3,
                                    ),),

                                  ],
                                  ),

                                  // MAINT FREQ
                                  new Container(alignment: Alignment.bottomLeft,
                                      height: 25.0,
                                      margin: EdgeInsets.only(left: 12.0, bottom: 2.0),
                                      child: new Text('Maintenance Frequency', style: Styles.h3,)
                                  ),
                                  new Row(children: <Widget>[
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityMaintFreq == 0) { priorityMaintFreq = null; }
                                          else { priorityMaintFreq = 0; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_maint_freq": priorityMaintFreq}, merge: true);
                                        });
                                      },
                                      selected: priorityMaintFreq == 0,
                                      score: 0,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityMaintFreq == 1) { priorityMaintFreq = null; }
                                          else { priorityMaintFreq = 1; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_maint_freq": priorityMaintFreq}, merge: true);
                                        });
                                      },
                                      selected: priorityMaintFreq == 1,
                                      score: 1,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityMaintFreq == 2) { priorityMaintFreq = null; }
                                          else { priorityMaintFreq = 2; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_maint_freq": priorityMaintFreq}, merge: true);
                                        });
                                      },
                                      selected: priorityMaintFreq == 2,
                                      score: 2,
                                    ),),
                                    new Expanded(child:
                                    new ScoreButton(
                                      onClick: () {
                                        // firestore change score
                                        setState(() {
                                          if (priorityMaintFreq == 3) { priorityMaintFreq = null; }
                                          else { priorityMaintFreq = 3; }
                                          Firestore.instance.collection('samplesasbestosbulk').document(sample).setData(
                                              {"priority_maint_freq": priorityMaintFreq}, merge: true);
                                        });
                                      },
                                      selected: priorityMaintFreq == 3,
                                      score: 3,
                                    ),),

                                  ],
                                  ),
                                ]),
                              )
                                  : new Container(),
                              new Divider(),

                              // Total Risk
                              new Container(
                                  width: 120.0,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                                  child: ScoreButton(
                                    bordercolor: totalRiskSet ? Colors.black26 : Colors.white,
                                    onClick: () {},
                                    selected: true,
                                    score: totalRiskSet ? totalRiskLevel : -1,
                                    textcolor: Colors.black54,
                                    text: totalRiskSet ? totalRiskText : 'Incomplete',
                                    radius: 0.0,
                                  )
                              ),
                            ],)
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

    if (sample == null) {
      _title = "Add New ACM";
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
      _title = "Edit ACM";
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
        _room = doc.data['room'];
        controllerDescription.text = doc.data['description'];
//        materialText = doc.data['material'];
        controllerMaterial.text = doc.data['material'];
        controllerNotes.text = doc.data['notes'];

        accessibilityScore = doc.data['accessibility'];

        // Material Risk assessment
        materialProductScore = doc.data['materialrisk_productscore'];
        materialDamageScore = doc.data['materialrisk_damagescore'];
        materialSurfaceScore = doc.data['materialrisk_surfacescore'];
        materialAsbestosScore = doc.data['materialrisk_asbestosscore'];
        controllerDamageDesc.text = doc.data['materialrisk_damagedesc'];
        controllerSurfaceDesc.text = doc.data['materialrisk_surfacedesc'];

        // Priority Risk Assessment
        priorityActivityMain = doc.data['priority_activity_main'];
        priorityActivitySecond = doc.data['priority_activity_second'];
        priorityDisturbanceLocation = doc.data['priority_disturbance_location'];
        priorityDisturbanceAccessibility = doc.data['priority_disturbance_accessibility'];
        priorityDisturbanceExtent = doc.data['priority_disturbance_extent'];
        priorityExposureOccupants = doc.data['priority_exposure_occupants'];
        priorityExposureUseFreq = doc.data['priority_exposure_usefreq'];
        priorityExposureAvgTime = doc.data['priority_exposure_avgtime'];
        priorityMaintType = doc.data['priority_maint_type'];
        priorityMaintFreq = doc.data['priority_maint_freq'];

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