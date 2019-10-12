package com.xgs.flutter_live;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.widget.Toast;

import com.baijiayun.live.ui.LiveSDKWithUI;
import com.baijiayun.livecore.context.LPConstants;

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
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (registrar.activity() == null) {
            result.error("no_activity", "Flutter_Live plugin requires a foreground activity.", null);
            return;
        }
        if (call.method.equals("startLive")) {
            startLiveActivity("", "", "", "", 0L);
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
}
