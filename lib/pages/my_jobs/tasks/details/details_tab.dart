import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/buttons.dart';
import 'package:k2e/widgets/common_widgets.dart';
import 'package:weather/weather.dart';

import '../../../../strings.dart';

// The base page for any type of job. Shows address, has cover photo,

class DetailsTab extends StatefulWidget {
  DetailsTab() : super();

  @override
  _DetailsTabState createState() => new _DetailsTabState();
}

//todo: https://stackoverflow.com/questions/37699688/cache-images-local-from-google-firebase-storage

class _DetailsTabState extends State<DetailsTab> {
  DocumentReference details;
  Stream detailsStream;
  Timer _debounce;
  WeatherStation weatherStation = new WeatherStation(Strings.weatherApi);
  final controllerAddress = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerScope = TextEditingController();
  final controllerTemp = TextEditingController();
  final controllerWeather = TextEditingController();

  // IMAGES
  String path_local;
  String path_remote;

  bool localPhoto = false;

  @override
  void initState() {
    controllerAddress.addListener(_updateAddress);
    controllerDescription.addListener(_updateDescription);
    controllerScope.addListener(_updateScope);
    _loadDetails();

    super.initState();
  }

  _updateAddress() {
    details.setData({"address": controllerAddress.text}, merge: true);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 3000), () {
      print('Sending address update to WFM');
      // TODO: Send update to WFM debounced
    });
  }

  _updateDescription() {
    details.setData({"description": controllerDescription.text}, merge: true);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 3000), () {
      print('Sending details update to WFM');
      // TODO: Send update to WFM debounced
    });
  }

  _updateScope() {
    details.setData({"scope": controllerScope.text}, merge: true);
  }

  _handleSurveyTypeClick(type) {
    details.setData({"surveyType": type}, merge: true);
  }

  _handleManagementPlanClick(value) {
    if (value == true) {
      details.setData({"doManagementPlan": false}, merge: true);
    } else {
      details.setData({"doManagementPlan": true}, merge: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        // this field stops the keyboard hiding the view when inputs are selected
        body: new StreamBuilder(
            stream: detailsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (!snapshot.hasData)
                  return LoadingPage(loadingText: 'Loading job info...');
                if (snapshot.hasData) {
                  if (controllerAddress.text == '') {
                    controllerAddress.text = snapshot.data['address'];
                    controllerDescription.text = snapshot.data['description'];
                    controllerScope.text = snapshot.data['scope'];
                  }
                  if (snapshot.data['path_local'] != null)
                    print('local path: ' + snapshot.data['path_local']);
                  if (snapshot.data['path_remote'] != null)
                    print('remote path: ' + snapshot.data['path_remote']);
                  return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Container(
                      padding: new EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(8.0),
                        child: Column(children: <Widget>[
                          Container(
                              alignment: Alignment.topLeft,
                              child: Text(snapshot.data['clientName'],
                                  style: Styles.h1),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                  RadioLabel(
                                    value: 'management',
                                    groupValue: snapshot.data['surveyType'],
                                    text: 'Management',
                                    onClick: (_) => _handleSurveyTypeClick('management'),
                                  ),
                                  RadioLabel(
                                    value: 'refurbishment',
                                    groupValue: snapshot.data['surveyType'],
                                    text: 'Refurbishment',
                                    onClick: (_) => _handleSurveyTypeClick('refurbishment'),
                                  ),
                                ]
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  RadioLabel(
                                    value: 'demolition',
                                    groupValue: snapshot.data['surveyType'],
                                    text: 'Demolition',
                                    onClick: (_) => _handleSurveyTypeClick('demolition'),
                                  ),
                                  RadioLabel(
                                    value: 'combination',
                                    groupValue: snapshot.data['surveyType'],
                                    text: 'Combination',
                                    onClick: (_) => _handleSurveyTypeClick('combination'),
                                  ),
                                ]
                              ),
                            ]
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: CheckLabel(
                                value: snapshot.data['doManagementPlan'],
                                text: "Prepare Management Plan",
                                onClick: (_) => _handleManagementPlanClick(snapshot.data['doManagementPlan']),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: TextField(
                                decoration:
                                    const InputDecoration(labelText: "Address"),
                                autocorrect: false,
                                controller: controllerAddress,
                                keyboardType: TextInputType.multiline,
                                maxLines: null),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            child: TextField(
                                decoration: const InputDecoration(
                                    labelText: "Description"),
                                autocorrect: false,
                                controller: controllerDescription,
                                keyboardType: TextInputType.multiline,
                                maxLines: null),
                          ),
                          Container(
                              height: 40.0,
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                "Main Site Photo",
                                style: Styles.h2,
                              )),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  height: 195.0,
                                  width: 257.5,
                                  margin: EdgeInsets.symmetric(vertical: 4.0),
                                  padding:
                                      EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                                  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    border: new Border.all(
                                        color: Colors.black38, width: 1.0),
                                    borderRadius:
                                        new BorderRadius.circular(4.0),
                                  ),
                                  child: GestureDetector(
                                      onTap: () {
                                        ImagePicker.pickImage(
                                                source: ImageSource.camera)
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
                                              snapshot.data['path_local']))
                                          : (snapshot.data['path_remote'] !=
                                                  null)
                                              ? new CachedNetworkImage(
                                                  imageUrl: snapshot
                                                      .data['path_remote'],
                                                  placeholder: (context, url) =>
                                                      new CircularProgressIndicator(),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          new Icon(Icons.error),
                                                  fadeInDuration:
                                                      new Duration(seconds: 1),
                                                )
                                              : new Icon(
                                                  Icons.camera,
                                                  color: CompanyColors
                                                      .accentRippled,
                                                  size: 48.0,
                                                )),
                                )
                              ]),
                          new Divider(),
                          new Container(
                            child: new Text("General Survey Information", style: Styles.h2),
                          ),
                          GestureDetector(
                            onLongPress: () {
                              // Show tool tip dialog offering suggestions
                            },
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: "Scope"),
                                  autocorrect: false,
                                  controller: controllerScope,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null),
                            ),
                          ),
                          // TODO: Details fields
                          // If management survey, who is responsible for the plan? Get contacts

                          // If combination, what is being refurbished, what is management
                          // Scope of refurbishment, extent of fire or other damage
                          // Building age, source?
                          // Use of the property (industrial, office, retail, domestic)
                          // Number of buildings: age, type, construction
                          // Number of rooms
                          // Any unusual features or underground sections
                          // Any installed plant or equipment?
                          // Is the site a listed building, conservation area etc.
                          // Are the surrounding ground and associated buildings or structures included in the survey scope?
                          // Are the premises occupied or vacant?
                          // Are there underground ducts or shafts?
                          // Any restrictions on access?
                          // Responsibility and arrangement for access?
                          // Special requirements or instructions
                          // Power on?
                          // Gas on?
                          // Is working machinery made safe?
                          // Any restrictions on photos? -> this could be moved to the rooms tab
                          // Any repairs to ACM?
                          // Any previous buildings demolished?

                          // Building age should relate to help, e.g. say what to look for in this type of building

                          // Building info (perhaps have dialog this can be made with, number of outbuildings, main cladding etc.)
                          // Dialog can also direct them to add more detail about construction type, e.g. foundations etc.

                          // Previous renovations at property
                          // Extensions
                          // New structures
                          // Has the property ever had asbestos removed? Reports upload? Description
                          // Have any other asbestos surveys or sampling been done at this property? Reports upload? Description
                          // Site visit log with sample ids etc.
                          // Any inaccessible areas
                          // Restrictions to demolition survey? Occupied areas etc.
                          // Any areas that are unsafe to enter?
                          // Force procedure, periphery -> inwards, roof to basement
                          // Internal areas, downwards from roof to basement, clockwise from the entry door, inspect each component inside each compartment
                          // 1. ceiling, 2. walls, 3. floor, 4. fixtures and fittings, 5. equipment and services
                          // Client requests re: sampling
                          // Check all photos and map is complete
                          // Re-check areas which are complex or have many items
                          // Do a final walk-through

                          // SCOPE
                          // Any external areas for inclusion?
                          // Any excluded areas?
                          // Type of survey
                          // Possible or known asbestos not to be included in the survey

                          // SURVEY
                          // Anticipated number of samples

                          new Container(
                            child: new Text("Weather", style: Styles.h3),
                          ),
                          FunctionButton(onClick: _getWeather, text: 'Log Current Weather Information'),
                          // TODO Change this so its a dismissable card that can be swiped to remove
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              TextLabel(
                                value: snapshot.data['weatherDescription'] != null ? snapshot.data['weatherDescription'] : 'N/A',
                                text: 'Description',
                              ),
                              Container(
                                child: snapshot.data['weatherIcon'] != null ?
                                Image.network('http://openweathermap.org/img/w/' + snapshot.data['weatherIcon'] + '.png')
                                    : Container(),
                              ),
                            ],
                          ),
                          TextLabel(
                            value: snapshot.data['weatherTemp'] != null ? snapshot.data['weatherTemp'].toStringAsFixed(1) + '\u00B0C' : 'N/A',
                            text: 'Temperature',
                          ),

                          // Add evidence of refurbishment, age of property,
                          // knowledge of any previous asbestos removal etc. etc.

                        ]),
                      ),
                    ),
                  );
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return ErrorPage();
              }
            }));
  }

  void _loadDetails() async {
    details = Firestore.instance.document(DataManager.get().currentJobPath);
    detailsStream = details.snapshots();
    DocumentSnapshot doc = await details.get();
    if (doc.data['path_local'] != null && doc.data['path_remote'] == null) {
      // only local image available (e.g. when taking photos with no internet)
      localPhoto = true;
      // try to upload
      _handleImageUpload(File(doc.data['path_local']));
    } else if (doc.data['path_remote'] != null) {
      localPhoto = false;
    }
    setState(() {
      print('is loading set to false');
    });
  }

  void _handleImageUpload(File image) async {
    details.setData({"path_local": image.path}, merge: true).then((_) {
      setState(() {});
    });
    ImageSync(image, 50, "sitephoto",
            "jobs/" + DataManager.get().currentJobNumber, details)
        .then((refs) {
      // Delete old photo if it doesn't overwrite
      details.setData({
        'path_remote': refs['downloadURL'],
        'storage_ref': refs['storageRef']
      }, merge: true);

      if (this.mounted) {
        setState(() {
          localPhoto = false;
        });
      }
    });
  }

  void _getWeather() async {
    weatherStation.currentWeather().then((weather) {
      details.setData({
        "weatherDescription": weather.weatherMain + ' (' + weather.weatherDescription + ')',
        "weatherTemp": weather.temperature.celsius,
        "weatherHumidity": weather.humidity,
        "weatherPressure": weather.pressure,
        "weatherCloudiness": weather.cloudiness,
        "weatherIcon": weather.weatherIcon,
        "weatherDate": weather.date,
        "weatherWindSpeed": weather.windSpeed,
        "weatherWindDegree": weather.windDegree,
      }, merge: true);
    });
  }
}
