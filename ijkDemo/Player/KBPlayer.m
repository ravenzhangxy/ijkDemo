//
//  KBPlayer.m
//  ijkDemo
//
//  Created by raven on 2018/1/23.
//  Copyright © 2018年 raven. All rights reserved.
//

#import "KBPlayer.h"
#import "IJKPlayerView.h"
#import "AVPlayerView.h"
#import "PlayerControlView.h"
#import "KBPlayerHelper.h"
#import "MBProgressHUD.h"

@interface KBPlayer () <PlayerControlDelegate, PlayerDelegate>

@property (nonatomic, strong) PlayerView *playerView;
@property (nonatomic, strong) PlayerControlView *controlView;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, assign) KBPlayerType playerType;
@property (nonatomic, strong) NSURL *url;

@end

@implementation KBPlayer

- (void)layoutSubviews
{
    self.playerView.frame = self.bounds;
    self.controlView.frame = self.bounds;
}

- (instancetype)initWithFrame:(CGRect)frame playerType:(KBPlayerType)playerType url:(NSURL *)url title:(NSString *)title fullScreen:(BOOL)isfullScreen
{
    if (self = [super initWithFrame:frame]) {
        self.originFrame = frame;
        self.backgroundColor = [UIColor blackColor];
        [self initPlayer:playerType url:url];
        [self initControlView:title];
        
        [[KBPlayerHelper sharedInstance] addObserver:self forKeyPath:@"networkStatus" options:NSKeyValueObservingOptionNew context:nil];
        // 监测设备方向
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDeviceOrientationChange)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        [self transformFullScreen:isfullScreen];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
    }
    return self;
}

- (void)shutdown
{
    [self.playerView shutdown];
}

#pragma mark init views
- (void)initPlayer:(KBPlayerType)playerType url:(NSURL *)url
{
    self.playerType = playerType;
    self.url = url;
    switch (playerType) {
        case KBPlayerTypeIJK:
        {
            self.playerView = [[IJKPlayerView alloc] initWithFrame:self.bounds url:url];
            break;
        }
        case KBPlayerTypeAVPlayer:
        {
            self.playerView = [[AVPlayerView alloc] initWithFrame:self.bounds url:url];
            break;
        }
        default:
            break;
    }
    [self addSubview:self.playerView];
    self.playerView.delegate = self;
}

- (void)initControlView:(NSString *)title
{
    self.controlView = [[PlayerControlView alloc] initWithFrame:self.bounds];
    self.controlView.videoTitle = title;
    [self addSubview:self.controlView];
    self.controlView.delegate = self;
}

#pragma mark PlayerControlDelegate
- (void)play
{
    [self.playerView play];
}

- (void)pause
{
    [self.playerView pause];
}

- (void)replay
{
    [self.playerView replay];
}

- (void)back
{
    [self shutdown];
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}

- (void)transformFullScreen:(BOOL)isZoomUp
{
    if (isZoomUp) {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeRight) {
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
        } else {
            [self toOrientation:UIInterfaceOrientationLandscapeRight];
        }
    } else {
        [self toOrientation:UIInterfaceOrientationPortrait];
    }
    self.controlView.fullScreen = isZoomUp;
}

- (void)seekToSliderValue:(NSTimeInterval)time
{
    [self.controlView refreshProgress:time];
    [self.playerView seekToTime:time];
//    [self.controlView updateCurrentFrameImage:[self.playerView thumbnailImageAtCurrentTime]];
}

- (void)retry
{
    [self.playerView shutdown];
    [self.playerView initPlayer:self.url];
}

#pragma mark PlayerDelegate
- (void)refreshProgress:(NSTimeInterval)time
{
    [self.controlView refreshProgress:time];
}

- (void)refreshTotalDuration:(NSTimeInterval)totalDuration
{
    [self.controlView refreshTotalDuration:totalDuration];
}

- (void)refreshBufferProgress:(CGFloat)progress
{
    [self.controlView refreshBufferProgress:progress];
}

- (void)moviePlayBackStateDidChange:(NSInteger)playbackState
{
    self.playerView.playState = playbackState;
    switch (playbackState)
    {
        case KBPlaybackStateStopped: {
            break;
        }
        case KBPlaybackStatePlaying: {
            [self.controlView showError:NO];
            break;
        }
        case KBPlaybackStatePaused: {
            break;
        }
        case KBPlaybackStateInterrupted: {
            break;
        }
        case KBPlaybackStateSeekingForward:
        case KBPlaybackStateSeekingBackward: {
            break;
        }
        case KBPlaybackStateReadyToPlay:
            break;
        case KBPlaybackStateFailed: {
            [self.controlView showError:YES];
            [self.controlView refreshPlayBtnState:KBPlaybackStateFailed];
            break;
        }
        default: {
            break;
        }
    }
    [self.controlView refreshPlayBtnState:playbackState];
    [self.hud removeFromSuperview];
}

- (void)moviePlayBackDidFinish:(NSInteger)movieFinishReason
{
    switch (movieFinishReason) {
        case KBMovieFinishReasonPlaybackEnded: {
            [self.controlView refreshPlayBtnState:KBPlaybackStateStopped];//视频播完时将按钮状态置为暂停状态
            [self.playerView pause];
            [self transformFullScreen:NO];
            break;
        }
        case KBMovieFinishReasonUserExited:
            break;
        case KBMovieFinishReasonPlaybackError:
            [self.hud removeFromSuperview];
            break;
        default:
            break;
    }
    if (self.playFinishBlock) {
        self.playFinishBlock(movieFinishReason);
    }
}

#pragma mark 监听设备方向
- (void)onDeviceOrientationChange
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown ) { return; }
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        case UIInterfaceOrientationPortrait:{
            if (self.controlView.isFullScreen) {
                [self toOrientation:UIInterfaceOrientationPortrait];
                self.controlView.fullScreen = NO;
            }
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:{
            if (!self.controlView.isFullScreen) {
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
                self.controlView.fullScreen = YES;
            } else {
                [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            }
            break;
        }
        case UIInterfaceOrientationLandscapeRight:{
            if (!self.controlView.isFullScreen) {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
                self.controlView.fullScreen = YES;
            } else {
                [self toOrientation:UIInterfaceOrientationLandscapeRight];
            }
            break;
        }
        default:
            break;
    }
    if (self.controlView.isFullScreen) {
        self.frame = [UIScreen mainScreen].bounds;
    } else {
        self.frame = self.originFrame;
    }
    self.playerView.frame = self.bounds;
    self.controlView.frame = self.bounds;
}

- (void)toOrientation:(UIInterfaceOrientation)orientation
{
    // 手动旋转屏幕
    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

#pragma mark 监听网络状况
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [KBPlayerHelper sharedInstance]) {
        if ([keyPath isEqualToString:@"networkStatus"]) {
            switch ([KBPlayerHelper sharedInstance].networkStatus) {
                case ReachableViaWWAN:
                {
                    [self pause];
                    [self.controlView showNetworkWarning:ReachableViaWWAN];
                    break;
                }
                case ReachableViaWiFi:
                {
                    [self play];
                    [self.controlView showNetworkWarning:ReachableViaWiFi];
                    break;
                }
                case NotReachable:
                {
                    [self pause];
                    [self.controlView showNetworkWarning:NotReachable];
                    break;
                }
                default:
                    break;
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    [[KBPlayerHelper sharedInstance] removeObserver:self forKeyPath:@"networkStatus"];
}

@end
