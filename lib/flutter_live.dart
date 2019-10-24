import 'package:flutter/services.dart';

/// Created  on 2019/10/12.
/// @author grey
/// Function :  直接跳转百家云平台
class FlutterLive {
  factory FlutterLive() => _getInstance();

  static FlutterLive get instance => _getInstance();
  static FlutterLive _instance;

  static FlutterLive _getInstance() {
    if (_instance == null) {
      _instance = new FlutterLive._internal();
    }
    return _instance;
  }

  FlutterLive._internal() {
    _channel = const MethodChannel('flutter_live');
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<dynamic> _methodCallHandler(MethodCall call) async {
    if (call.method == "callBack") {}
  }

  MethodChannel _channel;

  // 跳转直播
  void startLiveActivity(String userName, String userNum, String userAvatar, String sign, String roomId) {
    _channel.invokeMethod("startLive", {
      'userName': userName,
      'userNum': userNum,
      'userAvatar': userAvatar,
      'sign': sign,
      'roomId': roomId,
    });
  }

  // 跳转在线直播
  void startVideoActivity(String userName, String userId, String token, String videoId, String title) {
    _channel.invokeMethod("startVideo", {
      'videoId': videoId,
      'token': token,
      'userName': userName,
      'userId': userId,
      'title': title,
    });
  }

  void startTestActivity() {
    _channel.invokeListMethod("startTest", {
      'userName': '123456',
      'userNum': '12555500000',
      'userAvatar':
          'http://tmp/wx9fd2a84766c0dda5.o6zAJs0oTVyOg5T7zhHj3CN9L3oQ.twIfOl6IMgw12a17e8c1fb3c815fa16d70b17f6d6522.png',
      'sign': 'bebb30cdc6f7eeaf9bc5d34d4bd55616',
      'roomId': '19102354370699',
    });
  }
}
