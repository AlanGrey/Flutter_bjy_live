//
//  BJPUMediaControlView.h
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/3/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPUMediaControlView : UIView

@property (nonatomic, assign) BOOL slideCanceled;

@property (nonatomic, copy) void (^mediaPlayCallback)(void);
@property (nonatomic, copy) void (^mediaPauseCallback)(void);
@property (nonatomic, copy) void (^mediaSeekCallback)(NSTimeInterval toTime);
@property (nonatomic, copy) void (^showRateListCallback)(void);
@property (nonatomic, copy) void (^showDefinitionListCallback)(void);
@property (nonatomic, copy) void (^scaleCallback)(BOOL horizon);

- (void)updateConstraintsWithLayoutType:(BOOL)horizon;

- (void)updateProgressWithCurrentTime:(NSTimeInterval)currentTime
                        cacheDuration:(NSTimeInterval)cacheDuration
                        totalDuration:(NSTimeInterval)totalDuration
                            isHorizon:(BOOL)isHorizon;

- (void)updateWithPlayState:(BOOL)playing;

- (void)setSlideEnable:(BOOL)enable;

- (void)updateWithRate:(NSString *)rateString;

- (void)updateWithDefinition:(NSString *)definitionString;

@end

NS_ASSUME_NONNULL_END
