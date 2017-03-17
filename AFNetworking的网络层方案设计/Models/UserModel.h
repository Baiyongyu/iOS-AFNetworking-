//
//  UserModel.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

//手机号
@property(nonatomic,copy)NSString *username;
//密码
@property(nonatomic,copy)NSString *password;
//id
@property(nonatomic,copy)NSString *user_id;
//头像
@property(nonatomic,copy)NSString *avatar;
//注册时间
@property(nonatomic,copy)NSString *create_time;
//昵称
@property(nonatomic,copy)NSString *nickname;


@end



