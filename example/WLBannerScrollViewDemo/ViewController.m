//
//  ViewController.m
//  WLBannerScrollViewDemo
//
//  Created by lihongfeng on 15/12/31.
//  Copyright © 2015年 wanglei. All rights reserved.
//

#import "ViewController.h"
#import "WLBannerScrollView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //网络图片url
    NSArray *urlStrings = @[@"http://5.66825.com/download/pic/000/330/3b5cde71092b76905e66ef843b97ca49.jpg",
                            @"http://a0.att.hudong.com/15/08/300218769736132194086202411_950.jpg",
                            @"http://img2.3lian.com/img2007/19/03/024.jpg",
                            @"http://pic14.nipic.com/20110603/2707401_201406141000_2.jpg"];
    //初始化
    CGRect banner_frame = CGRectMake(0, 0, self.view.bounds.size.width, 200);
    WLBannerScrollView *banner = [WLBannerScrollView viewWithFrame:banner_frame
                                                        URLStrings:urlStrings
                                                  placeholderImage:[UIImage imageNamed:@"placeholderImage.jpg"]];
    //回调
    banner.scrollBlockHandle = ^(UIImage *image, NSInteger currentPage){
        NSLog(@"------------image: %@", image);
        NSLog(@"------currentPage: %ld", (long)currentPage);
    };
    
    //本地图片
//    NSMutableArray *images = [NSMutableArray array];
//    for (int i = 0; i<3; i++) {
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
//        [images addObject:image];
//    }
    //加载本地图片
    //    WLBannerScrollView *banner = [WLBannerScrollView viewWithFrame:banner_frame images:images];
    
    [self.view addSubview:banner];
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
