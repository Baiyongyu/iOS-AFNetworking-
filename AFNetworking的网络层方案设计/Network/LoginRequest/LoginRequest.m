//
//  LoginRequest.m
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import "LoginRequest.h"

@interface LoginRequest ()
@property (nonatomic,copy) void (^loginSuccessBlock)();
@property (nonatomic,copy) void (^loginFailureBlock)();
@end

@implementation LoginRequest

- (NSString *)requestPath {
    return Login_Url;
}

- (APIManagerRequestType)requestType {
    return APIManagerRequestTypePost;
}

- (Class)responseClass {
    return [LoginResponse class];
}

- (void)reformData {
    [self updateCookie];
}

- (NSInteger)loadDataWithHUDOnView:(UIView *)view {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        [cookieStorage deleteCookie:cookie];
    }
    return [super loadDataWithHUDOnView:view];
}

#pragma mark - public
+ (void)autoReloginSuccess:(void(^)())success failure:(void(^)())failure {
    if (![UserManager isLogedin]) {
        return;
    }
    DLog(@"%@-%@",userManager.userData.username, userManager.password);
    LoginRequest *loginRequest = [[LoginRequest alloc] init];
    loginRequest.paramSource = (id)loginRequest;
    loginRequest.delegate = (id)loginRequest;
    if (userManager.userData.username.length && userManager.password.length) {
        loginRequest.loginSuccessBlock = ^ {
            [UserManager saveLocalUserLoginInfo];
            success();
        };
        loginRequest.loginFailureBlock = ^ {
            failure();
        };
        [loginRequest loadDataWithHUDOnView:nil];
    } else {
        failure();
    }
}

#pragma mark - APIManagerApiCallBackDelegate
- (void)managerCallAPIDidSuccess:(BaseAPIRequest *)request {
    if (request==self) {
        if (self.loginSuccessBlock) {
            self.loginSuccessBlock();
        }
    }
}

- (void)managerCallAPIDidFailed:(BaseAPIRequest *)request {
    if (request==self) {
        if (self.loginFailureBlock) {
            self.loginFailureBlock();
        }
        return;
    }
}

#pragma mark - APIManagerParamSourceDelegate
- (NSDictionary *)paramsForApi:(BaseAPIRequest *)request {
    if (request==self) {
        return @{@"username":userManager.userData.username,
                 @"password":userManager.password,
                 @"client_version":APPVERSION,
                 @"device_type":@"1"};
    }
    return nil;
}

@end

@implementation LoginResponse


@end
