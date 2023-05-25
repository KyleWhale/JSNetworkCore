//
//  JSNetworkingBaseManager.m
//  JSNetworking
//
//  Created by yky on 2017/9/26.
//

#import "JSNetworkingBaseManager.h"
#import <AFNetworking/AFNetworking.h>
#import "XZProgressHUD.h"
#import "JSRequest.h"
#import "JSApiProxy.h"
#import "JSCache.h"
#import "YYModel.h"

#define JSKeyWindow  [UIApplication sharedApplication].keyWindow

@interface JSNetworkingBaseManager ()

@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, readwrite) JSNetworkingStatusType networkStatus;
/**
 key为对应的请求参数hardcode , value为task的标识
 */
@property (nonatomic, strong) NSMutableDictionary * requestIdList;
@property (nonatomic, strong) JSCache *cache;

@end

@implementation JSNetworkingBaseManager

- (void)dealloc
{
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        _callBackDelegate = nil;
        _paramSource = nil;
        _paramValidator = nil;
        _networkStatus = JSNetworkingStatusTypeDefault;
        if ([self conformsToProtocol:@protocol(JSApiDetailDelegate)]) {
            self.apiDetail = (id <JSApiDetailDelegate>)self;
        } else {
            self.apiDetail = (id <JSApiDetailDelegate>)self;
            NSException *exception = [[NSException alloc] initWithName:@"JSNetworkingBaseManager提示" reason:[NSString stringWithFormat:@"%@没有遵循JSAPIDetailDelegate协议",self.apiDetail] userInfo:nil];
            @throw exception;
        }
    }
    return self;
}

#pragma mark - calling api
- (NSInteger)loadData
{
    id params = [self.paramSource requestParamsDelegate:self];
    NSInteger requestId = [self loadDataWithParams:params];
    return requestId;
}

- (NSInteger)loadDataWithParams:(id)apiParams
{
    NSInteger requestId = 0;
    if ([self shouldCallAPIWithParams:apiParams]) {
        if ([self.paramValidator manager:self parameter:apiParams]) {
            // 先检查一下是否有缓存
            if ([self.apiDetail shouldCache] && [self hasCacheWithParams:apiParams]) {
                if(!self.isSpecialCache){
                    return 0;
                }
            }else if(self.isSpecialCache){
                //如果无缓存，且是首页特殊缓存，则清除请求参数的时间戳
                NSMutableDictionary* newParams = [apiParams mutableCopy];
                [newParams setObject:@"0" forKey:@"update_time"];
                apiParams = newParams;
            }
            // 实际的网络请求
            if ([self isReachable]) {
                self.isLoading = YES;
                if([self.apiDetail shouldShowHUD]){
                    if([self.apiDetail respondsToSelector:@selector(shouldDisableUserInterface)]){
                        if([self.apiDetail shouldDisableUserInterface]){
                            [XZProgressHUD showWithMaskType];
                        }else{
                            [XZProgressHUD show];
                        }
                    }else{
                        [XZProgressHUD show];
                    }
                }
                //注册ssl
                if([JSNetworkingConfigurations sharedInstance].enableSSL){
                    [[JSAPIProxy sharedInstance] configSSL:[[JSNetworkingConfigurations sharedInstance].delegate getSSLName]];
                }
                switch (self.apiDetail.requestType)
                {
                    case JSNetworkingRequestTypeGet:
                        requestId = [self get:apiParams];
                        break;
                    case JSNetworkingRequestTypePost:
                        requestId = [self post:apiParams];
                        break;
                    case JSNetworkingRequestTypeUpload:
                        requestId = [self upload:apiParams];
                        break;
                    case JSNetworkingRequestTypeUploadFile:
                        requestId = [self uploadFile:apiParams];
                        break;
                    default:
                        break;
                }
                if(self.apiDetail.requestType != JSNetworkingRequestTypeUpload
                   && self.apiDetail.requestType !=JSNetworkingRequestTypeUploadFile){
                    NSMutableDictionary *params = [apiParams mutableCopy];
                    params[JSNetworkingRequestID] = @(requestId);
                    [self afterCallingAPIWithParams:params];
                }
                return requestId;
            } else {
                [self failedOnCallingAPI:nil withErrorType:JSNetworkingStatusTypeNoNetwork];
                return requestId;
            }
        } else {
            [self failedOnCallingAPI:nil withErrorType:JSNetworkingStatusTypeParamsError];
            return requestId;
        }
    }
    return requestId;
}

