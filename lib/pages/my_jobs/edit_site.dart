import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/widgets/common_widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoder/geocoder.dart';

class EditSite extends StatefulWidget {
  EditSite({Key key, this.site}) : super(key: key);
  final String site;
  @override
  _EditSiteState createState() => new _EditSiteState();
}

class _EditSiteState extends State<EditSite> {
  String _title = "Edit Site";
  bool isLoading = true;

  Map<String, dynamic> siteObj = new Map<String, dynamic>();

  // images
  String site;
  bool localPhoto = false;

  var _formKey = GlobalKey<FormState>();
  final _focusNodes = List<FocusNode>.generate(
    5,
        (i) => FocusNode(),
  );

  @override
  void initState() {
    site = widget.site;
    _loadSite();
    super.initState();
  }

  _updateName(name) {
    this.setState(() {
      siteObj["name"] = name.trim();
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
//        resizeToAvoidBottomPadding: false,
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
                    Firestore.instance
                        .document(DataManager.get().currentJobPath)
                        .collection('rooms')
                        .document(siteObj['path'])
                        .setData(siteObj, merge: true);
                    Navigator.pop(context);
                  }
                })
          ]),
      body: isLoading
          ? LoadingPage(loadingText: 'Loading room group info...')
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
                    labelText: "Site Name",
                  ),
                  onSaved: (String value) {
                    siteObj["name"] = value.trim();
                  },
                  validator: (String value) {
                    return value.isEmpty ? 'You must add a name' : null;
                  },
                  focusNode: _focusNodes[0],
                  initialValue: siteObj["name"],
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(_focusNodes[1]);
                  },
                ),
              ),
              CheckLabel(
                text: "Label",
                value: siteObj['presume'],
                onClick: (value) => setState(() {
                  siteObj['presume'] =
                  siteObj['presume'] != null
                      ? !siteObj['presume']
                      : true;
                }),
              ),
              new Container(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Notes",
                  ),
                  autocorrect: false,
                  onSaved: (String value) async {
                    siteObj["address"] = value.trim();
                    var addresses = await Geocoder.local.findAddressesFromQuery(value.trim());
                    var first = addresses.first;
                    print("${first.featureName} : ${first.coordinates}");
                  },
                  initialValue: siteObj["address"],
                  focusNode: _focusNodes[1],
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              new Container(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Notes",
                  ),
                  autocorrect: false,
                  onSaved: (String value) {
                    siteObj["notes"] = value.trim();
                  },
                  initialValue: siteObj["notes"],
                  focusNode: _focusNodes[2],
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadSite() async {
    if (site == null) {
      _title = "Add New Site";
      siteObj['name'] = null;
      siteObj['children'] = new List();
      siteObj['roomtype'] = 'group';
      siteObj['path'] = new Uuid().v1();
      isLoading = false;
    } else {
      _title = "Edit Room Group";
      Firestore.instance
          .collection('sites')
          .document(site)
          .get()
          .then((doc) {
        setState(() {
          siteObj = doc.data;
          isLoading = false;
        });
      });
    }
  }
}
