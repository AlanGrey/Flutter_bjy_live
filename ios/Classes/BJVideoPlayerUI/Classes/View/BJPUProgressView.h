//
//  BJPUProgressView.h
//  BJVideoPlayerUI
//
//  Created by DLM on 2017/4/26.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BJPUVideoSlider;

@interface BJPUProgressView : UIView

@property (nonatomic, nullable) BJPUVideoSlider *slider;

- (void)setValue:(CGFloat)value cache:(CGFloat)cache duration:(CGFloat)duration;

@end

#pragma mark - custom slider

@interface BJPUVideoSlider : UISlider

@end

NS_ASSUME_NONNULL_END
