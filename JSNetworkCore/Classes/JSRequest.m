//
//  JSRequest.m
//  JSNetworking
//

#import "JSRequest.h"
#import "JSNetworkingConfigurations.h"
#import "NSURLRequest+JSNetworking.h"
#import "XZTimeTool.h"

@interface JSRequest ()

@end

@implementation JSRequest
#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static JSRequest *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JSRequest alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSURLRequest *)generateGETRequestWithParams:(NSDictionary *)requestParams methodName:(NSString *)methodName version:(NSString*)version
{
    return [self generateRequestWithParams:requestParams methodName:methodName version:version requestWithMethod:@"GET"];
}

- (NSURLRequest *)generatePOSTRequestWithParams:(NSDictionary *)requestParams methodName:(NSString *)methodName version:(NSString*)version
{
    return [self generateRequestWithParams:requestParams methodName:methodName version:version requestWithMethod:@"POST"];
}

- (NSURLRequest *)generateUploadRequestWithData:(NSData*)data methodName:(NSString *)methodName version:(NSString*)version
{
    NSString* url = [[JSNetworkingConfigurations sharedInstance] generatorUrlStr:methodName];
    [self setVersionHeader:version];
    [self setTokenHeader];
    NSMutableURLRequest* request =  [self.httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data
                                    name:@"file1"
                                fileName:@"/C:/Users/Administrator/Desktop/aaa.jpg"
                                mimeType:@"image/jpg"];
    } error:nil];
    
    return request;
}

- (NSURLRequest *)generateUploadFileRequestWithFileUrl:(NSURL*)fileUrl methodName:(NSString *)methodName version:(NSString*)version
{
    NSString* url = [[JSNetworkingConfigurations sharedInstance] generatorUrlStr:methodName];
    [self setVersionHeader:version];
    [self setTokenHeader];
    NSMutableURLRequest* request =  [self.httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:fileUrl]
                                    name:@"file"
                                fileName:@"file.aac"
                                mimeType:@"application/octet-stream"];
    } error:nil];
    
    return request;
}

- (NSURLRequest *)generateRequestWithParams:(NSDictionary *)requestParams methodName:(NSString *)methodName version:(NSString*)version requestWithMethod:(NSString *)method {
    NSString* url = [[JSNetworkingConfigurations sharedInstance] generatorUrlStr:methodName];
    [self setVersionHeader:version];
    [self setTokenHeader];
    requestParams = [NSMutableDictionary dictionaryWithDictionary:requestParams];
    if([JSNetworkingConfigurations sharedInstance].httpHeaders.count>0){
        for (NSString* key in [JSNetworkingConfigurations sharedInstance].httpHeaders) {
            [requestParams setValue:[[JSNetworkingConfigurations sharedInstance].httpHeaders objectForKey:key] forKey:key];
        }
    }
    
    //系统时间串10位
    //测试
    [requestParams setValue:[[XZTimeTool shareTimeTool] getNowTime] forKey:@"installTime"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *tzName = [timeZone name];
    [_httpRequestSerializer setValue:tzName forHTTPHeaderField:@"timezone"];
//    [requestParams setValue:tzName forKey:@"timezone"];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:method URLString:url parameters:requestParams error:NULL];
    request.requestParams = requestParams;
    return request;
}

#pragma mark - private method
//处理特殊header,版本号添加
- (void)setVersionHeader:(NSString *)version {
    
}
//获取token
- (void)setTokenHeader
{
//    [self.httpJsonRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [self.httpRequestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [self.httpJsonRequestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"enctype"];
//    [self.httpJsonRequestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
}

#pragma mark test
- (void)rest {
    self.httpJsonRequestSerializer = nil;
    self.httpRequestSerializer = nil;
}

- (AFHTTPRequestSerializer*)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.timeoutInterval = [JSNetworkingConfigurations sharedInstance].apiNetworkingTimeoutSeconds;
        if([JSNetworkingConfigurations sharedInstance].httpHeaders.count>0){
            for (NSString* key in [JSNetworkingConfigurations sharedInstance].httpHeaders) {
                [_httpRequestSerializer setValue:[[JSNetworkingConfigurations sharedInstance].httpHeaders objectForKey:key] forHTTPHeaderField:key];
            }
        }
        NSString *authToken = [[NSString alloc]initWithFormat:@"Bearer %@",[[JSNetworkingConfigurations sharedInstance].delegate getCurrentUserToken]];
        [_httpJsonRequestSerializer setValue:@"1" forHTTPHeaderField:@"token"];
        
        //系统时间串10位
        [_httpRequestSerializer setValue:[[XZTimeTool shareTimeTool] getNowTime] forHTTPHeaderField:@"installTime"];
        //随机数生成
//        NSString *strRandom = @"";
//        for(int i=0; i<8; i++)
//        {
//            strRandom = [strRandom stringByAppendingFormat:@"%i",(arc4random() % 9)];
//        }
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        NSString *tzName = [timeZone name];
        [_httpRequestSerializer setValue:tzName forHTTPHeaderField:@"timezone"];
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    
    return _httpRequestSerializer;
}

-(AFJSONRequestSerializer *)httpJsonRequestSerializer{
    if (!_httpRequestSerializer) {
        _httpJsonRequestSerializer = [[AFJSONRequestSerializer alloc]init];
        _httpJsonRequestSerializer.timeoutInterval = [JSNetworkingConfigurations sharedInstance].apiNetworkingTimeoutSeconds;
        if([JSNetworkingConfigurations sharedInstance].httpHeaders.count>0){
            for (NSString* key in [JSNetworkingConfigurations sharedInstance].httpHeaders) {
                [_httpJsonRequestSerializer setValue:[[JSNetworkingConfigurations sharedInstance].httpHeaders objectForKey:key] forHTTPHeaderField:key];
            }
        }
        NSString *authToken = [[NSString alloc]initWithFormat:@"Bearer %@",[[JSNetworkingConfigurations sharedInstance].delegate getCurrentUserToken]];
//        [_httpJsonRequestSerializer setValue:authToken forHTTPHeaderField:@"token"];
        
        //系统时间串10位
        [_httpJsonRequestSerializer setValue:[[XZTimeTool shareTimeTool] getNowTime] forHTTPHeaderField:@"installTime"];
        //随机数生成
        NSString *strRandom = @"";
        for(int i=0; i<8; i++)
        {
            strRandom = [strRandom stringByAppendingFormat:@"%i",(arc4random() % 9)];
        }
        [_httpJsonRequestSerializer setValue:strRandom forHTTPHeaderField:@"timezone"];
        _httpJsonRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpJsonRequestSerializer;
}

@end
