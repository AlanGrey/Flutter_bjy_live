//
//  BJPUReloadView.h
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/7/16.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BJPUReloadView : UIView

@property (nonatomic, copy, nullable) void (^reloadCallback)(void);
@property (nonatomic, copy, nullable) void (^cancelCallback)(void);


- (void)showWithTitle:(nullable NSString *)title detail:(nullable NSString *)detail;

@end
