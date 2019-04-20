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
