//
//  BJPUViewController+ui.m
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/3/8.
//

#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPUViewController+ui.h"
#import "BJPUViewController+protected.h"
#import "BJPUTheme.h"

@implementation BJPUViewController (ui)

- (void)setupSubviews {
    // playerView
    UIView *playerView = self.playerManager.playerView;
    [self.view addSubview:playerView];
    [playerView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    // audioOnlyImageView
    [self.view addSubview:self.audioOnlyImageView];
    [self.audioOnlyImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(playerView);
    }];
    
    // mediaControlView
    [self.view addSubview:self.mediaControlView];
    [self.mediaControlView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.height.equalTo(@40.0).priorityHigh();
    }];
    
    // topBarView
    CGFloat topBarHeight = 44.0;
    [self.view addSubview:self.topBarView];
    [self.topBarView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@(topBarHeight)).priorityHigh();
    }];
    
    // cancelButton
    UIButton *cancelButton = ({
        UIButton *button = [[UIButton alloc] init];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button setImage:[BJPUTheme backButtonImage] forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0);
        [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        
        button;
    });
    [self.topBarView addSubview:cancelButton];
    [cancelButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.topBarView.bjl_safeAreaLayoutGuide ?: self.topBarView);
        make.centerY.equalTo(self.topBarView);
        make.size.equal.sizeOffset(CGSizeMake(topBarHeight * 1.5, topBarHeight));
    }];
    
    
    UILabel *titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.tag = 111;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.font = [UIFont systemFontOfSize:14];
        [label sizeToFit];
        label.textColor = UIColor.whiteColor;
        label.text = @"";
        label;
        
    });
    
    [self.topBarView addSubview:titleLabel];
    [titleLabel bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.left.equalTo(cancelButton.bjl_right).offset(-10);
        make.centerY.equalTo(self.topBarView);
        make.right.equalTo(self.topBarView.bjl_right).offset(-20);
    }];
    
    
    
    // sliderView
    [self.view addSubview:self.sliderView];
    [self.sliderView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topBarView.bjl_bottom);
        make.bottom.equalTo(self.mediaControlView.bjl_top);
    }];
    
    // lockButton
    [self.view addSubview:self.lockButton];
    [self.lockButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view).offset(20.0);
        make.centerY.equalTo(self.view);
    }];
    
    // mediaSettingView
    [self.view addSubview:self.mediaSettingView];
    [self.mediaSettingView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.view.bjl_safeAreaLayoutGuide ?: self.view);
        make.width.equalTo(@(80.0));
    }];
    
    // reload view
    [self.view addSubview:self.reloadView];
    [self.reloadView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self setupControlActions];
}

#pragma mark - actions

- (void)setupControlActions {
    // show & hide
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideInterfaceViews)];
    [self.sliderView addGestureRecognizer:tap];
    
    // lock
    [self.lockButton addTarget:self action:@selector(lockAction) forControlEvents:UIControlEventTouchUpInside];
    
    // cancel
    bjl_weakify(self);
    [self.reloadView setCancelCallback:^{
        bjl_strongify(self);
        [self cancelAction];
    }];
}

- (void)backAction {
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && self.layoutType == BJVPlayerViewLayoutType_Horizon) {
        [self setLayoutType:BJVPlayerViewLayoutType_Vertical];
    }
    else {
        [self cancelAction];
    }
}

- (void)cancelAction {
    if (self.cancelCallback) {
        self.cancelCallback();
    }
    else if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (self.parentViewController) {
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }
    [self.playerManager destroy];
}

- (void)lockAction {
    BOOL lock = !self.lockButton.selected;
    self.lockButton.selected = lock;
    self.mediaControlView.hidden = lock;
    self.mediaSettingView.hidden = YES;
    self.topBarView.hidden = lock;
    self.sliderView.slideEnabled = !lock;
    [self.mediaControlView setSlideEnable:!lock];
    if (self.screenLockCallback) {
        self.screenLockCallback(lock);
    }
}

#pragma mark - show & hide

- (void)hideInterfaceViews {
    NSTimeInterval duration = 1.0;
    [self hideView:self.topBarView withDuration:duration];
    [self hideView:self.mediaControlView withDuration:duration];
    [self hideView:self.lockButton withDuration:duration];
}

- (void)hideInterfaceViewsAutomatically {
    if (!self.mediaControlView.slideCanceled) {
        // 进度条响应交互中，不执行隐藏
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideInterfaceViewsAutomatically) object:nil];
        [self performSelector:@selector(hideInterfaceViewsAutomatically) withObject:nil afterDelay:5.0];
        return;
    }
    [self hideInterfaceViews];
}

