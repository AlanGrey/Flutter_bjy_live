package com.xgs.flutter_live;


import android.app.Application;

import com.baijiayun.BJYPlayerSDK;

public class MyApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();

        //配置sdk
        new BJYPlayerSDK.Builder(this)
                .setDevelopMode(BuildConfig.DEBUG)
                .build();

    }
}
