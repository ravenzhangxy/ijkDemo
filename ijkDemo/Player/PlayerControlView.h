//
//  PlayerControlView.h
//  ijkDemo
//
//  Created by raven on 2017/12/12.
//  Copyright © 2017年 raven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerDelegate.h"

@interface PlayerControlView : UIView

@property (nonatomic, weak) id<PlayerDelegate>delegate;
@property (nonatomic, getter=isFullScreen) BOOL fullScreen;

- (void)playOrPause;

@end
