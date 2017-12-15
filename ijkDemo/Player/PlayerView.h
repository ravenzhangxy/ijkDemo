//
//  PlayerView.h
//  ijkDemo
//
//  Created by raven on 2017/12/14.
//  Copyright © 2017年 raven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerView : UIView

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)videoUrl;
- (void)prepareToPlay;
- (void)shutdown;
- (void)installMovieNotificationObservers;
- (void)removeMovieNotificationObservers;

@end
