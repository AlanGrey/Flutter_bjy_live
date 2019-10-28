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
          "123456",
          "12555500000",
          "https://oss-cn-shenzhen.aliyuncs.com/shenlun/pic/2019/10/24/17/1571908699755_9e4bdfc0-089a-4f39-92bb-f6d2ee8ff868.jpg?OSSAccessKeyId=0qzfiBreffBeNSjN&Expires=4725673163&Signature=comRZqMZjoi%2F1SuzFHi18To%2BLao%3D",
          "0fdc59c147d43f75a6e05d50fcf9f209",
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
      onTap: () async {
        double rate = await FlutterLive.instance.startVideoActivity(
          "Grey",
          "Hunt123459999",
          "7Enorfb7ARbPdaHUGveyXfIS9zHKsJoQgS-_vFmWAUEHOnWKCLWbAg",
          "27725726",
          "这是一个测试的标题",
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
          "19101439231218",
          "HaMD5BeUx-PPdaHUGveyXZK_gYveYItZq-5C3ldqmyCDeKo7A43xJzPqtYznXLn1CqdH1zJ1Si0",
          "0",
        );
      },
    );
  }
}
