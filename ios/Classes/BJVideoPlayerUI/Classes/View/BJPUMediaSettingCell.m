//
//  BJPUMediaSettingCell.m
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/3/9.
//

#import <BJLiveBase/BJLiveBase+UIKit.h>

#import "BJPUMediaSettingCell.h"
#import "BJPUTheme.h"

@interface BJPUMediaSettingCell ()

@property (nonatomic, strong) UIButton *optionButton;

@end

@implementation BJPUMediaSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setupSubView];
    }
    return self;
}

#pragma mark - subView

- (void)setupSubView {
    UIView *contentView = self.contentView;
    [contentView addSubview:self.optionButton];
    [self.optionButton bjl_makeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(contentView);
        make.size.equal.sizeOffset(CGSizeMake(50.0, 20.0));
    }];
}

#pragma mark - update

- (void)updateWithSettingTitle:(NSString *)title selected:(BOOL)selected {
    [self.optionButton setTitle:title forState:UIControlStateNormal];
    self.optionButton.selected = selected;
    self.optionButton.layer.borderColor = (selected? [BJPUTheme highlightTextColor] : [BJPUTheme defaultTextColor]).CGColor;
}

#pragma mark - action

- (void)selectAction {
    if (self.optionButton.selected) {
        return;
    }
    if (self.selectCallback) {
        self.selectCallback();
    }
}

#pragma mark - getters

- (UIButton *)optionButton {
    if (!_optionButton) {
        _optionButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.titleLabel.font = [UIFont systemFontOfSize:14.0];
            [button setTitleColor:[BJPUTheme defaultTextColor] forState:UIControlStateNormal];
            [button setTitleColor:[BJPUTheme highlightTextColor] forState:UIControlStateSelected];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 10.0;
            button.layer.borderWidth = 1.0;
            [button addTarget:self action:@selector(selectAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _optionButton;
}

@end
