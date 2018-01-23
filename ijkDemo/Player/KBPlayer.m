//
//  KBPlayer.m
//  ijkDemo
//
//  Created by raven on 2018/1/23.
//  Copyright © 2018年 raven. All rights reserved.
//

#import "KBPlayer.h"
#import "PlayerView.h"
#import "IJKPlayerView.h"
#import "PlayerControlView.h"

@interface KBPlayer () <PlayerControlDelegate, PlayerDelegate>

@property (nonatomic, strong) PlayerView *playerView;
@property (nonatomic, strong) PlayerControlView *controlView;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, assign) KBPlayerType playerType;

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
    switch (playerType) {
        case KBPlayerTypeIJK:
        {
            self.playerView = [[IJKPlayerView alloc] initWithFrame:self.bounds url:url];
            break;
        }
        case KBPlayerTypeAVPlayer:
            break;
        default:
            break;
    }
    [self addSubview:self.playerView];
    self.playerView.delegate = self;
}

- (void)initControlView:(NSString *)title
{
    self.controlView = [[PlayerControlView alloc] initWithFrame:self.bounds];
    self.controlView.vedioTitle = title;
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
    [self.controlView refreshProgress:time];
    self.playerView.currentPlaybackTime = time;
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
        default: {
            break;
        }
    }
}

- (void)moviePlayBackDidFinish:(NSInteger)movieFinishReason
{
    switch (movieFinishReason) {
        case KBMovieFinishReasonPlaybackEnded: {
            [self.controlView stop];//视频播完时将按钮状态置为暂停状态
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

@end
