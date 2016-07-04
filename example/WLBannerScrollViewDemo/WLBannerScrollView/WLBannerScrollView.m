//
//  WLBannerScrollView.m
//
//  Created by wanglei on 15/12/31.
//  Copyright © 2015年 wanglei. All rights reserved.
//

#import "WLBannerScrollView.h"

@interface WLBannerScrollView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIImage *failureImage;
@property (nonatomic, assign) BOOL infiniteLoop;

@property (nonatomic, strong) NSArray *URLStrings;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSURLSession *URLSession;

@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) WLPageControl *pageControl;

@property (nonatomic, strong) UIImage *tapImage;
@property (nonatomic, assign) NSInteger tapPage;
@property (nonatomic, assign) tapBlock tapImageBlock;

@property (nonatomic, strong) scrollBlock scrollBlockHandle;//滑动 scroll 时的回调

@end

@implementation WLBannerScrollView

#pragma mark - 网络图片初始化方法
+ (instancetype)viewWithFrame:(CGRect)frame
                   URLStrings:(NSArray *)urlStrings
             placeholderImage:(UIImage *)placeholderImage
                 failureImage:(UIImage *)failureImage
                 infiniteLoop:(BOOL)infiniteLoop{
    return [[WLBannerScrollView alloc] initWithFrame:frame
                                          URLStrings:urlStrings
                                    placeholderImage:placeholderImage
                                        failureImage:failureImage
                                        infiniteLoop:infiniteLoop];
}

- (instancetype)initWithFrame:(CGRect)frame
                   URLStrings:(NSArray *)urlStrings
             placeholderImage:(UIImage *)placeholderImage
                 failureImage:(UIImage *)failureImage
                 infiniteLoop:(BOOL)infiniteLoop
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if (placeholderImage && [placeholderImage isKindOfClass:[UIImage class]]) {
            self.placeholderImage = placeholderImage;
        }
        if (failureImage && [failureImage isKindOfClass:[UIImage class]]) {
            self.failureImage = failureImage;
        }
        
        self.tapPage = 10000;
        self.infiniteLoop = infiniteLoop;
        [self initViewWithURLStrings:urlStrings];
    }
    return self;
}

#pragma mark - 本地图片初始化方法
+ (instancetype)viewWithFrame:(CGRect)frame images:(NSArray *)images infiniteLoop:(BOOL)infiniteLoop{
    return [[WLBannerScrollView alloc] initWithFrame:frame images:images infiniteLoop:(BOOL)infiniteLoop];
}

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images infiniteLoop:(BOOL)infiniteLoop
{
    self = [super initWithFrame:frame];
    if (self) {
        self.infiniteLoop = infiniteLoop;
        [self initViewWithImages:images];
    }
    return self;
}

#pragma mark - 通过 urlString 创建 view
-(void)initViewWithURLStrings:(NSArray *)urlStrings{
    if (urlStrings.count == 0) {
        return;
    }
    for (id obj in urlStrings) {
        if (![obj isKindOfClass:[NSString class]]) {
            return;
        }
    }
    self.URLStrings = [NSArray arrayWithArray:urlStrings];
    
    self.scrollView = nil;
    self.scrollView = [self creatScrollViewWithImagesCount:urlStrings.count];
    self.scrollView.delegate = self;
    self.scrollView.userInteractionEnabled = YES;
    [self addSubview:self.scrollView];
    
    self.showPageControl = YES;
    self.showIndicatorView = YES;
    
    for (int i = 0; i<self.URLStrings.count; i++) {
        [self addImageViewWithImage:self.placeholderImage page:i];
    }
    
    [self requestImages];
    
}

#pragma mark - 通过本地图片创建 view
-(void)initViewWithImages:(NSArray *)images{
    if (images.count == 0) {
        return;
    }
    for (id obj in images) {
        if (![obj isKindOfClass:[UIImage class]]) {
            return;
        }
    }
    
    self.images = [NSMutableArray arrayWithArray:images];
    
    self.scrollView = nil;
    self.scrollView = [self creatScrollViewWithImagesCount:images.count];
    self.scrollView.delegate = self;
    self.scrollView.userInteractionEnabled = YES;
    [self addSubview:self.scrollView];
    
    self.showPageControl = YES;
    self.showIndicatorView = YES;
    
    for (int i = 0; i<images.count; i++) {
        [self addImageViewWithImage:images[i] page:i];
        [self addButtonWithPage:i];
    }
    
}

