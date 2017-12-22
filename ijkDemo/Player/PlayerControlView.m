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
//top
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
//bottom
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *zoomButton;

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalDurationLabel;
@property (nonatomic, strong) UISlider *progressSlider;

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

- (void)layoutSubviews
{
    CGFloat width = 0.f;
    CGFloat height = 0.f;
    if (self.isFullScreen) {
        width = CGRectGetHeight(self.superview.frame);
        height = CGRectGetWidth(self.superview.frame);
    } else {
        width = CGRectGetWidth(self.superview.frame);
        height = CGRectGetHeight(self.superview.frame);
    }
    
    CGRect topFrame = self.topPanel.frame;
    topFrame.size.width = width;
    self.topPanel.frame = topFrame;
    
    CGRect bottomFrame = self.bottomPanel.frame;
    bottomFrame.size.width = width;
    bottomFrame.origin.y = height - CGRectGetHeight(bottomFrame);
    self.bottomPanel.frame = bottomFrame;
    
    CGRect zoomFrame = self.zoomButton.frame;
    zoomFrame.origin.x = CGRectGetWidth(self.bottomPanel.frame) - CGRectGetWidth(zoomFrame);
    self.zoomButton.frame = zoomFrame;
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
    
    [self.topPanel addSubview:self.backButton];
    [self.topPanel addSubview:self.titleLabel];
    
    [self.bottomPanel addSubview:self.playButton];
    [self.bottomPanel addSubview:self.currentTimeLabel];
    [self.bottomPanel addSubview:self.zoomButton];
    [self.bottomPanel addSubview:self.progressSlider];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showOrHide];
    });
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
    [self.delegate transformScreen:sender.selected];
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

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, CGRectGetHeight(_topPanel.frame), CGRectGetHeight(_topPanel.frame));
        [_backButton setImage:[UIImage imageNamed:@"challenge_videoBack"] forState:UIControlStateNormal];
//        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_backButton.frame), 0, 200 * kScaleBaseForPhone6Radio, CGRectGetHeight(_topPanel.frame))];
        _titleLabel.text = @"这是一个标题";
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_currentTimeLabel.frame), 0, CGRectGetWidth(_bottomPanel.frame) - CGRectGetMaxX(_currentTimeLabel.frame) - CGRectGetWidth(_zoomButton.frame), CGRectGetHeight(_bottomPanel.frame))];
        _progressSlider.center = CGPointMake(_progressSlider.center.x, CGRectGetHeight(_bottomPanel.frame) / 2);
        _progressSlider.minimumTrackTintColor = [UIColor blueColor];
        _progressSlider.maximumTrackTintColor = [UIColor whiteColor];
        UIImage *thumbImg = [self getImageFromColor:[UIColor whiteColor] size:CGSizeMake(10, 10)];
        [_progressSlider setThumbImage:thumbImg forState:UIControlStateNormal];
        [_progressSlider setThumbImage:thumbImg forState:UIControlStateHighlighted];
    }
    return _progressSlider;
}

//通过颜色来生成一个纯色图片
- (UIImage *)getImageFromColor:(UIColor *)color size:(CGSize)aSize
{
    CGRect rect = CGRectZero;
    rect.size = aSize;
    UIGraphicsBeginImageContextWithOptions(rect.size, 0, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);//锯齿
    CGContextAddEllipseInRect(context, rect);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillPath(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end
