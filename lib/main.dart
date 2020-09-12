import 'package:flutter/material.dart';
import 'package:wasteagram01/wasteagram_ListScreen.dart';

void main()
{
  runApp(new WasteApp());
}

class WasteApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DetailsPage(),
    );
  }
}