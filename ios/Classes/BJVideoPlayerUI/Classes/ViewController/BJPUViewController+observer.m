//
//  BJPUViewController+observer.m
//  BJVideoPlayerUI
//
//  Created by HuangJie on 2018/4/8.
//

#import "BJPUViewController+observer.h"
#import "BJPUViewController+protected.h"
#import "BJPUViewController+ui.h"
#import "BJPUViewController+media.h"
#import "MBProgressHUD+bjp.h"
#import <BJLiveBase/NSObject+BJL_M9Dev.h>

@implementation BJPUViewController (observer)

- (void)setupObservers {
    bjl_weakify(self);
    // 播放状态
    [self bjl_kvo:BJLMakeProperty(self.playerManager, playStatus)
           filter:^BOOL(NSNumber * _Nullable now, NSNumber * _Nullable old, BJLPropertyChange * _Nullable change) {
               return (old == nil) || (now.integerValue != old.integerValue);
           } observer:^BOOL(NSNumber * _Nullable now, NSNumber * _Nullable old, BJLPropertyChange * _Nullable change) {
               bjl_strongify(self);
               BJVPlayerStatus status = self.playerManager.playStatus;
               NSLog(@"BJPUViewController - playerPlayStateChanged:%td", status);
               [self updateWithPlayState:status];
               
               // debug info
               switch (status) {
                   case BJVPlayerStatus_unload:
                       NSLog(@"播放状态变化：BJVPlayerStatus_Unload");
                       break;
                       
                   case BJVPlayerStatus_loading:
                       NSLog(@"播放状态变化：BJVPlayerStatus_Loading");
                       break;
                       
                   case BJVPlayerStatus_stalled:
                       NSLog(@"播放状态变化：BJVPlayerStatus_Stalled");
                       break;
                       
                   case BJVPlayerStatus_ready:
                       NSLog(@"播放状态变化：BJVPlayerStatus_Ready");
                       break;
                       
                   case BJVPlayerStatus_playing:
                       NSLog(@"播放状态变化：BJVPlayerStatus_Playing");
                       break;
                       
                   case BJVPlayerStatus_paused:
                       NSLog(@"播放状态变化：BJVPlayerStatus_Paused");
                       break;
                       
                   case BJVPlayerStatus_stopped:
                       NSLog(@"播放状态变化：BJVPlayerStatus_Stopped");
                       break;
                       
                   case BJVPlayerStatus_reachEnd:
                       NSLog(@"播放状态变化：BJVPlayerStatus_ReachEnd");
                       break;
                       
                   case BJVPlayerStatus_failed:
                       NSLog(@"播放状态变化：BJVPlayerStatus_Failed");
                       break;
                       
                   default:
                       break;
               }
               
               if (status == BJVPlayerStatus_loading
                   || status == BJVPlayerStatus_stalled) {
                   [BJLProgressHUD bjp_showLoading:@"正在加载" toView:self.view];
               }
               else {
                   [BJLProgressHUD bjp_closeLoadingView:self.view];
               }

               if (status == BJVPlayerStatus_unload) {
                   [self.updateDurationTimer invalidate];
                   self.updateDurationTimer = nil;
               }
               else {
                   if (!self.updateDurationTimer || ![self.updateDurationTimer isValid]) {
                       self.updateDurationTimer = [NSTimer bjl_scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
                           bjl_strongify(self);
                           [self updatePlayProgress];
                       }];
                   }
               }
               
               return YES;
           }];
    
    // 清晰度
    [self bjl_kvo:BJLMakeProperty(self.playerManager, currDefinitionInfo)
         observer:^BOOL(id  _Nullable now, id  _Nullable old, BJLPropertyChange * _Nullable change) {
             bjl_strongify(self);
             // 显示当前清晰度
             [self.mediaControlView updateWithDefinition:self.playerManager.currDefinitionInfo.definitionName];
             
             // 显示/隐藏 纯音频占位图
             self.audioOnlyImageView.hidden = !self.playerManager.currDefinitionInfo.isAudio;
             
             // 视频宽高比
             BJVDefinitionInfo *definitionInfo = self.playerManager.currDefinitionInfo;
             CGFloat width = definitionInfo.width;
             CGFloat height = definitionInfo.height;
             if (width > 0.0 && height > 0.0) {
                 CGFloat videoRatio = width / height;
                 // 更新播放视图宽高比
                 [self updatePlayerViewConstraintWithVideoRatio:videoRatio];
             }
             return YES;
    }];
    
    // 倍速
    [self bjl_kvo:BJLMakeProperty(self.playerManager, rate)
         observer:^BOOL(id  _Nullable now, id  _Nullable old, BJLPropertyChange * _Nullable change) {
             bjl_strongify(self);
             [self.mediaControlView updateWithRate:[NSString stringWithFormat:@"%.1fx", self.playerManager.rate]];
             return YES;
    }];
    
    // 播放出错
    [self bjl_observe:BJLMakeMethod(self.playerManager, video:playFailedWithError:)
             observer:^BOOL(BJVPlayInfo *playInfo, NSError *error) {
                 bjl_strongify(self);
                 [self video:playInfo playFailedWithError:error];
                 return YES;
    }];
}

#pragma mark - action

- (void)video:(BJVPlayInfo *)playInfo playFailedWithError:(NSError *)error {
    NSString *errorTitle;
    switch (error.code) {
        case BJVErrorCode_unknown:
            errorTitle = @"未知错误";
            break;
            
        case BJVErrorCode_requestFailed:
            errorTitle = @"网络请求失败";
            break;
            
        case BJVErrorCode_invalidToken:
            errorTitle = @"token 参数错误";
            break;
            
        case BJVErrorCode_invalidPlayInfo:
            errorTitle = @"播放信息解析错误";
            break;
            
        case BJVErrorCode_invalidVideoURL:
            errorTitle = @"视频 URL 失效";
            break;
            
        case BJVErrorCode_fileLost:
            errorTitle = @"播放文件不存在";
            break;
            
        case BJVErrorCode_playFailed:
            errorTitle = @"视频播放失败";
            break;
            
        default:
            break;
    }
    
    if (errorTitle.length) {
        NSString *detail = [NSString stringWithFormat:@"错误码:%ti \n %@", error.code, [error.userInfo objectForKey:NSLocalizedDescriptionKey] ?: @""];
        [self.reloadView showWithTitle:errorTitle detail:detail];
    }
}


@end
