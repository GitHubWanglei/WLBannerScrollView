//
//  WLBannerScrollView.h
//
//  Created by wanglei on 15/12/31.
//  Copyright © 2015年 wanglei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^tapBlock)(UIImage *image, NSInteger currentPage);
typedef void(^scrollBlock)(UIImage *image, NSInteger currentPage);

@interface WLBannerScrollView : UIView

@property (nonatomic, assign) BOOL showPageControl;// 是否显示 pageControl, 默认显示
@property (nonatomic, assign) BOOL showIndicatorView;// 是否显示菊花缓冲控件 indicatorView, 默认显示

//加载网络图片的初始化方法
+ (instancetype)viewWithFrame:(CGRect)frame URLStrings:(NSArray *)urlStrings placeholderImage:(UIImage *)placeholderImage failureImage:(UIImage *)failureImage;

//加载本地图片的初始化方法
+ (instancetype)viewWithFrame:(CGRect)frame images:(NSArray *)images;

//点击图片的回调
- (void)tapImageBlockHandle:(tapBlock)tapImageBlock;

//滑动图片的回调
- (void)scrollImageBlockHandle:(scrollBlock)scrollImageBlock;

//设置当前页
- (void)setCurrentPage:(NSInteger)currentPage animation:(BOOL)animation;

//设置 pageControl 颜色
- (void)setPageControlNormalColor:(UIColor *)normalColor currentPageColor:(UIColor *)currentPageColor;

@end



//自定义 PageControl
@interface WLPageControl : UIPageControl
-(void)setNormalColor:(UIColor *)normalColor currentPageColor:(UIColor *)currentPageColor;
@end