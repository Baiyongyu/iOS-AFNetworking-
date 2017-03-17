//
//  UserModel.m
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

- (instancetype)init {
    if (self = [super init]) {
        _username = @"";
        _password = @"";
        
        _user_id = @"";
        _avatar = @"";
        _create_time = @"";
        _nickname = @"";

    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"user_id":@"id"};
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self yy_modelInitWithCoder:aDecoder];
    }
    return self;
}

@end


