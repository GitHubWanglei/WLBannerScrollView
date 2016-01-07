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

@property (nonatomic, strong) NSArray *URLStrings;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSURLSession *URLSession;

@property (nonatomic, strong) NSMutableArray *images;

@property (nonatomic, strong) WLPageControl *pageControl;

@end

@implementation WLBannerScrollView

+ (instancetype)viewWithFrame:(CGRect)frame URLStrings:(NSArray *)urlStrings placeholderImage:(UIImage *)placeholderImage failureImage:(UIImage *)failureImage{
    return [[WLBannerScrollView alloc] initWithFrame:frame URLStrings:urlStrings placeholderImage:placeholderImage failureImage:failureImage];
}

- (instancetype)initWithFrame:(CGRect)frame URLStrings:(NSArray *)urlStrings placeholderImage:(UIImage *)placeholderImage failureImage:(UIImage *)failureImage
{
    self = [super initWithFrame:frame];
    if (self) {
        
        if (placeholderImage && [placeholderImage isKindOfClass:[UIImage class]]) {
            self.placeholderImage = placeholderImage;
        }
        if (failureImage && [failureImage isKindOfClass:[UIImage class]]) {
            self.failureImage = failureImage;
        }
        
        [self initViewWithURLStrings:urlStrings];
    }
    return self;
}

+ (instancetype)viewWithFrame:(CGRect)frame images:(NSArray *)images{
    return [[WLBannerScrollView alloc] initWithFrame:frame images:images];
}

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray *)images
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViewWithImages:images];
    }
    return self;
}

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
    [self addSubview:self.scrollView];
    
    self.showPageControl = YES;
    self.showIndicatorView = YES;
    
    for (int i = 0; i<self.URLStrings.count; i++) {
        [self addImageViewWithImage:self.placeholderImage page:i];
    }
    
    [self requestImages];
    
}

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
    [self addSubview:self.scrollView];
    
    self.showPageControl = YES;
    self.showIndicatorView = YES;
    
    for (int i = 0; i<images.count; i++) {
        [self addImageViewWithImage:images[i] page:i];
    }
    
}

-(UIScrollView *)creatScrollViewWithImagesCount:(NSInteger)count{
    
    CGFloat scrollView_W = self.bounds.size.width;
    CGFloat scrollView_H = self.bounds.size.height;
    NSInteger urlCount = count;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.contentSize = CGSizeMake(scrollView_W*urlCount, scrollView_H);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.directionalLockEnabled = YES;
    scrollView.alwaysBounceVertical = NO;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.backgroundColor = [UIColor blackColor];
    
    return scrollView;
}

-(void)requestImages{
    
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
                NSLog(@"------request page %d finished", (int)page);
#endif
                
                if (data.length>0) {
                    __block UIImage *image = [UIImage imageWithData:data];
                    
                    if (image == nil) {
                        if (self.failureImage != nil) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self addImageViewWithImage:self.failureImage page:(int)page];
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self addImageViewWithImage:self.placeholderImage page:(int)page];
                            });
                        }
                    }else{
                        [self.images addObject:image];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self addImageViewWithImage:image page:(int)page];
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

-(void)addImageViewWithImage:(UIImage *)image page:(int)page{
    
    CGFloat scrollView_W = self.bounds.size.width;
    CGFloat scrollView_H = self.bounds.size.height;
    CGRect imageViewFrame = CGRectMake(scrollView_W*page, 0, scrollView_W, scrollView_H);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    imageView.backgroundColor = [UIColor clearColor];
    if (image != nil) {
        imageView.image = image;
        
    }
    [self.scrollView addSubview:imageView];
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
            
            if (self.scrollView != nil && animation == YES) {
                [self.scrollView setContentOffset:CGPointMake(currentPage*scrollView_W, 0) animated:YES];
                self.pageControl.currentPage = currentPage;
            }
            if (self.scrollView != nil && animation == NO) {
                [self.scrollView setContentOffset:CGPointMake(currentPage*scrollView_W, 0) animated:NO];
                self.pageControl.currentPage = currentPage;
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
    
    if (self.scrollBlockHandle) {
        if (currentPage < self.images.count) {
            self.scrollBlockHandle(self.images[currentPage], currentPage);
        }else{
            self.scrollBlockHandle(nil, currentPage);
        }
    }
    
    self.pageControl.currentPage = currentPage;
}

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

























