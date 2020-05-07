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
        body: Column(
          children: <Widget>[
            _buildLiveBtn(),
            _buildVideoBtn(),
            _buildPlayBackBtn(),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveBtn() {
    return GestureDetector(
      child: Container(
        height: 50.0,
        width: double.infinity,
        color: Colors.red.shade200,
        child: Center(
          child: Text(
            "Flutter 直播点击",
            style: TextStyle(color: Colors.white),
          ),
        ),
        margin: EdgeInsets.all(16.0),
      ),
      onTap: () {
        FlutterLive.instance.startLiveActivity(
          "",
          "",
          "",
          "",
          "",
        );
//            FlutterLive.instance.startTestActivity();
      },
    );
  }

  Widget _buildVideoBtn() {
    return GestureDetector(
      child: Container(
        height: 50.0,
        width: double.infinity,
        color: Colors.blue.shade200,
        child: Center(
          child: Text(
            "Flutter 点播点击",
            style: TextStyle(color: Colors.white),
          ),
        ),
        margin: EdgeInsets.all(16.0),
      ),
      onTap: () async {
        double rate = await FlutterLive.instance.startVideoActivity(
          "",
          "",
          "",
          "",
          "",
        );

        print("播放进度 ： $rate");
      },
    );
  }

  Widget _buildPlayBackBtn() {
    return GestureDetector(
      child: Container(
        height: 50.0,
        width: double.infinity,
        color: Colors.green.shade200,
        child: Center(
          child: Text(
            "Flutter 回放点击",
            style: TextStyle(color: Colors.white),
          ),
        ),
        margin: EdgeInsets.all(16.0),
      ),
      onTap: () {
        FlutterLive.instance.startPlayBackActivity(
          "",
          "",
          "0",
        );
      },
    );
  }
}
