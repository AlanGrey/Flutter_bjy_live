package com.xgs.flutter_live;

import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;

import com.baijiayun.download.DownloadModel;
import com.baijiayun.videoplayer.VideoPlayerFactory;
import com.baijiayun.videoplayer.event.BundlePool;
import com.baijiayun.videoplayer.ui.activity.BaseActivity;
import com.baijiayun.videoplayer.ui.event.UIEventKey;
import com.baijiayun.videoplayer.ui.listener.IComponentEventListener;
import com.baijiayun.videoplayer.util.Utils;
import com.xgs.flutter_live.video.CustomBJYVideoView;
import com.xgs.flutter_live.video.IPlayProgressListener;

/**
 * Created  on 2019/10/24.
 *
 * @author grey
 */
public class BJYVideoPlayerActivity extends BaseActivity {

    CustomBJYVideoView bjyVideoView;

    boolean isOffline = false;
    long videoId = 0L;
    String token = "";
    String userName = "";
    String userId = "";
    String title = "";
    DownloadModel downloadVideo;

    int progress = 0;
    int totalProgress = 0;

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        BJYController.onPlayRateOfProgress(progress, totalProgress);
        bjyVideoView.onDestroy();
    }

    @Override
    protected void requestLayout(boolean isLandscape) {
        super.requestLayout(isLandscape);
        LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) bjyVideoView.getLayoutParams();
        if (isLandscape) {
            layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
            layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT;
        } else {
            layoutParams.width = Utils.getScreenWidthPixels(this);
            layoutParams.height = layoutParams.width * 9 / 16;
        }
        bjyVideoView.setLayoutParams(layoutParams);
        bjyVideoView.sendCustomEvent(UIEventKey.CUSTOM_CODE_REQUEST_TOGGLE_SCREEN, BundlePool.obtain(isLandscape));

    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.a_bjv_video_player);
        findView();
        bindingView();
        initView();
    }

    void findView() {
        bjyVideoView = findViewById(R.id.video_player);
    }

    void bindingView() {
        bjyVideoView.setComponentEventListener(new IComponentEventListener() {
            @Override
            public void onReceiverEvent(int eventCode, Bundle bundle) {
                switch (eventCode) {
                    case UIEventKey.CUSTOM_CODE_REQUEST_BACK:
                        if (isLandscape) {
                            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                        } else {
                            finish();
                        }
                        break;
                    case UIEventKey.CUSTOM_CODE_REQUEST_TOGGLE_SCREEN:
                        setRequestedOrientation(isLandscape ?
                                ActivityInfo.SCREEN_ORIENTATION_PORTRAIT :
                                ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                        break;
                    default:
                        break;
                }
            }
        });
    }

    void initView() {

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            isOffline = bundle.getBoolean("isOffline", false);
            videoId = bundle.getLong("videoId", 0L);
            token = bundle.getString("token", "");
            userName = bundle.getString("userName", "");
            userId = bundle.getString("userId", "");
            title = bundle.getString("title", "");
            if (isOffline) {
                downloadVideo = bundle.getParcelable("videoDownloadData");
            }
        }

        bjyVideoView.initOtherInfo(title);
        bjyVideoView.initPlayer(new VideoPlayerFactory.Builder()
                //后台暂停播放
                .setSupportBackgroundAudio(true)
                //开启循环播放
                .setSupportLooping(false)
                //开启记忆播放
                .setSupportBreakPointPlay(true, this)
                .setUserInfo(userName, userId)
                //绑定activity生命周期
                .setLifecycle(getLifecycle()).build());

        bjyVideoView.setPlayProgressListener(new IPlayProgressListener() {
            @Override
            public void onProgressCallBack(int p, int tp) {
                if (progress <= p) {
                    progress = p;
                }
                if (totalProgress <= tp) {
                    totalProgress = tp;
                }
            }
        });

        if (isOffline) {
            bjyVideoView.setupLocalVideoWithDownloadModel((DownloadModel) getIntent().getSerializableExtra("videoDownloadModel"));
        } else {
            bjyVideoView.setupOnlineVideoWithId(videoId, token, true);
        }
        if (isLandscape) {
            requestLayout(true);
        }

    }
}
