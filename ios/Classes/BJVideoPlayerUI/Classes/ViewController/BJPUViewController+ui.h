//
//  BJPUViewController+ui.h
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/3/8.
//

#import "BJPUViewController.h"

@interface BJPUViewController (ui)

- (void)setupSubviews;

- (void)updateConstriantsWithLayoutType:(BJVPlayerViewLayoutType)layoutType;
- (void)updatePlayerViewConstraintWithVideoRatio:(CGFloat)ratio;
- (void)updatePlayProgress;
- (void)updateWithPlayState:(BJVPlayerStatus)state;
- (void)showMediaSettingView;
- (BOOL)isHorizon;

@end
