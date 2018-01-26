//
//  PlayerControlView.h
//  ijkDemo
//
//  Created by raven on 2017/12/12.
//  Copyright © 2017年 raven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerControlDelegate.h"
#import "PlayerHeader.h"

@interface PlayerControlView : UIView

@property (nonatomic, weak) id<PlayerControlDelegate>delegate;
@property (nonatomic, getter=isFullScreen) BOOL fullScreen;
@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, strong) NSString *videoTitle;

- (void)refreshPlayBtnState:(KBPlaybackState)playbackState;
- (void)refreshTotalDuration:(NSTimeInterval)totalDuration;
- (void)refreshProgress:(NSTimeInterval)currentTime;
- (void)showError:(BOOL)isShow;

@end
