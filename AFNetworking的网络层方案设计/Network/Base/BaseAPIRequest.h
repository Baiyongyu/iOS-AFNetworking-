//
//  BaseAPIManager.h
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseAPIProxy.h"

@class BaseAPIRequest;
/*---------------------API回调-----------------------*/
@protocol APIManagerApiCallBackDelegate <NSObject>
@required
- (void)managerCallAPIDidSuccess:(BaseAPIRequest *)request;
- (void)managerCallAPIDidFailed:(BaseAPIRequest *)request;
@end

/*---------------------API参数-----------------------*/
@protocol APIManagerParamSourceDelegate <NSObject>
@required
- (NSDictionary *)paramsForApi:(BaseAPIRequest *)request;
@optional
- (void (^)(id <AFMultipartFormData> formData))uploadBlock:(BaseAPIRequest *)request;
@end

/*---------------------API验证器-----------------------*/
@protocol APIManagerValidator <NSObject>
@required
- (BOOL)manager:(BaseAPIRequest *)request isCorrectWithCallBackData:(BaseResponse *)data;
@end

/*---------------------APIManager-----------------------*/

@protocol APIManager <NSObject>
@optional
- (Class)responseClass;
- (AFHTTPRequestSerializer <AFURLRequestSerialization> *)requestSerializer;
- (AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializer;
- (NSDictionary *)reformParamsForApi:(NSDictionary *)params;
- (void)reformData;
@required
- (NSString *)requestPath;
- (APIManagerRequestType)requestType;

@end

@interface BaseAPIRequest : NSObject
@property (nonatomic, weak) id<APIManagerApiCallBackDelegate> delegate;
@property (nonatomic, weak) id<APIManagerParamSourceDelegate> paramSource;
@property (nonatomic, weak) id<APIManagerValidator> validator;
@property (nonatomic, weak) id<APIManager> child;
@property (nonatomic, assign, readonly) BOOL isReachable;
@property (nonatomic, strong) BaseResponse *responseData;
@property (nonatomic, assign, readonly)APIManagerErrorType errorType;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) BOOL disableErrorTip;
-(instancetype)initWithDelegate:(id)delegate paramSource:(id)paramSource;
- (NSInteger)loadDataWithHUDOnView:(UIView *)view;
- (NSInteger)loadDataWithHUDOnView:(UIView *)view HUDMsg:(NSString *)HUDMsg;
- (void)cancelAllRequests;
- (void)cancelRequestWithRequestId:(NSInteger)requestID;
@end
