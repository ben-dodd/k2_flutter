import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/model/samples/sample_asbestos_bulk.dart';
import 'package:k2e/theme.dart';

class SampleAsbestosBulkCard extends StatefulWidget {

  SampleAsbestosBulkCard({
    this.doc,
    @required this.onCardClick,
    @required this.onCardLongPress,
  });

  final DocumentSnapshot doc;
//  final SampleAsbestosBulk sample;

  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;

  @override
  _SampleAsbestosBulkCardState createState() => new _SampleAsbestosBulkCardState();

}

class _SampleAsbestosBulkCardState extends State<SampleAsbestosBulkCard>{
  String jobNumber;
  String sampleNumber;
  String description;
  String material;
  bool hasPhoto;
  @override
  Widget build(BuildContext context) {
    // todo is there a better way to assert this stuff
    if (widget.doc['jobNumber'] == null) {
      jobNumber = 'AS******';
    } else {
      jobNumber = widget.doc['jobNumber'];
    }
    if (widget.doc['sampleNumber'] == null) {
      sampleNumber = '0';
    } else {
      sampleNumber = widget.doc['sampleNumber'].toString();
    }
    if (widget.doc['description'] == null) {
      description = 'No description';
    } else {
      description = widget.doc['description'];
    }
    if (widget.doc['material'] == null) {
      material = 'Undefined material';
    } else {
      material = widget.doc['material'];
    }
    if (widget.doc['imagePath'] == null) {
      hasPhoto = false;
    } else {
      hasPhoto = true;
    }

    return new ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      dense: true,
      leading: new RawMaterialButton(
        onPressed: () {widget.onCardClick;},
        child: new Text(sampleNumber
        ),
        shape: new CircleBorder(),
        elevation: 2.0,
        fillColor: CompanyColors.accentRippled,
        padding: const EdgeInsets.all(10.0),
      ),
//      leading: const Icon(Icons.whatshot),
      title: Text(description),
      subtitle: Text(material),

//      subtitle: Text(widget.sample.description + '(' + widget.sample.material + ')'),
      // Tap -> go through to job task
      onTap: widget.onCardClick,
      // Long tap -> add options to sync or delete
      onLongPress: widget.onCardLongPress,
      // TODO: Icons display whether sample has photo or not
      trailing:
        hasPhoto ? Icon(Icons.camera_alt, color: Colors.green,)
            : Icon(Icons.camera_alt, color: Colors.red)
    );
  }
}