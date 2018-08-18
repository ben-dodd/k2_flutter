import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/jobs/job.dart';
import 'package:k2e/model/jobs/job_header.dart';
import 'package:k2e/styles.dart';

// The base page for any type of job. Shows address, has cover photo,

class JobDetailsFragment extends StatefulWidget {
  JobDetailsFragment() : super();
  @override
  _JobDetailsFragment createState() => new _JobDetailsFragment();
}

class _JobDetailsFragment extends State<JobDetailsFragment> {

  JobHeader jobHeader;

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


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
//TODO Stop view disappearing when keyboard is selected!
    return new Scaffold(
        body:
        new ListView(
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
                      maxLines: 10,
                      onChanged: (String value) {
                        DataManager.get().currentJob.jobHeader.description = value;
                      },
                    ),
                  ),
              ]
            ),
    );

  }
}