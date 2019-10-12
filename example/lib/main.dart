import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_live/flutter_live.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: GestureDetector(
          child: Container(
            height: 50.0,
            width: double.infinity,
            color: Colors.red.shade200,
            child: Center(
              child: Text(
                "Flutter 点击",
                style: TextStyle(color: Colors.white),
              ),
            ),
            margin: EdgeInsets.all(16.0),
          ),
          onTap: (){
            FlutterLive.instance.startTestActivity();
          },
        ),
      ),
    );
  }
}
