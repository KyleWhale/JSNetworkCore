//
//  JSAPIProxy.m
//  JSNetworking
//
#import <AFNetworking/AFNetworking.h>
#import "JSNetworkingConfigurations.h"
#import "NSURLRequest+JSNetworking.h"
#import "JSAPIProxy.h"
#import "JSRequest.h"

@interface JSAPIProxy ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation JSAPIProxy
#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/javascript",@"text/json",@"text/plain", nil];
        ///过滤掉  为null的键值对
        //        ((AFJSONResponseSerializer*)_sessionManager.responseSerializer).removesKeysWithNullValues = YES;
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
    }
    return _sessionManager;
}

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static JSAPIProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JSAPIProxy alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public methods
-(void)configSSL:(NSString*)sslName
{
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:sslName ofType:@"cer"];
    NSData * certData =[NSData dataWithContentsOfFile:cerPath];
    if(certData){
        NSSet * certSet = [[NSSet alloc] initWithObjects:certData, nil];
#ifdef DEBUG
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
#else
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
#endif
        [securityPolicy setPinnedCertificates:certSet];
        self.sessionManager.securityPolicy = securityPolicy;
    }
    NSLog(@"<<<<<<<<<<<<SSL证书未找到>>>>>>>>>>>>>");
}

- (NSInteger)callGETWithParams:(NSDictionary *)params methodName:(NSString *)methodName version:(NSString *)version success:(JSCallback)success fail:(JSCallback)fail
{
    NSURLRequest *request = [[JSRequest sharedInstance] generateGETRequestWithParams:params methodName:methodName version:version];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return [requestId integerValue];
}

- (NSInteger)callPOSTWithParams:(NSDictionary *)params methodName:(NSString *)methodName version:(NSString *)version success:(JSCallback)success fail:(JSCallback)fail
{
    NSURLRequest *request = [[JSRequest sharedInstance] generatePOSTRequestWithParams:params methodName:methodName version:version];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return [requestId integerValue];
}

- (NSInteger)callUploadWithData:(NSData *)data methodName:(NSString *)methodName version:(NSString *)version success:(JSCallback)success progress:(JSUploadProgress)progress fail:(JSCallback)fail
{
    NSURLRequest *request = [[JSRequest sharedInstance] generateUploadRequestWithData:data methodName:methodName version:version];
    NSInteger requestId = [self callUploadProgressRequest:request success:success progress:progress fail:fail];
    return requestId;
}

- (NSInteger)callUploadFileWithUrl:(NSURL *)fileUrl methodName:(NSString *)methodName version:(NSString *)version success:(JSCallback)success progress:(JSUploadProgress)progress fail:(JSCallback)fail
{
    NSURLRequest *request = [[JSRequest sharedInstance]generateUploadFileRequestWithFileUrl:fileUrl methodName:methodName version:version];
    NSInteger requestId = [self callUploadProgressRequest:request success:success progress:progress fail:fail];
    return requestId;
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSURLSessionDataTask *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSDictionary *)requestIDList
{
    __weak typeof (self)  wSelf = self;
    [requestIDList enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [wSelf cancelRequestWithRequestID:obj];
    }];
}

- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(JSCallback)success fail:(JSCallback)fail
{
    __block NSURLSessionDataTask *dataTask = nil;
    
    dataTask = [self.sessionManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.dispatchTable removeObjectForKey:requestID];
        NSString *responseString = nil;
        NSData *responseData = nil;
        if(responseObject){
            responseData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];;
            responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        }
        
        if (error) {
            JSResponse *response = [[JSResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData error:error];
            fail?fail(response):nil;
        } else {
            // 检查http response是否成立。
            JSResponse *response = [[JSResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData status:CTURLResponseStatusSuccess];
            success?success(response):nil;
        }
    }];
    
    NSNumber *requestId = @([dataTask taskIdentifier]);
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    return requestId;
}

-(NSInteger )callUploadProgressRequest:(NSURLRequest *)request success:(JSCallback)success progress:(JSUploadProgress)progress fail:(JSCallback)fail
{
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.sessionManager
                uploadTaskWithStreamedRequest:request
                progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progress(uploadProgress);
        });
    }
                completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.dispatchTable removeObjectForKey:requestID];
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        if (error) {
            JSResponse *response = [[JSResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData error:error];
            fail?fail(response):nil;
        } else {
            // 检查http response是否成立。
            JSResponse *response = [[JSResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData status:CTURLResponseStatusSuccess];
            success?success(response):nil;
        }
    }];
    [dataTask resume];
    //    [self.sessionManager invalidateSessionCancelingTasks:NO];
    return [dataTask taskIdentifier];
}
@end
