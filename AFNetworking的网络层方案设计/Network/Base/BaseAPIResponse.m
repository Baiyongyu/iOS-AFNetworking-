//
//  BaseAPIResponse.m
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import "BaseAPIResponse.h"

@interface BaseAPIResponse ()
@property (nonatomic, assign, readwrite)NSInteger httpStatusCode;
@property (nonatomic, assign, readwrite)APIManagerErrorType errorType;
@property (nonatomic, assign, readwrite)id responseData;
@end

@implementation BaseAPIResponse

- (instancetype)initWithRequestId:(NSNumber *)requestId responseObject:(id)responseObject urlResponse:(NSHTTPURLResponse *)urlResponse
{
    self = [super init];
    if (self) {
        self.httpStatusCode = urlResponse.statusCode;
        self.responseData = responseObject;
    }
    return self;
}

- (instancetype)initWithRequestId:(NSNumber *)requestId urlResponse:(NSHTTPURLResponse *)urlResponse error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.httpStatusCode = urlResponse.statusCode;
        self.msg = [self handelError:error];
        DLog(@"%ld",self.httpStatusCode);
        if (self.httpStatusCode==11010) {
            self.errorType = APIManagerErrorLoginTimeout;
        }
    }
    return self;
}

- (NSString *)handelError:(NSError*)error {
    NSString *errorMsg = Tip_RequestError;
    if (error) {
        NSData *responseData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        if (responseData) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
            if ([response isKindOfClass:[NSDictionary class]]) {
                errorMsg = safeString(response[@"msg"]);
                return errorMsg;
            }
        }
        if (safeNumber(error.userInfo[@"_kCFStreamErrorCodeKey"]).integerValue==-2102) {
            errorMsg = Tip_RequestOutTime;
        }
    }
    return errorMsg;
}

@end

@implementation BaseResponse


@end

@implementation PageModel
- (id)copyWithZone:(NSZone *)zone
{
    return [self yy_modelCopy];
}
@end
