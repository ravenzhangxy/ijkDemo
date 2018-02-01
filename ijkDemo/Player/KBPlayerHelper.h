//
//  KBPlayerHelper.h
//  ijkDemo
//
//  Created by raven on 2018/1/25.
//  Copyright © 2018年 raven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface KBPlayerHelper : NSObject

@property (nonatomic, assign) NetworkStatus networkStatus;

+ (instancetype)sharedInstance;
- (void)registerReachability;

@end
