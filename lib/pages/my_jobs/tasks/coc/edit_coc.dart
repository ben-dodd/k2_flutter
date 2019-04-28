import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/buttons.dart';
import 'package:k2e/widgets/common_widgets.dart';
import 'package:k2e/widgets/custom_auto_complete.dart';
import 'package:k2e/widgets/custom_typeahead.dart';
import 'package:k2e/widgets/date_picker.dart';
import 'package:uuid/uuid.dart';

class EditCoc extends StatefulWidget {
  EditCoc({Key key, this.coc, this.cocObj}) : super(key: key);
  final String coc;
  Map<String, dynamic> cocObj;
  @override
  _EditCocState createState() => new _EditCocState();
}

class _EditCocState extends State<EditCoc> {
  String _title = "Edit Chain of Custody";
  bool isLoading = true;
  Map<String, dynamic> cocObj = new Map<String, dynamic>();

  // images
  String coc;
  String version;
  bool localPhoto = false;
  List<Map<String, String>> roomgrouplist = new List();
  final Map constants = DataManager.get().constants;
  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<String>>();
  TextEditingController labelController;
  TextEditingController materialController;

//  final controllerRoomCode = TextEditingController();
  final _roomCodeController = TextEditingController();
  final _roomNameController = TextEditingController();

  List rooms;
  List items;
  List materials;
  List staff;
  List<String> personnelSelected = <String>[];
  List<DateTime> datesSelected = <DateTime>[];
  Map<String, dynamic> samples = new Map<String, dynamic>();
  int samplesLength = 10;

  var _formKey = GlobalKey<FormState>();

//  GlobalKey formFieldKey = new GlobalKey<AutoCompleteFormFieldState<String>>();

  ScrollController _scrollController;

  // Create list of focus nodes
  final _focusNodes = List<FocusNode>.generate(
    200,
    (i) => FocusNode(),
  );

  @override
  void initState() {
    staff = [];
    if (DataManager.get().staff == null) {
      Firestore.instance
          .collection('state')
          .document('staff')
          .get()
          .then((doc) {
        doc.data.forEach((key, value) => staff.add(value['name'].toString()));
        staff.sort((a, b) {
          return a.compareTo(b);
        });
        print(staff.toString());
      });
    } else {
      staff = DataManager.get().staff;
    }

    coc = widget.coc;
//    controllerRoomCode.addListener(_updateRoomCode);
    _loadCoc();
    _scrollController = ScrollController();

    rooms = constants['roomsuggestions'];
    items = constants['buildingitems'];
    materials = constants['buildingmaterials'];
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final List<DateTime> picked = await showMultiDatePicker(
        context: context,
        initialDates: datesSelected,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(new Duration(days: 365)));
    if (picked != null)
      picked.sort();
      setState(() {
        datesSelected = picked;
      });
  }

