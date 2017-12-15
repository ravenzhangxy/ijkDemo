//
//  PlayerControlView.m
//  ijkDemo
//
//  Created by raven on 2017/12/12.
//  Copyright © 2017年 raven. All rights reserved.
//

#import "PlayerControlView.h"

#define kFixedScreenWidth    ( [[UIScreen mainScreen] respondsToSelector:@selector(fixedCoordinateSpace)] ? [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.width : [UIScreen mainScreen].bounds.size.width )
#define kScaleBaseForPhone6Radio (kFixedScreenWidth/375.0)

@interface PlayerControlView ()

@property (nonatomic, strong) UIView *topPanel;
@property (nonatomic, strong) UIView *bottomPanel;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *zoomButton;

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalDurationLabel;
@property (nonatomic, strong) UISlider *mediaProgressSlider;

@property(nonatomic, assign) BOOL isShowControl;
@property(nonatomic, assign) BOOL isPlay;

@end

@implementation PlayerControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isShowControl = YES;
        self.isPlay = YES;
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHide)];
    singleTapGR.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapGR];
    
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playOrPause)];
    doubleTapGR.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGR];
    
    [self addSubview:self.topPanel];
    [self addSubview:self.bottomPanel];
    [self.bottomPanel addSubview:self.playButton];
    [self.bottomPanel addSubview:self.currentTimeLabel];
    [self.bottomPanel addSubview:self.zoomButton];
}

#pragma mark Event
- (void)showOrHide
{
    self.isShowControl = !self.isShowControl;
    if (self.isShowControl) {
        [UIView animateWithDuration:0.3 animations:^{
            self.topPanel.hidden = NO;
            self.bottomPanel.hidden = NO;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.topPanel.hidden = YES;
            self.bottomPanel.hidden = YES;
        }];
    }
}

- (void)playOrPause
{
    self.isPlay = !self.isPlay;
    if (self.isPlay) {
        self.playButton.selected = NO;
        [self.delegate play];
    } else {
        self.playButton.selected = YES;
        [self.delegate pause];
    }
}

- (void)play:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.isPlay = NO;
        [self.delegate pause];
    } else {
        self.isPlay = YES;
        [self.delegate play];
    }
}

- (void)zoom:(UIButton *)sender
{
    sender.selected = !sender.selected;
}

#pragma mark lazy load
- (UIView *)topPanel
{
    if (!_topPanel) {
        _topPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 40 * kScaleBaseForPhone6Radio)];
        _topPanel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    return _topPanel;
}

- (UIView *)bottomPanel
{
    if (!_bottomPanel) {
        _bottomPanel = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 40 * kScaleBaseForPhone6Radio, CGRectGetWidth(self.frame), 40 * kScaleBaseForPhone6Radio)];
        _bottomPanel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    return _bottomPanel;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(0, 0, CGRectGetHeight(_bottomPanel.frame), CGRectGetHeight(_bottomPanel.frame));
        [_playButton setImage:[UIImage imageNamed:@"challenge_videoPause"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"challenge_videoPlay"] forState:UIControlStateSelected];
        [_playButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playButton.frame), 0, 100 * kScaleBaseForPhone6Radio, CGRectGetHeight(_bottomPanel.frame))];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UIButton *)zoomButton
{
    if (!_zoomButton) {
        _zoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _zoomButton.frame = CGRectMake(CGRectGetWidth(self.frame) - CGRectGetHeight(_bottomPanel.frame), 0, CGRectGetHeight(_bottomPanel.frame), CGRectGetHeight(_bottomPanel.frame));
        [_zoomButton setImage:[UIImage imageNamed:@"challenge_videoAllScreen"] forState:UIControlStateNormal];
        [_zoomButton setImage:[UIImage imageNamed:@"challenge_videoMiniScreen"] forState:UIControlStateSelected];
        [_zoomButton addTarget:self action:@selector(zoom:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zoomButton;
}

@end
