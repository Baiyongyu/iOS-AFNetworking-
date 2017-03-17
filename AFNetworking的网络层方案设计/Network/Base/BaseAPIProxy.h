//
//  APIProxy.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseAPIResponse.h"

typedef NS_ENUM (NSUInteger, APIManagerRequestType){
    APIManagerRequestTypeGet,
    APIManagerRequestTypePost,
    APIManagerRequestTypeUpload,
    APIManagerRequestTypeDelete,
    APIManagerRequestTypePut
};

typedef void(^APICallback)(BaseAPIResponse *response);

@interface BaseAPIProxy : NSObject

@property (nonatomic, strong) AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;

+ (instancetype)sharedInstance;

- (NSInteger)callAPIWithRequestType:(APIManagerRequestType)requestType params:(NSDictionary *)params requestPath:(NSString *)requestPath uploadBlock:(void (^)(id <AFMultipartFormData> formData))uploadBlock success:(APICallback)success fail:(APICallback)fail;

- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
