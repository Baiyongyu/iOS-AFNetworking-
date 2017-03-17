//
//  MBProgressHUD+Additions.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

@interface MBProgressHUD (Additions)

/**
 *  显示一个只有文字的框
 *
 *  @param aString  内容
 *  @param duration 显示时间
 */
+ (void)showMsgHUD:(NSString *)aString duration:(CGFloat)duration;

/**
 *  显示一个只有文字的框
 *
 *  @param aString  内容
 */
+ (void)showMsgHUD:(NSString *)aString;

/**
 *  在指定view上显示一个只有文字的框
 *
 *  @param aString  内容
 *  @param view  显示HUD的view
 *  @param duration 显示时间
 */
+ (void)showMsgHUD:(NSString *)aString onView:(UIView *)view duration:(CGFloat)duration;

/**
 *  显示一个只有文字的框
 *
 *  @param aString  内容
 *  @param duration 显示时间
 *  @param close    是否支持点击关闭
 */
+ (void)showMsgHUD:(NSString *)aString duration:(CGFloat)duration touchClose:(BOOL)close;

/**
 *  在指定view上显示一个只有文字的框
 *
 *  @param aString  内容
 *  @param view  显示HUD的view
 *  @param duration 显示时间
 *  @param close    是否支持点击关闭
 */
+ (void)showMsgHUD:(NSString *)aString onView:(UIView *)view duration:(CGFloat)duration touchClose:(BOOL)close;

/**
 *  显示一个有菊花，有文字，自动消失的框
 *
 *  @param aString  文字内容，如果是nil，则只有文字，
 *  @param duration 显示时间
 */
+ (void)showLoadingHUD:(NSString *)aString duration:(CGFloat)duration;

/**
 *  显示一个有菊花，有文字的框，需要调用hideLoadingHUD消失
 *
 *  @param aString 内容
 */
+ (void)showLoadingHUD:(NSString *)aString;

/**
 *  在指定view上显示一个有菊花，有文字的框，需要调用hideLoadingHUD消失
 *
 *  @param aString 内容
 *  @param view  显示HUD的view
 */
+ (void)showLoadingHUD:(NSString *)aString onView:(UIView *)view;

/**
 *  显示一个自定义图片，有文字的框，自动消失
 *
 *  @param aString 内容
 *  @param customImage 自定义图片
 */
+ (void)showMsgHUD:(NSString *)aString customImage:(UIImage *)customImage;

/**
 *  隐藏loading
 */
+ (void)hideLoadingHUD;

/**
 *  更新loading里面的内容
 *
 *  @param aString 内容
 */
+ (void)updateLoadingHUD:(NSString*)aString;

@end
