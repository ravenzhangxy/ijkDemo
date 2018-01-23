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
    }
    return self;
}

#pragma mark Public Method
- (void)play
{
    
}

- (void)pause
{
    
}

#pragma mark setter
- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime
{
    
}

- (void)shutdown
{
    
}

@end
