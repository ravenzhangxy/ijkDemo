//
//  ViewController.m
//  ijkDemo
//
//  Created by raven on 2017/12/11.
//  Copyright © 2017年 raven. All rights reserved.
//

#import "ViewController.h"
#import "PlayerView.h"

@interface ViewController ()

@property (nonatomic, strong) PlayerView *playerView;

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
    
    self.playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 300) videoUrl:@"http://knowapp.b0.upaiyun.com/ss/live/video/hanjia2.mp4"];
    [self.view addSubview:self.playerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.playerView prepareToPlay];
    [self.playerView installMovieNotificationObservers];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.playerView shutdown];
    [self.playerView removeMovieNotificationObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
