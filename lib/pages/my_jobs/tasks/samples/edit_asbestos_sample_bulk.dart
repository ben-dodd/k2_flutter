import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:k2e/autocomplete.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/samples/sample_asbestos_bulk.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/theme.dart';
import 'package:k2e/utils/camera.dart';
import 'package:k2e/widgets/loading.dart';
//import 'package:simple_autocomplete_formfield/simple_autocomplete_formfield.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
//import 'package:uuid/uuid.dart';
//import 'package:validator/validator.dart';

class EditAsbestosSampleBulk extends StatefulWidget {
  EditAsbestosSampleBulk({Key key, this.sample}) : super(key: key);
  String sample;
  @override
  _EditAsbestosSampleBulkState createState() => new _EditAsbestosSampleBulkState();
}

class _EditAsbestosSampleBulkState extends State<EditAsbestosSampleBulk> {
//  bool _isLoading = false;
  String _title = "Edit Sample";
  Stream sampleDoc;
  bool creatingSample;
  List<String> materials = AutoComplete.materials.split(';');

  final controllerSampleNumber = TextEditingController();
  final controllerDescription = TextEditingController();
  final controllerMaterial = TextEditingController();


  @override
  void initState() {
      controllerSampleNumber.addListener(_updateSampleNumber);
      controllerDescription.addListener(_updateDescription);
      controllerMaterial.addListener(_updateMaterial);
      creatingSample = false;

//    sampleDoc = Firestore.instance.collection('samplesasbestosbulk').document(widget.sample).get().asStream();
    if (widget.sample == null) {
      _title = "Add New Sample";
      creatingSample = true;
      _createSample();
    }
    super.initState();
  }

  _updateSampleNumber() {
    Firestore.instance.collection('samplesasbestosbulk').document(widget.sample).setData(
        {"sampleNumber": int.tryParse(controllerSampleNumber.text)}, merge: true);
  }

  _updateDescription() {
    Firestore.instance.collection('samplesasbestosbulk').document(widget.sample).setData(
        {"description": controllerDescription.text}, merge: true);
  }

  _updateMaterial() {
    Firestore.instance.collection('samplesasbestosbulk').document(widget.sample).setData(
        {"material": controllerMaterial.text}, merge: true);
  }

  Widget build(BuildContext context) {
//    final DateTime today = new DateTime.now();

    materials.sort();
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar:
        new AppBar(title: Text(_title),
            actions: <Widget>[
              new IconButton(icon: const Icon(Icons.check), onPressed: () {
                Navigator.pop(context);
              })
            ]),
        body: new StreamBuilder(stream: Firestore.instance.collection('samplesasbestosbulk').document(widget.sample).snapshots(),
            builder: (context, snapshot) {
                if (!snapshot.hasData || creatingSample) return
                  loadingPage(loadingText: 'Loading sample info...');
                if (snapshot.hasData && !creatingSample) {
                    if (controllerSampleNumber.text == '') {
                      if (snapshot.data['sampleNumber'].toString() == 'null') {
                        controllerSampleNumber.text = '';
                      } else controllerSampleNumber.text = snapshot.data['sampleNumber'].toString();
                      controllerDescription.text = snapshot.data['description'];
                      controllerMaterial.text = snapshot.data['material'];
                    }
                  return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Container(
                          padding: new EdgeInsets.all(8.0),
                          child: ListView(
                            children: <Widget>[
                              Container(
                                // TODO Radio to select from Sampled to Presumed
                                alignment: Alignment.topLeft,
                                child: Radio()
                              ),
                              Container(
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
                                child: AutoCompleteTextField<String>(
                                    decoration: new InputDecoration(
//                                        hintText: "Search Item",
                                        labelText: "Material"
//                                        border: new OutlineInputBorder(
//                                            gapPadding: 0.0, borderRadius: new BorderRadius.circular(16.0)),
//                                        suffixIcon: new Icon(Icons.search)
                                    ),
//                                    key: new Key('material'),
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
                                    })
                              ),
                              Container(
                                  height: 40.0,
                                  alignment: Alignment.bottomLeft,
                                  child: Text("Sample Photo", style: Styles.h2,)
                              ),
                              Row(
                                children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                height: 156.0,
                                width: 120.0,
                                decoration: BoxDecoration(border: new Border.all(color: Colors.black)),
                                child: GestureDetector(
                                    onTap: () {
                                      ImagePicker.pickImage(source: ImageSource.camera).then((image) {
                                        ImageSync(
                                          image,
                                          50,
                                          "sample" + controllerSampleNumber.text + "_" + widget.sample + ".jpg",
                                          DataManager.get().currentJobNumber,
                                          Firestore.instance.collection('samplesasbestosbulk').document(widget.sample)
                                        );
                                        print (image.path + " added!");
                                      });
                                    },
//                                    child: (_imageFile != null)
//                                        ? Image.file(_imageFile)
                                    child: (snapshot.data['imagePath'] != 'null')
                                        ? new CachedNetworkImage(
                                      imageUrl: snapshot.data['imagePath'],
//                                            imageUrl: 'https://www.whaleoil.co.nz/wp-content/uploads/2018/08/Dog.jpg',
                                      placeholder: new CircularProgressIndicator(),
                                      errorWidget: new Icon(Icons.error),
                                      fadeInDuration: new Duration(seconds: 1),
                                    )
                                        : new Icon(
                                      Icons.camera, color: CompanyColors.accent,
                                      size: 48.0,)
                                ),
                              )]),
                            ],
                          )
                      )
                  );
                }
            }
        )
    );
  }

  void _createSample() async {
    Map<String, dynamic> dataMap = new Map();
    print('creating new sample');
    dataMap['jobNumber'] = DataManager
        .get()
        .currentJobNumber;
    //      sample.sampleNumber = DataManager.get().getHighestSampleNumber(DataManager.get().currentJob) + 1;
    dataMap['sampleNumber'] = '1';
    dataMap['description'] = '';
    dataMap['material'] = '';
    dataMap['imagePath'] = '';
    Firestore.instance.collection('samplesasbestosbulk').add(
        dataMap).then((ref) {
          setState(() {
            widget.sample = ref.documentID;
            print('New instance made: ' + ref.documentID);
            creatingSample = false;
          });
    });
  }
}