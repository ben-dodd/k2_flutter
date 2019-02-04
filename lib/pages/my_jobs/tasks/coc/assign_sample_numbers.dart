import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:uuid/uuid.dart';

class AssignSampleNumbers extends StatefulWidget {
  AssignSampleNumbers({Key key, this.acm}) : super(key: key);
  final Map<String, dynamic> acm;
  @override
  _AssignSampleNumbersState createState() => new _AssignSampleNumbersState();
}

class _AssignSampleNumbersState extends State<AssignSampleNumbers> {
  String _title = "Assign Sample Numbers";
  bool isLoading = true;
  
  String templateName = '-';
  List roomGroupTemplates = DataManager.get().roomGroupTemplates;
  List roomTemplates = DataManager.get().roomTemplates;

  Map<String, dynamic> acm = new Map<String, dynamic>();

  // images
  bool localPhoto = false;

  var _formKey = GlobalKey<FormState>();
  final _focusNodes = List<FocusNode>.generate(
    5,
        (i) => FocusNode(),
  );

  @override
  void initState() {
    acm = widget.acm;
    _loadSampleNumbers();
    super.initState();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
//        resizeToAvoidBottomPadding: false,
      appBar:
      new AppBar(title: Text(_title),
          leading: new IconButton(
            icon: new Icon(Icons.clear),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            new IconButton(icon: const Icon(Icons.check), onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                Firestore.instance.document(DataManager.get().currentJobPath).collection('rooms').document(acm['path']).setData(acm, merge: true);
                Navigator.pop(context);
              }
            })
          ]
      ),
      body: isLoading ?
      loadingPage(loadingText: 'Loading room group info...')
          : GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: new EdgeInsets.all(8.0),
//                  padding: new EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 200.0),
            children: <Widget>[
              new Container(
                child: new TextFormField(
                  decoration: new InputDecoration(
                    labelText: "Room Group Name",
                  ),
                  onSaved: (String value) {
                    acm["name"] = value.trim();
                  },
                  validator: (String value) {
                    return value.isEmpty ? 'You must add a name' : null;
                  },
                  focusNode: _focusNodes[0],
                  initialValue: acm["name"],
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(_focusNodes[1]);
                  },
                ),
              ),
              new Container(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Room Group Prefix",
                    hintText: "e.g. 1 for Level 1, B for Basement",
                  ),
                  autocorrect: false,
                  onSaved: (String value) {
                    acm["roomcode"] = value.trim();
                  },
                  initialValue: acm["roomcode"],
                  focusNode: _focusNodes[1],
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              new Container(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Notes",
                  ),
                  autocorrect: false,
                  onSaved: (String value) {
                    acm["notes"] = value.trim();
                  },
                  initialValue: acm["notes"],
                  focusNode: _focusNodes[2],
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              new Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(top: 14.0,),
                child: new Text("Create Rooms from Template", style: Styles.label,),
              ),
              new DropdownButton<String>(
                  value: templateName,
                  iconSize: 24.0,
                  items: roomGroupTemplates.map((item) {
                    return new DropdownMenuItem<String>(
                      value: item["name"],
                      child: new Text(item["name"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      templateName = value;
                    });
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadSampleNumbers() {

  }
}