#pragma mark - 创建 scrollView
-(UIScrollView *)creatScrollViewWithImagesCount:(NSInteger)count{
    
    CGFloat scrollView_W = self.bounds.size.width;
    CGFloat scrollView_H = self.bounds.size.height;
    NSInteger imagesCount = self.infiniteLoop ? count+2 : count;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.contentSize = CGSizeMake(scrollView_W*imagesCount, scrollView_H);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.directionalLockEnabled = YES;
    scrollView.alwaysBounceVertical = NO;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.backgroundColor = [UIColor blackColor];
    
    if (self.infiniteLoop == YES) {
        scrollView.contentOffset = CGPointMake(scrollView_W, 0);
    }
    
    return scrollView;
}

#pragma mark - 请求网络图片
-(void)requestImages{
    
    // 添加缓冲控件
    for (int i = 0; i<self.URLStrings.count; i++) {
        UIImageView *imageView = self.scrollView.subviews[i];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] init];
        indicatorView.backgroundColor = [UIColor clearColor];
        indicatorView.bounds = CGRectMake(0, 0, 50, 50);
        indicatorView.center = imageView.center;
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [indicatorView startAnimating];
        indicatorView.tag = i;
        [self.scrollView addSubview:indicatorView];
    }
    
    self.images = [NSMutableArray array];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    for (NSString *urlString in self.URLStrings) {
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        self.URLSession = session;
        NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSString *urlString = response.URL.absoluteString;
            NSUInteger page = [_URLStrings indexOfObject:urlString];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                for (UIActivityIndicatorView *subView in _scrollView.subviews) {
                    if ([subView isMemberOfClass:[UIActivityIndicatorView class]] && subView.tag == page) {
                        [subView startAnimating];
                        [subView removeFromSuperview];
                    }
                }
            });
            
            if (!error) {
                
#ifdef DEBUG
                NSLog(@"------request page %d finished.", (int)page);
#endif
                
                if (data.length>0) {
                    __block UIImage *image = [UIImage imageWithData:data];
                    
                    if (image == nil) {//请求失败
                        if (self.failureImage != nil) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self addImageViewWithImage:self.failureImage page:(int)page];
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self addImageViewWithImage:self.placeholderImage page:(int)page];
                            });
                        }
                    }else{//请求成功
                        [self.images addObject:image];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self addImageViewWithImage:image page:(int)page];
                            [self addButtonWithPage:(int)page];
                        });
                    }
                    
                }
                
            }else {
#ifdef DEBUG
                NSLog(@"error: %@", error.localizedDescription);
#endif
                
                if (self.failureImage != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addImageViewWithImage:self.failureImage page:(int)page];
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addImageViewWithImage:self.placeholderImage page:(int)page];
                    });
                }
                
            }
            
        }];
        [dataTask resume];
        
    }
    
}

