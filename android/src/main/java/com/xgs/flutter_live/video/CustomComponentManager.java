package com.xgs.flutter_live.video;

import android.content.Context;

import com.baijiayun.BJYPlayerSDK;
import com.baijiayun.videoplayer.ui.component.ComponentManager;
import com.baijiayun.videoplayer.ui.component.ErrorComponent;
import com.baijiayun.videoplayer.ui.component.GestureComponent;
import com.baijiayun.videoplayer.ui.component.LoadingComponent;
import com.baijiayun.videoplayer.ui.component.MediaPlayerDebugInfoComponent;
import com.baijiayun.videoplayer.ui.component.MenuComponent;
import com.baijiayun.videoplayer.ui.event.UIEventKey;
import com.xgs.flutter_live.widget.CustomControllerComponent;

/**
 * Created  on 2019/10/24.
 *
 * @author grey
 */
public class CustomComponentManager extends ComponentManager {

    private Context context;
    private String title;

    public CustomComponentManager(Context context) {
        super(context);
    }

    public CustomComponentManager(Context context, String title) {
        this(context);
        this.context = context;
        this.title = title;
        generateCustomComponentList();
    }


    private void generateCustomComponentList() {
        release();
        addComponent(UIEventKey.KEY_LOADING_COMPONENT, new LoadingComponent(context));
        addComponent(UIEventKey.KEY_GESTURE_COMPONENT, new GestureComponent(context));
        //controller 需在gesture布局上方，否则会有事件冲突
        CustomControllerComponent controllerComponent = new CustomControllerComponent(context);
        controllerComponent.setTitleValue(this.title);
        addComponent(UIEventKey.KEY_CONTROLLER_COMPONENT, controllerComponent);
        addComponent(UIEventKey.KEY_ERROR_COMPONENT, new ErrorComponent(context));
        addComponent(UIEventKey.KEY_MENU_COMPONENT, new MenuComponent(context));
        if (BJYPlayerSDK.IS_DEVELOP_MODE) {
            addComponent(UIEventKey.KEY_VIDEO_INFO_COMPONENT, new MediaPlayerDebugInfoComponent(context));
        }
    }
}
