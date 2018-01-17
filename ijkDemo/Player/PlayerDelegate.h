//
//  PlayerDelegate.h
//  ijkDemo
//
//  Created by raven on 2017/12/12.
//  Copyright © 2017年 raven. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerDelegate <NSObject>

- (void)play;
- (void)pause;
- (void)back;
- (void)transformFullScreen:(BOOL)isZoomUp;
- (void)seekToSliderValue:(NSTimeInterval)time;

@end