-(NSInteger)get:(NSDictionary*)params
{
    __weak typeof(self) weakSelf = self;
    if(self.custom){
        JSRequest* request = [JSRequest sharedInstance];
        NSURLRequest* urlRequest = [request.httpRequestSerializer requestWithMethod:@"GET" URLString:self.apiDetail.methodName parameters:params error:nil];
        NSNumber* requestID = [[JSAPIProxy sharedInstance] callApiWithRequest:urlRequest success:^(JSResponse *response) {
            [weakSelf successedOnCallingAPI:response];
        } fail:^(JSResponse *response) {
            [weakSelf successedOnCallingAPI:response];
        }];
        return [requestID integerValue];
    }else{
        NSInteger requestID = [[JSAPIProxy sharedInstance] callGETWithParams:params methodName:self.apiDetail.methodName version:self.apiDetail.APIVersion success:^(JSResponse *response) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf successedOnCallingAPI:response];
        } fail:^(JSResponse *response) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf failedOnCallingAPI:response withErrorType:JSNetworkingStatusTypeDefault];
        }];
        
        [self.requestIdList setObject:@(requestID) forKey:[JSCache keyWithMethodName:self.apiDetail.methodName requestParams:params]];
        return requestID;
    }
}

-(NSInteger)post:(NSDictionary*)params
{
    __weak typeof(self) weakSelf = self;
    if(self.custom){
        JSRequest* request = [JSRequest sharedInstance];
        NSURLRequest* urlRequest = [request.httpRequestSerializer requestWithMethod:@"POST" URLString:self.apiDetail.methodName parameters:params error:nil];
        NSNumber* requestID = [[JSAPIProxy sharedInstance] callApiWithRequest:urlRequest success:^(JSResponse *response) {
            [weakSelf successedOnCallingAPI:response];
        } fail:^(JSResponse *response) {
            [weakSelf successedOnCallingAPI:response];
        }];
        return [requestID integerValue];
    }else{
        NSInteger requestID = [[JSAPIProxy sharedInstance] callPOSTWithParams:params methodName:self.apiDetail.methodName version:self.apiDetail.APIVersion success:^(JSResponse *response) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf successedOnCallingAPI:response];
        } fail:^(JSResponse *response) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf failedOnCallingAPI:response withErrorType:JSNetworkingStatusTypeDefault];
        }];
        
        [self.requestIdList setObject:@(requestID) forKey:[JSCache keyWithMethodName:self.apiDetail.methodName requestParams:params]];
        
        return requestID;
    }
}

-(NSInteger)upload:(NSArray*)dataArray
{
    if(![dataArray isKindOfClass:[NSArray class]] &&  dataArray.count==0){
        NSLog(@"上传的内容不能为空");
        [self failedOnCallingAPI:nil withErrorType:JSNetworkingStatusTypeDefault];
        return 0;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSInteger i=0; i<dataArray.count; i++) {
            dispatch_semaphore_wait([JSNetworkingConfigurations sharedInstance].semap, DISPATCH_TIME_FOREVER);
            NSData* imageData = dataArray[i];
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.apiDetail shouldShowHUD]){
                    if([self.apiDetail respondsToSelector:@selector(shouldDisableUserInterface)]){
                        if([self.apiDetail shouldDisableUserInterface]){
                            [XZProgressHUD showWithMaskType];
                        }else{
                            [XZProgressHUD show];
                        }
                    }else{
                        [XZProgressHUD show];
                    }
                }
            });
            NSLog(@"开始上传图片");
            [[JSAPIProxy sharedInstance] callUploadWithData:imageData methodName:weakSelf.apiDetail.methodName version:weakSelf.apiDetail.APIVersion success:^(JSResponse *response) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                response.index = i;
                [strongSelf successedOnCallingAPI:response];
                NSLog(@"上传图片完成");
                dispatch_semaphore_signal([JSNetworkingConfigurations sharedInstance].semap);
            } progress:^(NSProgress *progress) {
                
            } fail:^(JSResponse *response) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                response.index = i;
                [strongSelf failedOnCallingAPI:response withErrorType:JSNetworkingStatusTypeDefault];
                dispatch_semaphore_signal([JSNetworkingConfigurations sharedInstance].semap);
            }];
        }
    });
    
    return 0;
}

-(NSInteger)uploadFile:(NSURL*)fileUrl
{
    if(fileUrl.absoluteString.length==0){
        NSLog(@"上传的内容不能为空");
        [self failedOnCallingAPI:nil withErrorType:JSNetworkingStatusTypeDefault];
        return 0;
    }
    
    if([self.apiDetail shouldShowHUD]){
        if([self.apiDetail respondsToSelector:@selector(shouldDisableUserInterface)]){
            if([self.apiDetail shouldDisableUserInterface]){
                [XZProgressHUD showWithMaskType];
            }else{
                [XZProgressHUD show];
            }
        }else{
            [XZProgressHUD show];
        }
    }
    __weak typeof(self) weakSelf = self;
    [[JSAPIProxy sharedInstance] callUploadFileWithUrl:fileUrl methodName:self.apiDetail.methodName version:self.apiDetail.APIVersion success:^(JSResponse *response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf successedOnCallingAPI:response];
    } progress:^(NSProgress *progress) {
        
    } fail:^(JSResponse *response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf failedOnCallingAPI:response withErrorType:JSNetworkingStatusTypeDefault];
    }];
    return 0;
}

