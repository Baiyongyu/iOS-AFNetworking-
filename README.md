# iOS-AFNetworking-
iOS-AFNetworking网络层封装设计方案

###前言  
>网络层在项目开发中是不可缺少的一部分，网络层在一个App中承载了API调用，用户操作日志记录等任务。虽然苹果对网络请求部分已经做了很好的封装，但业界内最受欢迎的还是第三方库AFNetworking，很多工程师针对自己的项目对此做了各式各样的封装，我看了很多，每次接手项目的时候最关注的也是这一块。看到各位架构师各显神通展示了各种技巧，我为之感到兴奋，但兴奋之余，往往因为一些缺陷而感到失望。下面给大家介绍一下我目前使用的框架。

在介绍之前，在此说明：本人技术有限，大家各持所需，哪怕有一个人看了之后有一点点收获，说明我做的事情就是有意义的，当然，哪里不好，有说错的地方，期望各位大神留言指正。

###一、封装的类
![封装的类](http://upload-images.jianshu.io/upload_images/2381595-928c380ef51fdd05.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

先说说BaseAPIRequest这个类：
BaseAPIRequest.h
```
#import <Foundation/Foundation.h>
#import "BaseAPIProxy.h"

/** 首先是定义的四个协议 */
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

/**  以上两个协议部分，正如注释所示：三个代理方法，是每个界面必须要遵守写出来的。
      (1)需要上传的参数;
      (2)请求成功、失败之后的回调处理。
   （除非这个界面是分页请求，只需要写一个API参数的协议，这个后面再说。）
*/

/**
 在次插一点说明：
 在iOS中有很多对象间数据的传递方式，大多数App在网络层所采用的方案主要集中于这三种：Delegate，Notification，Block。
 在这里，我主要以Delegate为主，Notification为辅。原因如下：
      (1)尽可能减少跨层数据交流的可能，限制耦合
   "跨层数据交流:【就是某一层（或模块）跟另外的与之没有直接对接关系的层（或模块）产生了数据交换。】"
      (2)统一回调方法，便于调试和维护
      (3)在跟业务层对接的部分只采用一种对接手段（delegate）限制灵活性，以此来交换应用的可维护性
 */
```

```
/*---------------------API验证器-----------------------*/
@protocol APIManagerValidator <NSObject>
@required
// 内部已经实现，无需再处理
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

/** 又来required，因为此设计为网络层的抽离，
就是说把所有请求都抽离出来，
在Controller里面只有上传的参数以及成功、失败回到的三个协议方法，
这样一来，大大缩小了控制器里面的代码，
处理业务逻辑变得更加清晰，维护起来也更加方便。
 */
/** 请求的url */
- (NSString *)requestPath;
/** 请求类型，（GET、POST...）*/
- (APIManagerRequestType)requestType;

@end

```

BaseAPIRequest类的声明
```
@interface BaseAPIRequest : NSObject
@property (nonatomic, weak) id<APIManagerApiCallBackDelegate> delegate;
@property (nonatomic, weak) id<APIManagerParamSourceDelegate> paramSource;
@property (nonatomic, weak) id<APIManagerValidator> validator;
@property (nonatomic, weak) id<APIManager> child;

/**  不做解释，看名称自己理解即可。*/
@property (nonatomic, assign, readonly) BOOL isReachable;
@property (nonatomic, strong) BaseResponse *responseData;
@property (nonatomic, assign, readonly)APIManagerErrorType errorType;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, assign) BOOL disableErrorTip;

- (instancetype)initWithDelegate:(id)delegate paramSource:(id)paramSource;

/** 此处定义就是每次发起请求需要调用的方法 */
- (NSInteger)loadDataWithHUDOnView:(UIView *)view;
- (NSInteger)loadDataWithHUDOnView:(UIView *)view HUDMsg:(NSString *)HUDMsg;

/** 取消所有请求，根据项目需要使用*/
- (void)cancelAllRequests;
- (void)cancelRequestWithRequestId:(NSInteger)requestID;
@end
```

BaseAPIRequest.m
```
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

/** 此处就是发起请求的调用方法，后文会举例说明 */
#pragma mark - calling api
- (NSInteger)loadDataWithHUDOnView:(UIView *)view {
    return [self loadDataWithHUDOnView:view HUDMsg:@""];
}

- (NSInteger)loadDataWithHUDOnView:(UIView *)view HUDMsg:(NSString *)HUDMsg {
    [self cancelAllRequests];
    if (view) {
        self.hudSuperView = view;
        [MBProgressHUD showLoadingHUD:HUDMsg onView:self.hudSuperView];
    }
    NSDictionary *params = [self.paramSource paramsForApi:self];
    if ([self.child respondsToSelector:@selector(reformParamsForApi:)]) {
        params = [self.child reformParamsForApi:params];
    }
    /**  
        由于考虑接口的安全性，此处为对参数加密处理，
        有则根据需求自行处理，如果接口没有特殊要求忽略即可。
    */
//    params = [self signatureParams:params];
    NSInteger requestId = [self loadDataWithParams:params];
    return requestId;
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params {
    NSInteger requestId = 0;
    if ([self isReachable]) {
        if ([self.child respondsToSelector:@selector(requestSerializer)]) {
            [BaseAPIProxy sharedInstance].requestSerializer = self.child.requestSerializer;
        } else {

/** 关于此处：
    AFJSONRequestSerializer：接口已JSON的格式上传;
    AFHTTPRequestSerializer: 正常的参数拼接：“name/yuxuan (各种斜杠拼接的)
    根据自己需求，自行切换模式”
 */
            [BaseAPIProxy sharedInstance].requestSerializer = [AFJSONRequestSerializer serializer]; 
        }
        if ([self.child respondsToSelector:@selector(responseSerializer)]) {
            [BaseAPIProxy sharedInstance].responseSerializer = self.child.responseSerializer;
        } else {
            [BaseAPIProxy sharedInstance].responseSerializer = [AFJSONResponseSerializer serializer];
        }
/** 
    此处就是load请求之后，调用BaseAPIProxy这个类，可以理解为对AF的封装(其中可以看到几个参数：
    * requestType：请求方式：GET、POST...
    * requestPath：url
  （看明白的同学应该想到，前面.h中有两个需要遵守的协议：)
      /** 请求的url */
      - (NSString *)requestPath;
      /** 请求类型，（GET、POST...）*/
      - (APIManagerRequestType)requestType;
   就是将参数拼接到请求当中。
*/
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
```
请求成功、失败
```
- (void)successedOnCallingAPI:(BaseAPIResponse *)response {
    if (self.hudSuperView) {
        [MBProgressHUD hideLoadingHUD];
    }
    [self removeRequestIdWithRequestID:response.requestId];
    
    DLog(@"%@:%@", [self.child requestPath],response.responseData);
    
    if ([self.child respondsToSelector:@selector(responseClass)]) {
        self.responseData =  [[self.child responseClass] yy_modelWithDictionary:response.responseData];
    /**  
        200:请求成功之后的状态码，
        如果是10000就改成10000，根据自己的接口返回自行处理
    */
        if (self.responseData.errcode!=200) {
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

- (void)failedOnCallingAPI:(BaseAPIResponse *)response withErrorType:(APIManagerErrorType)errorType {
    if (self.hudSuperView) {
        [MBProgressHUD hideLoadingHUD];
    }
    
    self.errorType = errorType;
    self.msg = response.msg;
    [self removeRequestIdWithRequestID:response.requestId];
    switch (errorType) {
    /** 
        此处就是请求失败返回的 各种状态，根据需求，自行修改处理
     */
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
}
```
PS:以上就是发起请求之后的处理的步骤，细心的同学应该注意到了，这里成功、失败提到的是" BaseAPIResponse"这个类，所谓Response就是响应的意思，只有发起请求request之后，通过服务器响应response，才能判断请求是成功还是失败，所以响应单独抽个类处理。

```
#pragma mark - private methods
- (void)cancelAllRequests {
    [[BaseAPIProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestID {
    [self removeRequestIdWithRequestID:requestID];
    [[BaseAPIProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (void)removeRequestIdWithRequestID:(NSInteger)requestId {
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
    /**
        参数的签名加密，上面提到过，
        根据自己的项目需求做处理，如果接口无特殊要求，
        请绕道自动忽略。
     */
- (NSDictionary *)signatureParams:(NSDictionary *)params {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    /** 处理签名方法 */
    、、、
    return newParams;
}

#pragma mark - getters and setters
- (BOOL)isReachable {
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

- (NSMutableArray *)requestIdList {
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}
@end
```


下面说一下响应的处理，根据定义的变量名称，想必大家一目了然，就是失败的几种情况，状态码之类的。
BaseAPIResponse.h

```
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

    /** 
      这里是针对分页请求做的处理，
      前文提到，次方案分页请求是单独抽出来一个类来做处理的，
      并且发起请求的时候，只需要遵守BaseAPIRequest中三个必须实现的
      三个(上传的参数、请求成功、失败的回调)协议中的
      一个(上传的参数)即可，因为，内部已做处理。
 */
@interface PageModel : NSObject
@property(nonatomic,copy)NSArray *list;
@property(nonatomic,copy)NSNumber *totalPage;
@property(nonatomic,copy)NSNumber *totalRow;
@property(nonatomic,copy)NSNumber *total_count;
@end
```

```
#import "BaseAPIResponse.h"

@interface BaseAPIResponse ()
@property (nonatomic, assign, readwrite)NSInteger httpStatusCode;
@property (nonatomic, assign, readwrite)APIManagerErrorType errorType;
@property (nonatomic, assign, readwrite)id responseData;
@end

@implementation BaseAPIResponse

- (instancetype)initWithRequestId:(NSNumber *)requestId responseObject:(id)responseObject urlResponse:(NSHTTPURLResponse *)urlResponse {
    self = [super init];
    if (self) {
        self.httpStatusCode = urlResponse.statusCode;
        self.responseData = responseObject;
    }
    return self;
}

- (instancetype)initWithRequestId:(NSNumber *)requestId urlResponse:(NSHTTPURLResponse *)urlResponse error:(NSError *)error {
    self = [super init];
    if (self) {
        self.httpStatusCode = urlResponse.statusCode;
        self.msg = [self handelError:error];
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

 /**
      因为解析用的是YYModel来处理的，个人推荐，可以看看，简单实用，很多都会帮你处理好，免去了解析的痛苦。
*/
@implementation PageModel
- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}
@end
```

到这里，两个主要的类已经说完了，我们很快就要成功了，大家 加油！下面说说BaseAPIProxy这个类：
```
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
/**  来个单例*/
+ (instancetype)sharedInstance;
```
```
/** 
    这里就是在文章开始说的那个BaseAPIRequest类中提到，
    发起请求之后，调用这个类，忘了的同学请上翻。⬆️
    上文中也提到此处可以理解为对AF的封装，
    每次都写请求多麻烦啊，对吧？并且是GET还是POST的啊(所以，上面列举了一堆枚举。)？
    这里都做了判断，没有说的东西。
*/
- (NSInteger)callAPIWithRequestType:(APIManagerRequestType)requestType params:(NSDictionary *)params requestPath:(NSString *)requestPath uploadBlock:(void (^)(id <AFMultipartFormData> formData))uploadBlock success:(APICallback)success fail:(APICallback)fail;

- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
```

BaseAPIProxy.m
```
#import "BaseAPIProxy.h"

#define kCookie @"Cookie"

@interface BaseAPIProxy ()
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end

@implementation BaseAPIProxy

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BaseAPIProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BaseAPIProxy alloc] init];
    });
    return sharedInstance;
}

- (NSInteger)callAPIWithRequestType:(APIManagerRequestType)requestType params:(NSDictionary *)params requestPath:(NSString *)requestPath uploadBlock:(void (^)(id <AFMultipartFormData> formData))uploadBlock success:(APICallback)success fail:(APICallback)fail {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",BaseUrl,requestPath];
    NSNumber *requestId = [self callApi:urlString requestType:requestType params:params uploadBlock:uploadBlock success:success fail:fail];
    return [requestId integerValue];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID {
    NSURLSessionDataTask *dataTask = self.dispatchTable[requestID];
    [dataTask cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList {
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}

- (NSNumber *)callApi:(NSString *)URLString requestType:(APIManagerRequestType)requestType params:(NSDictionary *)params uploadBlock:(void (^)(id <AFMultipartFormData> formData))uploadBlock success:(APICallback)success fail:(APICallback)fail {
    // 之所以不用getter，是因为如果放到getter里面的话，每次调用self.recordedRequestId的时候值就都变了，违背了getter的初衷
    NSNumber *requestId = [self generateRequestId];
    
    self.sessionManager.requestSerializer = self.requestSerializer;
    self.sessionManager.requestSerializer.timeoutInterval = 10;
    self.sessionManager.responseSerializer = self.responseSerializer;
    [self setCookie];
    // 跑到这里的block的时候，就已经是主线程了。
    NSURLSessionDataTask *dataTask;
    switch (requestType)
    {
        case APIManagerRequestTypeGet:
        {
            dataTask = [self.sessionManager GET:URLString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handelSuccessRequst:requestId task:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handelFailRequest:requestId task:task error:error fail:fail];
            }];
        }
            break;
        case APIManagerRequestTypePost:
        {
            dataTask = [self.sessionManager POST:URLString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handelSuccessRequst:requestId task:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handelFailRequest:requestId task:task error:error fail:fail];
            }];
        }
            break;
        case APIManagerRequestTypeUpload:
        {
            self.sessionManager.requestSerializer.timeoutInterval = 20;
            dataTask = [self.sessionManager POST:URLString parameters:params constructingBodyWithBlock:uploadBlock progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handelSuccessRequst:requestId task:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handelFailRequest:requestId task:task error:error fail:fail];
            }];
        }
            break;
        case APIManagerRequestTypeDelete:
        {
            dataTask = [self.sessionManager DELETE:URLString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handelSuccessRequst:requestId task:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handelFailRequest:requestId task:task error:error fail:fail];
            }];
        }
            break;
        case APIManagerRequestTypePut:
        {
            dataTask = [self.sessionManager PUT:URLString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self handelSuccessRequst:requestId task:task responseObject:responseObject success:success];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handelFailRequest:requestId task:task error:error fail:fail];
            }];
        }
            break;
        default:
            break;
    }
    
    self.dispatchTable[requestId] = dataTask;
    return requestId;
}

- (void)handelSuccessRequst:(NSNumber *)requestId task:(NSURLSessionDataTask *)task responseObject:(id)responseObject success:(APICallback)success {
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    //存储归档后的cookie
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cookiesData forKey:kCookie];
    [self setCookie];
    
    NSURLSessionDataTask *storedTask = self.dispatchTable[requestId];
    if (storedTask == nil) {
        // 如果这个task是被cancel的，那就不用处理回调了。
        return;
    } else {
        [self.dispatchTable removeObjectForKey:requestId];
    }
    
    BaseAPIResponse *response = [[BaseAPIResponse alloc] initWithRequestId:requestId responseObject:responseObject urlResponse:(NSHTTPURLResponse *)task.response];
    
    success?success(response):nil;
}

- (void)handelFailRequest:(NSNumber *)requestId task:(NSURLSessionDataTask *)task error:(NSError *)error fail:(APICallback)fail {
    NSURLSessionDataTask *storedTask = self.dispatchTable[requestId];
    if (storedTask == nil) {
        // 如果这个task是被cancel的，那就不用处理回调了。
        return;
    } else {
        [self.dispatchTable removeObjectForKey:requestId];
    }
    
    BaseAPIResponse *response = [[BaseAPIResponse alloc] initWithRequestId:requestId urlResponse:(NSHTTPURLResponse *)task.response error:error];
    
    fail?fail(response):nil;
}

```
并且对于请求成功之后也做了cookies处理
```
- (NSNumber *)generateRequestId {
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

- (void)setCookie {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:kCookie]) {
        return;
    }
    //对取出的cookie进行反归档处理
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[userDefaults objectForKey:kCookie]];
    
    if (cookies) {
        //设置cookie
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (id cookie in cookies) {
            [cookieStorage setCookie:(NSHTTPCookie *)cookie];
        }
    }
}

#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable {
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager == nil) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
    }
    return _sessionManager;
}

- (NSString *)cookie {
    return safeString([[NSUserDefaults standardUserDefaults] valueForKey:kCookie]);
}
@end
```
PS：以上除了分页请求就都介绍完了，但是革命尚未成功，同志而需努力！还差个分页，大家 加油！
在此，我就不做过多的解释了，注释很清楚。
```
#import "BaseAPIRequest.h"

@protocol PageDelegate <NSObject>
@required
- (NSArray *)buildPageArray;
@end

@interface PageAPIRequest : BaseAPIRequest <APIManager>

/**
 *  当前页数
 */
@property (nonatomic, assign) NSUInteger                currentPage;
/**
 *  最终结果
 */
@property (nonatomic, strong) NSMutableArray*           listArray;
/**
 *  是否还有数据，只要有数据返回，就认为还有下一页
 */
@property (nonatomic, assign) BOOL                      moreData;

/**
 *  清空listArray，currentPage = 1
 */
- (void)reload;

/**
 *  清空listArray，currentPage = 1
 */
- (void)reloadOnView:(UIView *)view;

/**
 *  每页多少条数据，默认20
 */
- (NSUInteger)pageSize;

@end
```

```
#import "PageAPIRequest.h"

@implementation PageAPIRequest

- (id)init {
    self = [super init];
    if (self) {
        self.currentPage = 1;
    }
    return self;
}

- (id)initWithDelegate:(id)delegate paramSource:(id)paramSource {
    self = [super initWithDelegate:delegate paramSource:paramSource];
    if (self) {
        self.currentPage = 1;
    }
    return self;
}

- (NSUInteger)pageSize {
    return 10;
}

/** 这里呢，就是根据自己的接口来定义分页，看接口是那个字段，做修改即可。原理就是根据key会自取。*/
- (NSDictionary *)reformParamsForApi:(NSDictionary *)params {
    NSMutableDictionary *newParmas = params?[params mutableCopy]:[NSMutableDictionary dictionary];
    [newParmas setObject:[NSNumber numberWithInteger:self.currentPage] forKey:@"page"];
    [newParmas setObject:[NSNumber numberWithInteger:[self pageSize]] forKey:@"pageSize"];
    、、、
    [newParmas setObject:[NSNumber numberWithInteger:[self pageSize]*(self.currentPage-1)] forKey:@"page_start"];
    return newParmas;
}

- (void)reformData {
    if (_currentPage == 1) {
        [self.listArray removeAllObjects];
    }
    
    NSArray *array = nil;
    if ([self.responseData respondsToSelector:@selector(buildPageArray)]) {
        array = [self.responseData performSelector:@selector(buildPageArray)];
        
    } else if ([self.responseData isKindOfClass:[NSArray class]]) {
        array = (NSArray *)self.responseData;
    }
    self.moreData = NO;
    if ([array count] > 0) {
        self.moreData = [array count] >= [self pageSize] ? YES : NO;
        self.currentPage ++;
        [self.listArray addObjectsFromArray:array];
    }
}

- (void)reload {
    self.currentPage = 1;
    [self loadDataWithHUDOnView:nil];
}

- (void)reloadOnView:(UIView *)view {
    self.currentPage = 1;
    [self loadDataWithHUDOnView:view];
}

- (NSString *)requestPath {
    return [self.child requestPath];
}

- (APIManagerRequestType)requestType {
    return [self.child requestType];
}

- (NSMutableArray *)listArray {
    if (!_listArray) {
        _listArray = [NSMutableArray array];
    }
    return _listArray;
}
@end
```

PS：好了，大功告成，到这里，对于此方案的设计就全部讲解完毕，还记得如何使用吗？记住：每个界面只需要实现三个代理方法即可，当分页的时候，只需要一个即可。

##--- 下面举两个例子---
因为文章中提到，次方案的设计是网络层的抽离，所以，每个请求都需要单独抽一个类出来：

>如果有这样的一个接口：
{
  "errcode": 200,
  "msg": "操作成功",
  "data": [
    {
      "id": "1",
      "name": "1231",
      "price": "123",
      "img_url": "123"
    },
    {
      "id": "2",
      "name": "123",
      "price": "123",
      "img_url": "123"
    },
  ]
}

这是一个简单的商品列表，没有分页，当我们创建请求类的时候继承的是BaseAPIRequest这个类。

BaseAPIRequest.h
```
#import "BaseAPIRequest.h"
/**
  创建请求类的时候继承BaseAPIRequest这个类,
  并且遵守<APIManager>协议，为什么？因为我们要实现三个协议方法啊。
  千万不要忘了！！！
*/
/** 请求 */
@interface GoodsListRequest : BaseAPIRequest <APIManager>

@end

/** 响应*/

/**
    因为我们需要对请求成功之后，服务器返回的数据进行赋值，
    所以才需要创建响应方法，
    如果这个接口只是上传几个参数（比如修改密码，成功了就是成功了，不需要返回什么），
    那么我们无需再写Response的响应处理了，
    (说白了，就是就是下面的这个方法就不用写了。)
 */
@interface GoodsListResponse : BaseResponse
/** 
    为什么定义数组呢？因为服务器返回的就是数组啊，
    如果返回的是对象，那么此处就定义一个model呗。
*/
@property(nonatomic,strong)NSArray *data;
// @property(nonatomic,strong)UserModel *data;
@end
```
BaseAPIRequest.m
```
#import "GoodsListRequest.h"

@implementation GoodsListRequest
/** 
    此处就是请求的接口，我的处理方式是定义一个.h类，
    专门放接口的，好修改。

    //商品列表
    #define Goods_List_Url                  @"/mall/shopList" 

    这里为啥只有一小段接口，前面的都是一样的，已经封装在BaseAPIProxy类中，
    忘了的同学请上翻⤴️。
*/
- (NSString *)requestPath {
    return Goods_List_Url;
}
/** 你是什么请求方式，get、post..,根据接口，自行修改。*/
- (APIManagerRequestType)requestType {
    return APIManagerRequestTypePost;
}
/** 
    请求成功的响应类，
    因为需要对请求成功之后的数据做处理，所有才会有这个类，
    名字对应好即可。
    在.h中，我有做了说明，
    如果这个接口只是上传几个参数，
    那么我们无需再写Response的响应处理了，
    将响应的类改为BaseResponse即可。
*/
- (Class)responseClass {
    return [GoodsListResponse class];
}
@end

@implementation GoodsListResponse

/** 这里我用的是YYModel解析，这是YYModel的方法，*/

YYModel使用起来还是很简单的，免去了很多解析的时间，
想必大部分人都知道，要么就是MJExtension，使用方法差不多类似。看看就会用了。

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : [GoodsModel class]};
}
@end
```
PS：好了，到这里，一个接口的请求就写完了，那么在Controller里面如何实现？直接上代码：

1、首页你得把这个方法初始化吧，要不鬼知道你这是哪里来的逗比请求。
```
 // 1>导入头文件 ,定义请求方法
@property(nonatomic,strong)GoodsListRequest *goodsListRequest;
 // 2>初始化
- (GoodsListRequest *)goodsListRequest {
    if (!_goodsListRequest) {
/** 
    注意：这里并不是简单的init初始化，你是需要遵守三个协议方法的，所以这里有两个self,因为文章开头我就讲了，忘了的同学请上翻⬆️*/
        _goodsListRequest = [[GoodsListRequest alloc] initWithDelegate:self paramSource:self];
    }
    return _goodsListRequest;
}
```
2、发起请求
```
/**  
      这里self.contentView就是加载的小菊花显示在哪个视图上，
      因为我这里最底层的视图是自定义的contentView，根据需求、用户体验，可自行修改视图。
    */
[self.goodsListRequest loadDataWithHUDOnView:self.contentView];
```
3、遵守三个协议，忘了的同学请继续上翻⬆️，我已经说明好几次了，应该都能记住了，不管如何实现能否掌握了解，但只要写好请求，实现三个协议方法，基本就能成功了。

```
#pragma mark - APIManagerParamSourceDelegate
- (NSDictionary *)paramsForApi:(BaseAPIRequest *)request {
/** 如果请求的接口需要传参，那么在此return。 */
    if (request == self.addCartRequest) {
        return @{@"goods_id":self.operatingGoods.goods_id,
                 @"number":@"1"};
    }
/** 文章中已经提到，如果该请求接口没有参数，直接返回nil即可。 */
    return nil;
}
```
```
/** 请求之后的，成功、失败的回调。 */
#pragma mark - APIManagerApiCallBackDelegate
- (void)managerCallAPIDidSuccess:(BaseAPIRequest *)request {
    if (request == self.goodsListRequest) {
/** 
    此处就是赋值操作，将请求下来的数据源，
    赋值给tableView的数据源，然后刷新表格即可。
 */
        self.shopTableView.dataArray = [[request.responseData valueForKey:@"data"] mutableCopy];

/**
    注意request.responseData接收的数据格式，因为此接口返回的是数组，所以这么写。
    如果返回的是对象，很简单：

/**  随便举个例子*/
    * self.userData：模型model 
              （将返回的对象中的数据赋值给model，然后取model中的各个字段，赋值即可。
                当然有表格的界面，在请求成功之后记得刷新表格。）

    * data : 此处的data为定义的model。
          文章中那个商品列表的请求提到，如果返回的是数组就定义数组，
          如果是对象就定义model。
      self.userData = [request.responseData valueForKey:@"data"];
*/
        [self.shopTableView reloadData];
        return;
    }
/** 此处对应请求的API接口，成功之后的回调*/
    if (request == self.addCartRequest) {
        [MBProgressHUD showMsgHUD:@"加入购物车成功"];
        return;
    }
}
/** 失败，可以不写什么，因为返回的是return，根据需求自行处理吧。 */
- (void)managerCallAPIDidFailed:(BaseAPIRequest *)request {
}
```

以上就是普通的接口请求，如果此接口为分页请求，文章中已经提到，只需要遵守一个参数的协议(APIManagerParamSourceDelegate)即可,这里就不在累赘了。


PS：写了一下午，终于是搞完了，到这里，所有功能已全部讲完，喜欢的小伙伴记得给个star，有错误的地方，请大神指正。个人认为此框架使用起来还是超级简单的，免去了Controler里面大量的代码，留给更多的空间来处理逻辑。也希望小小的一篇文章能帮助更多的人，一起努力，未来、我们都会是全栈工程师。大家加油！
