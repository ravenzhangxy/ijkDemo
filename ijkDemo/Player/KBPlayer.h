//
//  KBPlayer.h
//  ijkDemo
//
//  Created by raven on 2018/1/23.
//  Copyright © 2018年 raven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerHeader.h"

typedef void(^backActionBlock)(void);
typedef void(^playFinishBlock)(KBMovieFinishReason reason);

@interface KBPlayer : UIView

@property (nonatomic, copy) backActionBlock backActionBlock;
@property (nonatomic, copy) playFinishBlock playFinishBlock;

- (instancetype)initWithFrame:(CGRect)frame playerType:(KBPlayerType)playerType url:(NSURL *)url title:(NSString *)title fullScreen:(BOOL)isfullScreen;
- (void)shutdown;

@end
