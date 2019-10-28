//
//  BJPUMediaSettingView.h
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/3/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPUMediaSettingView : UIView

@property (nonatomic, copy) void (^selectCallback)(NSUInteger selectIndex);

- (void)updateWithSettingOptons:(NSArray<NSString *> *)options selectIndex:(NSUInteger)selectIndex;

@end

NS_ASSUME_NONNULL_END