  Widget build(BuildContext context) {
    print(samples.toString());
    if (cocObj['currentVersion'] == null)
      version = 'Not yet issued';
    else {
      version = 'Latest version: ' + cocObj['currentVersion'].toString();
      if (!cocObj['versionUpToDate']) version = version + ' (needs reissue)';
    }
    print(personnelSelected.toString());
    print(datesSelected.toString());
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
                    _handleCocSubmit();
                    _formKey.currentState.save();
                    cocObj['personnel'] = personnelSelected;
                    cocObj['dates'] = datesSelected;
                    Firestore.instance
                        .collection('cocs')
                        .document(coc)
                        .setData(cocObj);
                    Navigator.pop(context);
                  }
                })
          ]),
      body: isLoading
          ? LoadingPage(loadingText: 'Loading Chain of Custody...')
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
//                  padding: new EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 200.0),
                    children: <Widget>[
                      Container(
                        height: 16.0,
                      ),
                      Text(
                        cocObj['jobNumber'] + ': ' + cocObj['client'],
                        style: Styles.h2,
                      ),
                      Text(
                        cocObj['address'],
                        style: Styles.h3,
                      ),
                      Text(version, style: Styles.comment),
                      new Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(top: 14.0, bottom: 8.0),
                        child: new Text(
                          "Sample Date(s)",
                          style: Styles.label,
                        ),
                      ),
                      Text(datesSelected.length > 0 ? datesSelected.map((date) => new DateFormat('d MMMM yyyy').format(date)).join("\n") : 'No dates selected'),
                      FunctionButton(
                        text: "Select Dates",
                        onClick: () => _selectDate(context)
                      ),
                      new Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(
                          top: 14.0,
                        ),
                        child: new Text(
                          "Sampled By",
                          style: Styles.label,
                        ),
                      ),
                      new Container(
                        alignment: Alignment.topLeft,
                        child: DropdownButton<String>(
                          value: personnelSelected.isEmpty
                              ? null
                              : personnelSelected.last,
                          iconSize: 24.0,
                          items: staff.map((staff) {
                            return new DropdownMenuItem<String>(
                              value: staff,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.check,
                                    color: personnelSelected.contains(staff)
                                        ? null
                                        : Colors.transparent,
                                  ),
                                  SizedBox(width: 16),
                                  Text(staff),
                                ],
                              ),
                            );
                          }).toList(),
                          hint: Text("-"),
                          onChanged: (String newValue) {
                            setState(() {
                              print(personnelSelected.toString());
                              print(newValue);
                              if (personnelSelected.contains(newValue))
                                personnelSelected.remove(newValue);
                              else
                                personnelSelected.add(newValue);
                            });
                          },
                        ),
                      ),
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: new Text(
                          "Samples",
                          style: Styles.h2,
                        ),
                        children: <Widget>[
                          FunctionButton(
                            text: "Add 10 More Rows",
                            onClick: () => setState(() { samplesLength = samplesLength + 10; }),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: samplesLength,
                            itemBuilder: (context, index) {
                              return buildSamples(index + 1);
                            }),
                        ],
                      ),
                    ]),
              ),
            ),
    );
  }

  buildSamples(index) {
    var i = index.toString();
    var item = samples[i];
    if (item == null) {
      samples[i] = {
        'description': '',
        'material': '',
      };
    }
    if (samples[(index + 1).toString()] == null) {
      samples[(index + 1).toString()] = {
        'description': '',
        'material': '',
      };
    }

    labelController =
        TextEditingController(text: item == null ? '' : item['description']);
    materialController =
        TextEditingController(text: item == null ? '' : item['material']);
    Widget widget = new Row(children: <Widget>[
      new Container(
          width: 30.0,
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
            right: 14.0,
          ),
//          child: new Text(item["label"], style: Styles.label,),
          child: Text((index).toString())),
      new Container(
        width: 150.0,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(
          right: 14.0,
        ),
//          child: new Text(item["label"], style: Styles.label,),
        child: CustomTypeAhead(
          controller: labelController,
          capitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
//          label: 'Item',
          suggestions: items,
          onSaved: (value) => samples[i]["description"] = value.trim(),
          validator: (value) {},
          focusNode: _focusNodes[(index * 2) + 2],
          nextFocus: _focusNodes[(index * 2) + 3],
        ),
      ),
      new Flexible(
        child: CustomTypeAhead(
          controller: materialController,
          capitalization: TextCapitalization.none,
          textInputAction: TextInputAction.next,
//            label: 'Material',
          suggestions: materials,
          onSaved: (value) => samples[i]["material"] = value.trim(),
          validator: (value) {},
          focusNode: _focusNodes[(index * 2) + 3],
          nextFocus: (samples.length - 1 != index &&
                  samples[(index + 1).toString()] != null &&
                  samples[(index + 1).toString()]["description"].trim().length >
                      0)
              ? _focusNodes[((index + 1) * 2) + 3]
              : _focusNodes[((index + 1) * 2) + 2],
        ),
      )
    ]);
    return widget;
  }

  void _loadCoc() async {
    print('new coc');
    print(coc.toString());
//    print("Loading room");
    if (coc == null) {
      _title = "Add New Chain of Custody";
      if (widget.cocObj == null) {
        cocObj['deleted'] = false;
        // New room requires us to create a path so it doesn't need internet to get one from Firestore
        cocObj['uid'] = new Uuid().v1();
      } else {
        cocObj = widget.cocObj;
        cocObj['uid'] = cocObj['jobNumber'] + '_' + cocObj['client'] + '-' + Uuid().v1().toString();
      }

      setState(() {
        isLoading = false;
      });
    } else {
//      print('Edit room is ' + room.toString());
      _title = "Edit Chain of Custody";
      Map<String, dynamic> sample_temp = new Map<String, dynamic>();
      Firestore.instance.collection('cocs').document(coc).get().then((doc) {
        Firestore.instance
            .collection('samplesasbestos')
            .where('jobNumber', isEqualTo: doc.data['jobNumber'])
            .getDocuments()
            .then((docList) {
          docList.documents.forEach(
                  (doc) => sample_temp[doc.data['samplenumber'].toString()] = doc.data);

          print('Edit coc');
          setState(() {
            cocObj = doc.data;
            samples = sample_temp;

            print(cocObj['samples'].toString());
            if (cocObj['personnel'] != null) {
              cocObj['personnel'].forEach((p) {
                personnelSelected.add(p);
              });
            }
            if (cocObj['dates'] != null) {
              cocObj['dates'].forEach((d) {
                datesSelected.add(d.toDate());
              });
//            } else {
//              datesSelected.add(new DateTime.now());
            }
            _roomNameController.text = cocObj['name'];
            _roomCodeController.text = cocObj['roomcode'];
            isLoading = false;
          });
          print(samples);
        });
        // image
      });
    }
//    print(_title.toString());
  }

  void _handleCocSubmit() {
    print(samples.toString());
//    if (samples.length > 0) {
//      samples.forEach((Map<String, dynamic> sample) => {
//
//      });
//    }
  }


