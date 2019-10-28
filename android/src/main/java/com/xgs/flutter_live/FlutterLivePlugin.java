package com.xgs.flutter_live;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nonnull;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * Created  on 2019/10/11.
 *
 * @author grey
 */
public class FlutterLivePlugin implements MethodCallHandler, BJYController.VideoProgressListener {

    private final MethodChannel methodChannel;
    private MethodChannel.Result result;
    private final Registrar registrar;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        new FlutterLivePlugin(registrar);
    }

    @Override
    public void onMethodCall(@Nonnull MethodCall call, @Nonnull MethodChannel.Result result) {
        if (registrar.activity() == null) {
            result.error("no_activity", "Flutter_Live plugin requires a foreground activity.", null);
            return;
        }
        this.result = result;
        if (call.method.equals("startLive")) {
            BJYController.startLiveActivity(registrar.activity(), new BJYLiveOption().create(call));
            return;
        }
        if (call.method.equals("startBack")) {
            BJYController.startBJYPlayBack(registrar.activity(), new BJYBackOption().create(call));
            return;
        }
        if (call.method.equals("startVideo")) {
            BJYController.startBJYPVideo(registrar.activity(), new BJYVideoOption().create(call));
        }
    }

    private FlutterLivePlugin(Registrar registrar) {
        // 设置监听
        BJYController.videoProgressListener = this;

        this.registrar = registrar;
        methodChannel = new MethodChannel(registrar.messenger(), "flutter_live");
        methodChannel.setMethodCallHandler(this);
    }


    @Override
    public void onPlayRateOfProgress(int currentTime, int duration) {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("progress", currentTime);
        resultMap.put("totalProgress", duration);
        result.success(resultMap);
    }
}
