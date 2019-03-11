import 'package:calendarro/calendarro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/styles.dart';
import 'package:k2e/widgets/custom_auto_complete.dart';
import 'package:k2e/widgets/custom_typeahead.dart';
import 'package:k2e/widgets/dialogs.dart';
import 'package:k2e/widgets/loading.dart';
import 'package:uuid/uuid.dart';

class EditCoc extends StatefulWidget {
  EditCoc({Key key, this.coc}) : super(key: key);
  final String coc;
  @override
  _EditCocState createState() => new _EditCocState();
}

class _EditCocState extends State<EditCoc> {
  String _title = "Edit Chain of Custody";
  bool isLoading = true;
  Map<String, dynamic> cocObj = new Map<String, dynamic>();

  // images
  String coc;
  bool localPhoto = false;
  List<Map<String, String>> roomgrouplist = new List();
  final Map constants = DataManager.get().constants;
  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<String>>();

//  final controllerRoomCode = TextEditingController();
  final _roomCodeController = TextEditingController();
  final _roomNameController = TextEditingController();

  List rooms;
  List items;
  List materials;
  List staff;
  final List<String> personnelSelected = <String>[];
  final List<DateTime> datesSelected = <DateTime>[];

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

  Widget build(BuildContext context) {
    print(staff.toString());
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
          ? loadingPage(loadingText: 'Loading Chain of Custody...')
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
                      Text(
                          cocObj['currentVersion'] == null
                              ? 'Not issued'
                              : 'Latest version: ' + cocObj['currentVersion'],
                          style: Styles.comment),
                      new Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(top: 14.0, bottom: 16.0),
                        child: new Text(
                          "Sample Date(s)",
                          style: Styles.label,
                        ),
                      ),
                      Calendarro(
//                  startDate: DateUtils.getFirstDayOfMonth(new DateTime.now().month - 2),
//                  endDate: DateUtils.getLastDayOfNextMonth(),
                        selectionMode: SelectionMode.MULTI,
                        displayMode: DisplayMode.WEEKS,
//                  dayTileBuilder: ,
                        selectedDates: datesSelected,
//                  selectedDates: cocObj['dates'].map((date) { return new DateTime(date); } ).toList(),
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
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.fromLTRB(
                                  2.0,
                                  8.0,
                                  4.0,
                                  8.0,
                                ),
                                child: new OutlineButton(
                                  child: const Text("Add 10 More Rows"),
                                  color: Colors.white,
                                  onPressed: () {
                                    showRoomTemplateDialog(
                                      context,
                                      cocObj,
                                      applyTemplate,
                                    );
                                  },
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                ),
                              ),
                            ],
                          ),
                          (cocObj['samples'] != null &&
                                  cocObj['samples'].length > 0)
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: cocObj['samples'].length,
                                  itemBuilder: (context, index) {
                                    return buildSamples(index);
                                  })
                              : new Container(),
//                    buildBuildingMaterials(),
                        ],
                      ),
                    ]),
              ),
            ),
    );
  }

  buildSamples(index) {
//      print("Building item: " + item.toString());
    var item = cocObj['samples'][index];
    TextEditingController labelController =
        TextEditingController(text: item['label']);
    TextEditingController materialController =
        TextEditingController(text: item['material']);
    Widget widget = new Row(children: <Widget>[
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
          onSaved: (value) => cocObj['samples'][index]["label"] = value.trim(),
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
          onSaved: (value) =>
              cocObj['samples'][index]["material"] = value.trim(),
          validator: (value) {},
          focusNode: _focusNodes[(index * 2) + 3],
          nextFocus: (cocObj['samples'].length - 1 != index &&
                  cocObj['samples'][index + 1] != null &&
                  cocObj['samples'][index + 1]["label"].trim().length > 0)
              ? _focusNodes[((index + 1) * 2) + 3]
              : _focusNodes[((index + 1) * 2) + 2],
        ),
      )
    ]);
    return widget;
  }

  void applyTemplate(cocObj) {
    this.setState(() {
      cocObj = cocObj;
    });
  }

  void _loadCoc() async {
//    print("Loading room");
    if (coc == null) {
      _title = "Add New Chain of Custody";
      cocObj['deleted'] = false;

      // New room requires us to create a path so it doesn't need internet to get one from Firestore
      cocObj['path'] = new Uuid().v1();

      setState(() {
        isLoading = false;
      });
    } else {
//      print('Edit room is ' + room.toString());
      _title = "Edit Chain of Custody";
      Firestore.instance.collection('cocs').document(coc).get().then((doc) {
        // image
        setState(() {
          cocObj = doc.data;
          print(cocObj['samples'].toString());
          if (cocObj['personnel'] != null)
            cocObj['personnel'].forEach((p) {
              personnelSelected.add(p);
            });
          if (cocObj['dates'] != null)
            cocObj['dates'].forEach((d) {
              datesSelected.add(d);
            });
          else
            datesSelected.add(new DateTime.now());
          _roomNameController.text = cocObj['name'];
          _roomCodeController.text = cocObj['roomcode'];
          isLoading = false;
        });
      });
    }
//    print(_title.toString());
  }
}
