//
//  BJPUSliderView.m
//  BJVideoPlayerUI
//
//  Created by DLM on 2017/4/26.
//
//

#import <BJVideoPlayerCore/BJVPlayerMacro.h>
#import <MediaPlayer/MediaPlayer.h>
#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPUSliderView.h"
#import "BJPUAppearance.h"
#import "BJPUTheme.h"

typedef NS_ENUM(NSInteger, BJVSliderType) {
    BJVSliderType_None,
    BJVSliderType_Slide,
    BJVSliderType_Volume,
    BJVSliderType_Light
};

@interface BJPUSliderView ()
@property (strong, nonatomic) BJPUSliderSeekView *seekView;
@property (strong, nonatomic) BJPUSliderLightView *lightView;
@property (strong, nonatomic) MPVolumeView *volumeView;

@property (assign, nonatomic) CGFloat beginValue;
@property (assign, nonatomic) CGFloat durationValue;
@property (assign, nonatomic) CGFloat originVolume;
@property (assign, nonatomic) CGFloat originBrightness;

@property (assign, nonatomic) CGPoint touchBeganPoint;
@property (assign, nonatomic) BJVSliderType touchMoveType;
@end

@implementation BJPUSliderView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.seekView];
        [self.seekView bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.center.equal.to(@0);
            make.size.equal.sizeOffset(CGSizeMake(150, 80));
        }];
        
        self.slideEnabled = YES;
    }
    return self;
}

#pragma mark - touch event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.slideEnabled) {
        return;
    }
    if (touches.count == 1) {
        UITouch *touch = [touches anyObject];
        self.touchBeganPoint = [touch locationInView:self];
        self.touchMoveType = BJVSliderType_None;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.slideEnabled) {
        return;
    }
    if (touches.count == 1) { //单指滑动
        CGPoint movePoint = [[touches anyObject] locationInView:self];
        [self updateTouchMoveTypeByPoint:movePoint];
        
        CGFloat diffX = movePoint.x - self.touchBeganPoint.x;
        CGFloat diffY = movePoint.y - self.touchBeganPoint.y;
        if (self.touchMoveType == BJVSliderType_Slide) {
            [self.seekView resetRelTime:_beginValue duration:_durationValue difference:diffX/10];
            self.seekView.hidden = NO;
        }
        else if (self.touchMoveType == BJVSliderType_Light) {
            CGFloat brightness = self.originBrightness-diffY/100;
            if (brightness >= 1.0) {
                brightness = 1.0;
            }
            else if (brightness <= 0.0) {
                brightness = 0;
            }
            [[UIScreen mainScreen] setBrightness:brightness];
        }
        else if (self.touchMoveType == BJVSliderType_Volume) {
            CGFloat value = self.originBrightness-diffY/100;
            if (value >= 1.0) {
                value = 1.0;
            }
            else if (value <= 0.0) {
                value = 0;
            }
            [self volumeSlider].value = value;
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.slideEnabled) {
        return;
    }
    if (touches.count == 1) { //单指滑动
        UITouch *touch = [touches anyObject];
        CGPoint movePoint = [touch locationInView:self];
        CGFloat diff = movePoint.x - self.touchBeganPoint.x;
        if (fabs(diff/10) > 5 && self.touchMoveType == BJVSliderType_Slide) { //大于5秒
            CGFloat curr = [self modifyValue:self.beginValue + diff/10 minValue:0 maxValue:self.durationValue];
            [self.delegate touchSlideView:self finishHorizonalSlide:curr];
        }
    }
    self.seekView.hidden = YES;
    [UIView animateWithDuration:3 animations:^{
        self.lightView.alpha = 0.0f;
    }];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [BJLProgressHUD bjp_closeLoadingView:keyWindow];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.slideEnabled) {
        return;
    }
    self.seekView.hidden = YES;
    [UIView animateWithDuration:3 animations:^{
        self.lightView.alpha = 0.0f;
    }];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:keyWindow animated:YES];
}

#pragma mark touch private

- (void)updateTouchMoveTypeByPoint:(CGPoint)movePoint {
    CGFloat diffX = movePoint.x - self.touchBeganPoint.x;
    CGFloat diffY = movePoint.y - self.touchBeganPoint.y;
    if ((fabs(diffX) > 20 || fabs(diffY) > 20) && self.touchMoveType == BJVSliderType_None) {
        if (fabs(diffX/diffY) > 1.7) {
            self.touchMoveType = BJVSliderType_Slide;
            self.beginValue = [self.delegate originValueForTouchSlideView:self];
            self.durationValue = [self.delegate durationValueForTouchSlideView:self];
        }
        else if (fabs(diffX/diffY) < 0.6) {
            if (self.touchBeganPoint.x < (self.bounds.size.width / 2)) { //调亮度
                self.touchMoveType = BJVSliderType_Light;
                self.originBrightness = [UIScreen mainScreen].brightness;
                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                self.lightView.alpha = 1.0f;
                [keyWindow insertSubview:self.lightView aboveSubview:self];
                [self.lightView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
                    make.height.width.equalTo(@155);
                    make.centerY.centerX.equalTo(keyWindow);
                }];
            }
            else {
                self.touchMoveType = BJVSliderType_Volume;
                self.originVolume = [self volumeSlider].value;
            }
        }
    }
}

- (CGFloat)modifyValue:(double)value minValue:(double)min maxValue:(double)max {
    value = value < min ? min : value;
    value = value > max ? max : value;
    
    return value;
}

