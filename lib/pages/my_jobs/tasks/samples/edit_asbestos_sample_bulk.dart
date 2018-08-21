import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/entities/samples/sample_asbestos_bulk.dart';
import 'package:uuid/uuid.dart';
import 'package:validator/validator.dart';

class EditAsbestosSampleBulk extends StatefulWidget {
  @override
  _EditAsbestosSampleBulkState createState() => new _EditAsbestosSampleBulkState();
}

class _EditAsbestosSampleBulkState extends State<EditAsbestosSampleBulk> {
//  bool _isLoading = false;
  String _title;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  SampleAsbestosBulk sample;

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
//      _autovalidate = true; // Start validating on every change
    } else {
      sample.sampleNumber = sampleNumber;
      sample.description = description;
      sample.material = material;

      // TODO save sample with job
      Navigator.pop(context, sample);
    }
  }

  // controllers for form text controllers
  final TextEditingController _sampleNumberController = new TextEditingController();
  int sampleNumber;
  final TextEditingController _descriptionController = new TextEditingController();
  String description;
  final TextEditingController _materialController = new TextEditingController();
  String material;

  @override
  void initState() {
    sample = DataManager.get().currentAsbestosBulkSample;
    if (sample == null){
      print('null sample');
      print('creating new sample');
      sample = new SampleAsbestosBulk(uuid: new Uuid().v1(), asbestosItemUuid: null);
      _title = "Add New Sample";
      sample.jobNumber = DataManager.get().currentJob.jobHeader.jobNumber;
      sample.sampleNumber = DataManager.get().getHighestSampleNumber(DataManager.get().currentJob) + 1;
      sampleNumber = sample.sampleNumber;
    } else {
      sampleNumber = sample.sampleNumber;
      description = sample.description;
      material = sample.material;
      _title = "Edit " + sample.jobNumber + '-' +
          sample.sampleNumber.toString();
    }
    _sampleNumberController.text = sampleNumber.toString();
    _descriptionController.text = description;
    _materialController.text = material;

    super.initState();
  }

  Widget build(BuildContext context) {
    final DateTime today = new DateTime.now();

    return new Scaffold(
        appBar:
        new AppBar(title: Text(_title),
            actions: <Widget>[
              new IconButton(icon: const Icon(Icons.check), onPressed: () {
//          DataManager.get().currentJob.asbestosBulkSamples.add(sample);
                _handleSubmitted();
//                print(sample.jobNumber + '-' + sample.sampleNumber.toString() + ': ' + sample.description);
              })
            ]),
        body: new Form(
            key: _formKey,
            autovalidate: true,
//            onWillPop: _warnUserAboutInvalidData,
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                new Container(
                  child: new TextField(
                    decoration: const InputDecoration(labelText: "Sample Number"),
                    autocorrect: false,
                    controller: _sampleNumberController,
                    keyboardType: TextInputType.number,
                    onChanged: (String value) {
                      sampleNumber = toInt(value);
                    },
                  ),
                ),
                new Container(
                  child: new TextField(
                    decoration: const InputDecoration(labelText: "Description"),
                    autocorrect: false,
                    controller: _descriptionController,
                    onChanged: (String value) {
                      description = value;
                    },
                  ),
                ),
                new Container(
                  child: new TextField(
                    decoration: const InputDecoration(labelText: "Material"),
                    autocorrect: false,
                    controller: _materialController,
                    onChanged: (String value) {
                      material = value;
                    },
                  ),
                ),
              ],
            )));
  }
}