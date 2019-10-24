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
          "test",
          "asdasdasd",
          "https://oss-cn-shenzhen.aliyuncs.com/shenlun/pic/2019/10/22/16/1571732552500_45135fda-cc9e-41bf-a596-faa0345d61a3.jpg?OSSAccessKeyId=0qzfiBreffBeNSjN&Expires=4725419480&Signature=%2FzFcW2FZ5eEIzkrD3eF3iSyB6vE%3D",
          "08bad8c3f6f067286c794bd30e6f7e3c",
          "19102354370699",
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
      onTap: () {
        FlutterLive.instance.startVideoActivity(
          "Grey",
          "Hunt123459999",
          "7Enorfb7ARbPdaHUGveyXfIS9zHKsJoQgS-_vFmWAUEHOnWKCLWbAg",
          "27725726",
          "这是一个测试的标题",
        );
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
          "19101439231218",
          "HaMD5BeUx-PPdaHUGveyXZK_gYveYItZq-5C3ldqmyCDeKo7A43xJzPqtYznXLn1CqdH1zJ1Si0",
          "0",
        );
      },
    );
  }
}