- (void)showOrHideInterfaceViews {
    if (self.layoutType == BJVPlayerViewLayoutType_Horizon) {
        self.lockButton.hidden = !self.lockButton.hidden;
        [self hideView:self.mediaSettingView withDuration:0.5];
    }
    if (self.lockButton.selected) {
        return;
    }
    
    if (self.layoutType == BJVPlayerViewLayoutType_Horizon && !self.mediaSettingView.hidden) {
        self.mediaSettingView.hidden = YES;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideInterfaceViewsAutomatically) object:nil];
    BOOL hidden = !self.mediaControlView.hidden;
    self.mediaControlView.hidden = hidden;
    self.topBarView.hidden = hidden;
    if (!self.mediaControlView.hidden) {
        [self performSelector:@selector(hideInterfaceViewsAutomatically) withObject:nil afterDelay:5.0];
    }
}

- (void)hideView:(UIView *)view withDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        view.hidden = YES;
        view.alpha = 1.0;
    }];
}

#pragma mark - public

- (void)updateConstriantsWithLayoutType:(BJVPlayerViewLayoutType)layoutType {
    BOOL horizon = (layoutType == BJVPlayerViewLayoutType_Horizon);
    BOOL locked = self.lockButton.selected;
    if (locked && !horizon) {
        [self setLayoutType:BJVPlayerViewLayoutType_Horizon];
        return;
    }
    [self setLayoutType:layoutType];
    [self updatePlayProgress];
    
    [self.mediaControlView updateConstraintsWithLayoutType:horizon];
    
   // [self updateTopBarConstriantsWithLayoutType:horizon];
    
    BOOL controlHidden = self.mediaControlView.hidden;
    // mediaSettingView: 1: 竖屏：直接隐藏；2.之前是隐藏状态，继续保持。
    self.mediaSettingView.hidden = !horizon || self.mediaSettingView.hidden;
    self.lockButton.hidden = !horizon || controlHidden;
}

-(void)updateTopBarConstriantsWithLayoutType:(BOOL)horizon {
    
    UIView *tb = self.topBarView ;
    if (horizon) {
        
        [tb bjl_updateConstraints:^(BJLConstraintMaker * _Nonnull make) {
            make.top.equalTo(self.view).offset(0);
        }];
        
        
    }else{
        
        [tb bjl_updateConstraints:^(BJLConstraintMaker * _Nonnull make) {
            make.top.equalTo(self.view).offset(22);
        }];
    }
    
    
}

- (void)updatePlayerViewConstraintWithVideoRatio:(CGFloat)ratio {
    UIView *playerView = self.playerManager.playerView;
    [playerView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        if (ratio > 0) {
            make.edges.equalTo(self.view).priorityHigh();
            make.width.equalTo(playerView.bjl_height).multipliedBy(ratio);
            make.center.equalTo(self.view);
            make.top.left.greaterThanOrEqualTo(self.view);
            make.bottom.right.lessThanOrEqualTo(self.view);
        }
        else {
            make.edges.equalTo(self.view);
        }
    }];
}

- (void)updatePlayProgress {
    NSTimeInterval curr = self.playerManager.currentTime;
    NSTimeInterval cache = self.playerManager.cachedDuration;
    NSTimeInterval total = self.playerManager.duration;
    BOOL horizon = (self.layoutType == BJVPlayerViewLayoutType_Horizon);
    
    [self.mediaControlView updateProgressWithCurrentTime:curr
                                           cacheDuration:cache
                                           totalDuration:total
                                              isHorizon:horizon];
}

- (void)updateWithPlayState:(BJVPlayerStatus)state {
    if (state == BJVPlayerStatus_paused ||
        state == BJVPlayerStatus_stopped ||
        state == BJVPlayerStatus_reachEnd ||
        state == BJVPlayerStatus_failed ||
        state == BJVPlayerStatus_ready) {
        [self.mediaControlView updateWithPlayState:NO];
    }
    else if (state == BJVPlayerStatus_playing) {
        [self.mediaControlView updateWithPlayState:YES];
    }
    
    [self updatePlayProgress];
}

- (void)showMediaSettingView {
    if (self.layoutType != BJVPlayerViewLayoutType_Horizon) {
        return;
    }
    [self hideInterfaceViews];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.mediaSettingView.hidden = NO;
    });
}

- (BOOL)isHorizon {
    UIView *superView = self.view.superview;
    if (!superView) {
        return YES;
    }
    else {
        return superView.bounds.size.width > superView.bounds.size.height;
    }
}

@end
