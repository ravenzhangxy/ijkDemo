//
//  PlayerDelegate.h
//  ijkDemo
//
//  Created by raven on 2018/1/23.
//  Copyright © 2018年 raven. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayerDelegate <NSObject>

- (void)refreshProgress:(NSTimeInterval)time;
- (void)refreshTotalDuration:(NSTimeInterval)totalDuration;
- (void)moviePlayBackStateDidChange:(NSInteger)playbackState;

@end
