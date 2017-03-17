//
//  UserManager.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject

+ (instancetype)sharedInstance;
+ (BOOL)isLogedin;
+ (void)saveLocalUserLoginInfo;
+ (void)removeLocalUserLoginInfo;
+ (void)initWithLocalUserLoginInfo;

- (void)updatePassword:(NSString *)password;

@property(nonatomic, strong) UserModel *userData;
@property(nonatomic, copy) NSString *password;

@end
