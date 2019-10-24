package com.xgs.flutter_live;

import android.app.AlertDialog;
import android.app.PendingIntent;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.baijiayun.live.ui.LiveSDKWithUI;
import com.baijiayun.livecore.context.LPConstants;

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
public class FlutterLivePlugin implements MethodCallHandler {

    private final MethodChannel methodChannel;
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
        if (call.method.equals("startLive")) {
            String userName = call.argument("userName");
            String userNum = call.argument("userNum");
            String userAvatar = call.argument("userAvatar");
            String sign = call.argument("sign");
            String roomId = call.argument("roomId");
            if (roomId == null || roomId.equals("")) {
                roomId = "0";
            }
            startLiveActivity(userName, userAvatar, userNum, sign, Long.parseLong(roomId));
            return;
        }
        if (call.method.equals("startVideo")) {
            String videoId = call.argument("videoId");
            String token = call.argument("token");
            String userName = call.argument("userName");
            String userId = call.argument("userId");
            String title = call.argument("title");
            if (videoId == null || videoId.equals("")) {
                videoId = "0";
            }
            startBJYPVideo(userName, userId, token, Long.parseLong(videoId), title);
            return;
        }
        if (call.method.equals("startTest")) {
            String userName = call.argument("userName");
            String userNum = call.argument("userNum");
            String userAvatar = call.argument("userAvatar");
            String sign = call.argument("sign");
            String roomId = call.argument("roomId");

            Intent intent = new Intent(registrar.activity(), TestActivity.class);
            Bundle bundle = new Bundle();
            bundle.putString("userName", userName);
            bundle.putString("userNum", userNum);
            bundle.putString("userAvatar", userAvatar);
            bundle.putString("sign", sign);
            bundle.putString("roomId", roomId);
            intent.putExtras(bundle);
            registrar.activity().startActivity(intent);
        }
    }

    private FlutterLivePlugin(Registrar registrar) {
        this.registrar = registrar;
        methodChannel = new MethodChannel(registrar.messenger(), "flutter_live");
        methodChannel.setMethodCallHandler(this);
    }

    private void startLiveActivity(String userName, String avatarUrl, String userNum, String sign, long roomId) {
        // 编辑用户信息
        LiveSDKWithUI.LiveRoomUserModel userModel = new LiveSDKWithUI.LiveRoomUserModel(userName, avatarUrl, userNum, LPConstants.LPUserType.Student);
        // 进入直播房间
        LiveSDKWithUI.enterRoom(registrar.activity(), roomId, sign, userModel, new LiveSDKWithUI.LiveSDKEnterRoomListener() {
            @Override
            public void onError(String s) {
                Toast.makeText(registrar.context(), s, Toast.LENGTH_SHORT).show();
            }
        });

        //退出直播间二次确认回调 无二次确认无需设置
        LiveSDKWithUI.setRoomExitListener(new LiveSDKWithUI.LPRoomExitListener() {
            @Override
            public void onRoomExit(Context context, LiveSDKWithUI.LPRoomExitCallback callback) {
                callback.exit();
            }
        });

        //设置直播单点登录
        LiveSDKWithUI.setEnterRoomConflictListener(new LiveSDKWithUI.RoomEnterConflictListener() {
            @Override
            public void onConflict(Context context, LPConstants.LPEndType type, final LiveSDKWithUI.LPRoomExitCallback callback) {
                if (context != null) {
                    // 单点登录冲突 endType为冲突方终端类型
                    new AlertDialog.Builder(context)
                            .setTitle("提示")
                            .setMessage("已在其他设备观看")
                            .setCancelable(true)
                            .setPositiveButton("确定", new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                    callback.exit();
                                }
                            })
                            .create()
                            .show();
                }
            }
        });
    }

    // 跳转到点播
    private void startBJYPVideo(String userName, String userId, String token, long videoId, String title) {
        Intent intent = new Intent(registrar.activity(), BJYVideoPlayerActivity.class);
        Bundle bundle = new Bundle();
        bundle.putBoolean("isOffline", false);
        bundle.putLong("videoId", videoId);
        bundle.putString("token", token);
        bundle.putString("userName", userName);
        bundle.putString("userId", userId);
        bundle.putString("title", title);
        intent.putExtras(bundle);
        registrar.activity().startActivity(intent);
    }

}
