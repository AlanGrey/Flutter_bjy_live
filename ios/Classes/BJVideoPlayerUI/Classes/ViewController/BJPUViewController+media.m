//
//  BJPUViewController+media.m
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/3/9.
//

#import "BJPUViewController+media.h"
#import "BJPUViewController+protected.h"
#import "BJPUViewController+ui.h"

@implementation BJPUViewController (media)

#pragma mark - callbacks

- (void)setMediaCallbacks {
    bjl_weakify(self);
    // 播放
    [self.mediaControlView setMediaPlayCallback:^{
        bjl_strongify(self);
        [self play];
    }];
    
    // 暂停
    [self.mediaControlView setMediaPauseCallback:^{
        bjl_strongify(self);
        [self pause];
    }];
    
    // seek
    [self.mediaControlView setMediaSeekCallback:^(NSTimeInterval toTime) {
        bjl_strongify(self);
        [self seekToTime:toTime];
    }];
    
    // 切换倍速
    [self.mediaControlView setShowRateListCallback:^{
        bjl_strongify(self);
        [self showRateList];
    }];
    
    // 切换清晰度
    [self.mediaControlView setShowDefinitionListCallback:^{
        bjl_strongify(self);
        [self showDefinitionList];
    }];
    
    // 缩放
    [self.mediaControlView setScaleCallback:^(BOOL horizon) {
        bjl_strongify(self);
        [self updateConstriantsWithLayoutType:horizon? BJVPlayerViewLayoutType_Horizon : BJVPlayerViewLayoutType_Vertical];
    }];
    
    // 选择 倍速／清晰度
    [self.mediaSettingView setSelectCallback:^(NSUInteger selectIndex) {
        bjl_strongify(self);
        if (self.currentOptions == self.rateList) {
            id option = [self optionOrNilAtIndex:selectIndex];
            if (option && [option respondsToSelector:@selector(floatValue)]) {
                CGFloat rate = [option floatValue] ?: 1.0;
                [self.playerManager setRate:rate];
            }
        }
        else if (self.currentOptions == self.playerManager.playInfo.definitionList) {
            [self.playerManager changeDefinitionWithIndex:selectIndex];
        }
    }];
    
    // 刷新重试
    [self.reloadView setReloadCallback:^{
        bjl_strongify(self);
        if (self.isLocalVideo) {
            [self playWithDownloadItem:self.downloadItem];
        }
        else {
            [self playWithVid:self.videoID token:self.token];
        }
    }];
}

#pragma mark - action

- (void)play {
    [self.playerManager play];
}

- (void)pause {
    [self.playerManager pause];
}

- (void)seekToTime:(NSTimeInterval)time {
    time = MIN(time, self.playerManager.duration - 0.01);
    [self.playerManager seek:time];
}

- (void)showRateList {
    self.currentOptions = self.rateList;
    [self.mediaSettingView updateWithSettingOptons:[self getRateOptions]
                                       selectIndex:self.rateIndex];
    [self showMediaSettingView];
}

- (void)showDefinitionList {
    self.currentOptions = self.playerManager.playInfo.definitionList;
    [self.mediaSettingView updateWithSettingOptons:[self getDefinitionOptions]
                                       selectIndex:self.definitionIndex];
    [self showMediaSettingView];
}

#pragma mark - media setting

- (NSArray *)getRateOptions {
    self.rateIndex = 0;
    NSMutableArray *rateOptions = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.rateList.count; i ++) {
        CGFloat rate = [[self.rateList objectAtIndex:i] floatValue];
        NSString *option = [NSString stringWithFormat:@"%.1fx", rate];
        if (fabs(rate - self.playerManager.rate) < 0.1) {
            self.rateIndex = i;
        }
        [rateOptions addObject:option];
    }
    return [NSArray arrayWithArray:rateOptions];
}

- (NSArray *)getDefinitionOptions {
    NSArray *definitionList = self.playerManager.playInfo.definitionList;
    BJVDefinitionInfo *currdefinitionInfo = self.playerManager.currDefinitionInfo;
    NSMutableArray *definitionOptions = [[NSMutableArray alloc] init];
    for (int i = 0; i < definitionList.count; i ++) {
        BJVDefinitionInfo *definitionInfo = [definitionList objectAtIndex:i];
        if ([definitionInfo.definitionKey isEqualToString:currdefinitionInfo.definitionKey]) {
            self.definitionIndex = i;
        }
        [definitionOptions addObject:definitionInfo.definitionName ?: @""];
    }
    return definitionOptions;
}

#pragma mark - private

- (id)optionOrNilAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.currentOptions.count) {
        return [self.currentOptions objectAtIndex:index];
    }
    return nil;
}

@end
