//
//  PlayerView.m
//  ijkDemo
//
//  Created by raven on 2017/12/14.
//  Copyright © 2017年 raven. All rights reserved.
//

#import "PlayerView.h"
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import "PlayerControlView.h"

@interface PlayerView()<PlayerDelegate>

@property (atomic, retain) id<IJKMediaPlayback> player;
@property (nonatomic, strong) PlayerControlView *controlView;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PlayerView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.player.view.frame = self.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFill;

    self.controlView.frame = self.bounds;
}

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)videoUrl
{
    self = [super initWithFrame:frame];
    if (self) {
        self.originFrame = frame;
        [self initIJKPlayer:videoUrl];
        [self initControlView];
        self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(refreshControlView) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer setFireDate:[NSDate distantFuture]];
    }
    return self;
}

- (void)initIJKPlayer:(NSString *)videoUrl
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
    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videoUrl] withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFill;
    self.player.shouldAutoplay = YES;
    [self addSubview:self.player.view];
}

- (void)initControlView
{
    self.controlView = [[PlayerControlView alloc] initWithFrame:self.bounds];
    [self addSubview:self.controlView];
    self.controlView.delegate = self;
}

- (void)refreshControlView
{
    [self.controlView refreshProgress:self.player.duration currentTime:self.player.currentPlaybackTime];
}

#pragma mark Public Method
- (void)prepareToPlay
{
    [self.player prepareToPlay];
}

- (void)shutdown
{
    [self.player shutdown];
}

#pragma mark PlayerDelegate
- (void)play
{
    [self.player play];
}

- (void)pause
{
    [self.player pause];
}

- (void)transformFullScreen:(BOOL)isZoomUp
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat x = screenSize.height/self.frame.size.width;
    CGFloat y = screenSize.width/self.frame.size.height;
    
    CGPoint newPosition = CGPointMake(screenSize.width/2, screenSize.height/2);
    NSInteger transAngle = 90;
    
    if (!isZoomUp) {
        // 从全屏变为顶部显示
        x = 1.0;
        y = 1.0;
        newPosition = CGPointMake(_originFrame.size.width/2, CGRectGetHeight(_originFrame)/2+CGRectGetMinY(_originFrame));
        transAngle = 0;
    }
    CGAffineTransform t = CGAffineTransformMakeScale(y, x);
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        weakSelf.layer.anchorPoint = CGPointMake(0.5,0.5);//围绕点
        weakSelf.layer.position = newPosition;//位置
        weakSelf.transform = CGAffineTransformRotate(t,transAngle* M_PI/180.0);
        CGAffineTransform newTransform;
        if (isZoomUp) {
            weakSelf.controlView.fullScreen = YES;
            newTransform = CGAffineTransformMakeScale(1/x, 1/y);
        } else {
            weakSelf.controlView.fullScreen = NO;
            newTransform = CGAffineTransformMakeScale(1, 1);
        }
        [weakSelf resetSubViewsTransform:newTransform];
    } completion:^(BOOL finished) {
    }];
}

-(void)resetSubViewsTransform:(CGAffineTransform)aTransform
{
    for (UIView *sView in self.subviews) {
        sView.transform = aTransform;
    }
    
    for (CALayer *sLayer in self.layer.sublayers) {
        sLayer.affineTransform = aTransform;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)seekToSliderValue:(NSTimeInterval)time
{
    [self.controlView refreshProgress:self.player.duration currentTime:time];
    self.player.currentPlaybackTime = time;
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
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
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
    [self.controlView refreshProgress:self.player.duration currentTime:self.player.currentPlaybackTime];
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            [self.controlView playOrPause];//视频播完时将按钮状态置为暂停状态
            [self transformFullScreen:NO];
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

@end
