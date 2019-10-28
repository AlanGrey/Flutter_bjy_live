//
//  BJPUTheme.h
//  BJVideoPlayerUI
//
//  Created by DLM on 2017/4/26.
//
//

#import <Foundation/Foundation.h>

@interface BJPUTheme : NSObject

//color
+ (void)setDefaultTextColor:(UIColor *)color;

+ (void)setHighlightTextColor:(UIColor *)color;

+ (void)setBrandColor:(UIColor *)color;

//small image
+ (void)setLogoImage:(UIImage *)image;

+ (void)setBackButtonImage:(UIImage *)image;

+ (void)setPlayButtonImage:(UIImage *)image;

+ (void)setPauseButtonImage:(UIImage *)image;

+ (void)setStopButtonImage:(UIImage *)image;

+ (void)setNextButtonImage:(UIImage *)image;

+ (void)setProgressSliderImage:(UIImage *)image;

+ (void)setScaleButtonImage:(UIImage *)image;

+ (void)setForwardImage:(UIImage *)image;

+ (void)setBackwardImage:(UIImage *)image;


//color
+ (UIColor *)defaultTextColor;

+ (UIColor *)highlightTextColor;

+ (UIColor *)brandColor;

//small image
+ (UIImage *)logoImage;

+ (UIImage *)backButtonImage;

+ (UIImage *)playButtonImage;

+ (UIImage *)pauseButtonImage;

+ (UIImage *)stopButtonImage;

+ (UIImage *)nextButtonImage;

+ (UIImage *)sliderImage;

+ (UIImage *)scaleButtonImage;

+ (UIImage *)forwardImage;

+ (UIImage *)backwardImage;

@end
