//
//  AVPlayerView.m
//  ijkDemo
//
//  Created by raven on 2018/1/23.
//  Copyright © 2018年 raven. All rights reserved.
//

#import "AVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerView ()

@property (nonatomic, strong) AVPlayerLayer *playerViewLayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) id timeObserver;

@end

@implementation AVPlayerView

- (void)layoutSubviews
{
    self.playerViewLayer.frame = self.bounds;
}

- (void)initPlayer:(NSURL *)url
{
    self.playerItem = [[AVPlayerItem alloc] initWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerViewLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.layer addSublayer:self.playerViewLayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (weakSelf.player.rate != 0.0) {
            [weakSelf playTimeDidChange:time];
        }
    }];
    [self.player play];
}

- (void)play
{
    [self.player play];
}

-(void)pause
{
    [self.player pause];
}

- (void)seekToTime:(NSTimeInterval)time
{
    [self.player seekToTime:CMTimeMake(time, 1)];
}

- (void)shutdown
{
    [super shutdown];
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
    self.player = nil;
    self.playerItem = nil;
    [self.playerViewLayer removeFromSuperlayer];
    self.playerViewLayer = nil;
}

#pragma mark private
- (void)playDidFinished
{
    if ([self.delegate respondsToSelector:@selector(moviePlayBackDidFinish:)]) {
        [self.delegate moviePlayBackDidFinish:KBMovieFinishReasonPlaybackEnded];
    }
}

- (void)playTimeDidChange:(CMTime)time
{
    if ([self.delegate respondsToSelector:@selector(refreshTotalDuration:)]) {
        float allTime = CMTimeGetSeconds(self.playerItem.duration);
        [self.delegate refreshTotalDuration:!isnan(allTime)?allTime:0.0f];
    }
    if ([self.delegate respondsToSelector:@selector(refreshProgress:)]) {
        float currentTimeValue = isnan(time.value*1.0/time.timescale)?0.0f:time.value*1.0/time.timescale;
        [self.delegate refreshProgress:!isnan(currentTimeValue)?currentTimeValue:0.0f];
    }
}

@end
