//
//  PlayerControlView.m
//  ijkDemo
//
//  Created by raven on 2017/12/12.
//  Copyright © 2017年 raven. All rights reserved.
//

#import "PlayerControlView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BrightnessView.h"
#import "KBPlayerHelper.h"

#define kFixedScreenWidth    ( [[UIScreen mainScreen] respondsToSelector:@selector(fixedCoordinateSpace)] ? [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.width : [UIScreen mainScreen].bounds.size.width )
#define kScaleBaseForPhone6Radio (kFixedScreenWidth/375.0)

typedef NS_ENUM(NSUInteger, PanDirection) {
    PanDirectionHorizon = 0,
    PanDirectionVertical
};

typedef NS_ENUM(NSUInteger, AdjustType) {
    AdjustTypeVolume,
    AdjustTypeBrightness,
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
//
@property (nonatomic, strong) UILabel *seekLabel;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) BrightnessView *brightnessView;
@property (nonatomic, strong) UIButton *errorButton;
@property (nonatomic, strong) UIImageView *currentFrameImageView;
@property (nonatomic, strong) UIButton *replayButton;
@property (nonatomic, strong) UIButton *networkButton;

@property (nonatomic, assign) BOOL isShowControl;
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, assign) PanDirection panDirection;
@property (nonatomic, assign) CGFloat panMoveDuration;
@property (nonatomic, assign) AdjustType adjustType;

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
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    if (self.isFullScreen) {
        self.zoomButton.selected = YES;
    } else {
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
    self.errorButton.center = self.seekLabel.center;
    self.networkButton.center = self.seekLabel.center;
    self.currentFrameImageView.center = self.seekLabel.center;
    self.replayButton.center = self.seekLabel.center;
    
    [self.brightnessView removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:self.brightnessView];
    self.brightnessView.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
}

- (void)setupViews
{
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
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
    [self addSubview:self.errorButton];
    [self addSubview:self.networkButton];
    [self addSubview:self.currentFrameImageView];
    [self addSubview:self.replayButton];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self singleTapAction];
    });
    
    [self configureVolume];
    self.brightnessView = [[BrightnessView alloc] init];
    [[UIApplication sharedApplication].keyWindow addSubview:self.brightnessView];
}

/**
 *  获取系统音量
 */
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeSlider = (UISlider *)view;
            break;
        }
    }
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
}

#pragma mark --- Event
- (void)back
{
    if (self.isFullScreen) {
        [self.delegate transformFullScreen:NO];
    }
    [self.delegate back];
}

- (void)singleTapAction
{
    self.isShowControl = !self.isShowControl;
    if (self.isShowControl) {
        [self showOrHide:NO];
        [self performSelector:@selector(singleTapAction) withObject:nil afterDelay:5];
    } else {
        [self showOrHide:YES];
    }
}

- (void)showOrHide:(BOOL)isShow
{
    [UIView animateWithDuration:0.3 animations:^{
        self.topPanel.hidden = isShow;
        self.bottomPanel.hidden = isShow;
    }];
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
        self.replayButton.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
    } else if (playbackState == KBPlaybackStatePaused || playbackState == KBPlaybackStateStopped || playbackState == KBPlaybackStateFailed) {
        self.isPlay = NO;
        self.playButton.selected = YES;
        if (playbackState == KBPlaybackStateStopped) {
            self.replayButton.hidden = NO;
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        }
    } else if (playbackState == KBPlaybackStateReadyToPlay) {
        if ([KBPlayerHelper sharedInstance].networkStatus == ReachableViaWWAN) {
            _networkButton.hidden = NO;
            [self.delegate pause];
        }
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
    self.currentFrameImageView.hidden = YES;
    if (!self.playButton.userInteractionEnabled) {
        return;
    }
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

- (void)retry
{
    self.errorButton.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(retry)]) {
        [self.delegate retry];
        self.playButton.userInteractionEnabled = YES;
    }
}

