//
//  AppMacro.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef AppMacro_h
#define AppMacro_h

/**
 *  一些公共属性define
 */

//----------------------------------- 网络环境设置 ------------------------------------
//默认是正式环境  上线必需注释这两项  优先选择DEBUG的环境

// 设置测试环境
#define APP_DEBUG

// 设置预发环境
#define APP_PRERELEASE


//----------------------------------- 是否会打印log ------------------------------------
#if defined APP_DEBUG

#define APP_SHOW_LOG_DEBUG

#elif defined APP_PRERELEASE

#define APP_SHOW_LOG_DEBUG

#else

#endif


#ifdef APP_SHOW_LOG_DEBUG
#define NSLog(...)  NSLog(__VA_ARGS__)
#define DLog(fmt, ...)  NSLog((@"[File:%@][Line: %d]%s " fmt),[[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define NSLog(...)
#define DLog(...)
#endif


//----------------------------------- block ------------------------------------
typedef void (^VoidBlock)();
typedef void (^IdBlock)(id object);
typedef void (^BoolBlock)(BOOL value);

//----------------------------------- 常用宏 ------------------------------------
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self
#define kAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define kWindow  [UIApplication sharedApplication].keyWindow
#define kTabBarController kAppDelegate.tabBarController
#define locationManager [LocationManager sharedInstance]
#define userManager [UserManager sharedInstance]
#define APPVERSION  [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]


#endif /* AppMacro_h */
