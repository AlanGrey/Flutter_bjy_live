//
//  BJPUSliderView.h
//  BJVideoPlayerUI
//
//  Created by DLM on 2017/4/26.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BJPUSliderView;

@protocol BJPUSliderProtocol <NSObject>

@optional
- (CGFloat)originValueForTouchSlideView:(BJPUSliderView *)touchSlideView;
- (CGFloat)durationValueForTouchSlideView:(BJPUSliderView *)touchSlideView;
- (void)touchSlideView:(BJPUSliderView *)touchSlideView finishHorizonalSlide:(CGFloat)value;

@end

@interface BJPUSliderView : UIView

@property (nonatomic, weak) id<BJPUSliderProtocol> delegate;
@property (nonatomic, assign) BOOL slideEnabled;

@end

@interface BJPUSliderLightView : UIView

@end

@interface BJPUSliderSeekView : UIView

- (void)resetRelTime:(long)relTime duration:(long)duration difference:(long)difference;

@end

NS_ASSUME_NONNULL_END
