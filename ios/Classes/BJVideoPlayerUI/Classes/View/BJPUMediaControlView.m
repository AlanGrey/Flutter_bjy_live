//
//  BJPUMediaControlView.m
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/3/8.
//

#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPUMediaControlView.h"
#import "BJPUSliderView.h"
#import "BJPUProgressView.h"
#import "BJPUTheme.h"
#import "BJPUAppearance.h"

static const CGFloat controlButtonH = 30.0;

@interface BJPUMediaControlView () <BJPUSliderProtocol>

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *scaleButton;

@property (nonatomic, strong) UIButton *definitionButton;
@property (nonatomic, strong) UIButton *rateButton;

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) BJPUProgressView *progressView;
@property (nonatomic, assign) BOOL stopUpdateProgress;

@end

@implementation BJPUMediaControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:0.4];
        [self setupSubviews];
    }
    return self;
}

#pragma mark - subViews

- (void)setupSubviews {
    CGFloat margin = 10.0;
    
    // 播放按钮
    [self addSubview:self.playButton];
    [self.playButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self).offset(margin);
        make.centerY.equalTo(self);
        make.size.equal.sizeOffset(CGSizeMake(controlButtonH, controlButtonH));
    }];
    
    // 暂停按钮
    [self addSubview:self.pauseButton];
    [self.pauseButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.playButton);
    }];
    
    // 缩放按钮, 在 iPad 上不显示
    CGFloat scaleButtonWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)? 0.0 : controlButtonH;
    [self addSubview:self.scaleButton];
    [self.scaleButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-margin);
        make.height.equalTo(@(controlButtonH));
        make.width.equalTo(@(scaleButtonWidth)); // to update
    }];
    
    // 进度条: 约束待定
    [self addSubview:self.progressView];
    
    // 当前时间: 约束待定
    [self addSubview:self.currentTimeLabel];
    
    // 总时间: 约束待定
    [self addSubview:self.durationLabel];
    
    // 倍速按钮
    [self addSubview:self.rateButton];
    [self.rateButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.scaleButton.bjl_left).offset(-margin);
        make.height.equalTo(@(controlButtonH));
        make.width.equalTo(@0.0); // to update
    }];
    
    // 清晰度按钮
    [self addSubview:self.definitionButton];
    [self.definitionButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.rateButton.bjl_left).offset(-margin);
        make.height.equalTo(@(controlButtonH));
        make.width.equalTo(@0.0); // to update
    }];
}

#pragma mark - public

- (void)updateConstraintsWithLayoutType:(BOOL)horizon {
    CGFloat margin = 10.0;
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        // !!!: iPad 不显示缩放按钮
        [self.scaleButton bjl_updateConstraints:^(BJLConstraintMaker *make) {
            make.width.equalTo(horizon? @0.0 : @(controlButtonH));
        }];
    }
    
    [self.rateButton bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.width.equalTo(horizon? @45.0 : @0.0);
    }];
    
    [self.definitionButton bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.width.equalTo(horizon? @45.0 : @0.0);
    }];
    
    if (horizon) {
        [self.durationLabel bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self.definitionButton.bjl_left).offset(-margin);
        }];
        
        [self.currentTimeLabel bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.playButton.bjl_right).offset(margin);
        }];
        
        [self.progressView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.currentTimeLabel.bjl_right).offset(15.0);
            make.right.equalTo(self.durationLabel.bjl_left).offset(-15.0);
            make.height.equalTo(@10.0);
        }];
    }
    else {
        [self.progressView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.left.equalTo(self.playButton.bjl_right).offset(margin);
            make.right.equalTo(self.scaleButton.bjl_left).offset(-margin);
            make.centerY.equalTo(self.playButton);
            make.height.equalTo(@10.0);
        }];
        
        [self.durationLabel bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-5.0);
            make.right.equalTo(self.scaleButton.bjl_left).offset(-20.0);
        }];
        
        [self.currentTimeLabel bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.centerY.equalTo(self.durationLabel);
            make.right.equalTo(self.durationLabel.bjl_left);
        }];
    }
}

- (void)updateProgressWithCurrentTime:(NSTimeInterval)currentTime
                        cacheDuration:(NSTimeInterval)cacheDuration
                        totalDuration:(NSTimeInterval)totalDuration
                           isHorizon:(BOOL)isHorizon {
    if (self.stopUpdateProgress) {
        return;
    }
    BOOL durationInvalid = (ceil(totalDuration) <= 0);
    self.currentTimeLabel.text = (!isHorizon && durationInvalid)? @"" : [NSString stringFromTimeInterval:currentTime totalTimeInterval:totalDuration];
    NSString *separator = isHorizon? @"" : @" / ";
    self.durationLabel.text = durationInvalid? @"" : [NSString stringWithFormat:@"%@%@", separator, [NSString stringFromTimeInterval:totalDuration]];
    [self.progressView setValue:currentTime cache:cacheDuration duration:totalDuration];
}

