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

@property (nonatomic, weak) id<PlayerDelegate>delegate;
@property (nonatomic, assign) KBPlaybackState playState;
@property (nonatomic, assign) KBMovieScalingMode scalingMode;

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url;
- (void)initPlayer:(NSURL *)url;
- (void)play;
- (void)pause;
- (void)shutdown;
- (void)seekToTime:(NSTimeInterval)time;
- (UIImage *)thumbnailImageAtCurrentTime;

@end
