import 'package:flutter/material.dart';
import 'package:k2e/model/samples/sample_asbestos_air.dart';

class SampleAsbestosAirCard extends StatefulWidget {

  SampleAsbestosAirCard({
    this.sample,
    @required this.onCardClick,
    @required this.onCardLongPress,
  });

  final SampleAsbestosAir sample;

  final VoidCallback onCardClick;
  final VoidCallback onCardLongPress;

  @override
  _SampleAsbestosAirCardState createState() => new _SampleAsbestosAirCardState();

}

class _SampleAsbestosAirCardState extends State<SampleAsbestosAirCard>{
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: const Icon(Icons.whatshot),
      title: Text(widget.sample.jobNumber + '-' + widget.sample.sampleNumber),
      subtitle: Text(widget.sample.description),
      // Tap -> go through to job task
      onTap: widget.onCardClick,
      // Long tap -> add options to sync or delete
      onLongPress: widget.onCardLongPress,
    );
  }
}