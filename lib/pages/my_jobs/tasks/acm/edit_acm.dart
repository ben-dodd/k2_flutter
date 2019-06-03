import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/pages/my_jobs/tasks/acm/acm_widgets.dart';
import 'package:k2e/pages/my_jobs/tasks/coc/assign_sample_number.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/tooltips.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/utils/common_functions.dart';
import 'package:k2e/utils/firebase_conversion_functions.dart';
import 'package:k2e/utils/sample_painter.dart';
import 'package:k2e/widgets/buttons.dart';
import 'package:k2e/widgets/common_widgets.dart';
import 'package:k2e/widgets/custom_typeahead.dart';
import 'package:uuid/uuid.dart';

class EditACM extends StatefulWidget {
  EditACM({Key key, this.acm}) : super(key: key);
  final String acm;
  @override
  _EditACMState createState() => new _EditACMState();
}

class _EditACMState extends State<EditACM> {
  // TITLE
  String _title;

  // DOCUMENT IDS
  DocumentReference sample;
  DocumentReference acm;
  final Map constants = DataManager.get().constants;
  Map<String, String> _room;
  List<List<Offset>> arrowPaths = new List<List<Offset>>();
  List<List<Offset>> shadePaths = new List<List<Offset>>();
  List<Offset>
      offsetPoints; //List of points in one Tap or ery point or path is kept here

  Map<String, dynamic> acmObj = new Map<String, dynamic>();

  var _formKey = GlobalKey<FormState>();
  // Create list of focus nodes
  final _focusNodes = List<FocusNode>.generate(
    9,
    (i) => FocusNode(),
  );

  // UI STATE
  bool isLoading = true;
  bool isSampled = false;
  bool stronglyPresumed = false;
  String presumedText = 'Presumed';
  List<Map<String, String>> roomlist = new List();
  List<Map<String, String>> samplelist = new List();
  bool showMaterialRisk = true;
  bool showPriorityRisk = false;
  bool arrowOn = false;
  bool shadeOn = false;

  ScrollController _scrollController;

  // GENERAL INFO
  final controllerSampleNumber = TextEditingController();
  final controllerNotes = TextEditingController();

  // IMAGES
  bool localPhoto = false;

  // MATERIAL AUTOCOMPLETE
  List materials;
  final TextEditingController _materialController = TextEditingController();
  List items;
  final TextEditingController _itemController = TextEditingController();
  List damage;
  final TextEditingController _damageController = TextEditingController();
  List surface;
  final TextEditingController _surfaceController = TextEditingController();
  List extent;
  final TextEditingController _extentController = TextEditingController();
  List whynotsampled;
  final TextEditingController _whynotController = TextEditingController();

//  String initialDescription;
//  String initialMaterial;
//  String initialDamage;
//  String initialSurface;

  @override
  void initState() {
    // set paths
    if (widget.acm != null) {
      acm = Firestore.instance
          .document(DataManager.get().currentJobPath)
          .collection('acm')
          .document(widget.acm);
      _title = "Edit ACM";
    } else {
      _title = "Add New ACM";
    }
    _loadACM();
    materials = constants['asbestosmaterials'];
    items = constants['buildingitems'];
    damage = constants['damagesuggestions'];
    surface = constants['surfacesuggestions'];
    extent = constants['extentsuggestions'];
    whynotsampled = constants['whynotsampledsuggestions'];

    super.initState();
  }

