//
//  KBPlayer.h
//  ijkDemo
//
//  Created by raven on 2018/1/23.
//  Copyright © 2018年 raven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerHeader.h"

@interface KBPlayer : UIView

- (instancetype)initWithFrame:(CGRect)frame playerType:(KBPlayerType)playerType url:(NSURL *)url fullScreen:(BOOL)isfullScreen;

@end
