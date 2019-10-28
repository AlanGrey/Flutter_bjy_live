//
//  BJPUProgressView.m
//  BJVideoPlayerUI
//
//  Created by DLM on 2017/4/26.
//
//

#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPUProgressView.h"
#import "BJPUAppearance.h"

@interface BJPUProgressView ()

@property (nonatomic, strong) UIImageView *sliderBgView;
@property (nonatomic, strong) UIView *cacheView;

@end

@implementation BJPUProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO; // 解决警告
        [self setupSubviews];
    }
    return self;
}

- (void)dealloc {
    self.sliderBgView = nil;
    self.slider = nil;
}

#pragma mark - subViews

- (void)setupSubviews {
    // slideBgView
    [self addSubview:self.sliderBgView];
    [self.sliderBgView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(4.0, 0.0, 4.0, 0.0));
    }];
    
    // cacheView
    [self addSubview:self.cacheView];
    [self.cacheView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.sliderBgView);
        make.width.equalTo(self.sliderBgView).multipliedBy(FLT_MIN);
    }];
    
    // slider
    [self addSubview:self.slider];
    [self.slider bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.edges.equalTo(self.sliderBgView).insets(UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0));
    }];
}

#pragma mark - public

- (void)setValue:(CGFloat)value cache:(CGFloat)cache duration:(CGFloat)duration {
    // slider
    self.slider.maximumValue = duration;
    self.slider.value = value;
    
    // cache
    CGFloat cacheRate = (duration > 0)? cache / duration : FLT_MIN;
    [self.cacheView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.sliderBgView);
        make.width.equalTo(self.sliderBgView).multipliedBy(MIN(1.0, cacheRate));
    }];
}

#pragma mark - getters & setters

- (UIImageView *)sliderBgView {
    if (!_sliderBgView) {
        _sliderBgView = ({
            UIImage *image = [UIImage bjpu_imageNamed:@"ic_player_progress_gray_n.png"];
            UIImage *stretchImage = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5
                                                               topCapHeight:image.size.height * 0.5];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:stretchImage];
            imageView;
        });
    }
    return _sliderBgView;
}

- (BJPUVideoSlider *)slider {
    if (!_slider) {
        _slider = ({
            BJPUVideoSlider *slider = [[BJPUVideoSlider alloc] init];
            slider.backgroundColor = [UIColor clearColor];
            slider.minimumTrackTintColor = [UIColor clearColor];
            slider.maximumTrackTintColor = [UIColor clearColor];
            
            UIImage *leftImage = [UIImage bjpu_imageNamed:@"ic_player_progress_orange_n.png"];
            UIImage *leftStretch = [leftImage stretchableImageWithLeftCapWidth:leftImage.size.width * 0.5
                                                                  topCapHeight:leftImage.size.height * 0.5];

            
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
                [slider setMinimumTrackImage:leftStretch forState:UIControlStateNormal];
            }
            [slider setThumbImage:[UIImage bjpu_imageNamed:@"ic_player_current_n.png"] forState:UIControlStateNormal];
            [slider setThumbImage:[UIImage bjpu_imageNamed:@"ic_player_current_big_n.png"] forState:UIControlStateHighlighted];
            slider;
        });
    }
    return _slider;
}

- (UIView *)cacheView {
    if (!_cacheView) {
        _cacheView = ({
            UIView *view = [[UIView alloc] init];
            view.layer.masksToBounds = YES;
            view.layer.cornerRadius = 1.0;
            view.backgroundColor = [UIColor whiteColor];
            view;
        });
    }
    return _cacheView;
}

@end

#pragma mark - custom slider

@implementation BJPUVideoSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    thumbRect.origin.x = (self.maximumValue > 0?(value / self.maximumValue * self.frame.size.width):0) - self.currentThumbImage.size.width / 2;
    thumbRect.origin.y = 0;
    thumbRect.size.height = bounds.size.height;
    return thumbRect;
}

- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds {
    return CGRectZero;
}

- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds {
    return CGRectZero;
}

@end
