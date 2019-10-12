import 'package:flutter/services.dart';

/// Created  on 2019/10/12.
/// @author grey
/// Function :
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

  //跳转直播
  void startLiveActivity() {
    _channel.invokeMethod("startLive", {'path': ""});
  }
}
