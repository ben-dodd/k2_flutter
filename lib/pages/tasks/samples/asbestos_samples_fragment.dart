import 'package:flutter/material.dart';
import 'package:k2e/data/datamanager.dart';
import 'package:k2e/data/repos/sample_asbestos_bulk_repo.dart';
import 'package:k2e/model/entities/samples/sample_asbestos_air.dart';
import 'package:k2e/model/entities/samples/sample_asbestos_bulk.dart';
import 'package:k2e/pages/tasks/samples/edit_asbestos_sample_bulk.dart';
import 'package:k2e/widgets/sample_asbestos_air_card.dart';
import 'package:k2e/widgets/sample_asbestos_bulk_card.dart';

class AsbestosSamplesFragment extends StatefulWidget {
  AsbestosSamplesFragment() : super();

  @override
  _AsbestosSamplesFragmentState createState() => new _AsbestosSamplesFragmentState();
}

class _AsbestosSamplesFragmentState extends State<AsbestosSamplesFragment> {
  bool _isLoading = false;
  bool _isBulk = true;
  bool _isAir = false;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    // This shouldn't be called on every build!
    List<SampleAsbestosBulk> _bulkSamples = new List();
    _bulkSamples = DataManager.get().currentJob.asbestosBulkSamples;
    List<SampleAsbestosAir> _airSamples = new List();
    _airSamples = DataManager.get().currentJob.asbestosAirSamples;

    if (_bulkSamples.length > 0) { _isBulk = true; }
    if (_airSamples.length > 0) { _isAir = true; }

    return new Scaffold(
      body:
      new Container(
          padding: new EdgeInsets.all(8.0),
          child: new Stack(
              children: <Widget>[
                _isLoading?
                new Container(alignment: AlignmentDirectional.center,
                    child: Column(
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          Text('Loading samples...')]))

                    : new Container(),
                // Check if any bulk samples
                _isBulk?
//                new Column(
//                    children: <Widget>[Text('Bulk Samples'),
                ListView.builder(
                    itemCount: _bulkSamples.length,
                    itemBuilder: (context, index) {
                      return SampleAsbestosBulkCard(
                          sample: _bulkSamples[index],
                          onCardClick: () async {
                            SampleAsbestosBulk result = await Navigator.of(context).push(
                              new MaterialPageRoute(builder: (context) => EditAsbestosSampleBulk(_bulkSamples[index])),
                            );
                            setState((){
                              if (result != null) {
                                // TODO Need to make this more robust, seems dodgy
                                SampleAsbestosBulkRepo.get().updateJob(result);
                                DataManager
                                    .get()
                                    .currentJob
                                    .asbestosBulkSamples[index] = result;
                              }
//      Scaffold.of(context).showSnackBar(
//          new SnackBar(
//              content: new Text(result.jobNumber + '-' + result.sampleNumber.toString() + " created")));
                            });

                          },
                          onCardLongPress: () async {

                          },);
                    }
                )
                    : new Container(),

                _isAir?
                new Column(
                  children: <Widget>[
                // Check if any air samples
                Text('Air Samples'),
                ListView.builder(
                    itemCount: _airSamples.length,
                    itemBuilder: (context, index) {
                      return SampleAsbestosAirCard(
                          sample: _airSamples[index],
                          onCardClick: () async {

                          },
                          onCardLongPress: () async {

                          },);
                    }
                ),])
                    : new Container(),
          ]
      ),
      )
    );
  }
}