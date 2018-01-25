//
//  BrightnessView.m
//  ijkDemo
//
//  Created by raven on 2018/1/25.
//  Copyright © 2018年 raven. All rights reserved.
//

#import "BrightnessView.h"

@interface BrightnessView ()

@property (nonatomic, strong) UIView *brightnessLevelView;
@property (nonatomic, strong) NSMutableArray *tipArray;

@end

@implementation BrightnessView

- (void)layoutSubviews
{
    self.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
}

- (instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, 155, 155);
        [self setupUI];
        [self createTips];
        [self addObserver];
    }
    return self;
}

- (void)setupUI
{
    self.layer.cornerRadius  = 10;
    self.layer.masksToBounds = YES;
    // 使用UIToolbar实现毛玻璃效果，简单粗暴，支持iOS7+
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    toolbar.alpha = 0.97;
    [self addSubview:toolbar];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.bounds), 30)];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"亮度";
    [self addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"brightness"]];
    imageView.frame = CGRectMake(0, 0, 79, 76);
    imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self addSubview:imageView];
    
    self.brightnessLevelView = [[UIView alloc]initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
    self.brightnessLevelView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
    [self addSubview:self.brightnessLevelView];
    
    self.alpha = 0.0f;
}

- (void)createTips
{
    self.tipArray = [NSMutableArray arrayWithCapacity:16];
    CGFloat tipW = (self.brightnessLevelView.bounds.size.width - 17) / 16;
    CGFloat tipH = 5;
    CGFloat tipY = 1;
    
    for (int i = 0; i < 16; i++) {
        CGFloat tipX = i * (tipW + 1) + 1;
        UIImageView *image = [[UIImageView alloc] init];
        image.backgroundColor = [UIColor whiteColor];
        image.frame = CGRectMake(tipX, tipY, tipW, tipH);
        [self.brightnessLevelView addSubview:image];
        [self.tipArray addObject:image];
    }
    [self updateBrightnessLevel:[UIScreen mainScreen].brightness];
}

- (void)updateBrightnessLevel:(CGFloat)brightnessLevel {
    CGFloat stage = 1 / 16.0;
    NSInteger level = brightnessLevel / stage;
    for (int i = 0; i < self.tipArray.count; i++) {
        UIImageView *img = self.tipArray[i];
        if (i <= level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}

- (void)addObserver
{
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CGFloat brightness = [change[@"new"] floatValue];
    self.alpha = 1.f;
    [self updateBrightnessLevel:brightness];
}

- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
}

@end