//  export const handleCocSubmit = ({ doc, docid }) => dispatch => {
//  console.log(doc.samples);
//  let samplelist = [];
//  if (doc.samples) {
//  Object.keys(doc.samples).forEach(sample => {
//  if (!doc.samples[sample].uid) {
//  let datestring = new Intl.DateTimeFormat("en-GB", {
//  year: "2-digit",
//  month: "2-digit",
//  day: "2-digit",
//  hour: "2-digit",
//  minute: "2-digit",
//  second: "2-digit"
//  })
//      .format(new Date())
//      .replace(/[.:/,\s]/g, "_");
//  let uid = `${
//  doc.jobNumber
//  }-SAMPLE-${sample}-CREATED-${datestring}-${Math.round(
//  Math.random() * 1000
//  )}`;
//  console.log(`UID for new sample is ${uid}`);
//  doc.samples[sample].uid = uid;
//  samplelist.push(uid);
//  } else {
//  samplelist.push(doc.samples[sample].uid);
//  }
//  if (
//  (doc.samples[sample].description || doc.samples[sample].material) &&
//  !doc.samples[sample].disabled &&
//  (doc.samples[sample].cocUid === undefined ||
//  doc.samples[sample].cocUid === doc.uid)
//  ) {
//  console.log(`Submitting sample ${sample} to ${docid}`);
//  let sample2 = doc.samples[sample];
//  if (sample2.description)
//  sample2.description =
//  sample2.description.charAt(0).toUpperCase() +
//  sample2.description.slice(1);
//  if (doc.type === "air") {
//  sample2.isAirSample = true;
//  sample2.material = "Air Sample";
//  }
//  sample2.jobNumber = doc.jobNumber;
//  sample2.cocUid = docid;
//  sample2.samplenumber = parseInt(sample, 10);
//  if ("disabled" in sample2) delete sample2.disabled;
//  console.log("Sample 2");
//  console.log(sample2);
//  asbestosSamplesRef.doc(doc.samples[sample].uid).set(sample2);
//  }
//  });
//  }
//  let doc2 = doc;
//  if ("samples" in doc2) delete doc2.samples;
//  doc2.uid = docid;
//  doc2.samplelist = samplelist;
//  console.log(doc2);
//  cocsRef.doc(docid).set(doc2);
//  dispatch({ type: RESET_MODAL });
//  };

}
