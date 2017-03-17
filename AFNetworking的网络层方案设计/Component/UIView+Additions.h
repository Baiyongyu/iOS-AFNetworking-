//
//  UIView+Additions.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LINE_HEIGHT     (1/[[UIScreen mainScreen] scale])

typedef void(^UIViewClickHandle)(UIView *view);

@interface UIView (Additions)

/**
 *  orgin.x
 */
@property (nonatomic, assign) CGFloat left;
/**
 *  origin.y
 */
@property (nonatomic, assign) CGFloat top;
/**
 *  origin.x+width
 */
@property (nonatomic, assign) CGFloat right;
/**
 *  y+height
 */
@property (nonatomic, assign) CGFloat bottom;
/**
 *  view.frame.size.width 宽
 */
@property (nonatomic, assign) CGFloat width;
/**
 *  view.frame.size.height 高
 */
@property (nonatomic, assign) CGFloat height;
/**
 *  view.frame.origin
 */
@property (nonatomic, assign) CGPoint origin;
/**
 *  view.frame.size
 */
@property (nonatomic, assign) CGSize  size;
/**
 *  清空所有子view
 */
-(void)removeAllSubviews;
/**
 *  增加UIView的点击事件
 */
-(void)handleClick:(UIViewClickHandle)handle;

/**
 *  获取所在的控制器
 */
- (UIViewController*)viewController;

/**
 *  底部增加一根线，自动布局方式
 */
- (UIView *)addLineOnBottom;

/**
 *  当前view截图
 */
- (UIImage*)createImageWithScale:(CGFloat)scale;

#pragma mark - 设置部分圆角
/**
 *  设置部分圆角(绝对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii;
/**
 *  设置部分圆角(相对布局)
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 *  @param rect    需要设置的圆角view的rect
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                withRadii:(CGSize)radii
                 viewRect:(CGRect)rect;

@end
