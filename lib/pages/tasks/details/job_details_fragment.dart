import 'dart:io';

import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/model/jobs/job_header.dart';
import 'package:k2e/pages/cameras/camera_generic.dart';
import 'package:k2e/styles.dart';

import 'package:image_picker/image_picker.dart';
import 'package:k2e/theme.dart';

// The base page for any type of job. Shows address, has cover photo,

class JobDetailsFragment extends StatefulWidget {
  JobDetailsFragment() : super();
  @override
  _JobDetailsFragment createState() => new _JobDetailsFragment();
}

class _JobDetailsFragment extends State<JobDetailsFragment> {

  JobHeader jobHeader;

  File _imageFile;

  final TextEditingController _addressController = new TextEditingController();
  String address;
  final TextEditingController _descriptionController = new TextEditingController();
  String description;

  @override
  void initState() {
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
                          setState(() {
                            DataManager.get().currentJob.jobHeader.imagePath = _imageFile.path;
                            print(DataManager.get().currentJob.jobHeader.imagePath);
                          });
//                          _addMainPhoto();
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

  void _addMainPhoto() async {
    DataManager.get().currentJob.jobHeader.imagePath = await Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) => CameraGeneric()),
    );
    print(DataManager.get().currentJob.jobHeader.imagePath);
  }
}