//
//  IJKPlayerView.m
//  ijkDemo
//
//  Created by raven on 2018/1/23.
//  Copyright © 2018年 raven. All rights reserved.
//

#import "IJKPlayerView.h"
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>

@interface IJKPlayerView ()

@property (atomic, retain) id<IJKMediaPlayback> ijkPlayer;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation IJKPlayerView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.ijkPlayer.view.frame = self.bounds;
}

- (void)initPlayer:(NSURL *)url
{
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    //    [options setFormatOptionIntValue:1 forKey:@"analyzeduration"];
    //    [options setPlayerOptionIntValue:5 forKey:@"framedrop"];
    [options setPlayerOptionIntValue:1 forKey:@"enable-accurate-seek"];
    
    self.ijkPlayer = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
    self.ijkPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.ijkPlayer.view.frame = self.bounds;
    self.ijkPlayer.scalingMode = IJKMPMovieScalingModeAspectFill;
    self.ijkPlayer.shouldAutoplay = YES;
    [self addSubview:self.ijkPlayer.view];
    
    [self.ijkPlayer prepareToPlay];
    [self installMovieNotificationObservers];
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(refreshControlView) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark override
- (void)play
{
    [self.ijkPlayer play];
}

- (void)pause
{
    [self.ijkPlayer pause];
}

- (void)shutdown
{
    [self.timer invalidate];
    self.timer = nil;
    [self.ijkPlayer shutdown];
    [self removeMovieNotificationObservers];
    self.ijkPlayer = nil;
}

- (void)seekToTime:(NSTimeInterval)time
{
    self.ijkPlayer.currentPlaybackTime = time;
}

- (void)setScalingMode:(KBMovieScalingMode)scalingMode
{
    switch (scalingMode) {
        case KBMovieScalingModeAspectFit:
            self.ijkPlayer.scalingMode = IJKMPMovieScalingModeAspectFit;
            break;
        case KBMovieScalingModeAspectFill:
            self.ijkPlayer.scalingMode = IJKMPMovieScalingModeAspectFill;
            break;
        case KBMovieScalingModeFill:
            self.ijkPlayer.scalingMode = IJKMPMovieScalingModeFill;
            break;
        default:
            break;
    }
}

- (UIImage *)thumbnailImageAtCurrentTime
{
    return [self.ijkPlayer thumbnailImageAtCurrentTime];
}

#pragma mark timer event
- (void)refreshControlView
{
    if ([self.delegate respondsToSelector:@selector(refreshProgress:)]) {
        [self.delegate refreshProgress:self.ijkPlayer.currentPlaybackTime];
    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_ijkPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_ijkPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_ijkPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_ijkPlayer];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_ijkPlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_ijkPlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_ijkPlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_ijkPlayer];
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _ijkPlayer.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            self.playState = KBPlaybackStateFailed;
            if ([self.delegate respondsToSelector:@selector(moviePlayBackStateDidChange:)]) {
                [self.delegate moviePlayBackStateDidChange:KBPlaybackStateFailed];
            }
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
    if ([self.delegate respondsToSelector:@selector(moviePlayBackDidFinish:)]) {
        [self.delegate moviePlayBackDidFinish:reason];
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
    self.playState = KBPlaybackStateReadyToPlay;
    if ([self.delegate respondsToSelector:@selector(moviePlayBackStateDidChange:)]) {
        [self.delegate moviePlayBackStateDidChange:self.playState];
    }
    if ([self.delegate respondsToSelector:@selector(refreshTotalDuration:)]) {
        [self.delegate refreshTotalDuration:self.ijkPlayer.duration];
    }
    if ([self.delegate respondsToSelector:@selector(refreshProgress:)]) {
        [self.delegate refreshProgress:self.ijkPlayer.currentPlaybackTime];
    }
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (_ijkPlayer.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_ijkPlayer.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_ijkPlayer.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_ijkPlayer.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_ijkPlayer.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_ijkPlayer.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_ijkPlayer.playbackState);
            break;
        }
    }
    if ([self.delegate respondsToSelector:@selector(moviePlayBackStateDidChange:)]) {
        [self.delegate moviePlayBackStateDidChange:_ijkPlayer.playbackState];
    }
}

@end
