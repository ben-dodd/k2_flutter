import 'package:flutter/material.dart';

class UnderConstructionPage extends StatelessWidget {
  UnderConstructionPage() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(64.0),
      child: Text('This feature is currently unavailable.',
          style: TextStyle(fontSize: 24.0, color: Colors.black87)),
    );
  }
}
