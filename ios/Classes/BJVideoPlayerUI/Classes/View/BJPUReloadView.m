//
//  BJPUReloadView.m
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/7/16.
//  Copyright © 2018年 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPUReloadView.h"
#import "BJPUAppearance.h"
#import "BJPUTheme.h"

@interface BJPUReloadView ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UITextView *detailView;
@property (nonatomic) UIButton *reloadButton;

@end

@implementation BJPUReloadView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        [self setupSubviews];
        self.hidden = YES;
    }
    return self;
}

#pragma mark - subViews

- (void)setupSubviews {
    CGFloat viewSpace = 15.0;
    // error detail
    [self addSubview:self.detailView];
    [self.detailView bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.greaterThanOrEqualTo(self.bjl_safeAreaLayoutGuide ?: self).offset(viewSpace);
        make.right.lessThanOrEqualTo(self.bjl_safeAreaLayoutGuide ?: self).offset(-viewSpace);
        make.height.lessThanOrEqualTo(@60.0);
        make.size.equal.sizeOffset(CGSizeZero).priorityHigh(); // to update
    }];
    
    // error title
    [self addSubview:self.titleLabel];
    [self.titleLabel bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.left.greaterThanOrEqualTo(self.bjl_safeAreaLayoutGuide ?: self).offset(viewSpace);
        make.right.lessThanOrEqualTo(self.bjl_safeAreaLayoutGuide ?: self).offset(-viewSpace);
        make.bottom.equalTo(self.detailView.bjl_top).offset(-viewSpace);
    }];
    
    // reload button
    [self addSubview:self.reloadButton];
    [self.reloadButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.detailView.bjl_bottom).offset(viewSpace);
        make.size.equal.sizeOffset(CGSizeMake(144.0, 40.0)).priorityHigh();
    }];
    
    // cancelButton
    UIButton *cancelButton = ({
        UIButton *button = [[UIButton alloc] init];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button setImage:[BJPUTheme backButtonImage] forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0);
        [button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self addSubview:cancelButton];
    [cancelButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.top.left.equalTo(self.bjl_safeAreaLayoutGuide ?: self);
        make.size.equal.sizeOffset(CGSizeMake(60.0, 40.0));
    }];
}

#pragma mark - public

- (void)showWithTitle:(NSString *)title detail:(NSString *)detail {    
    self.titleLabel.text = title;
    self.detailView.text = detail;
    
    // UITextView 自适应大小
    CGSize detailSize = [self.detailView sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, 0.0)];
    [self.detailView bjl_updateConstraints:^(BJLConstraintMaker *make) {
        make.size.equal.sizeOffset(detailSize).priorityHigh();
    }];
    
    self.hidden = NO;
}

#pragma mark - actions

- (void)cancel {
    if (self.cancelCallback) {
        self.cancelCallback();
    }
}

- (void)reload {
    if (self.reloadCallback) {
        self.reloadCallback();
    }
    self.hidden = YES;
}

#pragma mark - getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont boldSystemFontOfSize:18.0];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label;
        });
    }
    return _titleLabel;
}

- (UITextView *)detailView {
    if (!_detailView) {
        _detailView = ({
            UITextView *view = [[UITextView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            view.font = [UIFont systemFontOfSize:14.0];
            view.textAlignment = NSTextAlignmentCenter;
            view.textColor = [UIColor whiteColor];
            view.editable = NO;
            view.bounces = NO;
            view.showsVerticalScrollIndicator = NO;
            view.showsHorizontalScrollIndicator = NO;
            view;
        });
    }
    return _detailView;
}

- (UIButton *)reloadButton {
    if (!_reloadButton) {
        _reloadButton = ({
            UIButton *button = [UIButton new];
            [button setTitle:@"刷新重试" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor bjpu_colorWithHexString:@"0x37A4F5"] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16.0];
            button.backgroundColor = [UIColor whiteColor];
            button.layer.cornerRadius = 3.0;
            button.layer.masksToBounds = YES;
            [button addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _reloadButton;
}

@end
