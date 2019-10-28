package com.xgs.flutter_live.video;

import android.content.Context;
import android.content.res.TypedArray;
import android.os.Build;
import android.os.Bundle;
import android.util.AttributeSet;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.baijiayun.constant.VideoDefinition;
import com.baijiayun.download.DownloadModel;
import com.baijiayun.glide.Glide;
import com.baijiayun.videoplayer.IBJYVideoPlayer;
import com.baijiayun.videoplayer.event.BundlePool;
import com.baijiayun.videoplayer.event.EventKey;
import com.baijiayun.videoplayer.event.OnPlayerEventListener;
import com.baijiayun.videoplayer.listeners.OnBufferedUpdateListener;
import com.baijiayun.videoplayer.listeners.OnBufferingListener;
import com.baijiayun.videoplayer.listeners.OnPlayerErrorListener;
import com.baijiayun.videoplayer.listeners.OnPlayerStatusChangeListener;
import com.baijiayun.videoplayer.listeners.OnPlayingTimeChangeListener;
import com.baijiayun.videoplayer.log.BJLog;
import com.baijiayun.videoplayer.player.PlayerStatus;
import com.baijiayun.videoplayer.player.error.PlayerError;
import com.baijiayun.videoplayer.render.AspectRatio;
import com.baijiayun.videoplayer.render.IRender;
import com.baijiayun.videoplayer.ui.event.UIEventKey;
import com.baijiayun.videoplayer.ui.utils.NetworkUtils;
import com.baijiayun.videoplayer.ui.widget.BaseVideoView;
import com.baijiayun.videoplayer.ui.widget.ComponentContainer;
import com.baijiayun.videoplayer.widget.BJYPlayerView;

/**
 *
 */

public class CustomBJYVideoView extends BaseVideoView {

    private static final String TAG = "CustomBJYVideoView";

    private BJYPlayerView bjyPlayerView;
    private long videoId;
    private String token;
    private String title;
    private boolean encrypted;
    private ImageView audioCoverIv;
    private int mAspectRatio = AspectRatio.AspectRatio_16_9.ordinal();
    private int mRenderType = IRender.RENDER_TYPE_SURFACE_VIEW;
    private boolean isPlayOnlineVideo = false;
    private IPlayProgressListener iPlayProgressListener;

    public CustomBJYVideoView(@NonNull Context context) {
        this(context, null);
    }

