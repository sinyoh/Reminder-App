import 'package:flutter/material.dart';

main() => runApp(TestAplikasi());

class TestAplikasi extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Aplikasi Kedua")),
        body: TextField(),),);
  }
}