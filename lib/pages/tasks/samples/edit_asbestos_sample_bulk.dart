import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/model/entities/samples/sample_asbestos_bulk.dart';
import 'package:uuid/uuid.dart';
import 'package:validator/validator.dart';

class EditAsbestosSampleBulk extends StatefulWidget {
  final SampleAsbestosBulk sample;
  EditAsbestosSampleBulk(this.sample) : super();

  @override
  _EditAsbestosSampleBulkState createState() => new _EditAsbestosSampleBulkState();
}

class _EditAsbestosSampleBulkState extends State<EditAsbestosSampleBulk> {
//  bool _isLoading = false;
  String _title;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SampleAsbestosBulk sample = widget.sample;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    if (sample == null) {
      sample = new SampleAsbestosBulk(uuid: new Uuid().v1(), asbestosItemUuid: null);
      _title = "Add New Sample";
      sample.jobNumber = DataManager.get().currentJob.jobHeader.jobNumber;
      sample.sampleNumber = DataManager.get().currentJob.highestSampleNumber + 1;
    } else {
      _title = "Edit Sample " + sample.jobNumber + '-' +
          sample.sampleNumber.toString();
    }

    return new Scaffold(
      appBar:
      new AppBar(title: Text(_title),
      actions: <Widget>[
        new IconButton(icon: const Icon(Icons.check), onPressed: () {
//          DataManager.get().currentJob.asbestosBulkSamples.add(sample);
          final FormState form = _formKey.currentState;
          form.save();
          Navigator.pop(context, sample);
          print(sample.jobNumber + '-' + sample.sampleNumber.toString() + ': ' + sample.description);
        })
      ]),
      body:
          new SafeArea(
            top: false,
            bottom: false,
            child: new Form(
              key: _formKey,
              autovalidate: true,
              child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.phone),
                      hintText: '#',
                      labelText: 'Sample Number',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                    ],
                    onSaved: (val) => sample.sampleNumber = toInt(val),
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(Icons.person),
                      hintText: 'Sample description',
                      labelText: 'Description',
                    ),
                    onSaved: (val) => sample.description = val,
                  ),
                ],
              )
          )
      )
    );
  }
}