#pragma mark - 在 scrollView 中添加图片
-(void)addImageViewWithImage:(UIImage *)image page:(int)page{
    
    CGFloat scrollView_W = self.bounds.size.width;
    CGFloat scrollView_H = self.bounds.size.height;
    
    if (self.infiniteLoop == NO) {
        CGRect imageViewFrame = CGRectMake(scrollView_W*page, 0, scrollView_W, scrollView_H);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.backgroundColor = [UIColor clearColor];
        if (image != nil) {
            imageView.image = image;
            imageView.tag = page;
        }
        [self.scrollView addSubview:imageView];
    }else{
        
        NSInteger imagesCount = self.URLStrings.count ? self.URLStrings.count : self.images.count;
        
        if (page == 0) {
            //最后一张
            CGRect imageViewFrame = CGRectMake(scrollView_W*(imagesCount+1), 0, scrollView_W, scrollView_H);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
            imageView.backgroundColor = [UIColor clearColor];
            //第二张
            CGRect imageViewFrame2 = CGRectMake(scrollView_W*(page+1), 0, scrollView_W, scrollView_H);
            UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:imageViewFrame2];
            imageView2.backgroundColor = [UIColor clearColor];
            if (image != nil) {
                imageView.image = image;
                imageView.tag = page;
                imageView2.image = image;
                imageView2.tag = page;
            }
            [self.scrollView addSubview:imageView];
            [self.scrollView addSubview:imageView2];
        }else if (page == imagesCount-1) {
            //第一张
            CGRect imageViewFrame = CGRectMake(scrollView_W*0, 0, scrollView_W, scrollView_H);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
            imageView.backgroundColor = [UIColor clearColor];
            //倒数第二张
            CGRect imageViewFrame2 = CGRectMake(scrollView_W*imagesCount, 0, scrollView_W, scrollView_H);
            UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:imageViewFrame2];
            imageView2.backgroundColor = [UIColor clearColor];
            if (image != nil) {
                imageView.image = image;
                imageView.tag = page;
                imageView2.image = image;
                imageView2.tag = page;
            }
            [self.scrollView addSubview:imageView];
            [self.scrollView addSubview:imageView2];
        }else{
            
            CGRect imageViewFrame = CGRectMake(scrollView_W*(page+1), 0, scrollView_W, scrollView_H);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
            imageView.backgroundColor = [UIColor clearColor];
            if (image != nil) {
                imageView.image = image;
                imageView.tag = page;
            }
            [self.scrollView addSubview:imageView];
        }
        
    }
    
}

-(void)addButtonWithPage:(int)page{
    CGFloat scrollView_W = self.bounds.size.width;
    CGFloat scrollView_H = self.bounds.size.height;
    CGRect BtnFrame = CGRectMake(0, 0, scrollView_W, scrollView_H);
    UIButton *btn = [[UIButton alloc] initWithFrame:BtnFrame];
    btn.backgroundColor = [UIColor clearColor];
    btn.tag = page;
    [btn addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
    for (UIImageView *imageView in self.scrollView.subviews) {
        if (imageView.tag == page) {
            [imageView addSubview:btn];
            imageView.userInteractionEnabled = YES;
        }
    }
}

-(void)clickImage:(UIButton *)btn{
    self.tapPage = (int)btn.tag;
    self.tapImage = ((UIImageView *)btn.superview).image;
    if (self.tapImage != nil && self.tapPage != 10000 && self.tapImageBlock != nil) {
        self.tapImageBlock(_tapImage, _tapPage);
    }
}

-(void)tapImageBlockHandle:(tapBlock)tapImageBlock{
    if (tapImageBlock) {
        self.tapImageBlock = tapImageBlock;
    }
}

-(void)setShowPageControl:(BOOL)showPageControl{
    if (showPageControl) {
        if (self.pageControl == nil) {
            
            WLPageControl *pageControl = [[WLPageControl alloc] init];
            CGSize size;
            if (self.URLStrings.count > 1) {
                pageControl.numberOfPages = self.URLStrings.count;
                size = [pageControl sizeForNumberOfPages:self.URLStrings.count];
            }else if (self.images.count > 1){
                pageControl.numberOfPages = self.images.count;
                size = [pageControl sizeForNumberOfPages:self.images.count];
            }
            pageControl.currentPage = 0;
            pageControl.backgroundColor = [UIColor clearColor];
            pageControl.bounds = CGRectMake(0, 0, size.width, size.height);
            pageControl.center = CGPointMake(self.scrollView.center.x, self.bounds.size.height-pageControl.bounds.size.height/2.0);
            [self addSubview:pageControl];
            [self bringSubviewToFront:pageControl];
            self.pageControl = pageControl;
            self.pageControl.enabled = NO;
        }
    }else{
        if (!self.pageControl) {
            [self.pageControl removeFromSuperview];
        }
    }
}

-(void)setShowIndicatorView:(BOOL)showIndicatorView{
    
    if (self.URLStrings.count > 0) {
        if (!showIndicatorView) {
            for (id obj in self.scrollView.subviews) {
                if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
                    [obj removeFromSuperview];
                }
            }
        }
    }
    
}

