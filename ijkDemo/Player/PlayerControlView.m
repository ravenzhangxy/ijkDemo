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

typedef NS_ENUM(NSUInteger, PanDirection) {
    PanDirectionHorizon = 0,
    PanDirectionVertical
};

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
//progress
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UISlider *progressSlider;
//hud
@property (nonatomic, strong) UILabel *seekLabel;

@property (nonatomic, assign) BOOL isShowControl;
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, assign) PanDirection panDirection;
@property (nonatomic, assign) CGFloat panMoveDuration;

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
        self.zoomButton.selected = YES;
    } else {
        width = CGRectGetWidth(self.superview.frame);
        height = CGRectGetHeight(self.superview.frame);
        self.zoomButton.selected = NO;
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
    
    [self.timeLabel sizeToFit];
    CGRect timeLabelFrame = self.timeLabel.frame;
    timeLabelFrame.size.width += 5;
    self.timeLabel.frame = timeLabelFrame;
    self.timeLabel.center = CGPointMake(self.timeLabel.center.x, CGRectGetHeight(self.bottomPanel.frame) / 2.0);
    
    CGRect sliderFrame = self.progressSlider.frame;
    sliderFrame.origin.x = CGRectGetMaxX(self.timeLabel.frame) + 10;
    sliderFrame.size.width = CGRectGetWidth(_bottomPanel.frame) - CGRectGetMaxX(_timeLabel.frame) - CGRectGetWidth(_zoomButton.frame) - 10;
    self.progressSlider.frame = sliderFrame;
    
    self.seekLabel.center = CGPointMake(width / 2, height / 2);
}

- (void)setupViews
{
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHide)];
    singleTapGR.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapGR];
    
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction)];
    doubleTapGR.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGR];
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self addGestureRecognizer:panGR];
    
    [self addSubview:self.topPanel];
    [self addSubview:self.bottomPanel];
    
    [self.topPanel addSubview:self.backButton];
    [self.topPanel addSubview:self.titleLabel];
    
    [self.bottomPanel addSubview:self.playButton];
    [self.bottomPanel addSubview:self.timeLabel];
    [self.bottomPanel addSubview:self.zoomButton];
    [self.bottomPanel addSubview:self.progressSlider];
    
    [self addSubview:self.seekLabel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showOrHide];
    });
}

#pragma mark Event
- (void)back
{
    [self.delegate back];
}

- (void)showOrHide
{
    self.isShowControl = !self.isShowControl;
    if (self.isShowControl) {
        [UIView animateWithDuration:0.3 animations:^{
            self.topPanel.hidden = NO;
            self.bottomPanel.hidden = NO;
        }];
        [self performSelector:@selector(showOrHide) withObject:nil afterDelay:3.5];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.topPanel.hidden = YES;
            self.bottomPanel.hidden = YES;
        }];
    }
}

- (void)doubleTapAction
{
    self.isPlay = !self.isPlay;
    if (self.isPlay) {
        [self.delegate play];
    } else {
        [self.delegate pause];
    }
}

- (void)play:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.delegate pause];
    } else {
        [self.delegate play];
    }
}

- (void)refreshPlayBtnState:(KBPlaybackState)playbackState
{
    if (playbackState == KBPlaybackStatePlaying) {
        self.isPlay = YES;
        self.playButton.selected = NO;
    } else if (playbackState == KBPlaybackStatePaused || playbackState == KBPlaybackStateStopped) {
        self.isPlay = NO;
        self.playButton.selected = YES;
    }
}

- (void)zoom:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.delegate transformFullScreen:sender.selected];
}

- (void)sliderValueChanged:(UISlider *)sender
{
    if ([self.delegate respondsToSelector:@selector(seekToSliderValue:)]) {
        [self.delegate seekToSliderValue:sender.value];
    }
}

- (void)sliderCanceled
{
    if ([self.delegate respondsToSelector:@selector(play)]) {
        [self.delegate play];
        self.isPlay = YES;
        self.playButton.selected = NO;
    }
}

- (void)refreshTotalDuration:(NSTimeInterval)totalDuration
{
    self.progressSlider.maximumValue = totalDuration;
    self.totalDuration = totalDuration;
}

- (void)refreshProgress:(NSTimeInterval)currentTime
{
    self.progressSlider.value = currentTime;
    NSString *current = [NSString stringWithFormat:@"%02d:%02d", (int)((int)currentTime / 60), (int)((int)currentTime % 60)];
    NSString *total = [NSString stringWithFormat:@"%02d:%02d", (int)((int)self.totalDuration / 60), (int)((int)self.totalDuration % 60)];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", current, total];
}

