package com.xgs.flutter_live;

import android.os.Bundle;

import javax.annotation.Nonnull;

import io.flutter.plugin.common.MethodCall;

/**
 * Created  on 2019/10/26.
 *
 * @author grey
 */
class BJYLiveOption {

    private String userName;
    private String avatarUrl;
    private String userNum;
    private String sign;
    private String roomId;

    BJYLiveOption create(@Nonnull MethodCall call) {
        this.userName = call.argument("userName");
        this.userNum = call.argument("userNum");
        this.avatarUrl = call.argument("userAvatar");
        this.sign = call.argument("sign");
        this.roomId = call.argument("roomId");
        return this;
    }

    String getUserName() {
        return userName == null ? "" : userName;
    }

    String getAvatarUrl() {
        return avatarUrl == null ? "" : avatarUrl;
    }

    String getUserNum() {
        return userNum == null ? "" : userNum;
    }

    String getSign() {
        return sign == null ? "" : sign;
    }

    Long getRoomId() {
        try {
            return Long.parseLong(roomId);
        } catch (Exception e) {
            return 0L;
        }
    }

}
