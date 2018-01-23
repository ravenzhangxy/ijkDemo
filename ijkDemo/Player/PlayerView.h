//
//  PlayerView.h
//  ijkDemo
//
//  Created by raven on 2017/12/14.
//  Copyright © 2017年 raven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerHeader.h"
#import "PlayerDelegate.h"

@interface PlayerView : UIView

@property (nonatomic, assign) NSTimeInterval currentPlaybackTime;
@property (nonatomic, weak) id<PlayerDelegate>delegate;

- (instancetype)initWithFrame:(CGRect)frame playerType:(KBPlayerType)playerType url:(NSURL *)url;
- (void)play;
- (void)pause;
- (void)shutdown;

@end
