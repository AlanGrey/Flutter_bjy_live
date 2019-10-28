//
//  BJPUMediaSettingCell.h
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/3/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJPUMediaSettingCell : UITableViewCell

- (void)updateWithSettingTitle:(NSString *)title selected:(BOOL)selected;

@property (nonatomic, copy, nullable) void (^selectCallback)(void);

@end

NS_ASSUME_NONNULL_END