#pragma mark - set get

- (BJPUSliderSeekView *)seekView {
    if (!_seekView) {
        _seekView = [[BJPUSliderSeekView alloc] init];
        _seekView.layer.cornerRadius = 10.f;
        _seekView.hidden = YES;
    }
    return _seekView;
}

- (BJPUSliderLightView *)lightView {
    if (!_lightView) {
        _lightView = [[BJPUSliderLightView alloc] init];
    }
    return _lightView;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] init];
    }
    return _volumeView;
}

- (UISlider *)volumeSlider {
    for (UIView *newView in self.volumeView.subviews) {
        if ([newView isKindOfClass:[UISlider class]]) {
            UISlider *slider = (UISlider *)newView;
            slider.hidden = YES;
            slider.autoresizesSubviews = NO;
            slider.autoresizingMask = UIViewAutoresizingNone;
            return (UISlider *)slider;
        }
    }
    return nil;
}

@end


//
//  BJPUSliderLightView
//  Pods
//
//  Created by DLM on 2017/4/26.
//
//
@interface BJPUSliderLightView ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *lightView;
@property (strong, nonatomic) UIImageView *progressView;
@property (strong, nonatomic) UIView *coverView;
@end

@implementation BJPUSliderLightView
- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 155, 155)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius  = 10;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor grayColor];
        [self setupSubviews];
        [self addObservers];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return self.bounds.size;
}

- (void)setupSubviews {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    toolbar.backgroundColor = [UIColor darkGrayColor];
    toolbar.alpha = 0.97;
    [self addSubview:toolbar];
    [self addSubview:self.titleLabel];
    [self addSubview:self.lightView];
    [self addSubview:self.progressView];
    [self.progressView addSubview:self.coverView];
    
    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equal.to(@0);
        make.height.equalTo(@30);
        make.top.equal.to(@5);
        make.width.equalTo(self);
    }];
    
    [self.lightView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.centerY.equal.to(@0);
        make.height.width.equalTo(@70);
    }];
    
    [self.progressView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equal.to(@0);
        //        make.top.equal.sizeOffset(self.lightView.bjl_bottom).offset(10.f);
        make.bottom.equal.to(@(-15.f));
        make.height.equalTo(@7);
        make.left.equal.to(@13.f);
    }];
}

#pragma mark - kvo

- (void)addObservers {
    UIScreen *screen = [UIScreen mainScreen];
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(screen, brightness) observer:^BOOL(id  _Nullable now, id  _Nullable old, BJLPropertyChange * _Nullable change) {
        bjl_strongify(self);
        CGFloat brightness = MAX(0.0, MIN(1.0, screen.brightness));
        [self.coverView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
            make.top.bottom.right.equal.to(@0);
            make.width.equalTo(self.progressView.bjl_width).multipliedBy(1.0 - brightness);
        }];
        return YES;
    }];
}

#pragma mark - set get

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        _titleLabel.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        _titleLabel.text = @"亮度";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIImageView *)lightView {
    if (!_lightView) {
        _lightView = [UIImageView new];
        _lightView.image = [UIImage bjpu_imageNamed:@"ic_sun"];
    }
    return _lightView;
}

- (UIImageView *)progressView {
    if (!_progressView) {
        _progressView = [UIImageView new];
        _progressView.image = [UIImage bjpu_imageNamed:@"ic_light"];
    }
    return _progressView;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor bjpu_colorWithHexString:@"333333"];
    }
    return _coverView;
}

@end


@interface BJPUSliderSeekView ()

@property (strong, nonatomic) UIImageView *directImageView;
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation BJPUSliderSeekView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [[BJPUTheme brandColor] colorWithAlphaComponent:.6f];
        [self addSubview:self.directImageView];
        [self addSubview:self.timeLabel];
        
        [self.directImageView bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerX.equal.to(@0);
            make.centerY.equal.to(@(-10));
        }];
        [self.timeLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
            make.centerX.equal.to(@0);
            make.top.equalTo(self.directImageView.bjl_bottom).offset(5.f);
        }];
    }
    return self;
}

#pragma mark - public

- (void)resetRelTime:(long)relTime duration:(long)duration difference:(long)difference {
    if (difference > 0) {
        [self.directImageView setImage:[BJPUTheme forwardImage]];
    }
    else {
        [self.directImageView setImage:[BJPUTheme backwardImage]];
    }
    
    long seekTime = relTime + difference;
    seekTime = seekTime > 0 ? seekTime : 0;
    seekTime = seekTime < duration ? seekTime : duration;
    
    long seekHours = seekTime / 3600;
    int seekMinums = ((long long)seekTime % 3600) / 60;
    int seekSeconds = (long long)seekTime % 60;
    
    long totalHours = duration / 3600;
    int totalMinums = ((long long)duration % 3600) / 60;
    int totalSeconds = (long long)duration % 60;
    if (totalHours > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02d:%02d / %02ld:%02d:%02d",
                               seekHours, seekMinums, seekSeconds, totalHours, totalMinums, totalSeconds];
    }
    else {
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d",
                               seekMinums, seekSeconds, totalMinums, totalSeconds];
    }
}

#pragma mark - set get

- (UIImageView *)directImageView {
    if (!_directImageView) {
        _directImageView = [[UIImageView alloc] init];
    }
    return _directImageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:14.f];
        _timeLabel.textColor = [BJPUTheme defaultTextColor];
    }
    return _timeLabel;
}

@end
