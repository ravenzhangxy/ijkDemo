//
//  KBPlayerHelper.m
//  ijkDemo
//
//  Created by raven on 2018/1/25.
//  Copyright © 2018年 raven. All rights reserved.
//

#import "KBPlayerHelper.h"

@interface KBPlayerHelper ()

@property (nonatomic, strong) Reachability *hostReachability;
@property (nonatomic, strong) Reachability *routerReachability;

@end

@implementation KBPlayerHelper

+ (instancetype)sharedInstance
{
    static KBPlayerHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[KBPlayerHelper alloc] init];
    });
    return helper;
}

- (void)registerReachability
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    // 检测指定服务器是否可达
    NSString *remoteHostName = @"www.baidu.com";
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    // 检测默认路由是否可达
    self.routerReachability = [Reachability reachabilityForInternetConnection];
    [self.routerReachability startNotifier];
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    [KBPlayerHelper sharedInstance].networkStatus = reach.currentReachabilityStatus;
    switch (reach.currentReachabilityStatus) {
        case NotReachable:
            NSLog(@"NotReachable");
            break;
        case ReachableViaWWAN:
            NSLog(@"ReachableViaWWAN");
            break;
        case ReachableViaWiFi:
            NSLog(@"ReachableViaWiFi");
            break;
        default:
            break;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