- (void)updateWithPlayState:(BOOL)playing {
    self.playButton.hidden = playing;
    self.pauseButton.hidden = !playing;
}

- (void)setSlideEnable:(BOOL)enable {
    self.progressView.userInteractionEnabled = enable;
}

- (void)updateWithRate:(NSString *)rateString {
    [self.rateButton setTitle:rateString ?: @"1.0X" forState:UIControlStateNormal];
}

- (void)updateWithDefinition:(NSString *)definitionString {
    [self.definitionButton setTitle:definitionString ?: @"高清" forState:UIControlStateNormal];
}

#pragma mark - actions

- (void)playAction:(UIButton *)button {
    if (self.mediaPlayCallback) {
        self.mediaPlayCallback();
    }
    
    [self disablePlayControlsAndThenRecover];
}

- (void)pauseAction:(UIButton *)button {
    if (self.mediaPauseCallback) {
        self.mediaPauseCallback();
    }
    
    [self disablePlayControlsAndThenRecover];
}

- (void)scaleAction:(UIButton *)button {
    if (self.scaleCallback) {
        self.scaleCallback(YES);
    }
}

- (void)showRateList {
    if (self.showRateListCallback) {
        self.showRateListCallback();
    }
}

- (void)showDefinitionList {
    if (self.showDefinitionListCallback) {
        self.showDefinitionListCallback();
    }
}

- (void)sliderChanged:(BJPUVideoSlider *)slider {
    self.stopUpdateProgress = YES;
    self.slideCanceled = NO;
    if (slider.maximumValue > 0.0) {
        self.currentTimeLabel.text = [NSString stringFromTimeInterval:slider.value totalTimeInterval:slider.maximumValue];
    }
}

- (void)touchSlider:(BJPUVideoSlider *)slider {
    self.stopUpdateProgress = YES;
    self.slideCanceled = NO;
    if (slider.maximumValue > 0.0) {
        self.currentTimeLabel.text = [NSString stringFromTimeInterval:slider.value totalTimeInterval:slider.maximumValue];
    }
}

- (void)dragSlider:(BJPUVideoSlider *)slider {
    self.stopUpdateProgress = NO;
    self.slideCanceled = YES;
    if (self.mediaSeekCallback) {
        self.mediaSeekCallback(slider.value);
    }
}

- (void)disablePlayControlsAndThenRecover {
    [self setPlayControlButtonsEnabled:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setPlayControlButtonsEnabled:YES];
    });
}

- (void)setPlayControlButtonsEnabled:(BOOL)enabled {
    self.playButton.enabled = enabled;
    self.pauseButton.enabled = enabled;
}

#pragma mark - setters & getters

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[BJPUTheme playButtonImage] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _playButton;
}

- (UIButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[BJPUTheme pauseButtonImage] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
            button.hidden = YES;
            button;
        });
    }
    return _pauseButton;
}

- (UIButton *)scaleButton {
    if (!_scaleButton) {
        _scaleButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[BJPUTheme scaleButtonImage] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(scaleAction:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _scaleButton;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [BJPUTheme defaultTextColor];
            label.font = [UIFont systemFontOfSize:10.0];
            label;
        });
    }
    return _currentTimeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [BJPUTheme defaultTextColor];
            label.font = [UIFont systemFontOfSize:10.0];
            label;
        });
    }
    return _durationLabel;
}

- (BJPUProgressView *)progressView {
    if (!_progressView) {
        _progressView = ({
            BJPUProgressView *view = [[BJPUProgressView alloc] init];
            [view.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
            [view.slider addTarget:self action:@selector(touchSlider:) forControlEvents:UIControlEventTouchDragInside];
            [view.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchUpInside];
            [view.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchUpOutside];
            [view.slider addTarget:self action:@selector(dragSlider:) forControlEvents:UIControlEventTouchCancel];
            view;
        });
    }
    return _progressView;
}

- (UIButton *)definitionButton {
    if (!_definitionButton) {
        _definitionButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.clipsToBounds = YES;
            [button setTitleColor:[BJPUTheme defaultTextColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setTitle:@"清晰度" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(showDefinitionList) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _definitionButton;
}

- (UIButton *)rateButton {
    if (!_rateButton) {
        _rateButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.clipsToBounds = YES;
            [button setTitleColor:[BJPUTheme defaultTextColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setTitle:@"倍速" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(showRateList) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _rateButton;
}

@end
