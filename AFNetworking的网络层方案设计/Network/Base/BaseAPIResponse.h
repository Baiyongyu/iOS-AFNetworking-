//
//  BaseAPIResponse.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, APIManagerErrorType){
    APIManagerErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    APIManagerErrorTypeSuccess,       //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    APIManagerErrorTypeNoContent,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    APIManagerErrorTypeParamsError,   //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    APIManagerErrorTypeTimeout,       //请求超时。ApiProxy设置的是20秒超时，具体超时时间的设置请自己去看ApiProxy的相关代码。
    APIManagerErrorTypeNoNetWork,     //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    APIManagerErrorLoginTimeout,       //登录超时
};

@interface BaseAPIResponse : NSObject

@property (nonatomic, assign, readonly)NSInteger requestId;
@property (nonatomic, copy)NSString *msg;
@property (nonatomic, assign, readonly)APIManagerErrorType errorType;
@property (nonatomic, assign, readonly)NSInteger httpStatusCode;
@property (nonatomic, assign, readonly)id responseData;

- (instancetype)initWithRequestId:(NSNumber *)requestId responseObject:(id)responseObject urlResponse:(NSHTTPURLResponse *)urlResponse;
- (instancetype)initWithRequestId:(NSNumber *)requestId urlResponse:(NSHTTPURLResponse *)urlResponse error:(NSError *)error;

@end

/* 根据服务器返回数据结构设计基本数据，如状态码、提示信息等*/
@interface BaseResponse : NSObject
@property(nonatomic, assign) NSInteger errcode;
@property(nonatomic, copy) NSString *msg;
@end

@interface PageModel : NSObject
@property(nonatomic,copy)NSArray *list;
@property(nonatomic,copy)NSNumber *totalPage;
@property(nonatomic,copy)NSNumber *totalRow;
@property(nonatomic,copy)NSNumber *total_count;
@end
