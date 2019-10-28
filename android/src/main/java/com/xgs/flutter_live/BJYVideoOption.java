package com.xgs.flutter_live;

import android.os.Bundle;

import javax.annotation.Nonnull;

import io.flutter.plugin.common.MethodCall;

/**
 * Created  on 2019/10/28.
 *
 * @author grey
 */
class BJYVideoOption {

    private String videoId;
    private String token;
    private String userName;
    private String userId;
    private String title;

    BJYVideoOption create(@Nonnull MethodCall call) {
        this.videoId = call.argument("videoId");
        this.token = call.argument("token");
        this.userName = call.argument("userName");
        this.userId = call.argument("userId");
        this.title = call.argument("title");
        return this;
    }

    Long getVideoId() {
        try {
            return Long.parseLong(videoId);
        } catch (Exception e) {
            return 0L;
        }
    }

    String getToken() {
        return token == null ? "" : token;
    }

    String getUserName() {
        return userName == null ? "匿名用户" : userName;
    }

    String getUserId() {
        return userId == null ? "" : userId;
    }

    String getTitle() {
        return title;
    }

    Bundle bundle() {
        Bundle bundle = new Bundle();
        bundle.putBoolean("isOffline", false);
        bundle.putLong("videoId", getVideoId());
        bundle.putString("token", getToken());
        bundle.putString("userName", getUserName());
        bundle.putString("userId", getUserId());
        bundle.putString("title", getTitle());
        return bundle;
    }

}