- (void)showError:(BOOL)isShow
{
    self.errorButton.hidden = !isShow;
    if (isShow) {
        self.playButton.userInteractionEnabled = NO;
    }
}

- (void)updateCurrentFrameImage:(UIImage *)image
{
    self.currentFrameImageView.hidden = NO;
    self.currentFrameImageView.image = image;
}

- (void)replay
{
    if (!self.isPlay) {
        [self.delegate play];
    }
    self.networkButton.hidden = YES;
}

- (void)showNetworkWarning:(NetworkStatus)networkStatus
{
    if (networkStatus == ReachableViaWWAN) {
        [_networkButton setTitle:@"当前为移动网络，确认继续播放吗？" forState:UIControlStateNormal];
        _networkButton.hidden = NO;
    } else if (networkStatus == ReachableViaWiFi) {
        _networkButton.hidden = YES;
    } else if (networkStatus == NotReachable) {
        _networkButton.hidden = NO;
        [_networkButton setTitle:@"当前没有网络连接，请检查网络" forState:UIControlStateNormal];
    }
}

#pragma mark UIPanGestureRecognizer 滑动改变进度、音量、亮度
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
                    self.adjustType = AdjustTypeVolume;
                } else { // 亮度调节
                    self.adjustType = AdjustTypeBrightness;
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
                    [self adjustValueChange:velocityPoint.y];
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
                    __weak typeof(self) weakSelf = self;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        weakSelf.brightnessView.alpha = 0;
                    });
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

- (void)adjustValueChange:(CGFloat)value
{
    if (self.adjustType == AdjustTypeBrightness) {
        [UIScreen mainScreen].brightness -= value / 10000;
    } else if (self.adjustType == AdjustTypeVolume) {
        self.volumeSlider.value -= value / 10000;
    }
}

#pragma mark setter
- (void)setVideoTitle:(NSString *)videoTitle
{
    _videoTitle = videoTitle;
    _titleLabel.text = videoTitle;
}

#pragma mark --- lazy load
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
        [_playButton setImage:KBPlayerImage(@"KBPlayer_pause") forState:UIControlStateNormal];
        [_playButton setImage:KBPlayerImage(@"KBPlayer_play") forState:UIControlStateSelected];
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
        [_zoomButton setImage:KBPlayerImage(@"KBPlayer_fullscreen") forState:UIControlStateNormal];
        [_zoomButton setImage:KBPlayerImage(@"KBPlayer_miniScreen") forState:UIControlStateSelected];
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
        [_backButton setImage:KBPlayerImage(@"KBPlayer_back") forState:UIControlStateNormal];
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

- (UIButton *)errorButton
{
    if (!_errorButton) {
        _errorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _errorButton.frame = CGRectMake(0, 0, 200, 30);
        [_errorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_errorButton setTitle:@"加载失败，请点击重试" forState:UIControlStateNormal];
        [_errorButton addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
        _errorButton.hidden = YES;
    }
    return _errorButton;
}

- (UIImageView *)currentFrameImageView
{
    if (!_currentFrameImageView) {
        _currentFrameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160 * kScaleBaseForPhone6Radio, 120 * kScaleBaseForPhone6Radio)];
        _currentFrameImageView.hidden = YES;
    }
    return _currentFrameImageView;
}

- (UIButton *)replayButton
{
    if (!_replayButton) {
        _replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _replayButton.frame = CGRectMake(0, 0, 40 * kScaleBaseForPhone6Radio, 60 * kScaleBaseForPhone6Radio);
        [_replayButton setBackgroundImage:KBPlayerImage(@"KBPlayer_replay") forState:UIControlStateNormal];
        _replayButton.hidden = YES;
        [_replayButton addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _replayButton;
}

- (UIButton *)networkButton
{
    if (!_networkButton) {
        _networkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _networkButton.frame = CGRectMake(0, 0, 300, 30);
        [_networkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_networkButton setTitle:@"当前为移动网络，确认继续播放吗？" forState:UIControlStateNormal];
        [_networkButton addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
        _networkButton.hidden = YES;
    }
    return _networkButton;
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