    public CustomBJYVideoView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CustomBJYVideoView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        TypedArray a = context.getTheme().obtainStyledAttributes(attrs, com.baijiayun.videoplayer.ui.R.styleable.BJVideoView, 0, 0);
        if (a.hasValue(com.baijiayun.videoplayer.ui.R.styleable.BJVideoView_aspect_ratio)) {
            mAspectRatio = a.getInt(com.baijiayun.videoplayer.ui.R.styleable.BJVideoView_aspect_ratio, AspectRatio.AspectRatio_16_9.ordinal());
        }
        if (a.hasValue(com.baijiayun.videoplayer.ui.R.styleable.BJVideoView_render_type)) {
            mRenderType = a.getInt(com.baijiayun.videoplayer.ui.R.styleable.BJVideoView_render_type, IRender.RENDER_TYPE_SURFACE_VIEW);
        }
        a.recycle();
    }


    @Override
    protected void init(Context context, AttributeSet attrs, int defStyleAttr) {
        bjyPlayerView = new BJYPlayerView(context, attrs);
        addView(bjyPlayerView);

        audioCoverIv = new ImageView(context);
        audioCoverIv.setScaleType(ImageView.ScaleType.FIT_XY);
        audioCoverIv.setVisibility(View.GONE);
        audioCoverIv.setLayoutParams(new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        addView(audioCoverIv);
    }

    /**
     * @param videoPlayer
     * @param shouldRenderCustomComponent 是否渲染播放器组件。回放只显示视频，不显示其它组件
     */
    public void initPlayer(IBJYVideoPlayer videoPlayer, boolean shouldRenderCustomComponent) {

        bjyVideoPlayer = videoPlayer;
        bjyVideoPlayer.bindPlayerView(bjyPlayerView);

        //初始化videoplayer之后才能设置宽高比
        bjyPlayerView.setRenderType(mRenderType);
        bjyPlayerView.setAspectRatio(AspectRatio.values()[mAspectRatio]);


        if (shouldRenderCustomComponent) {
            initComponentContainer();

            bjyVideoPlayer.addOnPlayerErrorListener(new OnPlayerErrorListener() {
                @Override
                public void onError(PlayerError error) {
                    Bundle bundle = BundlePool.obtain();
                    bundle.putString(EventKey.STRING_DATA, error.getMessage());
                    componentContainer.dispatchErrorEvent(error.getCode(), bundle);
                }
            });

            bjyVideoPlayer.addOnPlayingTimeChangeListener(new OnPlayingTimeChangeListener() {
                @Override
                public void onPlayingTimeChange(int currentTime, int duration) {
                    if (iPlayProgressListener != null) {
                        iPlayProgressListener.onProgressCallBack(currentTime, duration);
                    }
                    //只通知到controller component
                    Bundle bundle = BundlePool.obtainPrivate(UIEventKey.KEY_CONTROLLER_COMPONENT, currentTime);
                    componentContainer.dispatchPlayEvent(OnPlayerEventListener.PLAYER_EVENT_ON_TIMER_UPDATE, bundle);
                }
            });

            bjyVideoPlayer.addOnBufferUpdateListener(new OnBufferedUpdateListener() {
                @Override
                public void onBufferedPercentageChange(int bufferedPercentage) {
                    //只通知到controller component
                    Bundle bundle = BundlePool.obtainPrivate(UIEventKey.KEY_CONTROLLER_COMPONENT, bufferedPercentage);
                    componentContainer.dispatchPlayEvent(OnPlayerEventListener.PLAYER_EVENT_ON_BUFFERING_UPDATE, bundle);
                }
            });

            bjyVideoPlayer.addOnBufferingListener(new OnBufferingListener() {
                @Override
                public void onBufferingStart() {
                    BJLog.d("bjy", "onBufferingStart invoke");
                    componentContainer.dispatchPlayEvent(UIEventKey.PLAYER_CODE_BUFFERING_START, null);
                }

                @Override
                public void onBufferingEnd() {
                    BJLog.d("bjy", "onBufferingEnd invoke");
                    componentContainer.dispatchPlayEvent(UIEventKey.PLAYER_CODE_BUFFERING_END, null);
                }
            });
        } else {
            //回放模式下不监听网络
            useDefaultNetworkListener = false;
        }

        bjyVideoPlayer.addOnPlayerStatusChangeListener(new OnPlayerStatusChangeListener() {
            @Override
            public void onStatusChange(PlayerStatus status) {
                if (status == PlayerStatus.STATE_PREPARED) {
                    updateAudioCoverStatus(bjyVideoPlayer.getVideoInfo() != null && bjyVideoPlayer.getVideoInfo().getDefinition() == VideoDefinition.Audio);
                }
                if (componentContainer != null) {
                    Bundle bundle = BundlePool.obtain(status);
                    componentContainer.dispatchPlayEvent(OnPlayerEventListener.PLAYER_EVENT_ON_STATUS_CHANGE, bundle);
                }
            }
        });
    }

    public void initOtherInfo(String title) {
        this.title = title;
    }

    /**
     * 初始化播放器
     */
    public void initPlayer(IBJYVideoPlayer videoPlayer) {
        initPlayer(videoPlayer, true);
    }

    private void initComponentContainer() {
        componentContainer = new ComponentContainer(getContext());
        componentContainer.init(this, new CustomComponentManager(getContext(), this.title));
        componentContainer.setOnComponentEventListener(internalComponentEventListener);
        addView(componentContainer, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));
    }

    @Override
    protected void requestPlayAction() {
        super.requestPlayAction();
        //视频未初始化成功则请求视频地址
        if (isPlayOnlineVideo && (getVideoInfo() == null || getVideoInfo().getVideoId() == 0)) {
            setupOnlineVideoWithId(videoId, token, encrypted);
            sendCustomEvent(UIEventKey.CUSTOM_CODE_REQUEST_VIDEO_INFO, null);
        } else {
            play();
        }
    }

    /**
     * 设置播放百家云在线视频
     *
     * @param videoId 视频id
     * @param token   需要集成方后端调用百家云后端的API获取
     */
    public void setupOnlineVideoWithId(long videoId, String token) {
        setupOnlineVideoWithId(videoId, token, true);
    }

    /**
     * 设置播放百家云在线视频
     *
     * @param videoId   视频id
     * @param token     需要集成方后端调用百家云后端的API获取
     * @param encrypted 是否加密
     */
    public void setupOnlineVideoWithId(long videoId, String token, boolean encrypted) {
        this.videoId = videoId;
        this.token = token;
        this.encrypted = encrypted;
        if (useDefaultNetworkListener) {
            registerNetChangeReceiver();
        }
        if (!enablePlayWithMobileNetwork && NetworkUtils.isMobile(NetworkUtils.getNetworkState(getContext()))) {
            sendCustomEvent(UIEventKey.CUSTOM_CODE_NETWORK_CHANGE_TO_MOBILE, null);
        } else {
            bjyVideoPlayer.setupOnlineVideoWithId(videoId, token);
        }
        isPlayOnlineVideo = true;
    }

    /**
     * 设置播放本地文件路径(不支持记忆播放)
     *
     * @param path 视频文件绝对路径
     */
    public void setupLocalVideoWithFilePath(String path) {
        bjyVideoPlayer.setupLocalVideoWithFilePath(path);
        isPlayOnlineVideo = false;
    }

    public void setupLocalVideoWithDownloadModel(DownloadModel downloadModel) {
        bjyVideoPlayer.setupLocalVideoWithDownloadModel(downloadModel);
        isPlayOnlineVideo = false;
    }

    /**
     * 更新纯音频占位图状态
     */
    public void updateAudioCoverStatus(boolean isAudio) {
        if (isAudio) {
            audioCoverIv.setVisibility(View.VISIBLE);
            Glide.with(this)
                    .load(com.baijiayun.videoplayer.ui.R.drawable.ic_audio_only)
                    .into(audioCoverIv);
        } else {
            audioCoverIv.setVisibility(View.GONE);
        }
    }

    public void setPlayProgressListener(IPlayProgressListener listener) {
        this.iPlayProgressListener = listener;
    }
}
