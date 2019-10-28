//
//  BJPUViewController+protected.h
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/3/8.
//

#import <BJVideoPlayerCore/BJVPlayerManager.h>
#import <BJLiveBase/BJLNetworking.h>
#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPUViewController.h"
#import "BJPUMediaControlView.h"
#import "BJPUMediaSettingView.h"
#import "BJPUSliderView.h"
#import "BJPUReloadView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BJPUViewController ()

@property (nonatomic) BJVPlayerManager *playerManager;
@property (nonatomic) BJPUVideoOptions *videoOptions;
@property (nonatomic) BJLAFNetworkReachabilityManager *reachablityManager;

@property (nonatomic) BJPUMediaControlView *mediaControlView;
@property (nonatomic) BJPUMediaSettingView *mediaSettingView;
@property (nonatomic) BJPUSliderView *sliderView;
@property (nonatomic) UIImageView *audioOnlyImageView;
@property (nonatomic) UIView *topBarView;
@property (nonatomic) UIButton *lockButton;
@property (nonatomic) BJPUReloadView *reloadView;

@property (nonatomic, nullable) NSString *videoID, *token;
@property (nonatomic, nullable) BJVDownloadItem *downloadItem;
@property (nonatomic, nullable) NSTimer *updateDurationTimer;
@property (nonatomic) NSArray *currentOptions;
@property (nonatomic) NSArray *rateList;
@property (nonatomic) NSUInteger rateIndex;
@property (nonatomic) NSUInteger definitionIndex;
@property (nonatomic) BOOL isPlayingTailAD, isLocalVideo, pauseByInterrupt;

@end

NS_ASSUME_NONNULL_END

