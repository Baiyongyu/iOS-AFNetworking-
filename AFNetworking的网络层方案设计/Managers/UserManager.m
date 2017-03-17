//
//  UserManager.m
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import "UserManager.h"
#import "KeyChainManager.h"

#define USER_DATA @"USER_DATA"

@implementation UserManager

+ (instancetype)sharedInstance {
    static UserManager *sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _userData = [[UserModel alloc] init];
    }
    return self;
}

- (void)updatePassword:(NSString *)password {
    if (!password.length) {
        return;
    }
    [KeyChainManager save:kKeyPassword data:password];
}

+ (void)saveLocalUserLoginInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[UserManager sharedInstance].userData];
    [userDefaults setObject:data forKey:USER_DATA];
    [userDefaults synchronize];
}


+ (void)removeLocalUserLoginInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:USER_DATA];
    [userDefaults synchronize];
}

+ (void)initWithLocalUserLoginInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UserModel *user = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:USER_DATA]];
    [UserManager sharedInstance].userData = user;
    DLog(@"%@-%@",user.username,userManager.password);
}

+ (BOOL)isLogedin {
    return [UserManager sharedInstance].userData.user_id.length > 0;
}

- (NSString *)password {
    return safeString([KeyChainManager load:kKeyPassword]);
}

@end
