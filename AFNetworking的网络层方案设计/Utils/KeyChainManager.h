//
//  KeyChainManager.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kKeyPassword = @"com.beijing.LaundrySheet.password";

@interface KeyChainManager : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