  Widget build(BuildContext context) {
    // Calculate material totals
    var totals = _calculateMaterialTotals();

    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
          title: Text(_title),
          leading: new IconButton(
            icon: new Icon(Icons.clear),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    acmObj['riskTotals'] = _calculateMaterialTotals();
                    if (arrowPaths.length > 0) {
                      // Convert List of Lists of Offsets into a format Firebase can store
                      // Firebase can't do Lists of Lists
                      acmObj['arrowPaths'] =
                          convertListListOffsetToFirestore(arrowPaths);
                    }

                    Firestore.instance
                        .document(DataManager.get().currentJobPath)
                        .collection('acm')
                        .document(widget.acm)
                        .setData(acmObj, merge: true);
                    Navigator.pop(context);
                  }
                })
          ]),
      body: isLoading
          ? LoadingPage(loadingText: 'Loading ACM...')
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    padding: new EdgeInsets.all(8.0),
                    children: <Widget>[
                      _acmPhoto(),
                      _sampleTypeSelectors(),

                      // Add sample number if sampled

                      acmObj['idkey'] == 'i'
                          ? new Container(
                              margin: EdgeInsets.only(left: 54.0, right: 54.0),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                      child: new Column(children: <Widget>[
                                    new Container(
                                        padding: new EdgeInsets.only(top: 14.0),
                                        child: new Text(
                                          acmObj['sampleNumber'] != null
                                              ? 'Sample ' +
                                                  acmObj['sampleNumber']
                                              : 'Sample Number Not Assigned',
                                          style: Styles.sampleNumber,
                                        )),
                                    new Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(
                                        top: 14.0,
                                      ),
                                      child: new ToolTipButton(
                                          text: "Assign Sample Number",
                                          tooltip: Tip.assignSample,
                                          onClick: () {
                                            Navigator.of(context).push(
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      AssignSampleNumber(
                                                          acm: acmObj)),
                                            );
                                          }),
                                    )
                                  ]))
                                ],
                              ))
                          : new Container(),

                      // Add option to presume as if strongly presumed
                      acmObj['idkey'] == 's'
                          ? new Container(
                              margin: EdgeInsets.only(left: 54.0, right: 54.0),
                              child: new Row(
                                children: <Widget>[
                                  new Expanded(
                                      child: new Column(children: <Widget>[
                                    acmObj['sampleNumber'] != null
                                        ? new Container(
                                            child: new Text('Sample as ' +
                                                acmObj['sampleNumber']))
                                        : new Container(),
                                    new Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(
                                        top: 14.0,
                                      ),
                                      child: new ToolTipButton(
                                          text: "Presume As Sample",
                                          tooltip: Tip.presumeAs,
                                          onClick: () {
                                            Navigator.of(context).push(
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      AssignSampleNumber(
                                                          acm: acmObj)),
                                            );
                                          }),
                                    )
                                  ]))
                                ],
                              ))
                          : new Container(),
                      new Container(
                          padding: EdgeInsets.only(top: 14.0),
                          child: new Container()),
                      ExpansionTile(
                        title: new Text(
                          "General Information",
                          style: Styles.h2,
                        ),
                        initiallyExpanded: true,
                        children: <Widget>[
                          new Container(
                            alignment: Alignment.topLeft,
                            child: new Text(
                              "Room Name",
                              style: Styles.label,
                            ),
                          ),
                          new Container(
                            alignment: Alignment.topLeft,
                            child: DropdownButton<String>(
                              value: (_room == null) ? null : _room['path'],
                              iconSize: 24.0,
                              items: roomlist.map((Map<String, String> room) {
                                String val = "Untitled";
                                if (room['name'] != null &&
                                    room['roomcode'] != null) {
                                  val = room['name'] +
                                      "(" +
                                      room['roomcode'] +
                                      ")";
                                } else if (room['name'] != null) {
                                  val = room['name'];
                                } else if (room['roomcode'] != null) {
                                  val = room['roomcode'];
                                }
                                return new DropdownMenuItem<String>(
                                  value: room["path"],
                                  child: new Text(val),
                                );
                              }).toList(),
                              hint: Text("Room"),
                              onChanged: (value) {
                                setState(() {
                                  _room = roomlist
                                      .firstWhere((e) => e['path'] == value);
                                  acmObj["roompath"] = _room["path"];
                                  acmObj["roomname"] = _room["name"];
                                  DataManager.get().currentRoom = _room['path'];
                                  //                              acm.setData({"room": _room}, merge: true);
                                });
                              },
                            ),
                          ),
                          CustomTypeAhead(
                            controller: _itemController,
//                              initialValue: acmObj['description'],
                            capitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            label: 'Description/Item',
                            suggestions: items,
                            onSaved: (value) =>
                                acmObj['description'] = value.trim(),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'The description cannot be empty';
                              }
                            },
                            focusNode: _focusNodes[0],
                            onSuggestionSelected: (suggestion) {
                              _itemController.text = suggestion['label'];
                              FocusScope.of(context)
                                  .requestFocus(_focusNodes[1]);
                            },
                            onSubmitted: (v) {
                              FocusScope.of(context)
                                  .requestFocus(_focusNodes[1]);
                            },
                          ),
                          CustomTypeAhead(
                            controller: _materialController,
//                              initialValue: acmObj['material'],
                            capitalization: TextCapitalization.none,
                            textInputAction: TextInputAction.next,
                            label: 'Material',
                            suggestions: materials,
                            onSaved: (value) =>
                                acmObj['material'] = value.trim(),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'The material cannot be empty';
                              }
                            },
                            focusNode: _focusNodes[1],
                            nextFocus: _focusNodes[2],
                          ),
                        ],
                      ),
                      ExpansionTile(
                          title: new Text(
                            "Extent",
                            style: Styles.h2,
                          ),
                          initiallyExpanded: true,
                          children: <Widget>[
                            CustomTypeAhead(
                              controller: _extentController,
//                          initialValue: acmObj['extentdesc'],
                              capitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.next,
                              label: 'Extent Description',
                              suggestions: extent,
                              onSaved: (value) =>
                                  acmObj['extentdesc'] = value.trim(),
                              validator: (value) {},
                              focusNode: _focusNodes[2],
                              nextFocus: _focusNodes[3],
                            ),
                            new Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  new Container(
                                    width: 100.0,
                                    child: new TextFormField(
                                      decoration: new InputDecoration(
                                          labelText: "Extent"),
                                      onSaved: (String value) {
                                        acmObj["extent"] = value.trim();
                                      },
                                      validator: (String value) {
                                        //                            return value.isEmpty ? 'The material cannot be empty.' : null;
                                      },
                                      focusNode: _focusNodes[3],
                                      initialValue: acmObj["extent"],
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,
                                      autocorrect: false,
                                      onFieldSubmitted: (v) {
                                        FocusScope.of(context)
                                            .requestFocus(_focusNodes[4]);
                                      },
                                    ),
                                  ),
                                  new Container(
                                    width: 100.0,
//                            padding: EdgeInsets.only(top: 14.0),
                                    child: DropdownButton<String>(
                                      value: (acmObj["extentunits"] == null)
                                          ? "m\u00B2"
                                          : acmObj["extentunits"],
                                      iconSize: 24.0,
                                      items: [
                                        "m\u00B2",
                                        "m",
                                        "lm",
                                        "m\u00B3",
                                        "items",
                                      ].map((unit) {
                                        return new DropdownMenuItem<String>(
                                          value: unit,
                                          child: new Text(unit),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          acmObj["extentunits"] = value;
                                          print(acmObj["extentunits"]);
                                          //                              acm.setData({"room": _room}, merge: true);
                                        });
                                      },
                                    ),
                                  ),
                                ]),
                          ]),

                      ExpansionTile(
                          title: new Text(
                            "Condition",
                            style: Styles.h2,
                          ),
                          initiallyExpanded: true,
                          children: <Widget>[
                            CustomTypeAhead(
                              controller: _damageController,
//                            initialValue: acmObj['materialrisk_damagedesc'],
                              capitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.next,
                              label: 'Damage Description',
                              suggestions: damage,
                              onSaved: (value) =>
                                  acmObj['materialrisk_damagedesc'] =
                                      value.trim(),
                              validator: (value) {},
                              focusNode: _focusNodes[4],
                              nextFocus: _focusNodes[5],
                            ),
                            CustomTypeAhead(
                              controller: _surfaceController,
//                            initialValue: acmObj['materialrisk_surfacedesc'],
                              capitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              label: 'Surface Treatment',
                              suggestions: surface,
                              onSaved: (value) =>
                                  acmObj['materialrisk_surfacedesc'] =
                                      value.trim(),
                              validator: (value) {},
                              focusNode: _focusNodes[5],
                              nextFocus:
                                  isSampled ? _focusNodes[7] : _focusNodes[6],
                            ),
                          ]),

                      ExpansionTile(
                          title: new Text(
                            "Notes",
                            style: Styles.h2,
                          ),
                          initiallyExpanded: true,
                          children: <Widget>[
                            !isSampled
                                ? CustomTypeAhead(
                                    controller: _whynotController,
//                          initialValue: acmObj['reasonfornotsampling'],
                                    capitalization:
                                        TextCapitalization.sentences,
                                    textInputAction: TextInputAction.next,
                                    label: 'Reason for Not Sampling',
                                    suggestions: whynotsampled,
                                    onSaved: (value) =>
                                        acmObj['reasonfornotsampling'] = value,
                                    validator: (value) {},
                                    focusNode: _focusNodes[6],
                                    nextFocus: _focusNodes[7],
                                  )
                                : new Container(),
                            new Container(
                                alignment: Alignment.topLeft,
                                child: new TextFormField(
                                  decoration:
                                      new InputDecoration(labelText: "Notes"),
                                  onSaved: (String value) {
                                    acmObj["notes"] = value.trim();
                                  },
                                  focusNode: _focusNodes[7],
                                  initialValue: acmObj["notes"],
                                  textInputAction: TextInputAction.done,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  keyboardType: TextInputType.multiline,
                                  autocorrect: true,
                                  maxLines: null,
                                )),
                          ]),
                      ExpansionTile(
                          title: new Text(
                            "Risk Assessments",
                            style: Styles.h2,
                          ),
                          initiallyExpanded: true,
                          children: <Widget>[
                            // Accessibility Section
                            HeaderText(text: 'Accessibility'),
                            _getScoreSet(
                              acmObjVar: 'accessibility',
                              tooltip1: Tip.accessibility_easy,
                              tooltip2: Tip.accessibility_medium,
                              tooltip3: Tip.accessibility_difficult,
                              text1: 'Easy',
                              text2: 'Medium',
                              text3: 'Difficult',
                              showZero: false,
                            ),

                            // Material Section
                            new Divider(),
                            new Container(
                                child: new Row(
                              children: <Widget>[
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
                                      new Text("Material Risk"),
                                    ])),
                                new Container(
                                    width: 120.0,
                                    alignment: Alignment.centerRight,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    child: ScoreButton(
                                      bordercolor: totals['materialRiskSet']
                                          ? Colors.black26
                                          : Colors.white,
                                      onClick: () {},
                                      selected: true,
                                      score: totals['materialRiskSet']
                                          ? totals['materialRiskLevel']
                                          : -1,
                                      textcolor: Colors.black54,
                                      text: totals['materialRiskSet']
                                          ? totals['materialRiskText']
                                          : 'Incomplete',
                                      radius: 0.0,
                                    )),
                              ],
                            )),
                            showMaterialRisk
                                ? new Container(
                                    child: new Column(
                                    children: <Widget>[
                                      // PRODUCT SCORE

                                      HeaderText(text: 'Product'),
                                      _getScoreSet(
                                        acmObjVar: 'materialrisk_productscore',
                                        tooltip1: Tip.material_product_1,
                                        tooltip2: Tip.material_product_2,
                                        tooltip3: Tip.material_product_3,
                                        disabledZero: true,
                                      ),

                                      // DAMAGE SCORE

                                      HeaderText(text: 'Damage'),
                                      _getScoreSet(
                                        acmObjVar: 'materialrisk_damagescore',
                                        tooltip0: Tip.material_damage_0,
                                        tooltip1: Tip.material_damage_1,
                                        tooltip2: Tip.material_damage_2,
                                        tooltip3: Tip.material_damage_3,
                                      ),

                                      // SURFACE SCORE

                                      HeaderText(text: 'Surface'),
                                      _getScoreSet(
                                        acmObjVar: 'materialrisk_surfacescore',
                                        tooltip0: Tip.material_surface_0,
                                        tooltip1: Tip.material_surface_1,
                                        tooltip2: Tip.material_surface_2,
                                        tooltip3: Tip.material_surface_3,
                                      ),

                                      // ASBESTOS SCORE

                                      HeaderText(text: 'Asbestos Type'),
                                      _getScoreSet(
                                        acmObjVar: 'materialrisk_asbestosscore',
                                        tooltip1: Tip.material_asbestos_1,
                                        tooltip2: Tip.material_asbestos_2,
                                        tooltip3: Tip.material_asbestos_3,
                                        disabledZero: true,
                                      ),
                                    ],
                                  ))
                                : Container(),

                            // Priority Section
                            new Divider(),
                            new Container(
                                child: new Row(
                              children: <Widget>[
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
                                      new Text("Priority Risk"),
                                    ])),
                                new Container(
                                    width: 120.0,
                                    alignment: Alignment.centerRight,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    child: ScoreButton(
                                      bordercolor: totals['priorityRiskSet']
                                          ? Colors.black26
                                          : Colors.white,
                                      onClick: () {},
                                      selected: true,
                                      score: totals['priorityRiskSet']
                                          ? totals['priorityRiskLevel']
                                          : -1,
                                      textcolor: Colors.black54,
                                      text: totals['priorityRiskSet']
                                          ? totals['priorityRiskText']
                                          : 'Incomplete',
                                      radius: 0.0,
                                    )),
                              ],
                            )),

                            showPriorityRisk
                                ? new Container(
                                    child: new Column(children: <Widget>[
                                      // ACTIVITY

                                      // MAIN ACTIVITY
                                      HeaderText(text: 'Main Activity'),
                                      _getScoreSet(
                                        acmObjVar: 'priority_activity_main',
                                        tooltip0: Tip.priority_activity_main_0,
                                        tooltip1: Tip.priority_activity_main_1,
                                        tooltip2: Tip.priority_activity_main_2,
                                        tooltip3: Tip.priority_activity_main_3,
                                      ),

                                      // SECOND ACTIVITY
                                      HeaderText(text: 'Secondary Activity'),
                                      _getScoreSet(
                                        acmObjVar: 'priority_activity_second',
                                        tooltip0: Tip.priority_activity_secondary_0,
                                        tooltip1: Tip.priority_activity_secondary_1,
                                        tooltip2: Tip.priority_activity_secondary_2,
                                        tooltip3: Tip.priority_activity_secondary_3,
                                      ),

                                      new Divider(),

                                      // LOCATION
                                      HeaderText(text: 'Location'),
                                      _getScoreSet(
                                        acmObjVar: 'priority_disturbance_location',
                                        tooltip0: Tip.priority_disturbance_location_0,
                                        tooltip1: Tip.priority_disturbance_location_1,
                                        tooltip2: Tip.priority_disturbance_location_2,
                                        tooltip3: Tip.priority_disturbance_location_3,
                                      ),

                                      // ACCESS
                                      HeaderText(text: 'Accessibility'),
                                      _getScoreSet(
                                        acmObjVar: 'priority_disturbance_accessibility',
                                        tooltip0: Tip.priority_disturbance_accessibility_0,
                                        tooltip1: Tip.priority_disturbance_accessibility_1,
                                        tooltip2: Tip.priority_disturbance_accessibility_2,
                                        tooltip3: Tip.priority_disturbance_accessibility_3,
                                      ),

                                      //EXTENT
                                      HeaderText(text: 'Extent'),
                                      _getScoreSet(
                                        acmObjVar: 'priority_disturbance_extent',
                                        tooltip0: Tip.priority_disturbance_extent_0,
                                        tooltip1: Tip.priority_disturbance_extent_1,
                                        tooltip2: Tip.priority_disturbance_extent_2,
                                        tooltip3: Tip.priority_disturbance_extent_3,
                                      ),

                                      new Divider(),

                                      //OCCUPANTS
                                      HeaderText(text: 'Occupants'),
                                      _getScoreSet(
                                        acmObjVar: 'priority_exposure_occupants',
                                        tooltip0: Tip.priority_exposure_occupants_0,
                                        tooltip1: Tip.priority_exposure_occupants_1,
                                        tooltip2: Tip.priority_exposure_occupants_2,
                                        tooltip3: Tip.priority_exposure_occupants_3,
                                      ),

                                      //USEFREQ
                                      HeaderText(text: 'Use Frequency'),
                                      _getScoreSet(
                                        acmObjVar: 'priority_exposure_usefreq',
                                        tooltip0: Tip.priority_exposure_usefreq_0,
                                        tooltip1: Tip.priority_exposure_usefreq_1,
                                        tooltip2: Tip.priority_exposure_usefreq_2,
                                        tooltip3: Tip.priority_exposure_usefreq_3,
                                      ),

                                      //AVG TIME
                                      HeaderText(text: 'Average Time'),
                                      _getScoreSet(
                                        acmObjVar: 'priority_exposure_avgtime',
                                        tooltip0: Tip.priority_exposure_avgtime_0,
                                        tooltip1: Tip.priority_exposure_avgtime_1,
                                        tooltip2: Tip.priority_exposure_avgtime_2,
                                        tooltip3: Tip.priority_exposure_avgtime_3,
                                      ),

                                      new Divider(),

                                      //MAINT TYPE
                                      HeaderText(text: 'Maintenance Type'),
                                      _getScoreSet(
                                        acmObjVar: 'priority_maint_type',
                                        tooltip0: Tip.priority_maint_type_0,
                                        tooltip1: Tip.priority_maint_type_1,
                                        tooltip2: Tip.priority_maint_type_2,
                                        tooltip3: Tip.priority_maint_type_3,
                                      ),

                                      // MAINT FREQ
                                      HeaderText(text: 'Maintenance Frequency'),
                                      _getScoreSet(
                                        acmObjVar: 'priority_maint_freq',
                                        tooltip0: Tip.priority_maint_freq_0,
                                        tooltip1: Tip.priority_maint_freq_1,
                                        tooltip2: Tip.priority_maint_freq_2,
                                        tooltip3: Tip.priority_maint_freq_3,
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
                                  bordercolor: totals['totalRiskSet']
                                      ? Colors.black26
                                      : Colors.white,
                                  onClick: () {},
                                  selected: true,
                                  score: totals['totalRiskSet'] ? totals['totalRiskLevel'] : -1,
                                  textcolor: Colors.black54,
                                  text: totals['totalRiskSet']
                                      ? totals['totalRiskText']
                                      : 'Incomplete',
                                  radius: 0.0,
                                )),
                          ]),
                      widget.acm != null
                          ? FunctionButton(
                        text: "Delete ACM",
                        onClick: () => deleteDialog(
                          title: 'Delete ACM',
                          query: 'Are you sure you wish to delete this ACM (' + acmObj['description'] + ' ' + acmObj['material'] + ')?',
                          docPath: Firestore.instance
                              .document(DataManager.get().currentJobPath)
                              .collection('acm')
                              .document(widget.acm),
                          imagePath: acmObj['storage_ref'] != null ? FirebaseStorage.instance.ref().child(acmObj['storage_ref']) : null,
                          context: context,
                        )
                      ) : new Container(),
                    ],
                  ))),
    );
  }

  void _loadACM() async {
    // Load rooms from job
    QuerySnapshot roomSnapshot = await Firestore.instance
        .document(DataManager.get().currentJobPath)
        .collection('rooms')
        .getDocuments();
    roomSnapshot.documents.forEach((doc) {
      if (doc['roomtype'] != 'group')
        roomlist.add({"name": doc.data['name'], "path": doc.documentID});
    });
//    print('ROOMLIST ' + roomlist.toString());

    // Load samples from job
    QuerySnapshot sampleSnapshot = await Firestore.instance
        .collection('lab')
        .document('asbestos')
        .collection('labs')
        .document('k2environmental')
        .collection('samples')
        .where('jobNumber', isEqualTo: DataManager.get().currentJobNumber)
        .orderBy("sampleNumber")
        .getDocuments();
    sampleSnapshot.documents.forEach((doc) => samplelist.add({
          "name": doc.data['sampleNumber'].toString() +
              ': ' +
              doc.data['description'],
          "path": doc.documentID
        }));
//    print('ROOMLIST ' + roomlist.toString());
//    print('SAMPLE ' + samplelist.toString());

//    roomlist = [{"name": "Lounge","path": "lounge"}];

    if (widget.acm == null) {
      String room = DataManager.get().currentRoom;
      if (room == null ||
          !roomlist.map((room) => room['path']).contains(room)) {
        room = '';
      } else {
        _room = {"path": room, "name": ''};
      }

      acmObj['jobNumber'] = DataManager.get().currentJobNumber;
      //      sample.sampleNumber = DataManager.get().getHighestSampleNumber(DataManager.get().currentJob) + 1;
      acmObj['sample'] = null;
      acmObj['idkey'] = 'p';
      acmObj['description'] = null;
      acmObj['material'] = null;
      acmObj['path_local'] = null;
      acmObj['path_remote'] = null;
      acmObj['roompath'] = room;
      acmObj['materialrisk_asbestosscore'] = 3;

      // New room requires us to create a path so it doesn't need internet to get one from Firestore
      acmObj['path'] = new Uuid().v1();
//      acmObj['arrowPaths'] = arrowPaths;
//      acmObj['shadePaths'] = new List<List<Offset>>();

      setState(() {
        isLoading = false;
      });
    } else {
      _title = "Edit ACM";
      acm.get().then((doc) {
        acmObj = doc.data;
        // Get sample details if available
        if (doc.data['sample'] != 'null') {
//          sample =  Firestore.instance.collection('samplesasbestosbulk').document(doc.data['sample']);
        }

        if (acmObj['arrowPaths'] != null)
          arrowPaths = convertFirestoreToListListOffset(acmObj['arrowPaths']);
        else
          arrowPaths = new List<List<Offset>>();
        if (acmObj['shadePaths'] != null)
          shadePaths = convertFirestoreToListListOffset(acmObj['shadePaths']);
        else
          shadePaths = new List<List<Offset>>();
        if (acmObj['idkey'] == 'i') {
          isSampled = true;
          stronglyPresumed = false;
        } else {
          isSampled = false;
          if (acmObj['idkey'] == 's') {
            stronglyPresumed = true;
          } else {
            stronglyPresumed = false;
          }
        }
        if (acmObj['roompath'] != null && acmObj['roomname'] != null) _room = {"path": acmObj['roompath'], "name": acmObj['roomname']}; else _room = null;

        showMaterialRisk = acmObj['mRisk'] == true;
        showPriorityRisk = acmObj['pRisk'] == true;

        // Load autosuggests
        this._itemController.text = acmObj['description'];
        this._materialController.text = acmObj['material'];
        this._damageController.text = acmObj['materialrisk_damagedesc'];
        this._surfaceController.text = acmObj['materialrisk_surfacedesc'];
        this._extentController.text = acmObj['extentdesc'];
        this._whynotController.text = acmObj['reasonfornotsampling'];

        controllerNotes.text = acmObj['notes'];

        // image
        if (acmObj['path_remote'] == null && acmObj['path_local'] != null) {
          // only local image available (e.g. when taking photos with no internet)
          _handleImageUpload(File(acmObj['path_local']));
          localPhoto = true;
        } else if (acmObj['path_remote'] != null) {
          localPhoto = false;
        }
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  void _handleImageUpload(File image) async {
    String room_name;
    String item_name;
    String storageRef = acmObj['storage_ref'];
    String path = acmObj['path'];
    print(image.path.toString());
    if (_room == null) {
      room_name = 'room';
    } else {
      if (_room['name'] == null)
        room_name = 'room';
      else
        room_name = _room['name'];
      if (acmObj['description'] == null) {
        item_name = 'description';
      } else
        item_name = acmObj['description'];
    }
    setState(() {
      acmObj["path_local"] = image.path;
      acmObj["path_remote"] = '';
      acmObj["storage_ref"] = '';
    });

    print("acm" + room_name + "-" + item_name);

    ImageSync(image, 50, "acm" + room_name + "-" + item_name,
            "jobs/" + DataManager.get().currentJobNumber, acm)
        .then((refs) {
      // Delete old photo
      if (storageRef != null)
        FirebaseStorage.instance.ref().child(storageRef).delete();

      if (this.mounted) {
        setState(() {
          acmObj['path_remote'] = refs['downloadURL'];
          acmObj['storage_ref'] = refs['storageRef'];
          localPhoto = false;
        });
      } else {
        // User has left the page, upload url straight to firestore
        Firestore.instance
            .document(DataManager.get().currentJobPath)
            .collection('acm')
            .document(path)
            .setData({
          "path_remote": refs['downloadURL'],
          'storage_ref': refs['storageRef'],
        }, merge: true);
      }
    });
  }

  void _handleGallery() async {
    ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      if (image != null) {
        _clearArrows();
        localPhoto = true;
        _handleImageUpload(image);
      }
    });
  }

  void _handleCamera() {
    ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      if (image != null) {
        _clearArrows();
        localPhoto = true;
        _handleImageUpload(image);
      }
    });
  }

  void _clearArrows() {
    setState(() {
      arrowPaths = new List<List<Offset>>();
      acmObj['arrowPaths'] = new List<List<Offset>>();
      acmObj['shadePaths'] = new List<List<Offset>>();
    });
  }

  Widget _getScoreSet({acmObjVar, tooltip0, tooltip1, tooltip2, tooltip3, disabledZero: false, showZero: true, text1, text2, text3}) {
    return Row(
      children: <Widget>[
        showZero ?
          disabledZero ?
          AsbestosScoreButton(
            onClick: (val) {},
            val: null,
            // -1 = disabled button
            score: -1,
          ) :
          AsbestosScoreButton(
            onClick: (val) {
              // firestore change score
              setState(() { acmObj[acmObjVar] = val;});
            },
            val: acmObj[acmObjVar],
            score: 0,
            tooltip: tooltip0,
          )
        : new Container(),
        AsbestosScoreButton(
          onClick: (val) {
            setState(() {
              acmObj[acmObjVar] = val;
            });
          },
          val: acmObj[acmObjVar],
          score: 1,
          text: text1,
          tooltip: tooltip1,
        ),
        AsbestosScoreButton(
          onClick: (val) {
            // firestore change score
            setState(() {
              acmObj[acmObjVar] =
                  val;
            });
          },
          val: acmObj[acmObjVar],
          text: text2,
          score: 2,
          tooltip: tooltip2,
        ),
        AsbestosScoreButton(
          onClick: (val) {
            // firestore change score
            setState(() {
              acmObj[acmObjVar] =
                  val;
            });
          },
          val: acmObj[acmObjVar],
          text: text3,
          score: 3,
          tooltip: tooltip3,
        ),
      ],
    );
  }

  Widget _acmPhoto() {
    return Column(children: <Widget>[

      // SAMPLE PHOTO
      new Container(
        alignment: Alignment.center,
        height: 312.0,
        width: 240.0,
        margin: EdgeInsets.only(
          left: 54.0,
          right: 54.0,
        ),
        decoration: BoxDecoration(
            border: new Border.all(color: Colors.black)),
        child: SamplePainter(
          arrowOn: arrowOn,
          shadeOn: shadeOn,
          arrowPaths: arrowPaths,
          shadePaths: shadePaths,
          pathColour: CompanyColors.resultMid,
          photo: localPhoto
              ? new Image.file(new File(acmObj['path_local']))
              : (acmObj['path_remote'] != null)
              ? new CachedNetworkImage(
            imageUrl: acmObj['path_remote'],
            placeholder: (context, url) =>
            new CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
            new Column(children: <Widget>[
              Icon(Icons.error),
              Text('Image Not Found')
            ]),
            fadeInDuration: new Duration(seconds: 1),
          )
              : new Container(child: Text('NO PHOTO')),
          updatePaths: (List<Offset> points) {
            setState(() {
              offsetPoints = points;
              arrowPaths.add(offsetPoints);
            });
          },
          updatePoints: (List<Offset> points) {
            setState(() {
              offsetPoints = points;
            });
          },
        ),
      ),
      new Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            bottom: 14.0,
          ),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: new Icon(
                    Icons.camera,
                    color: CompanyColors.accentRippled,
                    size: 32.0,
                  ),
                  onPressed: () {
                    _handleCamera();
                  },
                  padding: EdgeInsets.all(14.0),
                  tooltip: Tip.camera,
                ),
                IconButton(
                  icon: new Icon(
                    Icons.image,
                    color: CompanyColors.accentRippled,
                    size: 32.0,
                  ),
                  onPressed: () {
                    _handleGallery();
                  },
                  padding: EdgeInsets.all(14.0),
                  tooltip: Tip.gallery,
                ),
                IconButton(
                  icon: new Icon(
                    Icons.arrow_forward,
                    color: arrowOn
                        ? CompanyColors.accentRippled
                        : Colors.grey,
                    size: 32.0,
                  ),
                  onPressed: () {
                    acmObj['path_local'] != null
                        ? setState(() {
                      arrowOn = !arrowOn;
                      shadeOn = false;
                    })
                        : null;
                  },
                  padding: EdgeInsets.all(14.0),
                  tooltip: Tip.arrow,
                ),
                IconButton(
                  icon: new Icon(
                    Icons.brush,
                    color: shadeOn
                        ? CompanyColors.accentRippled
                        : Colors.grey,
                    size: 32.0,
                  ),
//                              onPressed: () {acmObj['path_local'] != null ? setState((){ shadeOn = !shadeOn; arrowOn = false; }) : null;},
                  onPressed: () {
                    null;
                  },
                  padding: EdgeInsets.all(14.0),
                  tooltip: Tip.shade,
                ),
                IconButton(
                  icon: new Icon(
                    Icons.format_color_reset,
                    color: acmObj['path_local'] != null
                        ? CompanyColors.accentRippled
                        : Colors.grey,
                    size: 32.0,
                  ),
                  onPressed: () {
                    acmObj['path_local'] != null
                        ? _clearArrows()
                        : null;
                  },
                  padding: EdgeInsets.all(14.0),
                  tooltip: Tip.reset,
                ),
              ])),

    ],);
  }

  Widget _sampleTypeSelectors() {
    return
      // SAMPLE TYPE SELECTORS
      new Container(
//                          width: 240.0,
        padding: EdgeInsets.only(bottom: 14.0),
        margin: EdgeInsets.only(left: 54.0, right: 54.0),
//                          constraints: BoxConstraints(maxWidth: 240.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(child: ScoreButton(
                onClick: () {
                  setState(() {
                    isSampled = false;
                    acmObj['idkey'] = 'p';
                  });
                },
                dialogHeight: 300.0,
                selected: acmObj['idkey'] == 'p',
                score: 1,
                text: 'P',
                tooltip: Tip.presume),
            ),
            Expanded(child: ScoreButton(
                onClick: () {
                  setState(() {
                    isSampled = false;
                    acmObj['idkey'] = 's';
                  });
                },
                dialogHeight: 300.0,
                selected: acmObj['idkey'] == 's',
                score: 2,
                text: 'S',
                tooltip: Tip.stronglypresume),
            ),
            Expanded(child: ScoreButton(
                onClick: () {
                  setState(() {
                    isSampled = true;
                    acmObj['idkey'] = 'i';
                  });
                },
                dialogHeight: 300.0,
                selected: acmObj['idkey'] == 'i',
                score: 3,
                text: 'I',
                tooltip: Tip.sample),
            ),
          ],
        ),
      );
  }

  Map<String, dynamic> _calculateMaterialTotals() {

    // MATERIAL RISK
    int materialRiskScore = 0;
    String materialRiskText;
    int materialRiskLevel;

    // PRIORITY RISK

    int priorityRiskScore = 0;
    String priorityRiskText;
    int priorityRiskLevel;

    bool materialRiskSet = true;
    bool priorityRiskSet = true;

    int totalRiskScore = 0;
    int totalRiskLevel;
    String totalRiskText;
    bool totalRiskSet;

    if (acmObj['materialrisk_productscore'] != null)
      materialRiskScore = materialRiskScore + acmObj['materialrisk_productscore'];
    else
      materialRiskSet = false;
    if (acmObj['materialrisk_damagescore'] != null)
      materialRiskScore = materialRiskScore + acmObj['materialrisk_damagescore'];
    else
      materialRiskSet = false;
    if (acmObj['materialrisk_surfacescore'] != null)
      materialRiskScore = materialRiskScore + acmObj['materialrisk_surfacescore'];
    else
      materialRiskSet = false;
    if (acmObj['materialrisk_asbestosscore'] != null)
      materialRiskScore = materialRiskScore + acmObj['materialrisk_asbestosscore'];
    else
      materialRiskSet = false;

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
    // Calculate priority totals
    priorityRiskScore = 0;
    int i = 0;
    int priorityActivity = 0;
    int priorityDisturbance = 0;
    int priorityExposure = 0;
    int priorityMaint = 0;

    // Activity
    if (acmObj['priority_activity_main'] != null) {
      priorityActivity = priorityActivity + acmObj['priority_activity_main'];
      i = i + 1;
    }
    if (acmObj['priority_activity_second'] != null) {
      priorityActivity = priorityActivity + acmObj['priority_activity_second'];
      i = i + 1;
    }
    if (i == 0) {
      i = 1;
      priorityRiskSet = false;
    }
    (i > 1)
        ? priorityRiskScore =
        priorityRiskScore + ((priorityActivity + 0.9) / i).round()
        : priorityRiskScore = priorityRiskScore + priorityActivity;
    i = 0;

    // Disturbance
    if (acmObj['priority_disturbance_location'] != null) {
      priorityDisturbance = priorityDisturbance + acmObj['priority_disturbance_location'];
      i = i + 1;
    }
    if (acmObj['priority_disturbance_accessibility'] != null) {
      priorityDisturbance =
          priorityDisturbance + acmObj['priority_disturbance_accessibility'];
      i = i + 1;
    }
    if (acmObj['priority_disturbance_extent'] != null) {
      priorityDisturbance = priorityDisturbance + acmObj['priority_disturbance_extent'];
      i = i + 1;
    }
    if (i == 0) {
      i = 1;
      priorityRiskSet = false;
    }
    (i > 1)
        ? priorityRiskScore =
        priorityRiskScore + ((priorityDisturbance + 0.9) / i).round()
        : priorityRiskScore = priorityRiskScore + priorityDisturbance;
    i = 0;

    // Exposure
    if (acmObj['priority_exposure_occupants'] != null) {
      priorityExposure = priorityExposure + acmObj['priority_exposure_occupants'];
      i = i + 1;
    }
    if (acmObj['priority_exposure_usefreq'] != null) {
      priorityExposure = priorityExposure + acmObj['priority_exposure_usefreq'];
      i = i + 1;
    }
    if (acmObj['priority_exposure_avgtime'] != null) {
      priorityExposure = priorityExposure + acmObj['priority_exposure_avgtime'];
      i = i + 1;
    }
    if (i == 0) {
      i = 1;
      priorityRiskSet = false;
    }
    (i > 1)
        ? priorityRiskScore =
        priorityRiskScore + ((priorityExposure + 0.9) / i).round()
        : priorityRiskScore = priorityRiskScore + priorityExposure;
    print('Average: ' +
        ((priorityExposure + 0.9) / i).round().toString() +
        'Exposure: ' +
        priorityExposure.toString() +
        ', Counter: ' +
        i.toString() +
        ' PriorityRisk ' +
        priorityRiskScore.toString());
    i = 0;

    // Maint
    if (acmObj['priority_maint_type'] != null) {
      priorityMaint = priorityMaint + acmObj['priority_maint_type'];
      i = i + 1;
    }
    if (acmObj['priority_maint_freq'] != null) {
      priorityMaint = priorityMaint + acmObj['priority_maint_freq'];
      i = i + 1;
    }
    if (i == 0) {
      i = 1;
      priorityRiskSet = false;
    }
    (i > 1)
        ? priorityRiskScore =
        priorityRiskScore + ((priorityMaint + 0.9) / i).round()
        : priorityRiskScore = priorityRiskScore + priorityMaint;
    print('Average: ' +
        ((priorityMaint + 0.9) / i).round().toString() +
        'Maint: ' +
        priorityMaint.toString() +
        ', Counter: ' +
        i.toString() +
        ' PriorityRisk ' +
        priorityRiskScore.toString());
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

    // Calculate total
    if (!showMaterialRisk && !showPriorityRisk) {
      totalRiskSet = false;
      totalRiskText = 'No Risk Assessment Done';
    } else if (materialRiskSet && !showPriorityRisk) {
      totalRiskSet = true;
      totalRiskScore = materialRiskScore;
      totalRiskLevel = materialRiskLevel;
      totalRiskText = materialRiskText;
    } else if (priorityRiskSet && materialRiskSet) {
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
    } else
      totalRiskSet = false;


    return {
      'materialRiskScore': materialRiskScore,
      'materialRiskText': materialRiskText,
      'materialRiskLevel': materialRiskLevel,
      'priorityRiskScore': priorityRiskScore,
      'priorityRiskText': priorityRiskText,
      'priorityRiskLevel': priorityRiskLevel,
      'materialRiskSet': materialRiskSet,
      'priorityRiskSet': priorityRiskSet,
      'totalRiskScore': totalRiskScore,
      'totalRiskLevel': totalRiskLevel,
      'totalRiskText': totalRiskText,
      'totalRiskSet': totalRiskSet,
    };
  }
}
