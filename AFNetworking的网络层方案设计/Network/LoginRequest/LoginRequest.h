//
//  LoginRequest.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import "BaseAPIRequest.h"

@interface LoginRequest : BaseAPIRequest <APIManager>

+ (void)autoReloginSuccess:(void(^)())success failure:(void(^)())failure;

@end

@interface LoginResponse : BaseResponse
@property(nonatomic,strong)UserModel *data;
@end
