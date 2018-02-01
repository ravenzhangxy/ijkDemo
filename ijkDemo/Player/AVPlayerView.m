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
@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;

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
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] init];
    [self.playerItem addOutput:self.videoOutput];
    
    // 程序即将退出活跃状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    // 程序进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲区空了，需要等待数据
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // 缓冲区有足够数据可以播放了
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
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
    if ([self.delegate respondsToSelector:@selector(moviePlayBackStateDidChange:)]) {
        [self.delegate moviePlayBackStateDidChange:KBPlaybackStatePlaying];
    }
}

-(void)pause
{
    [self.player pause];
    if ([self.delegate respondsToSelector:@selector(moviePlayBackStateDidChange:)]) {
        [self.delegate moviePlayBackStateDidChange:KBPlaybackStatePaused];
    }
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
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    self.player = nil;
    self.playerItem = nil;
    [self.playerViewLayer removeFromSuperlayer];
    self.playerViewLayer = nil;
}

- (void)setScalingMode:(KBMovieScalingMode)scalingMode
{
    switch (scalingMode) {
        case KBMovieScalingModeAspectFit:
            self.playerViewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
        case KBMovieScalingModeAspectFill:
            self.playerViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        case KBMovieScalingModeFill:
            self.playerViewLayer.videoGravity = AVLayerVideoGravityResize;
            break;
        default:
            break;
    }
}

- (UIImage *)thumbnailImageAtCurrentTime
{
    CMTime itemTime = _player.currentItem.currentTime;
    CVPixelBufferRef pixelBuffer = [_videoOutput copyPixelBufferForItemTime:itemTime itemTimeForDisplay:nil];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0,
                                                 CVPixelBufferGetWidth(pixelBuffer),
                                                 CVPixelBufferGetHeight(pixelBuffer))];
    
    //当前帧的画面
    UIImage *currentImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    return currentImage;
}

#pragma mark private
- (void)playDidFinished
{
    self.playState = KBPlaybackStateStopped;
    if ([self.delegate respondsToSelector:@selector(moviePlayBackStateDidChange:)]) {
        [self.delegate moviePlayBackStateDidChange:KBPlaybackStateStopped];
    }
    if ([self.delegate respondsToSelector:@selector(moviePlayBackDidFinish:)]) {
        [self.delegate moviePlayBackDidFinish:KBMovieFinishReasonPlaybackEnded];
    }
}

- (void)playTimeDidChange:(CMTime)time
{
    if ([self.delegate respondsToSelector:@selector(refreshProgress:)]) {
        float currentTimeValue = isnan(time.value*1.0/time.timescale)?0.0f:time.value*1.0/time.timescale;
        [self.delegate refreshProgress:!isnan(currentTimeValue)?currentTimeValue:0.0f];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.player.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                self.playState = KBPlaybackStateReadyToPlay;
                if ([self.delegate respondsToSelector:@selector(refreshTotalDuration:)]) {
                    float allTime = CMTimeGetSeconds(self.playerItem.duration);
                    [self.delegate refreshTotalDuration:!isnan(allTime)?allTime:0.0f];
                }
            } else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                self.playState = KBPlaybackStateFailed;
            }
            if ([self.delegate respondsToSelector:@selector(moviePlayBackStateDidChange:)]) {
                [self.delegate moviePlayBackStateDidChange:self.playState];
            }
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            //TODO:显示缓冲进度
            //计算缓冲进度
            //            NSTimeInterval timeInterval = [self availableDuration];
            //            CMTime duration             = self.playerItem.duration;
            //            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            //            [self.controlView zf_playerSetProgress:timeInterval / totalDuration];
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            // 当缓冲好的时候
        }
    }
}
/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark notification
- (void)appWillResignActive:(NSNotification *)notification
{
    if (self.player) {
        [self pause];
    }
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
    if (self.player) {
        [self play];
    }
}

@end

