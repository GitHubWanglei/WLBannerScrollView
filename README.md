# WLBannerScrollView
bannerView 封装,可加载网络图片和本地图片,加载网络图片不需依赖第三方sdk,采用NSURLSession进行网络请求加载,适用于ios7及之后版本

示例代码:

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

示例图片:

![image](https://raw.githubusercontent.com/GitHubWanglei/WLBannerScrollView/master/image.png)
