import 'package:flutter/services.dart';

/// Created  on 2019/10/12.
/// @author grey
/// Function :  直接跳转百家云平台

typedef OnVideoProgressCallback = Function(int, int);

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
    if (call.method == "video_progress") {}
  }

  MethodChannel _channel;

  // 跳转直播
  void startLiveActivity(String userName, String userNum, String userAvatar,
      String sign, String roomId) {
    _channel.invokeMethod("startLive", {
      'userName': userName,
      'userNum': userNum,
      'userAvatar': userAvatar,
      'sign': sign,
      'roomId': roomId,
    });
  }

  // 跳转在线回放
  void startPlayBackActivity(String roomId, String token, String sessionId) {
    _channel.invokeMethod("startBack", {
      'roomId': roomId,
      'token': token,
      'sessionId': sessionId,
    });
  }

  // 跳转在线点播
  Future<double> startVideoActivity(String userName, String userId,
      String token, String videoId, String title) async {
    final dynamic map = await _channel.invokeMethod("startVideo", {
      'videoId': videoId,
      'token': token,
      'userName': userName,
      'userId': userId,
      'title': title,
    });

    if (map is Map) {
      int progress = map["progress"] ?? 0;
      int totalProgress = map["totalProgress"] ?? 0;
      if (totalProgress == 0) {
        return 0;
      }
      double rate = (progress / totalProgress) * 100;
      return rate;
    }
    return 0;
  }
}