- (void)panGestureAction:(UIPanGestureRecognizer *)pan
{
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint velocityPoint = [pan velocityInView:self];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            if (x > y) { // 水平移动
                self.panDirection = PanDirectionHorizon;
            } else { // 垂直运动
                self.panDirection = PanDirectionVertical;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) { // 音量调节
                    
                } else { // 亮度调节
                    
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            switch (self.panDirection) {
                case PanDirectionHorizon:{
                    // 水平移动的方法只要x方向的值
                    [self panTimeChange:velocityPoint.x];
                    break;
                }
                case PanDirectionVertical:{
                    // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizon:{
                    [self.delegate seekToSliderValue:self.progressSlider.value + self.panMoveDuration];
                    self.panMoveDuration = 0;
                    self.seekLabel.hidden = YES;
                    break;
                }
                case PanDirectionVertical:{
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
}

- (void)panTimeChange:(CGFloat)value
{
    self.panMoveDuration += value / 300;
    
    if (self.panMoveDuration > self.totalDuration - self.progressSlider.value) {
        self.panMoveDuration = self.totalDuration - self.progressSlider.value;
    }
    if (self.panMoveDuration < - self.progressSlider.value) {
        self.panMoveDuration = - self.progressSlider.value;
    }
    self.seekLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(((int)self.progressSlider.value + (int)self.panMoveDuration) / 60), (int)(((int)self.progressSlider.value + (int)self.panMoveDuration) % 60)];
    self.seekLabel.hidden = NO;
}

- (void)setVideoTitle:(NSString *)videoTitle
{
    _videoTitle = videoTitle;
    _titleLabel.text = videoTitle;
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
        _playButton.adjustsImageWhenHighlighted = NO;
        [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_playButton.frame), 0, 100 * kScaleBaseForPhone6Radio, CGRectGetHeight(_bottomPanel.frame))];
        _timeLabel.text = @"00:00/00:00";
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:13];
    }
    return _timeLabel;
}

- (UIButton *)zoomButton
{
    if (!_zoomButton) {
        _zoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _zoomButton.frame = CGRectMake(CGRectGetWidth(self.frame) - CGRectGetHeight(_bottomPanel.frame), 0, CGRectGetHeight(_bottomPanel.frame), CGRectGetHeight(_bottomPanel.frame));
        [_zoomButton setImage:[UIImage imageNamed:@"challenge_videoAllScreen"] forState:UIControlStateNormal];
        [_zoomButton setImage:[UIImage imageNamed:@"challenge_videoMiniScreen"] forState:UIControlStateSelected];
        _zoomButton.adjustsImageWhenHighlighted = NO;
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
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
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
        _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_timeLabel.frame) + 10, 0, CGRectGetWidth(_bottomPanel.frame) - CGRectGetMaxX(_timeLabel.frame) - CGRectGetWidth(_zoomButton.frame) - 10, CGRectGetHeight(_bottomPanel.frame))];
        _progressSlider.center = CGPointMake(_progressSlider.center.x, CGRectGetHeight(_bottomPanel.frame) / 2);
        _progressSlider.minimumTrackTintColor = [UIColor blueColor];
        _progressSlider.maximumTrackTintColor = [UIColor whiteColor];
        UIImage *thumbImg = [self getImageFromColor:[UIColor whiteColor] size:CGSizeMake(10, 10)];
        [_progressSlider setThumbImage:thumbImg forState:UIControlStateNormal];
        [_progressSlider setThumbImage:thumbImg forState:UIControlStateHighlighted];
        [_progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(sliderCanceled) forControlEvents:UIControlEventTouchDragExit | UIControlEventTouchCancel | UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
    }
    return _progressSlider;
}

- (UILabel *)seekLabel
{
    if (!_seekLabel) {
        _seekLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150 * kScaleBaseForPhone6Radio, 80 * kScaleBaseForPhone6Radio)];
        _seekLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _seekLabel.font = [UIFont systemFontOfSize:32];
        _seekLabel.textColor = [UIColor whiteColor];
        _seekLabel.textAlignment = NSTextAlignmentCenter;
        _seekLabel.hidden = YES;
        _seekLabel.layer.masksToBounds = YES;
        _seekLabel.layer.cornerRadius = 10;
    }
    return _seekLabel;
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


