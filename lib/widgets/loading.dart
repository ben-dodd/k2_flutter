import 'package:flutter/material.dart';
import 'package:k2e/styles.dart';

class loadingPage extends StatelessWidget {
  loadingPage({Key key, @required this.loadingText}) : super(key: key);

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

class errorPage extends StatelessWidget {
  errorPage() : super();

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
