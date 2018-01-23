//
//  ViewController.m
//  ijkDemo
//
//  Created by raven on 2017/12/11.
//  Copyright © 2017年 raven. All rights reserved.
//

#import "ViewController.h"
#import "KBPlayer.h"

@interface ViewController ()

@property (nonatomic, strong) KBPlayer *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //    https://susuanqiniu.knowbox.cn/map_videos/introduction.flv
    //    https://knowapp.b0.upaiyun.com/ss/live/video/170724_school_introduction.mp4
    //    http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8
    //    http://knowapp.b0.upaiyun.com/ss/live/video/hanjia2.mp4
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.playerView = [[KBPlayer alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 300) playerType:KBPlayerTypeAVPlayer url:[NSURL URLWithString:@"http://knowapp.b0.upaiyun.com/ss/live/video/hanjia2.mp4"] title:@"123" fullScreen:NO];
    __weak typeof(self) weakSelf = self;
    self.playerView.backActionBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    [self.view addSubview:self.playerView];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