-(void)setCurrentPage:(NSInteger)currentPage animation:(BOOL)animation{
    
    if (self.pageControl != nil) {
        CGFloat scrollView_W = self.scrollView.bounds.size.width;
        if (self.infiniteLoop == YES) {
            if (currentPage == 0) {
                [self.scrollView setContentOffset:CGPointMake(1*scrollView_W, 0) animated:animation];
            }else{
                [self.scrollView setContentOffset:CGPointMake((currentPage+1)*scrollView_W, 0) animated:animation];
            }
        }else{
            [self.scrollView setContentOffset:CGPointMake(currentPage*scrollView_W, 0) animated:animation];
        }
        
    }
    
}

-(void)setPageControlNormalColor:(UIColor *)normalColor currentPageColor:(UIColor *)currentPageColor{
    if (self.pageControl != nil) {
        [self.pageControl setNormalColor:normalColor currentPageColor:currentPageColor];
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGPoint contentOffset = scrollView.contentOffset;
    NSInteger currentPage = contentOffset.x/scrollView.bounds.size.width;
    
    if (self.infiniteLoop == YES) {
        
        NSLog(@"-----%ld", currentPage);

        NSInteger imagesCount = self.URLStrings.count ? self.URLStrings.count : self.images.count;
        
        if (currentPage == 0) {
            self.pageControl.currentPage = imagesCount;
        }else if (currentPage == imagesCount+1) {
            self.pageControl.currentPage = 0;
        }else{
            self.pageControl.currentPage = currentPage-1;
        }
        
        //切换图片
        if (currentPage == 0) {
            CGFloat scrollView_W = self.scrollView.bounds.size.width;
            [self.scrollView setContentOffset:CGPointMake(imagesCount*scrollView_W, 0) animated:NO];
        }
        
        if (currentPage == imagesCount+1) {
            CGFloat scrollView_W = self.scrollView.bounds.size.width;
            [self.scrollView setContentOffset:CGPointMake(1*scrollView_W, 0) animated:NO];
        }
        
    }else{
        self.pageControl.currentPage = currentPage;
    }
}

//快速连续滑动时, 停留时间非常短, 切换时会卡顿, 不适用
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    
//    CGPoint contentOffset = scrollView.contentOffset;
//    NSInteger currentPage = contentOffset.x/scrollView.bounds.size.width;
//    
//    if (self.infiniteLoop == YES) {
//        
//        NSInteger imagesCount = self.URLStrings.count ? self.URLStrings.count : self.images.count;
//        
//        if (currentPage == 0) {
//            CGFloat scrollView_W = self.scrollView.bounds.size.width;
//            [self.scrollView setContentOffset:CGPointMake(imagesCount*scrollView_W, 0) animated:NO];
//        }
//        
//        if (currentPage == imagesCount+1) {
//            CGFloat scrollView_W = self.scrollView.bounds.size.width;
//            [self.scrollView setContentOffset:CGPointMake(1*scrollView_W, 0) animated:NO];
//        }
//        
//    }
//    
//}

@end




#pragma mark - 自定义 WLPageControl 类
@implementation WLPageControl {
    UIColor *_normalColor;
    UIColor *_currentPageColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    [self freshColor];
}

-(void)setNormalColor:(UIColor *)normalColor currentPageColor:(UIColor *)currentPageColor{
    for (int i= 0 ; i<self.numberOfPages; i++) {
        UIView *dot = self.subviews[i];
        if (i == self.currentPage) {
            if (currentPageColor) {
                dot.backgroundColor = currentPageColor;
                _currentPageColor = currentPageColor;
            }
        }else{
            if (normalColor) {
                dot.backgroundColor = normalColor;
                _normalColor = normalColor;
            }
        }
    }
}

-(void)freshColor{
    for (int i= 0 ; i<self.numberOfPages; i++) {
        UIView *dot = self.subviews[i];
        if (i == self.currentPage) {
            if (_currentPageColor) {
                dot.backgroundColor = _currentPageColor;
            }
        }else{
            if (_normalColor) {
                dot.backgroundColor = _normalColor;
            }
        }
    }
    
}

@end

























