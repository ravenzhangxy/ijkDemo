//
//  PlayerView.h
//  ijkDemo
//
//  Created by raven on 2017/12/14.
//  Copyright © 2017年 raven. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^backBlock)(void);

@interface PlayerView : UIView

@property (nonatomic, copy) backBlock backBlock;

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)videoUrl isFullScreen:(BOOL)isFullScreen;
- (void)prepareToPlay;
- (void)shutdown;
- (void)installMovieNotificationObservers;
- (void)removeMovieNotificationObservers;

@end
