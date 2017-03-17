//
//  BaseAPIManager.m
//  AFNetworking的网络层方案设计
//
//  Created by 宇玄丶 on 2017/3/17.
//  Copyright © 2017年 北京116工作室. All rights reserved.
//

#import "BaseAPIRequest.h"
#import "BaseAPIProxy.h"
#import "LoginRequest.h"

@interface BaseAPIRequest ()
@property (nonatomic, copy, readwrite) NSString *errorMessage;
@property (nonatomic, copy, readwrite) NSString *successMessage;
@property (nonatomic, readwrite) APIManagerErrorType errorType;
@property (nonatomic, strong) NSMutableArray *requestIdList;
@property (nonatomic, strong)UIView *hudSuperView;
@property (nonatomic, assign)NSInteger reloginCount;
@end

@implementation BaseAPIRequest

-(instancetype)initWithDelegate:(id)delegate paramSource:(id)paramSource
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _paramSource = paramSource;
        _validator = (id)self;
        _errorType = APIManagerErrorTypeDefault;
        
        if ([self conformsToProtocol:@protocol(APIManager)]) {
            self.child = (id <APIManager>)self;
        }
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegate = nil;
        _paramSource = nil;
        _validator = (id)self;
        _errorType = APIManagerErrorTypeDefault;
        
        if ([self conformsToProtocol:@protocol(APIManager)]) {
            self.child = (id <APIManager>)self;
        }
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - calling api
-(NSInteger)loadDataWithHUDOnView:(UIView *)view
{
    return [self loadDataWithHUDOnView:view HUDMsg:@""];
}

-(NSInteger)loadDataWithHUDOnView:(UIView *)view HUDMsg:(NSString *)HUDMsg
{
    [self cancelAllRequests];
    if (view) {
        self.hudSuperView = view;
//        [MBProgressHUD showLoadingHUD:HUDMsg onView:self.hudSuperView];
    }
    NSDictionary *params = [self.paramSource paramsForApi:self];
    if ([self.child respondsToSelector:@selector(reformParamsForApi:)]) {
        params = [self.child reformParamsForApi:params];
    }
//    params = [self signatureParams:params];
    NSInteger requestId = [self loadDataWithParams:params];
    return requestId;
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params
{
    NSInteger requestId = 0;
    if ([self isReachable]) {
        if ([self.child respondsToSelector:@selector(requestSerializer)]) {
            [BaseAPIProxy sharedInstance].requestSerializer = self.child.requestSerializer;
        } else {
            [BaseAPIProxy sharedInstance].requestSerializer = [AFHTTPRequestSerializer serializer]; // 拼接，如果是JSON换成AFJSON
        }
        if ([self.child respondsToSelector:@selector(responseSerializer)]) {
            [BaseAPIProxy sharedInstance].responseSerializer = self.child.responseSerializer;
        } else {
            [BaseAPIProxy sharedInstance].responseSerializer = [AFJSONResponseSerializer serializer];
        }
        [[BaseAPIProxy sharedInstance] callAPIWithRequestType:self.child.requestType params:params requestPath:self.child.requestPath uploadBlock:[self.paramSource respondsToSelector:@selector(uploadBlock:)]?[self.paramSource uploadBlock:self]:nil success:^(BaseAPIResponse *response) {
            [self successedOnCallingAPI:response];
        } fail:^(BaseAPIResponse *response) {
            [self failedOnCallingAPI:response withErrorType:response.errorType];
        }];
        [self.requestIdList addObject:@(requestId)];
        return requestId;
        
    } else {
        [self failedOnCallingAPI:nil withErrorType:APIManagerErrorTypeNoNetWork];
        return requestId;
    }
    return requestId;
}

- (void)successedOnCallingAPI:(BaseAPIResponse *)response
{
    if (self.hudSuperView) {
//        [MBProgressHUD hideLoadingHUD];
    }
    [self removeRequestIdWithRequestID:response.requestId];
    
    DLog(@"%@:%@", [self.child requestPath],response.responseData);
    
    if ([self.child respondsToSelector:@selector(responseClass)]) {
        self.responseData =  [[self.child responseClass] yy_modelWithDictionary:response.responseData];
        if (self.responseData.errcode!=10000) {
            response.msg = self.responseData.msg;
            [self failedOnCallingAPI:response withErrorType:APIManagerErrorTypeDefault];
            return;
        }
    } else {
        self.responseData = response.responseData;
    }
    
    if ([self.validator respondsToSelector:@selector(manager:isCorrectWithCallBackData:)] && ![self.validator manager:self isCorrectWithCallBackData:self.responseData]) {
        [self failedOnCallingAPI:response withErrorType:APIManagerErrorTypeNoContent];
    } else {
        if ([self.child respondsToSelector:@selector(reformData)]) {
            [self.child reformData];
        }
        [self.delegate managerCallAPIDidSuccess:self];
    }
}

- (void)failedOnCallingAPI:(BaseAPIResponse *)response withErrorType:(APIManagerErrorType)errorType
{
    if (self.hudSuperView) {
        [MBProgressHUD hideLoadingHUD];
    }
    
    self.errorType = errorType;
    self.msg = response.msg;
    [self removeRequestIdWithRequestID:response.requestId];
    switch (errorType) {
        case APIManagerErrorTypeDefault:
            self.errorMessage = response.msg;
            break;
        case APIManagerErrorTypeSuccess:
            break;
        case APIManagerErrorTypeNoContent:
            break;
        case APIManagerErrorTypeParamsError:
            break;
        case APIManagerErrorTypeTimeout:
            self.msg = Tip_RequestOutTime;
            break;
        case APIManagerErrorTypeNoNetWork:
            self.msg = Tip_NoNetwork;
            break;
        case APIManagerErrorLoginTimeout:
            self.msg = Tip_LoginTimeOut;
            break;
        default:
            break;
    }
    if (self.errorType==APIManagerErrorLoginTimeout) {
        if (!self.reloginCount && ![self isKindOfClass:[LoginRequest class]]) {
            self.reloginCount++;
            [LoginRequest autoReloginSuccess:^{
                [self loadDataWithHUDOnView:self.hudSuperView];
            } failure:^{
                [UserManager removeLocalUserLoginInfo];
                [kAppDelegate loadLoginVC];
            }];
        } else {
            [UserManager removeLocalUserLoginInfo];
            [kAppDelegate loadLoginVC];
        }
    } else {
        [self.delegate managerCallAPIDidFailed:self];
        if (self.hudSuperView && !self.disableErrorTip) {
            [MBProgressHUD showMsgHUD:response.msg];
        }
    }
    
    if (self.responseData.errcode==11010) {
        [LoginRequest autoReloginSuccess:^{
            [self loadDataWithHUDOnView:self.hudSuperView];
        } failure:^{
            [UserManager removeLocalUserLoginInfo];
            [kAppDelegate loadLoginVC];
        }];
    }
}

#pragma mark - private methods
- (void)cancelAllRequests
{
    [[BaseAPIProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[BaseAPIProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}


#pragma mark - getters and setters
- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

- (NSMutableArray *)requestIdList
{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}

@end
