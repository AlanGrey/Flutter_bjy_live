//
//  BJPUVideoOptions.h
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/4/24.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BJVideoPlayerCore/BJVPlayerManager.h>
#import <BJLiveBase/BJLYYModel.h>

@interface BJPUVideoOptions : NSObject <BJLYYModel>

@property (nonatomic, assign) BJVPlayerType playerType;         // 播放器类型
@property (nonatomic, assign) BOOL advertisementEnabled;        // 播放广告
@property (nonatomic, assign) BOOL autoplay;                    // 自动播放
@property (nonatomic, assign) BOOL sliderDragEnabled;           // 能否拖动进度条
@property (nonatomic, assign) BOOL playTimeRecordEnabled;       // 开启记忆播放
@property (nonatomic, assign) BOOL encryptEnabled;              // 开启加密
@property (nonatomic, assign) BOOL backgroundAudioEnabled;      // 开启后台播放，必须在工程的 background modes 中添加 audio 才会生效

// !!!TODO: 此属性仅用于测试 core 的初始时间 API，测试完成后需删除
@property (nonatomic, assign) NSTimeInterval initialPlayTime;   // 起始播放时间

/**
 偏好清晰度列表
 
 #discussion 优先使用此列表中的清晰度播放在线视频，优先级按数组元素顺序递减
 #discussion 列表元素为清晰度的标识字符串，现有标识符：low（标清），high（高清），superHD（超清），720p，1080p，audio（纯音频），可根据实际情况动态扩展
 #discussion 此设置对播放本地视频无效
 */
@property (nonatomic, strong) NSArray<NSString *> *preferredDefinitionList;

/**
 第三方用户名和编号
 
 #discussion 用于上报统计
 */
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) NSInteger userNumber;

@end
