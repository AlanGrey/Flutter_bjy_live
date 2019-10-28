package com.xgs.flutter_live;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import com.baijiayun.live.ui.LiveSDKWithUI;
import com.baijiayun.livecore.context.LPConstants;
import com.baijiayun.videoplayer.ui.playback.PBRoomUI;

/**
 * Created  on 2019/10/26.
 *
 * @author grey
 */
public class BJYController {

    public static VideoProgressListener videoProgressListener;

    // 跳转直播
    static void startLiveActivity(final Activity activity, BJYLiveOption option) {
        // 编辑用户信息
        LiveSDKWithUI.LiveRoomUserModel userModel = new LiveSDKWithUI.LiveRoomUserModel(option.getUserName(), option.getAvatarUrl(), option.getUserNum(), LPConstants.LPUserType.Student);
        // 进入直播房间
        LiveSDKWithUI.enterRoom(activity, option.getRoomId(), option.getSign(), userModel, new LiveSDKWithUI.LiveSDKEnterRoomListener() {
            @Override
            public void onError(String s) {
                Toast.makeText(activity, s, Toast.LENGTH_SHORT).show();
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

    // 跳转到回放
    static void startBJYPlayBack(final Activity activity, BJYBackOption backOption) {
        PBRoomUI.enterPBRoom(activity, backOption.getRoomId(), backOption.getToken(), backOption.getSessionId(), new PBRoomUI.OnEnterPBRoomFailedListener() {
            @Override
            public void onEnterPBRoomFailed(String s) {
                Toast.makeText(activity, s, Toast.LENGTH_SHORT).show();
            }
        });
    }


    // 跳转到点播
    static void startBJYPVideo(final Activity activity, BJYVideoOption videoOption) {
        Intent intent = new Intent(activity, BJYVideoPlayerActivity.class);
        intent.putExtras(videoOption.bundle());
        activity.startActivity(intent);
    }

    // 进度回调
    static void onPlayRateOfProgress(int currentTime, int duration) {
        if (videoProgressListener != null) {
            videoProgressListener.onPlayRateOfProgress(currentTime, duration);
        }
    }

    public interface VideoProgressListener {

        void onPlayRateOfProgress(int currentTime, int duration);

    }

}
