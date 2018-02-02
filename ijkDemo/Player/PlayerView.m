//
//  PlayerView.m
//  ijkDemo
//
//  Created by raven on 2017/12/14.
//  Copyright © 2017年 raven. All rights reserved.
//

#import "PlayerView.h"

@interface PlayerView()

@end

@implementation PlayerView

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self initPlayer:url];
        self.scalingMode = KBMovieScalingModeAspectFill;
    }
    return self;
}

- (void)initPlayer:(NSURL *)url
{
    
}

- (void)play
{
    
}

- (void)pause
{
    
}

- (void)replay
{
    
}

- (void)seekToTime:(NSTimeInterval)time
{
    
}

- (void)shutdown
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIImage *)thumbnailImageAtCurrentTime
{
    return nil;
}

@end
