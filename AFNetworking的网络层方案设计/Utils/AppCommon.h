//
//  AppCommon.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import <UIKit/UIKit.h>

UIWindow *mainWindow();

UIViewController *topMostViewController();

@interface AppCommon : NSObject

+ (void)showLoading;
+ (void)hideLoading;

////隐藏导航栏
+ (void)showNavigationBar:(BOOL)isShow;

////统一调用此方法来push
+ (void)pushViewController:(UIViewController*)vc animated:(BOOL)animated;
+ (void)presentViewController:(UIViewController*)vc animated:(BOOL)animated;
+ (void)dismissViewControllerAnimated:(BOOL)animated;
+ (void)pushWithVCClass:(Class)vcClass properties:(NSDictionary*)properties;
+ (void)pushWithVCClassName:(NSString*)className properties:(NSDictionary*)properties;
+ (void)pushWithVCClass:(Class)vcClass;
+ (void)pushWithVCClassName:(NSString*)className;
+ (void)pushWithVCClassName:(NSString*)className needLogin:(BOOL)isNeedLogin;
+ (void)popViewControllerAnimated:(BOOL)animated;
+ (UINavigationController *)rootNavigationController;
+ (void)removeVC:(UIViewController *)thevc;
+ (void)setDeviceToken:(NSString*)deviceToken;
+ (NSString*)deviceToken;

@end
