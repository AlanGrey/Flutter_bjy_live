//
//  BJPUViewController.m
//  BJVideoPlayerUI
//
//  Created by DLM on 2017/4/26.
//
//

#import "BJPUViewController.h"
#import "BJPUProgressView.h"
#import "BJPUSliderView.h"

#import "BJPUMacro.h"
#import "BJPUTheme.h"
#import "BJPUAppearance.h"
#import "MBProgressHUD+bjp.h"

#import "BJPUViewController+protected.h"
#import "BJPUViewController+ui.h"
#import "BJPUViewController+observer.h"
#import "BJPUViewController+media.h"
#import "BJPUViewController+reachability.h"

@interface BJPUViewController () <BJPUSliderProtocol>

@property (nonatomic, assign) CGFloat seekTargetTime;

@end

@implementation BJPUViewController

- (instancetype)initWithVideoOptions:(BJPUVideoOptions *)videoOptions {
    self = [super init];
    if (self) {
        self.videoOptions = videoOptions;
    }
    return self;
}

- (void)dealloc {
    [self.reachablityManager stopMonitoring];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    // 子视图
    [self setupSubviews];
    // 监听
    [self setupObservers];
    // callback
    [self setMediaCallbacks];
    // 网络检查
    [self setupReachabilityManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 更新布局
    self.layoutType = [self isHorizon]? BJVPlayerViewLayoutType_Horizon : BJVPlayerViewLayoutType_Vertical;
    [self updateConstriantsWithLayoutType:self.layoutType];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.updateDurationTimer invalidate];
    self.updateDurationTimer = nil;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        // !!!: no setter for layoutType
        [self setNeedsStatusBarAppearanceUpdate];
        [self.view setNeedsUpdateConstraints];
    } completion:nil];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    BJVPlayerViewLayoutType layoutType = [self isHorizon]? BJVPlayerViewLayoutType_Horizon : BJVPlayerViewLayoutType_Vertical;
    [self updateConstriantsWithLayoutType:layoutType];
}

#pragma mark - setters & getters

- (BJVPlayerManager *)playerManager {
    if (!_playerManager) {
        _playerManager = ({
            BJVPlayerManager *manager = [[BJVPlayerManager alloc] initWithPlayerType:self.videoOptions.playerType];
            BJPUVideoOptions *options = self.videoOptions;
            manager.backgroundAudioEnabled = options.backgroundAudioEnabled;
            manager.preferredDefinitionList = options.preferredDefinitionList;
            manager.playTimeRecordEnabled = options.playTimeRecordEnabled;
            manager.initialPlayTime = options.initialPlayTime;
            manager.userName = options.userName;
            manager.userNumber = options.userNumber;
            manager;
        });
    }
    return _playerManager;
}

- (BJPUMediaControlView *)mediaControlView {
    if (!_mediaControlView) {
        _mediaControlView = ({
            BJPUMediaControlView *view = [[BJPUMediaControlView alloc] init];
            [view setSlideEnable:self.videoOptions.sliderDragEnabled];
            view;
        });
    }
    return _mediaControlView;
}

- (BJPUMediaSettingView *)mediaSettingView {
    if (!_mediaSettingView) {
        _mediaSettingView = [[BJPUMediaSettingView alloc] init];
        _mediaSettingView.hidden = YES;
    }
    return _mediaSettingView;
}

- (BJPUSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = ({
            BJPUSliderView *sliderView = [[BJPUSliderView alloc] init];
            sliderView.delegate = self;
            sliderView.slideEnabled = self.videoOptions.sliderDragEnabled;
            sliderView;
        });
    }
    return _sliderView;
}

- (UIImageView *)audioOnlyImageView {
    if (!_audioOnlyImageView) {
        _audioOnlyImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage bjpu_imageNamed:@"ic_audio_only"];
            imageView;
        });
    }
    return _audioOnlyImageView;
}

- (UIView *)topBarView {
    if (!_topBarView) {
        _topBarView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.4];
            view;
        });
    }
    return _topBarView;
}

- (UIButton *)lockButton {
    if (!_lockButton) {
        _lockButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage bjpu_imageNamed:@"ic_lock"] forState:UIControlStateNormal];
            [button setImage:[UIImage bjpu_imageNamed:@"ic_unlock"] forState:UIControlStateSelected];
            button;
        });
    }
    return _lockButton;
}

- (BJPUReloadView *)reloadView {
    if (!_reloadView) {
        _reloadView = ({
            BJPUReloadView *view = [[BJPUReloadView alloc] init];
            view.hidden = YES;
            view;
        });
    }
    return _reloadView;
}

- (NSArray *)rateList {
    if (!_rateList) {
        // iOS 10以下系统在 0.7、1.2 倍速时会出现音视频不同步，换成 0.8、1.25
        if (@available(iOS 10.0, *)) {
            _rateList = @[@0.7, @1.0, @1.2, @1.5, @2.0];
        }
        else {
            _rateList = @[@0.8, @1.0, @1.25, @1.5, @2.0];
        }
    }
    return _rateList;
}

#pragma mark - public interface

- (void)playWithVid:(NSString *)vid token:(NSString *)token {
    self.isLocalVideo = NO;
    self.videoID = vid;
    self.token = token;
    self.downloadItem = nil;
    
    [self clearOverlayViews];
    [self.playerManager setupOnlineVideoWithID:vid
                                         token:token
                                     encrypted:self.videoOptions.encryptEnabled
                                     accessKey:nil];
    if (self.videoOptions.autoplay) {
        [self.playerManager play];
    }
}

- (void)playWithDownloadItem:(BJVDownloadItem *)downloadItem {
    self.isLocalVideo = YES;
    self.downloadItem = downloadItem;
    self.videoID = nil;
    self.token = nil;
    
    // 清理 overlay
    [self clearOverlayViews];
    
    // 初始化播放器
    [self.playerManager setupLocalVideoWithDownloadItem:downloadItem];
    if (self.videoOptions.autoplay) {
        [self.playerManager play];
    }
}

- (void)setLayoutType:(BJVPlayerViewLayoutType)layoutType {
    BOOL shouldupdate = (_layoutType != layoutType);
    _layoutType = layoutType;
    
    BOOL horizon = [self isHorizon];
    if (layoutType == BJVPlayerViewLayoutType_Horizon && !horizon) {
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationLandscapeLeft) forKey:@"orientation"];
    }
    else if (layoutType == BJVPlayerViewLayoutType_Vertical && horizon) {
        [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    }
    else if (shouldupdate) {
        [self updateConstriantsWithLayoutType:_layoutType];
    }
}

#pragma mark - BJPUSliderProtocol

- (CGFloat)originValueForTouchSlideView:(BJPUSliderView *)touchSlideView {
    return self.playerManager.currentTime;
}

- (CGFloat)durationValueForTouchSlideView:(BJPUSliderView *)touchSlideView {
    return self.playerManager.duration;
}

- (void)touchSlideView:(BJPUSliderView *)touchSlideView finishHorizonalSlide:(CGFloat)value {
    // 控制频率，延时执行
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(videoSeekAction) object:nil];
    self.seekTargetTime = value;
    [self performSelector:@selector(videoSeekAction) withObject:nil afterDelay:0.8];
}

#pragma mark - action

- (void)videoSeekAction {
    [self seekToTime:self.seekTargetTime];
}

- (void)clearOverlayViews {
    self.reloadView.hidden = YES;
    self.mediaSettingView.hidden = YES;
}

@end
