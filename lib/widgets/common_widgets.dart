import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k2e/styles.dart';

class CheckLabel extends StatelessWidget {
  CheckLabel(
      {@required this.value,
        @required this.text,
        @required this.onClick,
      });
  final dynamic value;
  final ValueChanged onClick;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      new Container(
          alignment: Alignment.topLeft,
          child: Checkbox(
              value: value != null
                  ? value
                  : false,
              onChanged: onClick,
          )),
      new Container(
        alignment: Alignment.topLeft,
        child: new Text(text,
          style: Styles.label,
        ),
      ),
    ]);
  }
}

class RadioLabel extends StatelessWidget {
  RadioLabel(
      {@required this.value,
        @required this.text,
        @required this.onClick,
        @required this.groupValue,
      });
  final dynamic value;
  final dynamic groupValue;
  final ValueChanged onClick;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      new Container(
          alignment: Alignment.topLeft,
          child: Radio(
            value: value,
            groupValue: groupValue,
            onChanged: onClick,
          )),
      new Container(
        alignment: Alignment.topLeft,
        child: new Text(text,
          style: Styles.label,
        ),
      ),
    ]);
  }
}

class TextLabel extends StatelessWidget {
  TextLabel(
      {@required this.value,
        @required this.text,
      });
  final dynamic value;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
      new Container(
        alignment: Alignment.topLeft,
        child: new Text(text, style: Styles.label),
      ),
      new Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.only(bottom: 12.0),
          child: Text(value, style: Styles.body),
      ),
    ]);
  }
}


class EmptyList extends StatelessWidget {
  EmptyList(
      {@required this.text,
        this.action,
      });
  final String text;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.not_interested, size: 64.0),
              Container(
                  alignment: Alignment.center,
                  height: 64.0,
                  child: Text(text)),
              action != null ? action : new Container()
            ]
        )
    );
  }
}

class LoadingPage extends StatelessWidget {
  LoadingPage({Key key, @required this.loadingText}) : super(key: key);

  final String loadingText;
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new CircularProgressIndicator(),
              Container(
                  alignment: Alignment.center,
                  height: 64.0,
                  child: Text(loadingText, style: Styles.loading))
            ]));
  }
}

class ErrorPage extends StatelessWidget {
  ErrorPage() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.error),
              ),
              Text(
                'Error loading data',
                style: Styles.loading,
              )
            ],
          ),
        ));
  }
}
//
//class ItemList extends StatelessWidget {
//  ItemList({Key key, @required this.stream, @required this.context, @required this.snapshot, @required this.itemdesc, @required this.card}) : super(key: key);
//
//  final Stream<dynamic> stream;
//  final BuildContext context;
//  final QuerySnapshot snapshot;
//  final String itemdesc;
//  final Widget card;
//
//  @override
//  Widget build(context) {
//    return new StreamBuilder(
//        stream: stream,
//        builder: (context, snapshot) {
//          if (!snapshot.hasData)
//            return Container(
//                padding: EdgeInsets.only(top: 16.0),
//                alignment: Alignment.center,
//                color: Colors.white,
//                child: Column(
//                    mainAxisAlignment:
//                    MainAxisAlignment.center,
//                    children: <Widget>[
//                      new CircularProgressIndicator(),
//                      Container(
//                          alignment:
//                          Alignment.center,
//                          height: 64.0,
//                          child: Text(
//                              "Loading " + itemdesc + "..."))
//                    ]));
//          if (snapshot.data.documents.length == 0)
//            return EmptyList(
//                text: 'This job has no ' + itemdesc + '.'
//            );
//          return ListView.builder(
//              shrinkWrap: true,
//              physics:
//              NeverScrollableScrollPhysics(),
//              itemCount:
//              snapshot.data.documents.length,
//              itemBuilder: (context, index) {
//                var doc = snapshot
//                    .data.documents[index].data;
//                doc['path'] = snapshot.data
//                    .documents[index].documentID;
//                return card(
//                  doc: snapshot
//                      .data.documents[index],
//                  onCardClick: () async {
//                    if (snapshot.data
//                        .documents[index]
//                    ['sampletype'] ==
//                        'air') {
//                      Navigator.of(context).push(
//                        new MaterialPageRoute(
//                            builder: (context) =>
//                                EditSampleAsbestosAir(
//                                    sample: snapshot
//                                        .data
//                                        .documents[
//                                    index]
//                                        .documentID)),
//                      );
//                    } else {
//                      Navigator.of(context).push(
//                        new MaterialPageRoute(
//                            builder: (context) =>
//                                EditACM(
//                                    acm: snapshot
//                                        .data
//                                        .documents[
//                                    index]
//                                        .documentID)),
//                      );
//                    }
//                  },
//                  onCardLongPress: () {
//                    // Delete
//                    // Bulk add /clone etc.
//                  },
//                );
//              });
//        })
//  }
//}