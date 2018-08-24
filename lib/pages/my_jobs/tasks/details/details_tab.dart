import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/model/jobs/job_header.dart';
import 'package:k2e/pages/cameras/camera_generic.dart';
import 'package:k2e/styles.dart';

import 'package:image_picker/image_picker.dart';
import 'package:k2e/theme.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// The base page for any type of job. Shows address, has cover photo,

class DetailsTab extends StatefulWidget {
  DetailsTab() : super();
  @override
  _DetailsTabState createState() => new _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {

  JobHeader jobHeader;
  Directory docPath;
  File _imageFile;

  final TextEditingController _addressController = new TextEditingController();
  String address;
  final TextEditingController _descriptionController = new TextEditingController();
  String description;

  @override
  Future initState() async {
    Directory docPath = await getApplicationDocumentsDirectory();
    jobHeader = DataManager.get().currentJob.jobHeader;
    address = jobHeader.address;
    description = jobHeader.description;

    _addressController.text = address;
    _descriptionController.text = description;
    try {
      _imageFile = new File(jobHeader.imagePath);
    } catch (e) {
      print(e.toString());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return new Scaffold(
        resizeToAvoidBottomPadding: false, // this field stops the keyboard hiding the view when inputs are selected
        body:
        new GestureDetector(
          onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          },
        child: Container(
        padding: new EdgeInsets.all(8.0),
        child: ListView(
                  children: <Widget> [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(jobHeader.clientName
                    ,style: Styles.h1)
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: TextField(
                      decoration: const InputDecoration(labelText: "Address"),
                      autocorrect: false,
                        controller: _addressController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (String value) {
                          DataManager.get().currentJob.jobHeader.address = value;
                        },
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: TextField(
                      decoration: const InputDecoration(labelText: "Description"),
                      autocorrect: false,
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onChanged: (String value) {
                        DataManager.get().currentJob.jobHeader.description = value;
                      },
                    ),
                  ),
                  Container(
                      alignment: Alignment.center,
                      height: 156.0,
                      child: GestureDetector(
                        onTap: () async {
                          _imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
                          String fileName = basename(_imageFile.path);
                          File newImage = await _imageFile.copy('${docPath.path}/$fileName');
                          setState(() async {
                            DataManager.get().currentJob.jobHeader.imagePath = fileName;
                            print(_imageFile.path);
                            print(newImage.path);
                            print(fileName);
                          });
                        },
                        child: (_imageFile != null)
//                        ? new Image.file(new File(DataManager.get().currentJob.jobHeader.imagePath))
                      ? Image.file(_imageFile)
                        : new Icon(Icons.camera, color: CompanyColors.accent, size: 48.0,)
                      ),
                    )
                ]),
              )
        )
    );

  }
}