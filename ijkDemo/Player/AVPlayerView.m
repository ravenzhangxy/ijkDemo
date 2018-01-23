//
//  AVPlayerView.m
//  ijkDemo
//
//  Created by raven on 2018/1/23.
//  Copyright © 2018年 raven. All rights reserved.
//

#import "AVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerView ()

@property (nonatomic,strong) AVPlayerLayer *playerViewLayer;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayer *player;

@end

@implementation AVPlayerView

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url
{
    if (self = [super initWithFrame:frame url:url]) {
        
    }
    return self;
}

@end
