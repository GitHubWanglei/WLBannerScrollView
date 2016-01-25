# WLBannerScrollView
bannerView 封装, 可加载网络图片和本地图片, 加载网络图片采用NSURLSession进行网络请求加载, 适用于ios7及之后版本.

示例代码:

    //网络图片url
    NSArray *urlStrings = @[@"http://5.66825.com/download/pic/000/330/3b5cde71092b76905e66ef843b97ca49.jpg",
                            @"http://a0.att.hudong.com/15/08/300218769736132194086202411_950.jpg",
                            @"http://img2.3lian.com/img2007/19/03/024.jpg",
                            @"http://pic14.nipic.com/20110603/2707401_201406141000_2"];
    //初始化
    WLBannerScrollView *banner = [WLBannerScrollView viewWithFrame:banner_frame
                                                        URLStrings:urlStrings
                                                  placeholderImage:[UIImage imageNamed:@"placeholderImage.jpg"]
                                                      failureImage:[UIImage imageNamed:@"failureImage"]];
    //点击图片的回调
    [banner tapImageBlockHandle:^(UIImage *image, NSInteger currentPage) {
        NSLog(@"------currentPage: %ld", (long)currentPage);
    }];
    
    [self.view addSubview:banner];

效果图:

![image](https://raw.githubusercontent.com/GitHubWanglei/WLBannerScrollView/master/image.png)