#pragma mark - public methods
- (void)cancelAllRequests
{
    [[JSAPIProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[JSAPIProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (void)cleanData
{
    [self.cache clean];
    self.networkStatus = JSNetworkingStatusTypeDefault;
}

#pragma mark - private methods
- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    __weak typeof (self)  wSelf = self;
    [self.requestIdList enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([obj integerValue] == requestId){
            [wSelf.requestIdList removeObjectForKey:key];
            *stop = YES;
        }
    }];
}

- (BOOL)hasCacheWithParams:(NSDictionary *)params
{
    NSString *methodName = self.apiDetail.methodName;
    NSData *result = [self.cache fetchCachedDataWithmethodName:methodName requestParams:params];
    
    if (result == nil) {
        return NO;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof (weakSelf) strongSelf = weakSelf;
        JSResponse *response = [[JSResponse alloc] initWithData:result];
        response.requestParams = params;
        [strongSelf successedOnCallingAPI:response];
    });
    return YES;
}

#pragma mark - method for interceptor
- (BOOL)beforePerformSuccessWithResponse:(JSResponse *)response
{
    BOOL result = YES;
    self.networkStatus = JSNetworkingStatusTypeSuccess;
    if ([self.interceptor respondsToSelector:@selector(manager: beforePerformSuccessWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
    return result;
}

- (void)afterPerformSuccessWithResponse:(JSResponse *)response
{
    if ([self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (BOOL)beforePerformFailWithResponse:(JSResponse *)response
{
    BOOL result = YES;
    if ( [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
    return result;
}

- (void)afterPerformFailWithResponse:(JSResponse *)response
{
    if ([self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

//只有返回YES才会继续调用API
- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:params];
    } else {
        return YES;
    }
}

- (void)afterCallingAPIWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingAPIWithParams:)]) {
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}

#pragma mark - api callbacks
- (void)successedOnCallingAPI:(JSResponse *)response
{
    self.isLoading = NO;
    if (response.content[@"data"] == (id)kCFNull) {
        NSMutableDictionary* responseDic = [[response.content yy_modelToJSONObject] mutableCopy];
        responseDic[@"data"] = nil;
        JSResponse * responseN = [[JSResponse alloc]initWithResponseString:responseDic.yy_modelToJSONString requestId:@(response.requestId) request:response.request responseData:responseDic.yy_modelToJSONData status:CTURLResponseStatusSuccess];
        responseN.requestParams = response.requestParams;
        response = responseN;
    }
    self.response = response;
    if([self.apiDetail shouldShowHUD]){
        [XZProgressHUD dismiss];
    }
    [self removeRequestIdWithRequestID:response.requestId];
    //如果外挂的reponseValidator是空，那么默认不对response验证，认为成功 ，否则验证responseValidator代理方法
    if([JSNetworkingConfigurations sharedInstance].delegate == nil || [[JSNetworkingConfigurations sharedInstance].delegate manager:self responseObject:response.content]){
        if([self.apiDetail shouldCache] && !response.isCache){
            if(self.isSpecialCache && [[response.content objectForKey:@"data"] count]>0){
                [self.cache saveCacheWithData:response.responseData methodName:self.apiDetail.methodName requestParams:response.requestParams];
            }else if(!self.isSpecialCache){
                [self.cache saveCacheWithData:response.responseData methodName:self.apiDetail.methodName requestParams:response.requestParams];
            }
        }
        if ([self beforePerformSuccessWithResponse:response]) {
            [self.callBackDelegate callAPIDidSuccess:self];
        }
        [self afterPerformSuccessWithResponse:response];
    }else{
        [self failedOnCallingAPI:response withErrorType:JSNetworkingStatusTypeContentError];
    }
}

- (void)failedOnCallingAPI:(JSResponse *)response withErrorType:(JSNetworkingStatusType)errorType
{
    self.isLoading = NO;
    self.response = response;
    if([self.apiDetail shouldShowHUD] && !response.error){
        [XZProgressHUD dismiss];
    }
    [self removeRequestIdWithRequestID:response.requestId];
    if ([self beforePerformFailWithResponse:response]) {
        if([[JSNetworkingConfigurations sharedInstance].delegate respondsToSelector:@selector(networkError:)]){
            [[JSNetworkingConfigurations sharedInstance].delegate networkError:self];
        }
        [self.callBackDelegate callAPIDidFail:self];
    }
    [self afterPerformFailWithResponse:response];
}

#pragma mark - getter & setter
- (JSCache *)cache
{
    if (_cache == nil) {
        _cache = [JSCache sharedInstance];
    }
    return _cache;
}

- (NSMutableDictionary *)requestIdList
{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableDictionary alloc] init];
    }
    return _requestIdList;
}

- (BOOL)isReachable
{
    BOOL isReachability = [JSNetworkingConfigurations sharedInstance].isReachable;
    if (!isReachability) {
        self.networkStatus = JSNetworkingStatusTypeNoNetwork;
    }
    return isReachability;
}

- (BOOL)isLoading
{
    if (self.requestIdList.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}

@end
