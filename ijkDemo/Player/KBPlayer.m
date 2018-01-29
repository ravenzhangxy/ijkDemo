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

@interface KBPlayer () <PlayerControlDelegate, PlayerDelegate>

@property (nonatomic, strong) PlayerView *playerView;
@property (nonatomic, strong) PlayerControlView *controlView;

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
        
        // 监测设备方向
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDeviceOrientationChange)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onStatusBarOrientationChange)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        [self transformFullScreen:isfullScreen];
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
//        [self toOrientation:UIInterfaceOrientationLandscapeLeft];
    } else {
        [self toOrientation:UIInterfaceOrientationPortrait];
    }
    self.controlView.fullScreen = isZoomUp;
//    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    CGFloat x = screenSize.height/self.frame.size.width;
//    CGFloat y = screenSize.width/self.frame.size.height;
//
//    CGPoint newPosition = CGPointMake(screenSize.width/2, screenSize.height/2);
//    NSInteger transAngle = 90;
//
//    if (!isZoomUp) {
//        // 从全屏变为顶部显示
//        x = 1.0;
//        y = 1.0;
//        newPosition = CGPointMake(_originFrame.size.width/2, CGRectGetHeight(_originFrame)/2+CGRectGetMinY(_originFrame));
//        transAngle = 0;
//    }
//    CGAffineTransform t = CGAffineTransformMakeScale(y, x);
//    __weak typeof(self) weakSelf = self;
//    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//        weakSelf.layer.anchorPoint = CGPointMake(0.5,0.5);//围绕点
//        weakSelf.layer.position = newPosition;//位置
//        weakSelf.transform = CGAffineTransformRotate(t,transAngle* M_PI/180.0);
//        CGAffineTransform newTransform;
//        if (isZoomUp) {
//            weakSelf.controlView.fullScreen = YES;
//            newTransform = CGAffineTransformMakeScale(1/x, 1/y);
//        } else {
//            weakSelf.controlView.fullScreen = NO;
//            newTransform = CGAffineTransformMakeScale(1, 1);
//        }
//        [weakSelf resetSubViewsTransform:newTransform];
//    } completion:^(BOOL finished) {
//    }];
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

- (void)onStatusBarOrientationChange
{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self toOrientation:currentOrientation];
}

- (void)toOrientation:(UIInterfaceOrientation)orientation
{
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    // 判断如果当前方向和要旋转的方向一致,那么不做任何操作
    if (currentOrientation == orientation) { return; }

//    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];//DEPRECATED
    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
    // 获取旋转状态条需要的时间:
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    // 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
    // 给你的播放视频的view视图设置旋转
    self.transform = CGAffineTransformIdentity;
    self.transform = [self getTransformRotationAngle];
    // 开始旋转
    [UIView commitAnimations];
}

/**
 * 获取变换的旋转角度
 *
 * @return 角度
 */
- (CGAffineTransform)getTransformRotationAngle {
    // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

@end
